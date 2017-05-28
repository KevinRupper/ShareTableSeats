//
//  DBHelper.m
//  ShareTableSeats
//
//  Created by Kevin Rupper on 4/4/15.
//  Copyright (c) 2015 Guerrilla Dev SWAT. All rights reserved.
//

#import "DBHelper.h"
#import "DateHelper.h"

// Entities
#import "User.h"
#import "Station.h"
#import "Table.h"
#import "TableSearch.h"

@implementation DBHelper

#pragma mark - Basics

+ (id) queryOneObjectWithEntityName:(NSString *)entityName predicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)moc
{
    return [self queryOneObjectWithEntityName:entityName predicate:predicate sortDescriptors:nil inContext:moc];
}

+ (id) queryOneObjectWithEntityName:(NSString *)entityName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors inContext:(NSManagedObjectContext *)moc
{
    id object = nil;
    if (entityName && moc)
    {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
        if (predicate)
            request.predicate = predicate;
        if (sortDescriptors)
            request.sortDescriptors = sortDescriptors;
        
        NSError *error = nil;        
        request.fetchLimit = 1;
        
        NSArray *result = [moc executeFetchRequest:request error:&error];
        if (error)
            NSLog(@"queryOneObjectWithEntityName ERROR: %@", [error description]);
        else if (result.count > 0)
            object = result[0];
    }
    
    return object;
}

#pragma mark - Current user

+ (User *)currentUserInContext:(NSManagedObjectContext *)moc
{
    return [self queryOneObjectWithEntityName:@"User" predicate:nil inContext:moc];
}

#pragma mark - Stationss

+ (NSArray *)createStationsWithArray:(NSArray *)stationsArray inContext:(NSManagedObjectContext *)moc
{
    NSMutableArray *stations = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dict in stationsArray)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"serverID == %@", dict[@"_id"]];
        Station *newStation = [self queryOneObjectWithEntityName:@"Station" predicate:predicate inContext:moc];
        
        if(newStation == nil)
            newStation =  [NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:moc];
        
        newStation.serverID = dict[@"_id"];
        newStation.name = dict[@"name"];
        
        [stations addObject:newStation];
    }
    
    return stations;
}

+ (Station *)getStationWithID:(NSString *)stationID inContext:(NSManagedObjectContext *)moc
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"serverID == %@", stationID];
    
    Station *station = [self queryOneObjectWithEntityName:@"Station" predicate:predicate inContext:moc];
    
    return station;
}

#pragma mark - User

+ (User *)createUserWithDict:(NSDictionary *)dict inContext:(NSManagedObjectContext *)moc
{
    User *user = [self currentUserInContext:moc];
    
    if(user == nil)
        user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:moc];
    
    user.serverID = dict[@"_id"];
    user.email = dict[@"email"];
    user.password = dict[@"password"];
    
    // Optional keys
    if(dict[@"name"])
        user.name = dict[@"name"];
    if(dict[@"phone"])
        user.phone = dict[@"phone"];
    
    return user;
}

#pragma mark - Tables

+ (Table *)createTableWithDict:(NSDictionary *)dict inContext:(NSManagedObjectContext *)moc
{
    User *currentUser = [self currentUserInContext:moc];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"serverID == %@", dict[@"_fromStation"]];
    Station *origin = [self queryOneObjectWithEntityName:@"Station" predicate:predicate inContext:moc];
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"serverID == %@", dict[@"_toStation"]];
    Station *destination = [self queryOneObjectWithEntityName:@"Station" predicate:predicate2 inContext:moc];
    
    NSPredicate *predicate3 = [NSPredicate predicateWithFormat:@"serverID == %@", dict[@"_id"]];
    Table *newTable = [self queryOneObjectWithEntityName:@"Table" predicate:predicate3 inContext:moc];
    
    if(newTable == nil)
        newTable = [NSEntityDescription insertNewObjectForEntityForName:@"Table" inManagedObjectContext:moc];
    
    newTable.serverID = dict[@"_id"];
    newTable.user = currentUser;
    newTable.fromDatetime = [DateHelper dateFromStringISO8601:dict[@"fromDatetime"]];
    newTable.toDatetime = [DateHelper dateFromStringISO8601:dict[@"toDatetime"]];
    newTable.availablePlaces = @([dict[@"availablePlaces"] integerValue]);
    newTable.ownerEmail = currentUser.email;
    newTable.price = dict[@"price"];
    
    if(currentUser.name)
        newTable.ownerName = currentUser.name;
    
    if(currentUser.phone)
        newTable.ownerPhone = currentUser.phone;
    
    if(origin)
    {
        newTable.fromStationServerID = origin.serverID;
        newTable.fromStationName = origin.name;
    }
    
    if(destination)
    {
        newTable.toStationServerID = destination.serverID;
        newTable.toStationName = destination.name;
    }
    
    return newTable;
}

