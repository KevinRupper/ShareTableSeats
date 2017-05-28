//
//  SelectDateRangeViewController.m
//  MesasAve
//
//  Created by Kevin Rupper on 27/4/15.
//  Copyright (c) 2015 Guerrilla Dev SWAT. All rights reserved.
//

#import "SelectDateRangeViewController.h"

@interface SelectDateRangeViewController ()

@property (nonatomic, strong) IBOutlet UIDatePicker *sinceDatePicker;
@property (nonatomic, strong) IBOutlet UIDatePicker *toDatePicker;
@property (nonatomic, strong) IBOutlet UISwitch *toDateSwitch;

- (IBAction)okButtonTap:(id)sender;
- (IBAction)cancelButtonTap:(id)sender;
- (IBAction)switchValueChanged:(id)sender;

@end

@implementation SelectDateRangeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _sinceDatePicker.timeZone = [NSTimeZone localTimeZone];
    _sinceDatePicker.calendar = [NSCalendar currentCalendar];
    
    _toDatePicker.timeZone = [NSTimeZone localTimeZone];
    _toDatePicker.calendar = [NSCalendar currentCalendar];
    
    _toDatePicker.userInteractionEnabled = NO;
    _toDatePicker.alpha = 0.2;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.sinceDatePicker.minimumDate = [NSDate date];
    self.sinceDatePicker.datePickerMode = UIDatePickerModeDate;
    
    self.toDatePicker.minimumDate = [NSDate date];
    self.toDatePicker.datePickerMode = UIDatePickerModeDate;
}

#pragma mark - Actions

- (IBAction)okButtonTap:(id)sender
{
    NSMutableDictionary *dict = [@{@"sinceDate": self.sinceDatePicker.date} mutableCopy];
    
    if(self.toDateSwitch.isOn)
        dict[@"toDate"] = self.toDatePicker.date;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didSelectDateRange" object:dict];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelButtonTap:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)switchValueChanged:(id)sender
{
    if(self.toDateSwitch.isOn)
    {
        self.toDatePicker.userInteractionEnabled = YES;
        _toDatePicker.alpha = 1;
    }
    else
    {
        self.toDatePicker.userInteractionEnabled = NO;
        _toDatePicker.alpha = 0.2;
    }
}

@end
