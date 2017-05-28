//
//  DateHelper.m
//  ShareTableSeats
//
//  Created by Kevin Rupper on 4/4/15.
//  Copyright (c) 2015 Guerrilla Dev SWAT. All rights reserved.
//

#import "DateHelper.h"

@implementation DateHelper

static NSDateFormatter *mDisplayShortDateFormatter;
static NSDateFormatter *mDisplayShortTimeFormatter;


+ (NSDate *) dateFromStringISO8601:(NSString *)dateString
{
    // @"2013-03-29T15:27:00Z"
    // @"2015-05-26T07:56:00.123Z";
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //[formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"];
    return [formatter dateFromString:dateString];
}

+ (NSString *) stringISO8601FromDate:(NSDate *)date
{
    // @"2013-03-29T15:27:00Z"
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    return [formatter stringFromDate:date];
}

+ (NSString *) stringTimeFromDate:(NSDate *)date
{
    return [[self displayShortTimeFormatter] stringFromDate:date];
}

+ (NSString *) stringDateFromDate:(NSDate *)date
{
    return [[self displayShortDateFormatter] stringFromDate:date];
}

+ (NSDateFormatter *) displayShortTimeFormatter
{
    if (!mDisplayShortTimeFormatter)
    {
        mDisplayShortTimeFormatter = [[NSDateFormatter alloc] init];
        mDisplayShortTimeFormatter.locale = [NSLocale currentLocale];
        mDisplayShortTimeFormatter.timeZone = [NSTimeZone defaultTimeZone];
        mDisplayShortTimeFormatter.timeStyle = NSDateFormatterShortStyle;
        mDisplayShortTimeFormatter.dateStyle = NSDateFormatterNoStyle;
        [mDisplayShortTimeFormatter setLenient:YES];
    }
    
    return mDisplayShortTimeFormatter;
}

+ (NSDateFormatter *) displayShortDateFormatter
{
    if (!mDisplayShortDateFormatter)
    {
        mDisplayShortDateFormatter = [[NSDateFormatter alloc] init];
        mDisplayShortDateFormatter.locale = [NSLocale currentLocale];
        mDisplayShortDateFormatter.timeZone = [NSTimeZone defaultTimeZone];
        mDisplayShortDateFormatter.timeStyle = NSDateFormatterNoStyle;
        mDisplayShortDateFormatter.dateStyle = NSDateFormatterShortStyle;
        [mDisplayShortDateFormatter setLenient:YES];
    }
    
    return mDisplayShortDateFormatter;
}

@end
