//
//  MyTableDetailViewController.m
//  ShareTableSeats
//
//  Created by Kevin Rupper on 30/4/15.
//  Copyright (c) 2015 Guerrilla Dev SWAT. All rights reserved.
//

#import "MyTableDetailViewController.h"
#import "AppDelegate.h"
#import "WebService.h"
#import "DateHelper.h"
#import "DBHelper.h"

#import "CustomPresentationTransition.h"
#import "CustomDissmisalTransition.h"

// Coredata
#import "Station.h"
#import "Table.h"
#import "User.h"

// ViewController
#import "SelectStationsViewController.h"
#import "SelectDateViewController.h"

@interface MyTableDetailViewController ()<UIViewControllerTransitioningDelegate>
{
    AppDelegate *mAppDelegate;
    Station *mSelectedOrigin;
    Station *mSelectedDestination;
    NSDate *mSelectedDate;
    NSString *mSelectedTime;
    NSString *mAvailablePlaces;
    UIBarButtonItem *backButtonItem;
}

@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) IBOutlet UILabel *datetimeLabel;
@property (nonatomic, strong) IBOutlet UILabel *originLabel;
@property (nonatomic, strong) IBOutlet UILabel *destinationLabel;
@property (nonatomic, strong) IBOutlet UITextField *numberOfPeopleTextField;
@property (nonatomic, strong) IBOutlet UITextField *priceTextField;

- (IBAction)stationsButtonTap:(id)sender;
- (IBAction)dateButtonTap:(id)sender;
- (IBAction)updateTableButtonTap:(id)sender;

@end

@implementation MyTableDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    mAppDelegate = [UIApplication sharedApplication].delegate;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectDate:) name:@"didSelectDate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectStations:) name:@"didSelectStations" object:nil];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-back.png"]
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(backButtonTap)];
    
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didSelectDate" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didSelectStations" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.dateLabel.text = [DateHelper stringDateFromDate:mSelectedDate];
    self.datetimeLabel.text = [DateHelper stringTimeFromDate:self.currentTable.fromDatetime];
    self.originLabel.text = mSelectedOrigin.name;
    self.destinationLabel.text = mSelectedDestination.name;
    self.priceTextField.text = [NSString stringWithFormat:@"%@€",[_currentTable.price stringValue]];
    self.numberOfPeopleTextField.text = [_currentTable.availablePlaces stringValue];
}

- (void)setCurrentTable:(Table *)currentTable
{
    _currentTable = currentTable;
    
    mAppDelegate = [UIApplication sharedApplication].delegate;
    
    mSelectedDate = _currentTable.fromDatetime;
    
    mSelectedOrigin = [DBHelper getStationWithID:_currentTable.fromStationServerID inContext:mAppDelegate.managedObjectContext];
    mSelectedDestination = [DBHelper getStationWithID:_currentTable.toStationServerID inContext:mAppDelegate.managedObjectContext];
}

#pragma mark - Notifications

- (void)didSelectDate:(NSNotification *)notification
{
    NSDictionary *dict = notification.object;
    mSelectedDate = dict[@"date"];
    
    self.dateLabel.text = [DateHelper stringDateFromDate:mSelectedDate];
    self.datetimeLabel.text = [DateHelper stringTimeFromDate:mSelectedDate];
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

- (void) backButtonTap
{
    [self.navigationController popViewControllerAnimated:YES];
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
    SelectStationsViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SelectStationsViewController"];

    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self presentViewController:nc animated:YES completion:nil];
}

- (IBAction)updateTableButtonTap:(id)sender
{
    User *currenUser = [DBHelper currentUserInContext:mAppDelegate.managedObjectContext];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];;
    
    if(mSelectedOrigin)
        dict[@"_fromStation"] = mSelectedOrigin.serverID;
    
    if(mSelectedDestination)
        dict[@"_toStation"] = mSelectedDestination.serverID;
    
    if(mSelectedDate)
        dict[@"_fromDatetime"] = [DateHelper stringISO8601FromDate:mSelectedDate];
    
    if(mAvailablePlaces)
    {
        NSInteger places = [mAvailablePlaces integerValue];
        
        if(places <= 0 || places > 3 )
            places = [self.currentTable.availablePlaces integerValue];

        
        dict[@"availablePlaces"] = @(places);
    }
    
    // Nothing to update
    if(![dict allKeys].firstObject)
        return;
    
    dict[@"_user"] = currenUser.serverID;
    
    [[WebService sharedInstance] updateTableWithTableID:self.currentTable.serverID
                                                   dict:dict
                                            credentials:@{@"email":currenUser.email, @"password":currenUser.password}
                                             completion:^(BOOL ok, NSDictionary *response, NSString *errorMessage)
    {
        if(!ok)
            return;
        
        if(errorMessage.length > 0)
        {
            NSLog(@"#ERROR: %@", errorMessage);
            return ;
        }
        
        [DBHelper updateTableWithDict:response inContext:mAppDelegate.managedObjectContext];
        [mAppDelegate saveContext:mAppDelegate.managedObjectContext];
    }];
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
