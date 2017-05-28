//
//  SearchTablesViewController.m
//  ShareTableSeats
//
//  Created by Kevin Rupper on 2/3/15.
//  Copyright (c) 2015 Guerrilla Dev SWAT. All rights reserved.
//

#import "SearchTablesViewController.h"
#import "AppDelegate.h"
#import "SelectDateViewController.h"
#import "SearchedTablesTableViewController.h"
#import "WebService.h"
#import "DateHelper.h"
#import "DBHelper.h"
#import "Station.h"

@interface SearchTablesViewController ()
{
    AppDelegate *mAppDelegate;
    
    Station *mSelectedOrigin;
    Station *mSelectedDestination;
    NSDate *mSelectedSinceDate;
    NSDate *mSelectedToDate;
    NSString *mSelectedTime;
    NSString *mAvailablePlaces;
    NSMutableDictionary *mQueryParams;
}

@property (nonatomic, strong) IBOutlet UILabel *sinceDateLabel;
@property (nonatomic, strong) IBOutlet UILabel *toDateLabel;
@property (nonatomic, strong) IBOutlet UILabel *originLabel;
@property (nonatomic, strong) IBOutlet UILabel *destinationLabel;
@property (nonatomic, strong) IBOutlet UITextField *numberOfPeopleTextField;
@property (nonatomic, strong) IBOutlet UISwitch *saveSearchSwitch;

@property (nonatomic, strong) IBOutlet UIButton *dateButton;
@property (nonatomic, strong) IBOutlet UIButton *stationsButton;
@property (nonatomic, strong) IBOutlet UIButton *searchButton;

- (IBAction)cancelButtonTap:(id)sender;
- (IBAction)stationsButtonTap:(id)sender;
- (IBAction)dateButtonTap:(id)sender;
- (IBAction)searchTableButtonTap:(id)sender;
- (IBAction)mySearchsTableButtonTap:(id)sender;

@end

@implementation SearchTablesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    mAppDelegate = [UIApplication sharedApplication].delegate;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectDateRange:) name:@"didSelectDateRange" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectStations:) name:@"didSelectStations" object:nil];
    
    [self setAppearance];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didSelectDateRange" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didSelectStations" object:nil];
}

- (void) setAppearance
{
    [mAppDelegate setBorderViewWithColor:[UIColor clearColor]
                             borderWidth:1.0
                            cornerRadius:8.0
                                    view:self.sinceDateLabel];
    
    [mAppDelegate setBorderViewWithColor:[UIColor clearColor]
                             borderWidth:1.0
                            cornerRadius:8.0
                                    view:self.toDateLabel];
    
    [mAppDelegate setBorderViewWithColor:[UIColor clearColor]
                             borderWidth:1.0
                            cornerRadius:8.0
                                    view:self.originLabel];
    
    [mAppDelegate setBorderViewWithColor:[UIColor clearColor]
                             borderWidth:1.0
                            cornerRadius:8.0
                                    view:self.destinationLabel];
    
    [mAppDelegate setBorderViewWithColor:[UIColor clearColor]
                             borderWidth:1.0
                            cornerRadius:8.0
                                    view:self.sinceDateLabel];
    
    [mAppDelegate setBorderViewWithColor:[UIColor clearColor]
                             borderWidth:1.0
                            cornerRadius:8.0
                                    view:self.dateButton];
    
    [mAppDelegate setBorderViewWithColor:[UIColor clearColor]
                             borderWidth:1.0
                            cornerRadius:8.0
                                    view:self.stationsButton];
    
    [mAppDelegate setBorderViewWithColor:[UIColor clearColor]
                             borderWidth:1.0
                            cornerRadius:8.0
                                    view:self.searchButton];
}

#pragma mark - Notifications

- (void)didSelectDateRange:(NSNotification *)notification
{
    NSDictionary *dict = notification.object;
    mSelectedSinceDate = dict[@"sinceDate"];
    self.sinceDateLabel.text = [DateHelper stringDateFromDate:mSelectedSinceDate];
    
    if(dict[@"toDate"])
    {
        mSelectedToDate = dict[@"toDate"];
        self.toDateLabel.text = [DateHelper stringDateFromDate:mSelectedToDate];
    }
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

- (IBAction)searchTableButtonTap:(id)sender
{
    mQueryParams = [[NSMutableDictionary alloc] init];
    
    if(mSelectedOrigin)
        mQueryParams[@"_fromStation"] = mSelectedOrigin.serverID;
    if(mSelectedDestination)
        mQueryParams[@"_toStation"] = mSelectedDestination.serverID;
    if(mSelectedSinceDate)
        mQueryParams[@"fromDatetime"] = [DateHelper stringDateFromDate:mSelectedSinceDate];
    if(mSelectedToDate)
        mQueryParams[@"toDatetime"] = [DateHelper stringDateFromDate:mSelectedToDate];
    
    if(self.numberOfPeopleTextField.text.length > 0)
        mQueryParams[@"availablePlaces"] = self.numberOfPeopleTextField.text;
    
    if([mQueryParams allKeys].count == 0) // TODO: alert, one parameter at least
        return;
    
    if(self.saveSearchSwitch.isOn)
        [self saveNewSearch];
    
    [self performSegueWithIdentifier:@"GoToQueryTables" sender:self];
}

- (IBAction)dateButtonTap:(id)sender
{
    [self performSegueWithIdentifier:@"GoToSelectDates" sender:self];
}

- (IBAction)stationsButtonTap:(id)sender;
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *vc = [sb instantiateViewControllerWithIdentifier:@"SelectStationsNavigation"];
    vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:vc animated:YES completion:NULL];
}

- (IBAction)mySearchsTableButtonTap:(id)sender
{
    [self performSegueWithIdentifier:@"GoToMySearches" sender:self];
}

- (IBAction)cancelButtonTap:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"GoToQueryTables"])
    {
        SearchedTablesTableViewController *vc = segue.destinationViewController;
        vc.queryParams = mQueryParams;
    }
}

#pragma mark - Methods

- (void) saveNewSearch
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:mQueryParams];
    
    if(mSelectedOrigin)
        dict[@"fromStationName"] = mSelectedOrigin.name;
    
    if(mSelectedDestination)
        dict[@"toStationName"] = mSelectedDestination.name;
    
    if(mSelectedSinceDate)
        dict[@"fromDateTime"] = mSelectedSinceDate;
    
    if(mSelectedToDate)
        dict[@"toDateTime"] = mSelectedToDate;
    
    [DBHelper createTableSearch:dict inContext:mAppDelegate.managedObjectContext];
    
    [mAppDelegate saveContext:mAppDelegate.managedObjectContext];
}

@end
