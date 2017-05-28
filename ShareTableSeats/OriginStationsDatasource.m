//
//  OriginStationsDatasource.m
//  MesasAve
//
//  Created by Kevin Rupper on 17/4/15.
//  Copyright (c) 2015 Guerrilla Dev SWAT. All rights reserved.
//

#import "OriginStationsDatasource.h"
#import "Station.h"

@interface OriginStationsDatasource()
{
    AppDelegate *mAppDelegate;
    Station *mSelectedStation;
}

@end

@implementation OriginStationsDatasource

- (id) init
{
    self = [super init];
    if (self)
    {
        mAppDelegate = [UIApplication sharedApplication].delegate;
    }
    return self;
}

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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OriginCell" forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Station *station = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = station.name;
    
    if(mSelectedStation != nil)
    {
        if(mSelectedStation == station)
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else
            cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

#pragma mark - TableView delegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Origen";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    Station *station = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    if(mSelectedStation != nil)
    {
        if(mSelectedStation != station)
        {
            NSIndexPath *ip = [self.fetchedResultsController indexPathForObject:mSelectedStation];
            UITableViewCell *cellAux = [tableView cellForRowAtIndexPath:ip];
            cellAux.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    mSelectedStation = station;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didSelectOriginStation" object:mSelectedStation];
}

#pragma mark - FetchedResultsController

- (NSFetchedResultsController *) fetchedResultsController
{
    AppDelegate *ad = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = ad.managedObjectContext;
    if (_fetchedResultsController || !moc)
        return _fetchedResultsController;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Station"];
    fetchRequest.fetchBatchSize = 20;
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    
    fetchRequest.sortDescriptors = @[sortDescriptor];
    
    if(self.searchString.length > 0)
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[c] %@", self.searchString];
    
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
    [self.originTableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.originTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.originTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.originTableView;
    
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
    [self.originTableView endUpdates];
}

@end
