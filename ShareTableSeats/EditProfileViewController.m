//
//  EditProfileViewController.m
//  ShareTableSeats
//
//  Created by Kevin Rupper on 5/5/15.
//  Copyright (c) 2015 Guerrilla Dev SWAT. All rights reserved.
//

#import "EditProfileViewController.h"
#import "AppDelegate.h"
#import "WebService.h"
#import "DBHelper.h"
#import "User.h"

@interface EditProfileViewController () <UITextFieldDelegate>
{
    AppDelegate *mAppDelegate;
    User *mCurrentUser;
    
    NSString *mNewName;
    NSString *mNewPhone;
    NSString *mNewPassword;
}

@property (nonatomic, strong) IBOutlet UITextField *nameTextField;
@property (nonatomic, strong) IBOutlet UITextField *phoneTextField;
@property (nonatomic, strong) IBOutlet UITextField *passwordTextField;
@property (nonatomic, strong) IBOutlet UIButton *saveButton;

- (IBAction)saveButtonTap:(id)sender;
- (IBAction)backButtonTap:(id)sender;

@end

@implementation EditProfileViewController

- (void)viewDidLoad
{
    mAppDelegate = [UIApplication sharedApplication].delegate;
    
    mCurrentUser = [DBHelper currentUserInContext:mAppDelegate.managedObjectContext];
    
    self.nameTextField.text = mNewName = mCurrentUser.name;
    self.phoneTextField.text = mNewPhone = mCurrentUser.phone;
    self.passwordTextField.text = mNewPassword = mCurrentUser.password;
    
    [mAppDelegate setBorderViewWithColor:[UIColor clearColor]
                             borderWidth:1.0
                            cornerRadius:8.0
                                    view:self.saveButton];
}


#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [self.view viewWithTag:nextTag];
    
    if (nextResponder)
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    else
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
    
    return NO; // We do not want UITextField to insert line-breaks.
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField.tag == 0)       // Name
        mNewName = textField.text;
    else if (textField.tag == 1) // Phone
        mNewPhone = textField.text;
    else if (textField.tag == 2) // Password
        mNewPassword = textField.text;
}

#pragma mark - Actions

- (IBAction)saveButtonTap:(id)sender
{
    [[WebService sharedInstance] updateUserWithUserID:mCurrentUser.serverID
                                             password:mCurrentUser.password
                                                email:mCurrentUser.email
                                              newName:mNewName
                                             newPhone:mNewPhone
                                          newPassword:mNewPassword
                                           completion:^(BOOL ok, NSDictionary *response, NSString *errorMessage)
    {
        if(!ok
           || errorMessage.length > 0)
        {
            NSString *message =  @"Hubo un error al guardar los cambios";
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Registro"
                                                                                     message:message
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:action];
            [self presentViewController:alertController animated:YES completion:nil];
            return;
        }
        
        mCurrentUser.name = mNewName;
        mCurrentUser.phone = mNewPhone;
        mCurrentUser.password = mNewPassword;
        
        [mAppDelegate saveContext];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didLoginSuccess" object:nil];
        
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (IBAction)backButtonTap:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
