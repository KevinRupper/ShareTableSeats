//
//  TableDetailViewController.m
//  ShareTableSeats
//
//  Created by Kevin Rupper on 2/3/15.
//  Copyright (c) 2015 Guerrilla Dev SWAT. All rights reserved.
//

#import "TableDetailViewController.h"
#import "DateHelper.h"
#import "Table.h"

@interface TableDetailViewController ()

@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) IBOutlet UILabel *dateTimeLabel;
@property (nonatomic, strong) IBOutlet UILabel *fromStationLabel;
@property (nonatomic, strong) IBOutlet UILabel *toStationLabel;
@property (nonatomic, strong) IBOutlet UILabel *ownerNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *ownerEmailLabel;
@property (nonatomic, strong) IBOutlet UILabel *ownerPhoneLabel;
@property (nonatomic, strong) IBOutlet UILabel *availablePlacesLabel;

- (IBAction)backButtonTap:(id)sender;

@end

@implementation TableDetailViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.dateLabel.text = [DateHelper stringDateFromDate:self.currentTable.fromDatetime];
    self.dateTimeLabel.text = [DateHelper stringTimeFromDate:self.currentTable.fromDatetime];
    self.fromStationLabel.text = self.currentTable.fromStationName;
    self.toStationLabel.text = self.currentTable.toStationName;
    self.availablePlacesLabel.text = [self.currentTable.availablePlaces stringValue];
    self.ownerNameLabel.text = self.currentTable.ownerName;
    self.ownerEmailLabel.text = self.currentTable.ownerEmail;
    self.ownerPhoneLabel.text = self.currentTable.ownerPhone;
    
    [self setLabelsAppearance];
}

- (IBAction)backButtonTap:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) setLabelsAppearance
{
    self.dateLabel.layer.borderColor = [[UIColor clearColor] CGColor];
    self.dateLabel.layer.borderWidth = 1.0;
    self.dateLabel.layer.cornerRadius = 8.0;
    self.dateLabel.clipsToBounds = YES;
    
    self.dateTimeLabel.layer.borderColor = [[UIColor clearColor] CGColor];
    self.dateTimeLabel.layer.borderWidth = 1.0;
    self.dateTimeLabel.layer.cornerRadius = 8.0;
    self.dateTimeLabel.clipsToBounds = YES;
    
    self.fromStationLabel.layer.borderColor = [[UIColor clearColor] CGColor];
    self.fromStationLabel.layer.borderWidth = 1.0;
    self.fromStationLabel.layer.cornerRadius = 8.0;
    self.fromStationLabel.clipsToBounds = YES;
    
    self.toStationLabel.layer.borderColor = [[UIColor clearColor] CGColor];
    self.toStationLabel.layer.borderWidth = 1.0;
    self.toStationLabel.layer.cornerRadius = 8.0;
    self.toStationLabel.clipsToBounds = YES;
    
    self.availablePlacesLabel.layer.borderColor = [[UIColor clearColor] CGColor];
    self.availablePlacesLabel.layer.borderWidth = 1.0;
    self.availablePlacesLabel.layer.cornerRadius = 8.0;
    self.availablePlacesLabel.clipsToBounds = YES;
    
    self.ownerNameLabel.layer.borderColor = [[UIColor clearColor] CGColor];
    self.ownerNameLabel.layer.borderWidth = 1.0;
    self.ownerNameLabel.layer.cornerRadius = 8.0;
    self.ownerNameLabel.clipsToBounds = YES;
    
    self.ownerEmailLabel.layer.borderColor = [[UIColor clearColor] CGColor];
    self.ownerEmailLabel.layer.borderWidth = 1.0;
    self.ownerEmailLabel.layer.cornerRadius = 8.0;
    self.ownerEmailLabel.clipsToBounds = YES;
    
    self.ownerPhoneLabel.layer.borderColor = [[UIColor clearColor] CGColor];
    self.ownerPhoneLabel.layer.borderWidth = 1.0;
    self.ownerPhoneLabel.layer.cornerRadius = 8.0;
    self.ownerPhoneLabel.clipsToBounds = YES;
}

@end
