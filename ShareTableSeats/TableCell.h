//
//  TableCell.h
//  ShareTableSeats
//
//  Created by Kevin Rupper on 2/3/15.
//  Copyright (c) 2015 Guerrilla Dev SWAT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) IBOutlet UILabel *timeLabel;
@property (nonatomic, strong) IBOutlet UILabel *availablePlacesLabel;
@property (nonatomic, strong) IBOutlet UILabel *stationsLabel;
@property (nonatomic, strong) IBOutlet UILabel *toDate;
@property (nonatomic, strong) IBOutlet UILabel *priceLabel;
@property (nonatomic, strong) IBOutlet UIView *placesBackgroundView;
@property (nonatomic, strong) IBOutlet UIImageView *placesImageView;

@end
