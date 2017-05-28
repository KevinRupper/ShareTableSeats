//
//  WebServiceCommand.m
//  ShareTableSeats
//
//  Created by Kevin Rupper on 4/4/15.
//  Copyright (c) 2015 Guerrilla Dev SWAT. All rights reserved.
//

#import "WebServiceCommand.h"
#import "NSData+Base64.h"

@interface WebServiceCommand ()
{
    WebServiceCompletionBlock mCompletionBlock;
    NSMutableURLRequest *mRequest;
    NSString *mErrorString;
}

@end

@implementation WebServiceCommand

- (instancetype)initWithCommand:(NSString *)command baseURLString:(NSString *)baseURLString method:(NSString *)method
{
    self = [super init];
    
    if(self)
    {
        NSString *urlstring = [NSString stringWithFormat:@"%@%@", baseURLString, command];
        NSString *encodedString = [urlstring stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:encodedString];
        
        mRequest = [[NSMutableURLRequest alloc] initWithURL:url];
        mRequest.HTTPMethod = method;
    }
    
    return self;
}

#pragma mark - Methods

- (void)setCompletionBlock:(WebServiceCompletionBlock)completion
{
    mCompletionBlock = completion;
}

- (void)setCredentials:(NSDictionary *)credentials
{
    // Set encoded credentials
    NSString *cred = [NSString stringWithFormat:@"%@:%@", credentials[@"email"], credentials[@"password"]];
    NSString *credBase64 = [[cred dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString];
    NSString *authHeader = [NSString stringWithFormat:@"Basic %@", credBase64];
    
    [mRequest addValue:authHeader forHTTPHeaderField:@"Authorization"];
}

- (void)setBody:(NSDictionary *)body
{
    NSError *error;
    mRequest.HTTPBody = [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error:&error];
    [mRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    if(error)
        NSLog(@"#ERROR: %@", error.localizedDescription);
}

#pragma mark - Background

- (void)start
{
    NSData *data;
    NSError *error;
    NSHTTPURLResponse *response;
    
    data = [NSURLConnection sendSynchronousRequest:mRequest returningResponse:&response error:&error];
    
    [self responseStatusCode:response];
    
    if(error)
        NSLog(@"#ERROR: %@", error.localizedDescription);
    
    id responseData = [self decodeData:data];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        // Nasty...
        if([self.method isEqualToString:@"DELETE"])
            mCompletionBlock(YES, nil, mErrorString);
        else
            if(mCompletionBlock != nil)
                mCompletionBlock(responseData ? YES:NO, responseData, mErrorString);
    });
}

- (id)decodeData:(NSData *)data
{
    if(data != nil)
        return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    return nil;
}

- (void) responseStatusCode:(NSHTTPURLResponse *)response
{
    switch (response.statusCode)
    {
        case 200:
            NSLog(@"#INFO: request OK");
            mErrorString = nil;
            break;
        case 400:
            NSLog(@"#ERROR: incorrect request 400");
            mErrorString = @"Incorrect request / Status 400";
            break;
        case 401:
            NSLog(@"#ERROR: not authorized 401");
            mErrorString = @"Not authorized 401 / Status 401";
            break;
        case 500:
            NSLog(@"#ERROR: internarl server error 500");
            mErrorString = @"Internar server error / Status 500";
            break;
    }
}

@end
