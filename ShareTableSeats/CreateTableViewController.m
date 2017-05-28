//
//  CreateTableViewController.m
//  ShareTableSeats
//
//  Created by Kevin Rupper on 2/3/15.
//  Copyright (c) 2015 Guerrilla Dev SWAT. All rights reserved.
//

#import "CreateTableViewController.h"
#import "AppDelegate.h"
#import "SelectDateViewController.h"
#import "CustomPresentationTransition.h"
#import "CustomDissmisalTransition.h"
#import "WebService.h"
#import "DateHelper.h"
#import "DBHelper.h"
#import "User.h"
#import "Station.h"

@interface CreateTableViewController ()<UIViewControllerTransitioningDelegate>
{
    AppDelegate *mAppDelegate;
    
    Station *mSelectedOrigin;
    Station *mSelectedDestination;
    NSDate *mSelectedDate;
    NSString *mSelectedTime;
    NSString *mAvailablePlaces;
}

@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) IBOutlet UILabel *timeLabel;
@property (nonatomic, strong) IBOutlet UILabel *originLabel;
@property (nonatomic, strong) IBOutlet UILabel *destinationLabel;
@property (nonatomic, strong) IBOutlet UITextField *numberOfPeopleTextField;
@property (nonatomic, strong) IBOutlet UITextField *priceTextField;

@property (nonatomic, strong) IBOutlet UIButton *dateButton;
@property (nonatomic, strong) IBOutlet UIButton *createButton;
@property (nonatomic, strong) IBOutlet UIButton *stationButton;


- (IBAction)cancelButtonTap:(id)sender;
- (IBAction)stationsButtonTap:(id)sender;
- (IBAction)dateButtonTap:(id)sender;
- (IBAction)createTableButtonTap:(id)sender;

@end

@implementation CreateTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    mAppDelegate = [UIApplication sharedApplication].delegate;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectDate:) name:@"didSelectDate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectStations:) name:@"didSelectStations" object:nil];
    
    [self setAppearance];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didSelectDate" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didSelectStations" object:nil];
}

- (void) setAppearance
{
    [mAppDelegate setBorderViewWithColor:[UIColor clearColor]
                             borderWidth:1.0
                            cornerRadius:8.0
                                    view:self.dateButton];
    
    [mAppDelegate setBorderViewWithColor:[UIColor clearColor]
                             borderWidth:1.0
                            cornerRadius:8.0
                                    view:self.createButton];
    
    [mAppDelegate setBorderViewWithColor:[UIColor clearColor]
                             borderWidth:1.0
                            cornerRadius:8.0
                                    view:self.stationButton];
}

#pragma mark - Notifications

- (void)didSelectDate:(NSNotification *)notification
{
    NSDictionary *dict = notification.object;
    mSelectedDate = dict[@"date"];

    self.dateLabel.text = [DateHelper stringDateFromDate:mSelectedDate];
    self.timeLabel.text = [DateHelper stringTimeFromDate:mSelectedDate];
}

- (void)didSelectStations:(NSNotification *)notification
{
    NSDictionary *dict = notification.object;
    
    if( dict[@"origin"])
    {
        mSelectedOrigin = dict[@"origin"];
        self.originLabel.text = mSelectedOrigin.name;
    }

    if( dict[@"destination"])
    {
        mSelectedDestination = dict[@"destination"];
        self.destinationLabel.text = mSelectedDestination.name;
    }
}

#pragma mark - Actions

- (IBAction)createTableButtonTap:(id)sender
{
    // TODO: finish this
    
    if(!mSelectedOrigin
       || !mSelectedDestination)
        return;
    
    if(!mSelectedDate)
        return;
    
    NSInteger places = [mAvailablePlaces integerValue];
    
    if(places <= 0
       || places > 3 )
        places = 3;
    
    float price = [self.priceTextField.text floatValue];
    
    User *currentUser = [DBHelper currentUserInContext:mAppDelegate.managedObjectContext];
    
    NSDictionary *credentials = @{@"email": currentUser.email, @"password": currentUser.password};
    
    NSMutableDictionary *newTable = [[NSMutableDictionary alloc] init];
    
    newTable[@"_user"] = currentUser.serverID;
    newTable[@"_fromStation"] = mSelectedOrigin.serverID,
    newTable[@"_toStation"] = mSelectedDestination.serverID,
    newTable[@"fromDatetime"] = [DateHelper stringISO8601FromDate:mSelectedDate],
    newTable[@"toDatetime"] = [DateHelper stringISO8601FromDate:mSelectedDate],
    newTable[@"availablePlaces"] =  @(places),
    newTable[@"price"] = @(price);
    
    [[WebService sharedInstance] createTableWithDict:newTable
                                     credentials:credentials
                                      completion:^(BOOL ok, NSDictionary *response, NSString *errorMessage)
    {
        if(errorMessage)
            NSLog(@"#ERROR: %@", errorMessage);
        
        if(!ok)
            return;
        
        [DBHelper createTableWithDict:response inContext:mAppDelegate.managedObjectContext];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (IBAction)dateButtonTap:(id)sender
{
    SelectDateViewController *vc = [[self mainStoryboard] instantiateViewControllerWithIdentifier:@"SelectDateViewController"];
    vc.modalPresentationStyle = UIModalPresentationCustom;
    vc.transitioningDelegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)stationsButtonTap:(id)sender;
{
    [self performSegueWithIdentifier:@"GoToSelectStations" sender:self];
}

- (IBAction)cancelButtonTap:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Methods

- (UIStoryboard *)mainStoryboard
{
    return [UIStoryboard storyboardWithName:@"Main" bundle:nil];
}

#pragma mark - UIViewController transitioning delegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return [[CustomPresentationTransition alloc] init];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [[CustomDissmisalTransition alloc] init];
}

@end
