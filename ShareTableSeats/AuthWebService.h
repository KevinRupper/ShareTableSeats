//
//  AuthWebServices.h
//  ShareTableSeats
//
//  Created by Kevin Rupper on 16/4/15.
//  Copyright (c) 2015 Guerrilla Dev SWAT. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^AuthWebServiceCompletionBlock)(BOOL ok, id response, NSString *errorMessage);

@interface AuthWebService : NSObject

- (instancetype)initWithCommand:(NSString *)command;

- (void)setCompletion:(AuthWebServiceCompletionBlock)completion;
- (void)setBody:(NSDictionary *)body;
- (void)setHTTPMethod:(NSString *)method;
- (void)setCredentials:(NSDictionary *)credentials;
- (void)executeRequest;

@end
