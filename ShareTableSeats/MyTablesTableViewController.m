//
//  MyTablesTableViewController.m
//  ShareTableSeats
//
//  Created by Kevin Rupper on 28/4/15.
//  Copyright (c) 2015 Guerrilla Dev SWAT. All rights reserved.
//

#import "MyTablesTableViewController.h"
#import "AppDelegate.h"
#import "ProfileCustomView.h"
#import "WebService.h"
#import "DBHelper.h"
#import "DateHelper.h"
#import "TableCell.h"
#import "Table.h"
#import "User.h"

#import "MyTableDetailViewController.h"
#import "LoginViewController.h"
#import "SignUpViewController.h"

@interface MyTablesTableViewController () <NSFetchedResultsControllerDelegate, ProfileCustomViewDelegate>
{
    AppDelegate *mAppDelegate;
    Table *mSelectedTable;
    ProfileCustomView *mProfileCustomView;
}

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation MyTablesTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    mAppDelegate = [UIApplication sharedApplication].delegate;
    
    self.navigationController.hidesBarsOnSwipe = YES;
    self.title = @"Mis mesas";
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refreshControl;
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"logged"])
        [self updateUserTables:nil];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"logged"])
    {
        [self.navigationController.view addSubview:[self customView]];
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    else
    {
        if(mProfileCustomView)
            [mProfileCustomView removeFromSuperview];
        
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

- (UIView *)customView
{
    if(mProfileCustomView)
        return mProfileCustomView;
    
    NSNumber *height = @(ABS(self.view.frame.size.height) + self.navigationController.navigationBar.frame.size.height
    + [UIApplication sharedApplication].statusBarFrame.size.height);
    CGRect frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, height.floatValue);
    
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = frame;
    
    mProfileCustomView = [[ProfileCustomView alloc] init];
    mProfileCustomView.delegate = self;
    [mProfileCustomView addSubview:visualEffectView];
    [mProfileCustomView sendSubviewToBack:visualEffectView];
    mProfileCustomView.alpha = 1.0;
    mProfileCustomView.frame = frame;

    [mAppDelegate setBorderViewWithColor:[UIColor clearColor]
                             borderWidth:1.0
                            cornerRadius:8.0
                                    view:mProfileCustomView.loginButton];
    
    [mAppDelegate setBorderViewWithColor:[UIColor clearColor]
                             borderWidth:1.0
                            cornerRadius:8.0
                                    view:mProfileCustomView.signUpButton];
    
    return mProfileCustomView;
}

#pragma mark - Methods

- (void)refresh:(UIRefreshControl *)sender
{
    sender.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    [self updateUserTables:sender];
}

- (void) updateUserTables:(UIRefreshControl *)sender
{
    User *currentUser = [DBHelper currentUserInContext:mAppDelegate.managedObjectContext];
    
    [[WebService sharedInstance] getCurrentUserTablesWithUserID:currentUser.serverID
                                                     completion:^(BOOL ok, NSArray *tables, NSString *errorMessage)
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

#pragma mark - ProfileCustomView delegate

- (void)didLoginButtonTap
{
    LoginViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginViewController"];
    
    [self presentViewController:vc];
}

- (void)didSignUpButtonTap
{
    SignUpViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SignUpViewController"];
    
    [self presentViewController:vc];
}

- (void)presentViewController:(UIViewController *)vc
{
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [mAppDelegate.window.rootViewController presentViewController:nc animated:YES completion:nil];
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
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"TableCell" forIndexPath:indexPath];
    
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        User *currentUser = [DBHelper currentUserInContext:mAppDelegate.managedObjectContext];
        
        if(currentUser == nil)
            return;
        
        NSDictionary *credentials = @{@"email": currentUser.email, @"password": currentUser.password};
        
        Table *table = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        [[WebService sharedInstance] deleteTableWithID:table.serverID
                                           credentials:credentials
                                            completion:^(BOOL ok, NSString *errorMessage)
        {
            if(errorMessage.length) // TODO: warn user
            {
                NSLog(@"#ERROR: %@", errorMessage);
                return;
            }

            if(!ok)
                return;

            [mAppDelegate.managedObjectContext deleteObject:table];
            [mAppDelegate saveContext:mAppDelegate.managedObjectContext];
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    mSelectedTable = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [self performSegueWithIdentifier:@"GoToMyTableDetail" sender:self];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"GoToMyTableDetail"])
    {
        MyTableDetailViewController *vc = segue.destinationViewController;
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
    
    User *currentUser = [DBHelper currentUserInContext:mAppDelegate.managedObjectContext];
    
    if(currentUser != nil)
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"user == %@", currentUser];
    else
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"user != nil"];
    
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
