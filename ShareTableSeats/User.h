//
//  User.h
//  ShareTableSeats
//
//  Created by Kevin Rupper on 17/4/15.
//  Copyright (c) 2015 Guerrilla Dev SWAT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Table;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * serverID;
@property (nonatomic, retain) NSSet *tables;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addTablesObject:(Table *)value;
- (void)removeTablesObject:(Table *)value;
- (void)addTables:(NSSet *)values;
- (void)removeTables:(NSSet *)values;

@end
