//
//  AuthWebServices.m
//  ShareTableSeats
//
//  Created by Kevin Rupper on 16/4/15.
//  Copyright (c) 2015 Guerrilla Dev SWAT. All rights reserved.
//

#import "AuthWebService.h"
#import <UIKit/UIKit.h>
#import "NSData+Base64.h"

#define kBaseURLString @"http://mesasave.herokuapp.com/api/v1/"

@interface AuthWebService() <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
    AuthWebServiceCompletionBlock mCompletion;
    NSMutableData *mData;
    NSString *mCommand;
    NSString *mBody;
    NSString *mErrorString;
    NSMutableURLRequest *mRequest;
}

@end

@implementation AuthWebService

- (instancetype)initWithCommand:(NSString *)command
{
    self = [super init];
    
    if (self)
    {
        NSString *urlstring = [NSString stringWithFormat:@"%@%@", kBaseURLString, command];
        
        // Init request with url command
        mRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlstring]];
    }
    
    return self;
}

- (void)setCompletion:(AuthWebServiceCompletionBlock)completion
{
    mCompletion = completion;
}

- (void)setHTTPMethod:(NSString *)method
{
    mRequest.HTTPMethod = method;
}

- (void)setBody:(NSDictionary *)body
{
    NSError *error;
    mRequest.HTTPBody = [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error:&error];
    [mRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    if(error)
        NSLog(@"#ERROR: %@", error.localizedDescription);
}

- (void)setCredentials:(NSDictionary *)credentials
{
    // Set encoded credentials
    NSString *cred = [NSString stringWithFormat:@"%@:%@", credentials[@"email"], credentials[@"password"]];
    NSString *credBase64 = [[cred dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString];
    NSString *authHeader = [NSString stringWithFormat:@"Basic %@", credBase64];
    
    [mRequest addValue:authHeader forHTTPHeaderField:@"Authorization"];
}

- (void)executeRequest
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [NSURLConnection connectionWithRequest:mRequest delegate:self];
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
    
    switch (res.statusCode)
    {
        case 200:
            mErrorString = nil;
            break;
        case 400:
            NSLog(@"#ERROR: incorrect request 400");
            mErrorString = @"Incorrect request";
            break;
        case 401:
            NSLog(@"#ERROR: not authorized 401");
            mErrorString = @"Not authorized";
        case 404:
            NSLog(@"#ERROR: resource not found 404");
            mErrorString = @"Resource not found 404";
            break;
        case 500:
            NSLog(@"#ERROR: internarl server error 500");
            mErrorString = @"Internal server error";
            break;
    }
    
    if(response.expectedContentLength != NSURLResponseUnknownLength)
        mData = [NSMutableData dataWithCapacity: (NSUInteger)response.expectedContentLength];
    else
        mData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [mData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSLog(@"#ERROR: %@", error);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    id responseData = [self decodeData:mData];
    
    // Nasty code (smell)
    if([mRequest.HTTPMethod isEqualToString:@"DELETE"])
    {
        if(mCompletion)
            mCompletion(YES, nil, mErrorString);
    }
    else
        if(mCompletion)
            mCompletion(responseData ? YES: NO, responseData, mErrorString);
}

#pragma mark - Methods

- (id)decodeData:(NSData *)data
{
    if(data != nil)
        return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    return nil;
}


@end
