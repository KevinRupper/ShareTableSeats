//
//  Table.h
//  ShareTableSeats
//
//  Created by Kevin Rupper on 8/6/15.
//  Copyright (c) 2015 Guerrilla Dev SWAT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Table : NSManagedObject

@property (nonatomic, retain) NSNumber * availablePlaces;
@property (nonatomic, retain) NSDate * fromDatetime;
@property (nonatomic, retain) NSString * fromStationName;
@property (nonatomic, retain) NSString * fromStationServerID;
@property (nonatomic, retain) NSString * ownerEmail;
@property (nonatomic, retain) NSString * ownerName;
@property (nonatomic, retain) NSString * ownerPhone;
@property (nonatomic, retain) NSString * serverID;
@property (nonatomic, retain) NSDate * toDatetime;
@property (nonatomic, retain) NSString * toStationName;
@property (nonatomic, retain) NSString * toStationServerID;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) User *user;

@end
