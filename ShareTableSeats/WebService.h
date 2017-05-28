//
//  WebService.h
//  ShareTableSeats
//
//  Created by Kevin Rupper on 4/4/15.
//  Copyright (c) 2015 Guerrilla Dev SWAT. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^GetTablesCompletionBlock)(BOOL ok, NSArray *tables, NSString *errorMessage);
typedef void (^GetStationsCompletionBlock)(BOOL ok, NSArray *stations, NSString *errorMessage);
typedef void (^CommonServiceCompletionBlock)(BOOL ok, NSDictionary *response, NSString *errorMessage);
typedef void (^DeleteTableCompletionBlock)(BOOL ok, NSString *errorMessage);

typedef enum : NSUInteger {
    
    WebServiceReachableStatusNone,
    WebServiceReachableStatusReachable,
    
}WebServiceReachableStatus;

@class WebService;

@protocol WebServiceDelegate <NSObject>

@optional

- (void) webService:(WebService *)webService didChangeReachableStatus:(WebServiceReachableStatus)status;

@end

@interface WebService : NSObject

+ (id)sharedInstance;

@property (nonatomic, weak) id <WebServiceDelegate> delegate;

// Stations
- (void)getStationsWithCompletion:(GetStationsCompletionBlock)completion;

// Tables
- (void)getTablesWithCompletion:(GetTablesCompletionBlock)completion;
- (void)getTablesWithQueryParamsWithDict:(NSDictionary *)queryParams completion:(GetTablesCompletionBlock)completion;
- (void)getCurrentUserTablesWithUserID:(NSString *)userID completion:(GetTablesCompletionBlock)completion;
- (void)createTableWithDict:(NSDictionary *)dict credentials:(NSDictionary *)credentials completion:(CommonServiceCompletionBlock)completion;
- (void)deleteTableWithID:(NSString *)tableID credentials:(NSDictionary *)credentials completion:(DeleteTableCompletionBlock)completion;

- (void)updateTableWithTableID:(NSString *)tableID
                          dict:(NSDictionary *)dict
                   credentials:(NSDictionary *)credentials
                    completion:(CommonServiceCompletionBlock)completion;

// User
- (void)signUpWithName:(NSString *)name
                 email:(NSString *)email
                 phone:(NSString *)phone
              password:(NSString *)password
            completion:(CommonServiceCompletionBlock)completion;

- (void)loginWithEmail:(NSString *)email
              password:(NSString *)password
            completion:(CommonServiceCompletionBlock)completion;

- (void)updateUserWithUserID:(NSString *)userID
                    password:(NSString *)password
                       email:(NSString *)email
                     newName:(NSString *)newName
                    newPhone:(NSString *)newPhone
                 newPassword:(NSString *)newPassword
                  completion:(CommonServiceCompletionBlock)completion;

@end
