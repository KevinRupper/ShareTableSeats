//
//  SelectDateDissmisalTransition.m
//  MesasAve
//
//  Created by Kevin Rupper on 4/4/15.
//  Copyright (c) 2015 Guerrilla Dev SWAT. All rights reserved.
//

#import "CustomDissmisalTransition.h"
#import "SelectDateViewController.h"

@implementation CustomDissmisalTransition

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.72;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    SelectDateViewController *vc = (SelectDateViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    CGPoint finalCenter = CGPointMake(160.0f, (vc.view.bounds.size.height / 2) - 1000.0f);
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0.0f
         usingSpringWithDamping:0.64f
          initialSpringVelocity:0.22f
                        options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowAnimatedContent
                     animations:^{
                         vc.view.center = finalCenter;
                         vc.transitionningBackgroundView.alpha = 0.0f;
                         }
                     completion:^(BOOL finished) {
                         [vc.view removeFromSuperview];
                         [transitionContext completeTransition:YES];
                     }];
}

@end
