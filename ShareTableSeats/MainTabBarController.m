//
//  MainTabBarController.m
//  ShareTableSeats
//
//  Created by Kevin Rupper on 8/6/15.
//  Copyright (c) 2015 Guerrilla Dev SWAT. All rights reserved.
//

#import "MainTabBarController.h"

@implementation MainTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITabBarItem *item = [self.tabBar.items objectAtIndex:0];
    item.image = [[UIImage imageNamed:@"tabbar-icon-tables-off.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item.selectedImage = [[UIImage imageNamed:@"tabbar-icon-tables-on.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UITabBarItem *item1 = [self.tabBar.items objectAtIndex:1];
    item1.image = [[UIImage imageNamed:@"tabbar-icon-mytables-off.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item1.selectedImage = [[UIImage imageNamed:@"tabbar-icon-mytables-on.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UITabBarItem *item2 = [self.tabBar.items objectAtIndex:2];
    item2.image = [[UIImage imageNamed:@"tabbar-icon-user-off.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item2.selectedImage = [[UIImage imageNamed:@"tabbar-icon-user-on.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

@end
