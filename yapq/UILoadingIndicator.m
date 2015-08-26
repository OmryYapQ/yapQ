//
//  UILoadingIndicator.m
//  yapq
//
//  Created by yapQ Ltd on 12/2/13.
//  Copyright (c) 2013 yapQ Ltd. All rights reserved.
//

#import "UILoadingIndicator.h"

@implementation UILoadingIndicator

static UILoadingIndicator *instance;

+(UILoadingIndicator *)sharedIndicator {
    if (!instance) {
        instance = [[UILoadingIndicator alloc] init];
    }
    
    return instance;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.image = [UIImage imageNamed:@"activity_indicator"];
    }
    return self;
}

-(void)startAnimationInView:(UIView *)view {
    
    [view addSubview:self];
    self.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
    
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: -M_PI * 2.0];
    rotationAnimation.duration = 1.5;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = HUGE_VALF;
    
    [self.layer addAnimation:rotationAnimation forKey:lIRotationAnimation];
    
    /*[UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionRepeat animations:^{
        self.transform = CGAffineTransformMakeRotation(M_PI);
    } completion:^(BOOL finished) {
    
    }];*/
}

-(void)stopAnimation {
    [self.layer removeAnimationForKey:lIRotationAnimation];
    [self removeFromSuperview];
}

@end
