//
//  AppDelegate.h
//  ShareTableSeats
//
//  Created by Kevin Rupper on 28/2/15.
//  Copyright (c) 2015 Guerrilla Dev SWAT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

// Coredata stack
@property (readonly, strong, nonatomic) NSManagedObjectContext       *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel         *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (BOOL)saveContext:(NSManagedObjectContext *)moc;
- (NSManagedObjectContext *)newChildMOC;
- (NSURL *)applicationDocumentsDirectory;

- (void) setBorderViewWithColor:(UIColor *)color
                    borderWidth:(CGFloat)border
                   cornerRadius:(CGFloat)radius
                           view:(UIView *)view;

@end

