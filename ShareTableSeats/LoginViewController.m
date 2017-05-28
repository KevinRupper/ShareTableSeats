//
//  LoginViewController.m
//  ShareTableSeats
//
//  Created by Kevin Rupper on 4/4/15.
//  Copyright (c) 2015 Guerrilla Dev SWAT. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "WebService.h"
#import "DBHelper.h"
#import "User.h"

@interface LoginViewController ()
{
    AppDelegate *mAppDelegate;
}

@property (nonatomic, strong) IBOutlet UIButton *loginButton;

- (IBAction)loginButtonTap:(id)sender;
- (IBAction)cancelButtonTap:(id)sender;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    mAppDelegate = [UIApplication sharedApplication].delegate;
    
    [mAppDelegate setBorderViewWithColor:[UIColor clearColor]
                             borderWidth:1.0
                            cornerRadius:8.0
                                    view:self.loginButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions

- (IBAction)loginButtonTap:(id)sender
{
    [[WebService sharedInstance] loginWithEmail:@""
                                   password:@""
                                 completion:^(BOOL ok, NSDictionary *response, NSString *errorMessage)
    {
        if(!ok)
            return;
        
        if(errorMessage != nil)
        {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:action];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        
        [DBHelper createUserWithDict:response inContext:mAppDelegate.managedObjectContext];
        
        [mAppDelegate saveContext];
        
        [self updateCurrentUserTables];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didLoginSuccess" object:nil];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"logged"];

        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (IBAction)cancelButtonTap:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Methods

- (void) updateCurrentUserTables
{
    User *currentUser = [DBHelper currentUserInContext:mAppDelegate.managedObjectContext];
    
    [[WebService sharedInstance] getCurrentUserTablesWithUserID:currentUser.serverID
                                                     completion:^(BOOL ok, NSArray *tables, NSString *errorMessage)
     {
         if (errorMessage.length)
         {
             NSLog(@"#ERROR: %@", errorMessage);
             return;
         }
         
         if(!ok)
             return;
         
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
             
             NSManagedObjectContext *moc = [mAppDelegate newChildMOC];
             
             [DBHelper createTablesWithArray:tables inContext:moc];
             [mAppDelegate saveContext:moc];
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [mAppDelegate saveContext:mAppDelegate.managedObjectContext];
             });
         });
     }];
}

@end
