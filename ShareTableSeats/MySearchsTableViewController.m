//
//  MySearchsTableViewController.m
//  ShareTableSeats
//
//  Created by Kevin Rupper on 29/4/15.
//  Copyright (c) 2015 Guerrilla Dev SWAT. All rights reserved.
//

#import "MySearchsTableViewController.h"
#import "AppDelegate.h"
#import "DateHelper.h"
#import "TableCell.h"
#import "TableSearch.h"
#import "SearchedTablesTableViewController.h"

@interface MySearchsTableViewController () <NSFetchedResultsControllerDelegate>
{
    AppDelegate *mAppDelegate;
    TableSearch *mSelectedSearch;
}

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

- (IBAction)cancelButtonTap:(id)sender;

@end

@implementation MySearchsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    mAppDelegate = [UIApplication sharedApplication].delegate;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-back.png"]
                                                                             style:UIBarButtonItemStyleDone
                                                                            target:self
                                                                            action:@selector(backButtonTap)];
    
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
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
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"TableCell" forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    TableCell *cellAux = (TableCell *)cell;
    
    TableSearch *tableSearch = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cellAux.dateLabel.text = [DateHelper stringDateFromDate:tableSearch.fromDateTime];
    cellAux.toDate.text = [DateHelper stringDateFromDate:tableSearch.toDateTime];
    cellAux.availablePlacesLabel.text = [tableSearch.availablePlaces stringValue];
    cellAux.timeLabel.text = [DateHelper stringTimeFromDate:tableSearch.fromDateTime];
    cellAux.stationsLabel.text = [NSString stringWithFormat:@"%@ - %@", tableSearch.fromStationName, tableSearch.toStationName];
}

#pragma mark - TableView delegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        TableSearch *tableSearch = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        [mAppDelegate.managedObjectContext deleteObject:tableSearch];
        [mAppDelegate saveContext:mAppDelegate.managedObjectContext];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    mSelectedSearch = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"GoToMySearchedTables" sender:self];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSMutableDictionary *queryParams = [[NSMutableDictionary alloc] init];
    
    if(mSelectedSearch.fromStationServerID)
        queryParams[@"_fromStation"] = mSelectedSearch.fromStationServerID;
    if(mSelectedSearch.toStationServerID)
        queryParams[@"_toStation"] = mSelectedSearch.toStationServerID;
    if(mSelectedSearch.fromDateTime)
        queryParams[@"_fromDatetime"] = [DateHelper stringISO8601FromDate:mSelectedSearch.fromDateTime];
    if(mSelectedSearch.toDateTime)
        queryParams[@"_toDatetime"] = [DateHelper stringISO8601FromDate:mSelectedSearch.toDateTime];
    
    SearchedTablesTableViewController *vc = segue.destinationViewController;
    vc.queryParams = queryParams;
}

#pragma mark - Actions

- (IBAction)cancelButtonTap:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - FetchedResultsController

- (NSFetchedResultsController *) fetchedResultsController
{
    AppDelegate *ad = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = ad.managedObjectContext;
    if (_fetchedResultsController || !moc)
        return _fetchedResultsController;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"TableSearch"];
    fetchRequest.fetchBatchSize = 20;
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"fromStationName" ascending:NO];
    
    fetchRequest.sortDescriptors = @[sortDescriptor];
    
    fetchRequest.predicate = nil;
    
    NSString *cacheName = NSStringFromClass([self class]);
    [NSFetchedResultsController deleteCacheWithName:cacheName];
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:moc sectionNameKeyPath:nil cacheName:cacheName];
    
    NSError *error = nil;
    if ([aFetchedResultsController performFetch:&error])
    {
        aFetchedResultsController.delegate = self;
        _fetchedResultsController = aFetchedResultsController;
    }
    
    return _fetchedResultsController;
}

#pragma mark - FetchedResultsController delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

@end
