//
//  TablesViewController.m
//  ShareTableSeats
//
//  Created by Kevin Rupper on 28/2/15.
//  Copyright (c) 2015 Guerrilla Dev SWAT. All rights reserved.
//

#import "TablesViewController.h"
#import "AppDelegate.h"
#import "WebService.h"
#import "TableCell.h"
#import "DateHelper.h"
#import "DBHelper.h"
#import "Table.h"

#import "TableDetailViewController.h"

static NSString * const cellID = @"TableCell";

@interface TablesViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>
{
    AppDelegate *mAppDelegate;
    Table *mSelectedTable;
}

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation TablesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    mAppDelegate = [UIApplication sharedApplication].delegate;
    
    self.title = @"Mesas";
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refreshControl;
    
    [self updateTables:nil];
}

#pragma mark - Methods

- (void)refresh:(UIRefreshControl *)sender
{
    sender.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    [self updateTables:sender];
}

- (void)updateTables:(UIRefreshControl *)sender
{
    [[WebService sharedInstance] getTablesWithCompletion:^(BOOL ok, NSArray *tables, NSString *errorMessage)
     {
         if (errorMessage.length)
         {
             NSLog(@"#ERROR: %@", errorMessage);
             return;
         }
         
         if(!ok)
             return;
         
         if(sender)
             [sender endRefreshing];
         
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
             
             NSManagedObjectContext *moc = [mAppDelegate newChildMOC];
             
             [DBHelper createTablesWithArray:tables inContext:moc];
             [mAppDelegate saveContext:moc];
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [mAppDelegate saveContext:mAppDelegate.managedObjectContext];
             });
         });
     }];
}

#pragma mark - Actions

//- (IBAction)searchTableButtonTap:(id)sender
//{
//
//    if([[NSUserDefaults standardUserDefaults] boolForKey:@"logged"])
//        [self performSegueWithIdentifier:@"GoToCreateTable" sender:self];
//    else
//    {
//        NSString *message = @"Debes haber iniciado sesion para crear una mesa nueva";
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Alerta"
//                                                                                 message:message
//                                                                          preferredStyle:UIAlertControllerStyleAlert];
//        
//        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
//        [alertController addAction:action];
//        [self presentViewController:alertController animated:YES completion:nil];
//    }
//}


#pragma mark - TableView datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    TableCell *cellAux = (TableCell *)cell;
    
    Table *table = [self.fetchedResultsController objectAtIndexPath:indexPath];

    cellAux.dateLabel.text = [DateHelper stringDateFromDate:table.fromDatetime];
    cellAux.availablePlacesLabel.text = [table.availablePlaces stringValue];
    cellAux.timeLabel.text = [DateHelper stringTimeFromDate:table.fromDatetime];
    cellAux.stationsLabel.text = [NSString stringWithFormat:@"%@ - %@", table.fromStationName, table.toStationName];
    cellAux.priceLabel.text = [NSString stringWithFormat:@"%@€",[table.price stringValue]];
    
    [mAppDelegate setBorderViewWithColor:[UIColor clearColor]
                             borderWidth:1.0
                            cornerRadius:8.0
                                    view:cellAux.placesBackgroundView];
    
    switch (table.availablePlaces.integerValue) {
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
    mSelectedTable = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [self performSegueWithIdentifier:@"GoToTableDetail" sender:self];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"GoToTableDetail"])
    {
        TableDetailViewController *vc = segue.destinationViewController;
        vc.currentTable = mSelectedTable;
    }
}

#pragma mark - FetchedResultsController

- (NSFetchedResultsController *) fetchedResultsController
{
    AppDelegate *ad = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = ad.managedObjectContext;
    if (_fetchedResultsController || !moc)
        return _fetchedResultsController;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Table"];
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
