//
//  UICircleLoaderView.m
//  UICircleLoader
//
//  Created by yapQ Ltd.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import "UICircleLoaderView.h"

@interface UICircleLoaderView ()

/**
 * Cirlce shape layer
 */
@property (strong, nonatomic) CAShapeLayer *progressLayer;

@end

@implementation UICircleLoaderView

/**
 * Initializer for using in code.
 */
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initDefaults];
    }
    return self;
}
/**
 * Initialize all paramaters when used in IB.
 */
-(void)awakeFromNib {
    [self initDefaults];
}

/**
 * Setting default values
 */
-(void)initDefaults {
    
    _indicatorLineWidth = 3;
    _indicatorViewColor = [UIColor clearColor];
    _indicatorColor = [UIColor darkGrayColor];
    _indicatorBackgroundColor = [UIColor grayColor];
    
    self.contentMode = UIViewContentModeRedraw;
    self.backgroundColor = _indicatorViewColor;
    
    _progressLayer = [[CAShapeLayer alloc] init];
    _progressLayer.strokeColor = self.indicatorColor.CGColor;
    _progressLayer.strokeEnd = 0;
    _progressLayer.fillColor = nil;
    _progressLayer.lineWidth = 3;
    [self.layer addSublayer:_progressLayer];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    _progressLayer.frame = self.bounds;
    [self updatePath];
}

-(void)setProgress:(float)progress animated:(BOOL)isAnimated {
    if (progress > 0) {
        if (isAnimated) {
            if ([[NSThread currentThread] isMainThread]) {
                [self animateProgress:progress];
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self animateProgress:progress];
                });
            }
        } else {
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            self.progressLayer.strokeEnd = progress;
            [CATransaction commit];
        }
    } else {
        self.progressLayer.strokeEnd = 0.0f;
        [self.progressLayer removeAnimationForKey:@"animation"];
    }
    _progress = progress;
}

-(void)animateProgress:(float)progress {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"stroke"];
    animation.fromValue = self.progress == 0 ? @0 : nil;
    animation.toValue = [NSNumber numberWithFloat:progress];
    animation.duration = 1;
    self.progressLayer.strokeEnd = progress;
    [self.progressLayer addAnimation:animation forKey:@"animation"];
}



-(void)updatePath {
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    self.progressLayer.path = [UIBezierPath bezierPathWithArcCenter:center
                                                             radius:self.bounds.size.width/2 - (_indicatorLineWidth/2.)
                                                         startAngle:-M_PI_2
                                                           endAngle:-M_PI_2 + 2 * M_PI
                                                          clockwise:YES].CGPath;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, _indicatorColor.CGColor);
    CGContextSetStrokeColorWithColor(context, _indicatorBackgroundColor.CGColor);
    //CGContextSetLineWidth(context, _indicatorLineWidth);
    CGContextStrokeEllipseInRect(context, CGRectInset(self.bounds, 1, 1));
    
    CGRect stopRect = (CGRect){
        CGRectGetMidX(self.bounds)-self.bounds.size.width/8,
        CGRectGetMidY(self.bounds)-self.bounds.size.height/8,
        self.bounds.size.width / 4,
        self.bounds.size.height / 4
    };
    CGContextFillRect(context, CGRectIntegral(stopRect));
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Attribute setters
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////
-(void)setIndicatorBackgroundColor:(UIColor *)indicatorBackgroundColor {
    _indicatorBackgroundColor = indicatorBackgroundColor;
    [self setNeedsDisplay];
}

-(void)setIndicatorColor:(UIColor *)indicatorColor {
    _indicatorColor = indicatorColor;
    self.progressLayer.strokeColor = _indicatorColor.CGColor;
    [self setNeedsDisplay];
}

-(void)setIndicatorLineWidth:(int)indicatorLineWidth {
    _indicatorLineWidth = indicatorLineWidth;
    _progressLayer.lineWidth = _indicatorLineWidth;
    [self setNeedsDisplay];
}

-(void)setIndicatorViewColor:(UIColor *)indicatorViewColor {
    _indicatorViewColor = indicatorViewColor;
    self.backgroundColor = indicatorViewColor;
    [self setNeedsDisplay];
}

-(void)setProgress:(float)progress {
    [self setProgress:progress animated:NO];
}

@end

