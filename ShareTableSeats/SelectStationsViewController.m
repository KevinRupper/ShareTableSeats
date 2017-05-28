//
//  SelectStationsViewController.m
//  MesasAve
//
//  Created by Kevin Rupper on 17/4/15.
//  Copyright (c) 2015 Guerrilla Dev SWAT. All rights reserved.
//

#import "SelectStationsViewController.h"
#import "AppDelegate.h"

#import "OriginStationsDatasource.h"
#import "DestinationStationsDatasource.h"

#import "Station.h"

@interface SelectStationsViewController ()<UISearchBarDelegate>
{
    AppDelegate *mAppDelegate;
    OriginStationsDatasource *mOriginStationsDatasource;
    DestinationStationsDatasource *mDestinationDatasource;
    
    NSString *mSearchString;
    UITapGestureRecognizer *mOriginSearchEndGesture;
    UITapGestureRecognizer *mDestinationSearchEndGesture;
    
    Station *mOrigin;
    Station *mDestination;
}

@property (nonatomic, strong) IBOutlet UITableView *originTableView;
@property (nonatomic, strong) IBOutlet UITableView *destinationTableView;
@property (nonatomic, strong) IBOutlet UISearchBar *originSearchBar;
@property (nonatomic, strong) IBOutlet UISearchBar *destinationSearchBar;


- (IBAction)cancelButtonTap:(id)sender;
- (IBAction)okButtonTap:(id)sender;

@end

@implementation SelectStationsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    mAppDelegate = [UIApplication sharedApplication].delegate;
    
    // TableView datasources
    mOriginStationsDatasource = [[OriginStationsDatasource alloc] init];
    mOriginStationsDatasource.originTableView = self.originTableView;
    self.originTableView.dataSource = mOriginStationsDatasource;
    self.originTableView.delegate = mOriginStationsDatasource;
    
    mDestinationDatasource = [[DestinationStationsDatasource alloc] init];
    mDestinationDatasource.destinationTableView = self.destinationTableView;
    self.destinationTableView.dataSource = mDestinationDatasource;
    self.destinationTableView.delegate = mDestinationDatasource;
    
    // Search bar gestures
    mOriginSearchEndGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(originSearchEndTap)];
    mOriginSearchEndGesture.cancelsTouchesInView = NO;
    mDestinationSearchEndGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(destinationSearchEndTap)];
    mDestinationSearchEndGesture.cancelsTouchesInView = NO;
    mSearchString = nil;
    
    // Search bar delegates
    self.originSearchBar.delegate = self;
    self.destinationSearchBar.delegate = self;
    
    // Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSelectOriginStation:)
                                                 name:@"didSelectOriginStation"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSelectDestinationStation:)
                                                 name:@"didSelectDestinationStation"
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didSelectOriginStation" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didSelectDestinationStation" object:nil];
}

#pragma mark - Actions

- (IBAction)cancelButtonTap:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)okButtonTap:(id)sender
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    if(mOrigin)
        dict[@"origin"] = mOrigin;
    if(mDestination)
        dict[@"destination"] = mDestination;
    
    // Notify to CreateTable controller the user selected stations
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didSelectStations"
                                                        object:dict];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Notifications

- (void)didSelectOriginStation:(NSNotification *)notification
{
    mOrigin = notification.object;
}

- (void)didSelectDestinationStation:(NSNotification *)notification
{
    mDestination = notification.object;
}

#pragma mark - SearchBar

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    if(searchBar == self.originSearchBar)
        [self.originTableView addGestureRecognizer:mOriginSearchEndGesture];
    else
        [self.destinationTableView addGestureRecognizer:mDestinationSearchEndGesture];
}

- (void) searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    if(searchBar == self.originSearchBar)
        [self.originTableView removeGestureRecognizer:mOriginSearchEndGesture];
    else
        [self.destinationTableView removeGestureRecognizer:mDestinationSearchEndGesture];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if(searchBar == self.originSearchBar)
        [self.originSearchBar resignFirstResponder];
    else
        [self.destinationSearchBar resignFirstResponder];
}

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText length] == 0)
        mSearchString = nil;
    else
        mSearchString = searchText;
    
    if(searchBar == self.originSearchBar)
    {
        mOriginStationsDatasource.fetchedResultsController = nil;
        mOriginStationsDatasource.searchString = mSearchString;
        [self.originTableView reloadData];
    }
    else
    {
        mDestinationDatasource.fetchedResultsController = nil;
        mDestinationDatasource.searchString = mSearchString;
        [self.destinationTableView reloadData];
    }
}

- (void) originSearchEndTap
{
    [self.originSearchBar resignFirstResponder];
}

- (void) destinationSearchEndTap
{
    [self.destinationSearchBar resignFirstResponder];
}

@end