+ (NSArray *)createTablesWithArray:(NSArray *)tables inContext:(NSManagedObjectContext *)moc
{
    NSMutableArray *tablesArray = [[NSMutableArray alloc] init];
    
    User *currentUser = [self currentUserInContext:moc];
    
    for (NSDictionary *dict in tables)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"serverID == %@", dict[@"_id"]];
        Table *newTable = [self queryOneObjectWithEntityName:@"Table" predicate:predicate inContext:moc];
        
        if(newTable == nil)
            newTable = [NSEntityDescription insertNewObjectForEntityForName:@"Table" inManagedObjectContext:moc];
        
        newTable.serverID = dict[@"_id"];
        newTable.availablePlaces = @([dict[@"availablePlaces"] integerValue]);
        newTable.fromDatetime = [DateHelper dateFromStringISO8601:dict[@"fromDatetime"]];
        newTable.toDatetime = [DateHelper dateFromStringISO8601:dict[@"toDatetime"]];
        newTable.price = dict[@"price"];
        
        NSDictionary *userDict = dict[@"_user"];
            
        if(![userDict isKindOfClass:[NSNull class]])
        {
            // Table belongs to current user
            if([currentUser.serverID isEqualToString:userDict[@"_id"]])
                newTable.user = currentUser;
            
            newTable.ownerEmail = userDict[@"email"];
            
            if(userDict[@"name"])
                newTable.ownerName = userDict[@"name"];
            
            if(userDict[@"phone"])
                newTable.ownerPhone = userDict[@"phone"];
        }
        
        NSDictionary *fromStationDict = dict[@"_fromStation"];
        NSDictionary *toStationDict = dict[@"_toStation"];
        
        newTable.fromStationServerID = fromStationDict[@"_id"];
        newTable.fromStationName = fromStationDict[@"name"];
        newTable.toStationServerID = toStationDict[@"_id"];
        newTable.toStationName = toStationDict[@"name"];
        
        [tablesArray addObject:newTable];
    }
    
    return tablesArray;
}

+ (TableSearch *)createTableSearch:(NSDictionary *)dict inContext:(NSManagedObjectContext *)moc
{
    TableSearch *newTableSearch = [NSEntityDescription insertNewObjectForEntityForName:@"TableSearch" inManagedObjectContext:moc];
    
    if(dict[@"availablePlaces"])
        newTableSearch.availablePlaces = dict[@"availablePlaces"];
    
    if(dict[@"fromDateTime"])
        newTableSearch.fromDateTime = dict[@"fromDateTime"];
    
    if(dict[@"toDateTime"])
        newTableSearch.toDateTime = dict[@"toDateTime"];
    
    if(dict[@"_fromStation"])
    {
        newTableSearch.fromStationServerID = dict[@"_fromStation"];
        newTableSearch.fromStationName = dict[@"fromStationName"];
    }
    
    if(dict[@"_toStation"])
    {
        newTableSearch.toStationServerID = dict[@"_toStation"];
        newTableSearch.toStationName = dict[@"toStationName"];
    }
    
    return newTableSearch;
}

+ (Table *)updateTableWithDict:(NSDictionary *)dict inContext:(NSManagedObjectContext *)moc
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"serverID == %@", dict[@"_id"]];
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"serverID == %@", dict[@"_fromStation"]];
    NSPredicate *predicate3 = [NSPredicate predicateWithFormat:@"serverID == %@", dict[@"_toStation"]];
    
    Table *table = [self queryOneObjectWithEntityName:@"Table" predicate:predicate inContext:moc];
    Station *origin = [self queryOneObjectWithEntityName:@"Station" predicate:predicate2 inContext:moc];
    Station *destination = [self queryOneObjectWithEntityName:@"Station" predicate:predicate3 inContext:moc];
    
    table.fromDatetime = [DateHelper dateFromStringISO8601:dict[@"fromDatetime"]];
    table.toDatetime = [DateHelper dateFromStringISO8601:dict[@"toDatetime"]];
    table.availablePlaces = @([dict[@"availablePlaces"] integerValue]);
    table.fromStationServerID = origin.serverID;
    table.fromStationName = origin.name;
    table.toStationServerID = destination.serverID;
    table.toStationName = destination.name;
    
    return table;
}

@end
