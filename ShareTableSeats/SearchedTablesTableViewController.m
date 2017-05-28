//
//  SearchedTablesTableViewController.m
//  ShareTableSeats
//
//  Created by Kevin Rupper on 28/4/15.
//  Copyright (c) 2015 Guerrilla Dev SWAT. All rights reserved.
//

#import "SearchedTablesTableViewController.h"
#import "AppDelegate.h"
#import "DateHelper.h"
#import "DBHelper.h"
#import "WebService.h"
#import "TableCell.h"
#import "TableDetailViewController.h"
#import "Table.h"

@interface SearchedTablesTableViewController ()
{
    AppDelegate *mAppDelegate;
    NSArray *mTables;
    NSDictionary *mSelectedTableDict;
    
    Table *mSelectTable;
}

@end

@implementation SearchedTablesTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    mAppDelegate = [UIApplication sharedApplication].delegate;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-back.png"]
                                                                             style:UIBarButtonItemStyleDone
                                                                            target:self
                                                                            action:@selector(backButtonTap)];
    
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
    
    [[WebService sharedInstance] getTablesWithQueryParamsWithDict:self.queryParams
                                                       completion:^(BOOL ok, NSArray *tables, NSString *errorMessage)
     {
         if(errorMessage)
             NSLog(@"#ERROR: %@", errorMessage);
         
         if(!ok)
             return;
         
         mTables = [NSArray arrayWithArray:tables];
         
         [self.tableView reloadData];
     }];
}

- (void)viewWillAppear:(BOOL)animated
{
    if(mSelectTable != nil)
        [mAppDelegate.managedObjectContext deleteObject:mSelectTable];
}

- (void) backButtonTap
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - TableView datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //id <NSFetchedResultsSectionInfo> sectionInfo = <#(FetchedSection)#>;
    
    return mTables.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"TableCell" forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    TableCell *cellAux = (TableCell *)cell;
    
    NSDictionary *tableDict = [mTables objectAtIndex:indexPath.row];
    NSDictionary *fromStationDict = tableDict[@"_fromStation"];
    NSDictionary *toStationDict = tableDict[@"_toStation"];
    
    NSDate *date = [DateHelper dateFromStringISO8601:tableDict[@"fromDatetime"]];
    
    cellAux.dateLabel.text = [DateHelper stringDateFromDate:date];
    cellAux.stationsLabel.text = [NSString stringWithFormat:@"%@ - %@", fromStationDict[@"name"], toStationDict[@"name"]];
    NSNumber *places = tableDict[@"availablePlaces"];
    cellAux.timeLabel.text = [DateHelper stringTimeFromDate:date];
    cellAux.priceLabel.text = [NSString stringWithFormat:@"%@€",tableDict[@"price"]];
    
    [mAppDelegate setBorderViewWithColor:[UIColor clearColor]
                             borderWidth:1.0
                            cornerRadius:8.0
                                    view:cellAux.placesBackgroundView];
    
    switch (places.integerValue) {
        case 0:
            cellAux.placesImageView.image = [UIImage imageNamed:@"icon-tables-0.png"];
            break;
        case 1:
            cellAux.placesImageView.image = [UIImage imageNamed:@"icon-tables-1.png"];
            break;
        case 2:
            cellAux.placesImageView.image = [UIImage imageNamed:@"icon-tables-2.png"];
            break;
        case 3:
            cellAux.placesImageView.image = [UIImage imageNamed:@"icon-tables-3.png"];
            break;
        case 4:
            cellAux.placesImageView.image = [UIImage imageNamed:@"icon-tables-4.png"];
            break;
            
        default:
            break;
    }
}

#pragma mark - TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    mSelectedTableDict = [mTables objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"GoToTableDetailFromSearch" sender:self];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    Table *table = [DBHelper createTableWithDict:mSelectedTableDict inContext:mAppDelegate.managedObjectContext];
    
    TableDetailViewController *vc = segue.destinationViewController;
    vc.currentTable = table;
}

@end
