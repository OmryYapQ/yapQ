//
//  YViewController.h
//  yapq
//
//  Created by yapQ Ltd on 6/27/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIDotLoaderIndicatorView.h"

@interface YViewController : UIViewController

@property (strong, nonatomic) UIView *animationView;
@property BOOL isAnimated;

-(UIView *)leftBarView;
-(UIBarButtonItem *)rightBarView;
-(UIView *)titleView;
-(void)showLoading:(BOOL)show;

-(void)animateBicycle:(CGRect)rcCover;
-(void)stopAnimationAndRemoveFromSuperview;

@end
