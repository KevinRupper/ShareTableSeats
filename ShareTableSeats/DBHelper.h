//
//  DBHelper.h
//  ShareTableSeats
//
//  Created by Kevin Rupper on 4/4/15.
//  Copyright (c) 2015 Guerrilla Dev SWAT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User, Table, TableSearch, Station;

@interface DBHelper : NSObject

// Current user
+ (User *)currentUserInContext:(NSManagedObjectContext *)moc;

// Basics
+ (id) queryOneObjectWithEntityName:(NSString *)entityName predicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)moc;

// Inserts
+ (User *)createUserWithDict:(NSDictionary *)dict inContext:(NSManagedObjectContext *)moc;
+ (Table *)createTableWithDict:(NSDictionary *)dict inContext:(NSManagedObjectContext *)moc;
+ (TableSearch *)createTableSearch:(NSDictionary *)dict inContext:(NSManagedObjectContext *)moc;
+ (NSArray *)createTablesWithArray:(NSArray *)tables inContext:(NSManagedObjectContext *)moc;
+ (NSArray *)createStationsWithArray:(NSArray *)stationsArray inContext:(NSManagedObjectContext *)moc;

+ (Station *)getStationWithID:(NSString *)stationID inContext:(NSManagedObjectContext *)moc;

+ (Table *)updateTableWithDict:(NSDictionary *)dict inContext:(NSManagedObjectContext *)moc;

@end
