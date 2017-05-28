//
//  AppDelegate.m
//  ShareTableSeats
//
//  Created by Kevin Rupper on 28/2/15.
//  Copyright (c) 2015 Guerrilla Dev SWAT. All rights reserved.
//

#import "AppDelegate.h"
#import "WebService.h"
#import "DBHelper.h"

@interface AppDelegate ()<WebServiceDelegate>

@end

@implementation AppDelegate

@synthesize managedObjectContext       = _managedObjectContext;
@synthesize managedObjectModel         = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self getStations];
    
    [self setAppAppearence];
    
    return YES;
}

- (void) setAppAppearence
{
    UIColor *tabBarTitleColor = [UIColor colorWithRed:117.0/255.0 green:0.0/255.0 blue:111.0/255.0 alpha:1.0];
    UIColor *tabBarTintColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0];
    UIColor *navigationBarTintColor = [UIColor colorWithRed:65.0/255.0 green:116.0/255.0 blue:162.0/255.0 alpha:1.0];
    UIColor *navigationTitleColor = [UIColor colorWithRed:113.0/255.0 green:156.0/255.0 blue:196.0/255.0 alpha:1.0];
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Bold"
                                                                                            size:10.0f],NSForegroundColorAttributeName:tabBarTitleColor}
                                             forState:UIControlStateSelected];
    
    [[UITabBar appearance] setBarTintColor:tabBarTintColor];
    
    [[UINavigationBar appearance] setBarTintColor:navigationBarTintColor];
    
    [[UINavigationBar appearance] setTranslucent:NO];
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:navigationTitleColor}];
}

- (void) setBorderViewWithColor:(UIColor *)color borderWidth:(CGFloat)border cornerRadius:(CGFloat)radius view:(UIView *)view;
{
    view.layer.borderWidth = border;
    view.layer.borderColor = [color CGColor];
    view.layer.cornerRadius = radius;
    view.clipsToBounds = YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {}

- (void)applicationDidEnterBackground:(UIApplication *)application {}

- (void)applicationWillEnterForeground:(UIApplication *)application {}

- (void)applicationDidBecomeActive:(UIApplication *)application {}

- (void)applicationWillTerminate:(UIApplication *)application {}

#pragma mark - Core Data stack

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"AveDB.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {

        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Save context

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (BOOL) saveContext:(NSManagedObjectContext *)moc
{
    NSError *error = nil;
    return [self saveContext:moc error:&error];
}

- (BOOL) saveContext:(NSManagedObjectContext *)moc error:(NSError **)error
{
    if(!moc)
        return NO;
    
    BOOL success = YES;
    
    @try
    {
        if ([moc hasChanges])
        {
            if (![moc save:error])
            {
                [moc rollback];
                success = NO;
                if (error)
                {
                    NSLog(@"#ERROR: %@", *error);
                }
            }
            else
            {
                if (moc.parentContext == nil)
                    NSLog(@"Did Save Context");
                else
                    NSLog(@"Did Save Child Context");
            }
        }
    }
    @catch (NSException *exception)
    {
        NSString *errorString = [NSString stringWithFormat:@"Exception While Saving Context:\n %@", exception.description];
        NSLog(@"#ERROR: %@", errorString);
        [moc rollback];
        success = NO;
    }
    
    return success;
}

#pragma mark - New moc with parent

- (NSManagedObjectContext *) newChildMOC;
{
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    moc.parentContext = self.managedObjectContext;
    return moc;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


#pragma mark - WebService

//- (WebService *)webService
//{
//    if(_webService != nil)
//        return _webService;
//    
//    _webService = [[WebService alloc] init];
//    _webService.delegate = self;
//    
//    return _webService;
//}

#pragma mark - WebService delegate

- (void)webService:(WebService *)webService didChangeReachableStatus:(WebServiceReachableStatus)status
{
    // TODO: tell user internet status
}

#pragma mark - WebServices calls

- (void) getStations
{
    [[WebService sharedInstance] getStationsWithCompletion:^(BOOL ok, NSArray *stations, NSString *errorMessage) {
        
        if(errorMessage != nil)
        {
            NSLog(@"#ERROR: %@", errorMessage);
            return;
        }
        
        if(!ok)
            return;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            
            NSManagedObjectContext *moc = [self newChildMOC];
            
            [DBHelper createStationsWithArray:stations inContext:moc];
            [self saveContext:moc];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self saveContext:self.managedObjectContext];
            });
        });

    }];
}

@end
