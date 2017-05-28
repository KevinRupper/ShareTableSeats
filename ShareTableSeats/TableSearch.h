//
//  TableSearch.h
//  ShareTableSeats
//
//  Created by Kevin Rupper on 29/4/15.
//  Copyright (c) 2015 Guerrilla Dev SWAT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TableSearch : NSManagedObject

@property (nonatomic, retain) NSNumber * availablePlaces;
@property (nonatomic, retain) NSString * toStationName;
@property (nonatomic, retain) NSString * fromStationServerID;
@property (nonatomic, retain) NSString * fromStationName;
@property (nonatomic, retain) NSDate * fromDateTime;
@property (nonatomic, retain) NSString * toStationServerID;
@property (nonatomic, retain) NSDate * toDateTime;

@end
