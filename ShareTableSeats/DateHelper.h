//
//  DateHelper.h
//  ShareTableSeats
//
//  Created by Kevin Rupper on 4/4/15.
//  Copyright (c) 2015 Guerrilla Dev SWAT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateHelper : NSObject

+ (NSDate *) dateFromStringISO8601:(NSString *)dateString;
+ (NSString *) stringISO8601FromDate:(NSDate *)date;
+ (NSString *) stringDateFromDate:(NSDate *)date;
+ (NSString *) stringTimeFromDate:(NSDate *)date;


@end
