//
//  ProfileViewController.m
//  ShareTableSeats
//
//  Created by Kevin Rupper on 28/2/15.
//  Copyright (c) 2015 Guerrilla Dev SWAT. All rights reserved.
//

#import "ProfileViewController.h"
#import "AppDelegate.h"
#import "ProfileCustomView.h"
#import "SignUpViewController.h"
#import "LoginViewController.h"
#import "ProfileCustomView.h"
#import "DBHelper.h"
#import "User.h"

@interface ProfileViewController() <ProfileCustomViewDelegate>
{
    AppDelegate *mAppDelegate;
    User *mCurrentUser;
    ProfileCustomView *mProfileCustomView;
}

@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *phoneLabel;
@property (nonatomic, strong) IBOutlet UILabel *emailLabel;
@property (nonatomic, strong) IBOutlet UIButton *logoutButton;

- (IBAction)logoutButtonTap:(id)sender;

@end

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    mAppDelegate = [UIApplication sharedApplication].delegate;
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.title = @"Mi perfil";
    
    // User has been logged
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"logged"])
    {
        [self updateUserDataFields];
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didLoginSucces:)
                                                 name:@"didLoginSuccess"
                                               object:nil];
    
    [self setItemsAppearance];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"logged"])
    {
        [self.navigationController.view addSubview:[self customView]];
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    else
    {
        if(mProfileCustomView)
            [mProfileCustomView removeFromSuperview];
        
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [self updateUserDataFields];
    }
}

- (void) setItemsAppearance
{
    [mAppDelegate setBorderViewWithColor:[UIColor clearColor]
                             borderWidth:1.0
                            cornerRadius:8.0
                                    view:self.nameLabel];
    
    [mAppDelegate setBorderViewWithColor:[UIColor clearColor]
                             borderWidth:1.0
                            cornerRadius:8.0
                                    view:self.phoneLabel];
    
    [mAppDelegate setBorderViewWithColor:[UIColor clearColor]
                             borderWidth:1.0
                            cornerRadius:8.0
                                    view:self.emailLabel];
    
    [mAppDelegate setBorderViewWithColor:[UIColor clearColor]
                             borderWidth:1.0
                            cornerRadius:8.0
                                    view:self.logoutButton];
}

- (UIView *)customView
{
    if(mProfileCustomView)
        return mProfileCustomView;
    
    NSNumber *height = @(ABS(self.view.frame.size.height) + self.navigationController.navigationBar.frame.size.height
    + [UIApplication sharedApplication].statusBarFrame.size.height);
    CGRect frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, height.floatValue);
    
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = frame;
    
    mProfileCustomView = [[ProfileCustomView alloc] init];
    mProfileCustomView.delegate = self;
    [mProfileCustomView addSubview:visualEffectView];
    [mProfileCustomView sendSubviewToBack:visualEffectView];
    mProfileCustomView.alpha = 1.0;
    mProfileCustomView.frame = frame;

    [mAppDelegate setBorderViewWithColor:[UIColor clearColor]
                             borderWidth:1.0
                            cornerRadius:8.0
                                    view:mProfileCustomView.loginButton];
    
    [mAppDelegate setBorderViewWithColor:[UIColor clearColor]
                             borderWidth:1.0
                            cornerRadius:8.0
                                    view:mProfileCustomView.signUpButton];
    
    return mProfileCustomView;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:@"didLoginSuccess"];
}

#pragma mark - ProfileCustomView delegate

- (void)didLoginButtonTap
{
    LoginViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginViewController"];

    [self presentViewController:vc];
}

- (void)didSignUpButtonTap
{
    SignUpViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SignUpViewController"];
    
    [self presentViewController:vc];
}

- (void)presentViewController:(UIViewController *)vc
{
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [mAppDelegate.window.rootViewController presentViewController:nc animated:YES completion:nil];
}

#pragma mark - Methods

- (void) updateUserDataFields
{
    mCurrentUser = [DBHelper currentUserInContext:mAppDelegate.managedObjectContext];
    
    self.emailLabel.text    = mCurrentUser.email;
    self.nameLabel.text     = mCurrentUser.name;
    self.phoneLabel.text    = mCurrentUser.phone;
}

#pragma mark - Actions

- (IBAction)logoutButtonTap:(id)sender;
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"logged"];
    [self.navigationController.view addSubview:[self customView]];
}

#pragma mark - Notifications

- (void)didLoginSucces:(NSNotification *)notification
{
    [self updateUserDataFields];
}

@end
