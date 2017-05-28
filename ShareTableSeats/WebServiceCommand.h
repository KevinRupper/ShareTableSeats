//
//  WebServiceCommand.h
//  ShareTableSeats
//
//  Created by Kevin Rupper on 4/4/15.
//  Copyright (c) 2015 Guerrilla Dev SWAT. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^WebServiceCompletionBlock)(BOOL ok, id response, NSString *errorMessage);

@interface WebServiceCommand : NSOperation

@property (nonatomic, strong) NSString *baseURLString;
@property (nonatomic, strong) NSString *command;
@property (nonatomic, strong) NSString *method;

- (instancetype)initWithCommand:(NSString *)command
                  baseURLString:(NSString *)baseURLString
                         method:(NSString *)method;

- (void)setCompletionBlock:(WebServiceCompletionBlock)completion;
- (void)setCredentials:(NSDictionary *)credentials;
- (void)setBody:(NSDictionary *)body;

- (id)decodeData:(NSData *)data;

@end
