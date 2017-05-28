//
//  ProfileCustomView.h
//  ShareTableSeats
//
//  Created by Kevin Rupper on 4/4/15.
//  Copyright (c) 2015 Guerrilla Dev SWAT. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ProfileCustomViewDelegate

- (void)didLoginButtonTap;
- (void)didSignUpButtonTap;

@end

@interface ProfileCustomView : UIView

@property (nonatomic, strong) IBOutlet UIButton *loginButton;
@property (nonatomic, strong) IBOutlet UIButton *signUpButton;

@property (nonatomic, weak) id<ProfileCustomViewDelegate>delegate;

- (IBAction)loginButtonTap:(id)sender;
- (IBAction)signUpButtonTap:(id)sender;

@end
