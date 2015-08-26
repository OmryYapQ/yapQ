//
//  UILoadingIndicator.h
//  yapq
//
//  Created by yapQ Ltd on 12/2/13.
//  Copyright (c) 2013 yapQ Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>

#define lIRotationAnimation @"rotationAnimation"

@interface UILoadingIndicator : UIImageView

-(void)startAnimationInView:(UIView *)view;
-(void)stopAnimation;

+(UILoadingIndicator *)sharedIndicator;

@end
