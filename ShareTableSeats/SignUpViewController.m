//
//  SignUpViewController.m
//  ShareTableSeats
//
//  Created by Kevin Rupper on 4/4/15.
//  Copyright (c) 2015 Guerrilla Dev SWAT. All rights reserved.
//

#import "SignUpViewController.h"
#import "AppDelegate.h"
#import "WebService.h"
#import "DBHelper.h"

@interface SignUpViewController () <UITextFieldDelegate>
{
    AppDelegate *mAppDelegate;
    
    NSString *mName;
    NSString *mPhone;
    NSString *mEmail;
    NSString *mPassword;
}

@property (nonatomic, strong) IBOutlet UITextField *nameTextField;
@property (nonatomic, strong) IBOutlet UITextField *phoneTextField;
@property (nonatomic, strong) IBOutlet UITextField *emailtextField;
@property (nonatomic, strong) IBOutlet UITextField *passwordtextField;
@property (nonatomic, strong) IBOutlet UIButton *signUpButton;

- (IBAction)signUpButtonTap:(id)sender;
- (IBAction)cancelButtonTap:(id)sender;

@end

@implementation SignUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    mAppDelegate = [UIApplication sharedApplication].delegate;
    
    [mAppDelegate setBorderViewWithColor:[UIColor clearColor]
                             borderWidth:1.0
                            cornerRadius:8.0
                                    view:self.signUpButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
        mName = textField.text;
    else if (textField.tag == 1) // Phone
        mPhone = textField.text;
    else if (textField.tag == 2) // Email
        mEmail = textField.text;
    else if (textField.tag == 3) // Password
        mPassword = textField.text;
}

#pragma mark - Actions

- (IBAction)signUpButtonTap:(id)sender
{
    [[WebService  sharedInstance] signUpWithName:@""
                                           email:@""
                                           phone:@""
                                        password:@""
                                      completion:^(BOOL ok, NSDictionary *response, NSString *errorMessage)
    {
        if(!ok
           || errorMessage.length > 0)
        {
            NSString *message =  @"Hubo un error en el registro";
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Registro"
                                                                                     message:message
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:action];
            [self presentViewController:alertController animated:YES completion:nil];
            return;
        }
        
        [DBHelper createUserWithDict:response inContext:mAppDelegate.managedObjectContext];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"logged"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didLoginSuccess" object:nil];
        
        NSString *message =  @"Registro completado";
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Registro"
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action)
        {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [alertController addAction:action];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }];
}

- (IBAction)cancelButtonTap:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
