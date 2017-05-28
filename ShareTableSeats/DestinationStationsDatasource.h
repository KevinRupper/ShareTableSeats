//
//  DestinationStationsDatasource.h
//  MesasAve
//
//  Created by Kevin Rupper on 17/4/15.
//  Copyright (c) 2015 Guerrilla Dev SWAT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@interface DestinationStationsDatasource : NSObject <UITableViewDataSource, UITableViewDelegate,NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) UITableView *destinationTableView;
@property (nonatomic, strong) NSString *searchString;

@end
