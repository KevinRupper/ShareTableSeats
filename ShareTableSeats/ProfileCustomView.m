//
//  ProfileCustomView.m
//  ShareTableSeats
//
//  Created by Kevin Rupper on 4/4/15.
//  Copyright (c) 2015 Guerrilla Dev SWAT. All rights reserved.
//

#import "ProfileCustomView.h"

@implementation ProfileCustomView

-(id)init{
    
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"ProfileCustomView" owner:self options:nil];
    id mainView = [subviewArray objectAtIndex:0];
    
    return mainView; 
}

//- (instancetype)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if(self)
//    {
//        [[NSBundle mainBundle] loadNibNamed:@"ProfileCustomView" owner:self options:nil];
//        self.frame = frame;
//    }
//    return self;
//}

//- (id)initWithCoder:(NSCoder *)aDecoder
//{
//    self = [super initWithCoder:aDecoder];
//}

- (void)configureWith:(id<ProfileCustomViewDelegate>)delegate{

    self.delegate = delegate;
}

- (IBAction)loginButtonTap:(id)sender
{
    if(self.delegate != nil)
        [self.delegate didLoginButtonTap];
}
     
- (IBAction)signUpButtonTap:(id)sender
{
    if(self.delegate != nil)
        [self.delegate didSignUpButtonTap];
}

@end
