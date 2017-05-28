//
//  Station.h
//  ShareTableSeats
//
//  Created by Kevin Rupper on 17/4/15.
//  Copyright (c) 2015 Guerrilla Dev SWAT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Station : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * serverID;

@end
