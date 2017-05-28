//
//  SelectDateViewController.m
//  MesasAve
//
//  Created by Kevin Rupper on 4/4/15.
//  Copyright (c) 2015 Guerrilla Dev SWAT. All rights reserved.
//

#import "SelectDateViewController.h"
#import "AppDelegate.h"

@interface SelectDateViewController ()

@property (nonatomic, strong) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, strong) IBOutlet UIDatePicker *datePicker;

@end

@implementation SelectDateViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    _datePicker.timeZone = [NSTimeZone localTimeZone];
    _datePicker.calendar = [NSCalendar currentCalendar];

    [appDelegate setBorderViewWithColor:[UIColor clearColor] borderWidth:1.0 cornerRadius:8.0 view:self.view];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    [self.transitionningBackgroundView addGestureRecognizer:gesture];
    
    self.transitionningBackgroundView.userInteractionEnabled = YES;
    self.datePicker.minimumDate = [NSDate date];
    self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    self.navigationBar.topItem.title = @"Fecha/Hora";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Actions

- (IBAction)okButtonTap:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didSelectDate" object:@{@"date": self.datePicker.date}];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelButtonTap:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
