//
//  WebService.m
//  ShareTableSeats
//
//  Created by Kevin Rupper on 4/4/15.
//  Copyright (c) 2015 Guerrilla Dev SWAT. All rights reserved.
//

#import "WebService.h"
#import "Reachability.h"
#import "WebServiceCommand.h"
#import "AuthWebService.h"

#define kBaseURLString @"http://mesasave.herokuapp.com/api/v1/"

#define kGetStationsCommand    @"stations"
#define kTablesCommand         @"tables"
#define kUsersCommand          @"users"

@interface WebService ()
{
    NSOperationQueue *mCommanQueue;
    NSURLConnection *mConnetion;
    Reachability *mReachability;
}

@end

@implementation WebService

// Singleton
+ (id)sharedInstance
{
    static WebService *sharedWebService = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedWebService = [[self alloc] init];
    });
    
    return sharedWebService;
}

- (instancetype)init
{
    if(self = [super init])
    {
        mCommanQueue = [[NSOperationQueue alloc] init];
        mReachability = [Reachability reachabilityForInternetConnection];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reachabilityForInternetNotification:)
                                                     name:kReachabilityChangedNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

#pragma mark - Reachavility

- (void)reachabilityForInternetNotification:(NSNotification *)notification
{
    [self checkConnection];
}

- (void) checkConnection
{
    if(mReachability.currentReachabilityStatus == NotReachable)
        [self.delegate webService:self didChangeReachableStatus:WebServiceReachableStatusNone];
    else
        [self.delegate webService:self didChangeReachableStatus:WebServiceReachableStatusReachable];
}

- (void) executeCommand:(WebServiceCommand *)command
{
    [mCommanQueue addOperation:command];
}


#pragma mark - Stations

- (void)getStationsWithCompletion:(GetStationsCompletionBlock)completion
{
    WebServiceCommand *cmd = [[WebServiceCommand alloc] initWithCommand:kGetStationsCommand
                                                          baseURLString:kBaseURLString
                                                                 method:@"GET"];
    
    [cmd setCompletionBlock:^(BOOL ok, id response, NSString *errorMessage) {
        
        if(completion)
            completion(ok, response, errorMessage);
    }];
    
    [self executeCommand:cmd];
}

#pragma mark - Tables

- (void)getTablesWithCompletion:(GetTablesCompletionBlock)completion
{
    WebServiceCommand *cmd = [[WebServiceCommand alloc] initWithCommand:kTablesCommand
                                                          baseURLString:kBaseURLString
                                                                 method:@"GET"];
    
    [cmd setCompletionBlock:^(BOOL ok, id response, NSString *errorMessage) {
       
        NSLog(@"#INFO: %@", response);
        
        NSArray *tables = (NSArray *)response;
        
        if(completion)
            completion(ok, tables, errorMessage);
    }];
    
    [self executeCommand:cmd];
}

- (void)getTablesWithQueryParamsWithDict:(NSDictionary *)queryParams completion:(GetTablesCompletionBlock)completion
{
    NSMutableString *commandString = [NSMutableString stringWithFormat:@"%@?", kTablesCommand];
    NSArray *queryParamsArray = [queryParams allKeys];
    
    for (NSString *keyParam in queryParamsArray)
    {
        [commandString appendString:keyParam];
        [commandString appendString:@"="];
        [commandString appendString:[queryParams objectForKey:keyParam]];
        
        if(![keyParam isEqualToString:[queryParamsArray lastObject]])
           [commandString appendString:@"&"];
    }
    
    NSLog(@"INFO: %@", commandString);
    
    WebServiceCommand *cmd = [[WebServiceCommand alloc] initWithCommand:commandString baseURLString:kBaseURLString method:@"GET"];
    
    [cmd setCompletionBlock:^(BOOL ok, id response, NSString *errorMessage) {
       
        NSLog(@"#INFO: %@", response);
        
        NSArray *tables = (NSArray *)response;
        
        if(completion)
            completion(ok, tables, errorMessage);
    }];
    
    [self executeCommand:cmd];
}

- (void)getCurrentUserTablesWithUserID:(NSString *)userID completion:(GetTablesCompletionBlock)completion
{
    NSMutableString *commandString = [NSMutableString stringWithFormat:@"%@?", kTablesCommand];
    [commandString appendString:[NSString stringWithFormat:@"_user=%@", userID]];
    
    WebServiceCommand *cmd = [[WebServiceCommand alloc] initWithCommand:commandString baseURLString:kBaseURLString method:@"GET"];
    
    [cmd setCompletionBlock:^(BOOL ok, id response, NSString *errorMessage) {
        
        //NSLog(@"#INFO: %@", response);
        
        NSArray *tables = (NSArray *)response;
        
        if(completion)
            completion(ok, tables, errorMessage);
    }];
    
    [self executeCommand:cmd];
}

- (void)createTableWithDict:(NSDictionary *)dict credentials:(NSDictionary *)credentials completion:(CommonServiceCompletionBlock)completion
{
    WebServiceCommand *cmd = [[WebServiceCommand alloc] initWithCommand:kTablesCommand baseURLString:kBaseURLString method:@"POST"];
    [cmd setCredentials:credentials];
    [cmd setBody:dict];
    [cmd setCompletionBlock:^(BOOL ok, id response, NSString *errorMessage) {
        
        if(completion)
            completion(ok, response, errorMessage);
    }];
    
    [self executeCommand:cmd];
}

- (void)deleteTableWithID:(NSString *)tableID credentials:(NSDictionary *)credentials completion:(DeleteTableCompletionBlock)completion
{
    NSString *commandString = [NSString stringWithFormat:@"%@/%@", kTablesCommand, tableID];
    
    WebServiceCommand *cmd = [[WebServiceCommand alloc] initWithCommand:commandString baseURLString:kBaseURLString method:@"DELETE"];
    [cmd setCredentials:credentials];
    [cmd setCompletionBlock:^(BOOL ok, id response, NSString *errorMessage) {
        
        if(completion)
            completion(ok, errorMessage);
        
    }];
    
    [self executeCommand:cmd];
}

- (void)updateTableWithTableID:(NSString *)tableID dict:(NSDictionary *)dict credentials:(NSDictionary *)credentials completion:(CommonServiceCompletionBlock)completion
{
    NSString *commandString = [NSString stringWithFormat:@"%@/%@", kTablesCommand, tableID];
    
    WebServiceCommand *cmd = [[WebServiceCommand alloc] initWithCommand:commandString baseURLString:kBaseURLString method:@"PUT"];;
    [cmd setCredentials:credentials];
    [cmd setBody:dict];
    [cmd setCompletionBlock:^(BOOL ok, id response, NSString *errorMessage) {
        
        if(completion)
            completion(ok, response, errorMessage);
        
    }];
    
    [self executeCommand:cmd];
}

#pragma mark - User

- (void)signUpWithName:(NSString *)name
                 email:(NSString *)email
                 phone:(NSString *)phone
              password:(NSString *)password
            completion:(CommonServiceCompletionBlock)completion
{
    WebServiceCommand *cmd = [[WebServiceCommand alloc] initWithCommand:kUsersCommand
                                                          baseURLString:kBaseURLString
                                                                 method:@"POST"];
        
    [cmd setBody:@{@"name":name,
                   @"email":email,
                   @"phone":phone,
                   @"password":password}];
    
    [cmd setCompletionBlock:^(BOOL ok, id response, NSString *errorMessage) {

        NSDictionary *dict = response;
        
        if(completion)
            completion(ok, dict, errorMessage);
    }];

    [self executeCommand:cmd];
}

- (void)loginWithEmail:(NSString *)email password:(NSString *)password completion:(CommonServiceCompletionBlock)completion
{
    NSString *commandString = [NSString stringWithFormat:@"%@/login", kUsersCommand];
    
    WebServiceCommand *cmd = [[WebServiceCommand alloc] initWithCommand:commandString baseURLString:kBaseURLString method:@"POST"];
    [cmd setCredentials:@{@"email": email, @"password": password}];
    [cmd setCompletionBlock:^(BOOL ok, id response, NSString *errorMessage) {
        
        if(completion)
            completion(ok, response, errorMessage);
        
    }];
    
    [self executeCommand:cmd];
}

- (void)updateUserWithUserID:(NSString *)userID
                    password:(NSString *)password
                       email:(NSString *)email
                     newName:(NSString *)newName
                    newPhone:(NSString *)newPhone
                 newPassword:(NSString *)newPassword
                  completion:(CommonServiceCompletionBlock)completion
{
    NSString *commandString = [NSString stringWithFormat:@"%@/%@", kUsersCommand, userID];
    
    WebServiceCommand *cmd = [[WebServiceCommand alloc] initWithCommand:commandString baseURLString:kBaseURLString method:@"PUT"];
    
    [cmd setCredentials:@{@"email": email, @"password": password}];
    
    [cmd setBody:@{@"email":email,
                   @"password":password,
                   @"name":newName,
                   @"phone":newPhone,
                   @"newPassword": newPassword,
                   @"repeatNewPassword": newPassword}];
    
    [cmd setCompletionBlock:^(BOOL ok, id response, NSString *errorMessage) {
        
        if(completion)
            completion(ok, response, errorMessage);
        
    }];
    
    [self executeCommand:cmd];
}

@end
