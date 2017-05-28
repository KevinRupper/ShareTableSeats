//
//  SelectDatePresentationTransition.m
//  MesasAve
//
//  Created by Kevin Rupper on 4/4/15.
//  Copyright (c) 2015 Guerrilla Dev SWAT. All rights reserved.
//

#import "CustomPresentationTransition.h"
#import "SelectDateViewController.h"
#import "UIImage+ImageEffects.h"

@implementation CustomPresentationTransition

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.72;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
     SelectDateViewController *toVC = (SelectDateViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIImageView *blurView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    blurView.alpha = 0.0f;
    
    // Begin context // Set blurred background image
    UIGraphicsBeginImageContextWithOptions([UIScreen mainScreen].bounds.size, NO, [UIScreen mainScreen].scale);
    [fromVC.view drawViewHierarchyInRect:[UIScreen mainScreen].bounds afterScreenUpdates:YES];
    
    UIImage *blurredImage = UIGraphicsGetImageFromCurrentImageContext();
    blurredImage = [blurredImage applyDarkEffect];
    
    UIGraphicsEndImageContext();
    // EndContext
    
    blurView.image = blurredImage;
    toVC.transitionningBackgroundView = blurView;
    
    /*
      The container view acts as the superview of all other
      views (including those of the presenting and presented view controllers) 
      during the animation sequence.
     */
    [transitionContext.containerView addSubview:blurView];
    [transitionContext.containerView addSubview:toVC.view];

    CGRect toViewFrame = CGRectMake(0.0f, 0.0f, 260.0f, 204.0f);
    toVC.view.frame = toViewFrame;
    
    CGPoint finalCenter = CGPointMake(fromVC.view.bounds.size.width / 2, 20.0f + toViewFrame.size.height / 2);
    toVC.view.center = CGPointMake(finalCenter.x, finalCenter.y - 1000.0f);
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0.0f
         usingSpringWithDamping:0.64f
          initialSpringVelocity:0.22f
                        options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowAnimatedContent
                     animations:^{
                         toVC.view.center = finalCenter;
                         blurView.alpha = 0.7;
                     } completion:^(BOOL finished) {
                         toVC.view.center = finalCenter;
                         [transitionContext completeTransition:YES];
                     }];
}

@end
