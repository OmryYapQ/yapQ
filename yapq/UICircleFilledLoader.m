//
//  UICircleFilledLoader.m
//  UICircleLoader
//
//  Created by yapQ Ltd on 6/4/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import "UICircleFilledLoader.h"

@interface UICircleFilledLoader ()

/**
 * Cirlce shape layer
 */
@property (strong, nonatomic) CAShapeLayer *progressLayer;


@end

@implementation UICircleFilledLoader

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
    
    _indicatorViewColor = [UIColor clearColor];
    _indicatorColor = [UIColor darkGrayColor];
    
    self.contentMode = UIViewContentModeRedraw;
    self.backgroundColor = _indicatorViewColor;
    
    _progressLayer = [[CAShapeLayer alloc] init];
    _progressLayer.cornerRadius = self.bounds.size.width/2.;
    _progressLayer.strokeColor = self.indicatorColor.CGColor;
    _progressLayer.strokeEnd = 0;
    _progressLayer.fillColor = nil;
    _progressLayer.lineWidth = floor(self.bounds.size.width/2.0)-RADIUS_OFFSET;
    [self.layer insertSublayer:_progressLayer atIndex:1];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    _progressLayer.frame =  (CGRect){self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width-2, self.bounds.size.height-2};
    [self updatePath];
}

-(void)setProgress:(float)progress animated:(BOOL)isAnimated {
    if (progress > 0) {
        if (isAnimated) {
            //if ([[NSThread currentThread] isMainThread]) {
                //[self animateProgress:progress];
            //}
            //else {
                [Utilities UITaskInSeparatedBlock:^{
                    [self animateProgress:progress];
                }];
            //}
        } else {
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            self.progressLayer.strokeEnd = progress;
            [CATransaction commit];
        }
    } else {
        self.progressLayer.strokeEnd = 0.0f;
        [self.progressLayer removeAnimationForKey:@"animationStroke"];
    }
    _progress = progress;
}

-(void)animateProgress:(float)progress {
    //[self.progressLayer removeAllAnimations];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"stroke"];
    animation.fromValue = _progress == 0 ? @0 : nil;
    animation.toValue = [NSNumber numberWithFloat:progress];
    animation.duration = 1.0;
    self.progressLayer.strokeEnd = progress;
    [self.progressLayer addAnimation:animation forKey:@"animationStroke"];
}

-(void)updatePath {
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    self.progressLayer.path = [UIBezierPath bezierPathWithArcCenter:center
                                                             radius:self.bounds.size.width/2 - (_progressLayer.lineWidth/2.0)-RADIUS_OFFSET
                                                         startAngle:-M_PI_2
                                                           endAngle:-M_PI_2 + 2 * M_PI
                                                          clockwise:YES].CGPath;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, _indicatorColor.CGColor);
    CGContextSetStrokeColorWithColor(context, _indicatorColor.CGColor);//[Utilities colorWith255StyleRed:160 green:155 blue:149 alpha:1.0].CGColor);
    CGContextSetLineWidth(context, LINE_WIDTH);
    CGRect bounds =  (CGRect){LINE_WIDTH/2,
        LINE_WIDTH/2,
        self.bounds.size.width-LINE_WIDTH,
        self.bounds.size.height-LINE_WIDTH};
    CGContextStrokeEllipseInRect(context, CGRectInset(bounds, 1, 1));
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Attribute setters
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////
-(void)setIndicatorColor:(UIColor *)indicatorColor {
    _indicatorColor = indicatorColor;
    self.progressLayer.strokeColor = _indicatorColor.CGColor;
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
