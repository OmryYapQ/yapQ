//
//  UIDotLoaderIndicatorView.m
//  Dot Loading Indicator
//
//  Created by yapQ Ltd
//  Copyright (c) 2013 yapQ Ltd. All rights reserved.
//

#import "UIDotLoaderIndicatorView.h"

@implementation UIDotLoaderIndicatorView

- (id)initWithSize:(DLIndicatorSize)size atPosition:(CGPoint)point tintColor:(UIColor *)color
{
    self = [super initWithFrame:CGRectMake(point.x, point.y, size.width, size.height)];
    if (self) {
        
        self.userInteractionEnabled = NO;
        a = 0.6;
        b = 0.6;
        c = 0.6;
        
        self.layer.cornerRadius = 5;
        
        _tintColor = [color isEqual:DEFAULT_COLOR] ? [UIColor darkGrayColor] : color;
        
        [self addSubview:[self dot_1:size]];
        [self addSubview:[self dot_2:size]];
        [self addSubview:[self dot_3:size]];
        _speed = DEFAULT_ANIM_SPEED;
    }
    return self;
}

-(id)initWithSize:(DLIndicatorSize)size atPosition:(CGPoint)point tintColor:(UIColor *)color animationSpeed:(double)speed {
    
    self = [self initWithSize:size atPosition:point tintColor:color];
    if (1-speed > 0) {
        _speed = 1 - speed;
    }
    
    return self;
}

-(UIView *)dot_1:(DLIndicatorSize)size {
    if (!_dot_1) {
        
        _dot_1 = [self createViewOnView:_dot_1 withSize:size];
        _dot_1.frame = CGRectMake(5, 5, _dot_1.frame.size.width, _dot_1.frame.size.width);
        _dot_1.backgroundColor = _tintColor;
        _dot_1.alpha = a;
    }
    
    return _dot_1;
}

-(UIView *)dot_2:(DLIndicatorSize)size {
    if (!_dot_2) {
        
        _dot_2 = [self createViewOnView:_dot_2 withSize:size];
        _dot_2.frame = CGRectMake(5+_dot_1.frame.size.width+5, 5, _dot_2.frame.size.width, _dot_2.frame.size.width);
        _dot_2.backgroundColor = _tintColor;
        _dot_2.alpha = b;
    }
    return _dot_2;
}

-(UIView *)dot_3:(DLIndicatorSize)size {
    if (!_dot_3) {
        
        _dot_3 = [self createViewOnView:_dot_3 withSize:size];
        _dot_3.frame = CGRectMake(5+_dot_1.frame.size.width+5+_dot_2.frame.size.width+5, 5, _dot_3.frame.size.width, _dot_3.frame.size.width);
        _dot_3.backgroundColor = _tintColor;
        _dot_3.alpha = c;
    }
    return _dot_3;
}

-(UIView *)createViewOnView:(UIView *)view withSize:(DLIndicatorSize)size {
    float w = size.width;
    
    float cleanW = w - (4*SPACE_W);
    float viewW = cleanW/3;
    
    view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewW, viewW)];
    view.layer.cornerRadius = (float)viewW/(float)2;
    
    return view;
}

-(CAAnimationGroup *)group:(int) index {
    
    CABasicAnimation *aa = [CABasicAnimation animationWithKeyPath:@"opacity"];
    aa.fromValue = @[[NSNumber numberWithFloat:0.6]];
    aa.toValue = @[[NSNumber numberWithFloat:0.3]];
    aa.duration = _speed;//0.5;
    aa.beginTime = 0.0;
    aa.cumulative = YES;
    aa.autoreverses = YES;
    
    CABasicAnimation *bb = [CABasicAnimation animationWithKeyPath:@"opacity"];
    bb.fromValue = @[[NSNumber numberWithFloat:0.6]];
    bb.toValue = @[[NSNumber numberWithFloat:0.3]];
    bb.duration = _speed;//0.5;
    bb.beginTime = _speed*0.8;//0.4;
    bb.cumulative = YES;
    bb.autoreverses = YES;
    
    CABasicAnimation *cc = [CABasicAnimation animationWithKeyPath:@"opacity"];
    cc.fromValue = @[[NSNumber numberWithFloat:0.6]];
    cc.toValue = @[[NSNumber numberWithFloat:0.3]];
    cc.duration = _speed;//0.5;
    cc.beginTime = _speed*1.6;//0.8;
    cc.cumulative = YES;
    cc.autoreverses = YES;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.repeatCount = INFINITY;
    [group setDuration:_speed*3];
    
    group.delegate = self;
    
    if (index == 1) {
        [group setAnimations:@[aa]];
    }
    else if (index == 2) {
        [group setAnimations:@[bb]];
    }
    else {
        [group setAnimations:@[cc]];
    }
    
    return group;
}

/**
 * Indication movement left
 */
-(void)calculateNextAlphaMoveLeft {
    a = a + b;
    b = a - b;
    a = a - b;
    
    b = b + c;
    c = b - c;
    b = b - c;
}

/**
 * Indication movement right
 */
-(void)calculateNextAlphaMoveRight {

    b = b + c;
    c = b - c;
    b = b - c;
    
    a = a + b;
    b = a - b;
    a = a - b;
}

-(void)startAnimation {
    
    [self start];
    
    // AppDelegate Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(void)start {
    
    if ([_delegate respondsToSelector:@selector(indicatorWillStartAnimating)]) {
        [_delegate indicatorWillStartAnimating];
    }
    
    if (_animateLeft) {
        [self calculateNextAlphaMoveLeft];
    }
    else {
        [self calculateNextAlphaMoveRight];
    }
    
    [_dot_1.layer addAnimation:[self group:1] forKey:@"aa"];
    [_dot_2.layer addAnimation:[self group:2] forKey:@"bb"];
    [_dot_3.layer addAnimation:[self group:3] forKey:@"cc"];
}

-(void)animationDidStart:(CAAnimation *)anim {

    if ([[_dot_1.layer animationForKey:@"aa"] isEqual:anim]) {
        if ([_delegate respondsToSelector:@selector(indicatorDidStartAnimating)]) {
            [_delegate indicatorDidStartAnimating];
        }
    }
    
}

-(void)stopAndRemoveFromSuperView:(BOOL) isRemove {
    
    [self stopAnimation];
    [self removeFromSuperview];
}

-(void)stopAnimation {
    
    if ([_delegate respondsToSelector:@selector(indicatorWillStopAnimating)]) {
        [_delegate indicatorWillStopAnimating];
    }
    
    [self stop];
    
    // AppDelegate Notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if ([_delegate respondsToSelector:@selector(indicatorDidStopAnimating)]) {
        [_delegate indicatorDidStopAnimating];
    }
}

-(void)stop {
    [_dot_1.layer removeAllAnimations];
    [_dot_2.layer removeAllAnimations];
    [_dot_3.layer removeAllAnimations];
}

#//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Background Forground notifications
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////
-(void)enterBackground:(id)sender {
    [self stop];
}

-(void)enterForeground:(id)sender {
    [self start];
}

@end
