//
//  UICircleLabledLoader.m
//  UICircleLoader
//
//  Created by yapQ Ltd on 6/7/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import "UICircleLabeledLoader.h"

@interface UICircleLabeledLoader ()

/**
 * Cirlce shape layer
 */
@property (strong, nonatomic) CAShapeLayer *progressLayer;

/**
 * Progress text
 */
@property (strong, nonatomic) UILabel *text;

@end

@implementation UICircleLabeledLoader

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
    _indicatorTextColor = _indicatorColor;
    
    self.contentMode = UIViewContentModeRedraw;
    self.backgroundColor = _indicatorViewColor;
    
    _progressLayer = [[CAShapeLayer alloc] init];
    _progressLayer.strokeColor = self.indicatorColor.CGColor;
    _progressLayer.strokeEnd = 0;
    _progressLayer.fillColor = nil;
    _progressLayer.lineWidth = 3;
    [self.layer addSublayer:_progressLayer];
    
    CGRect textRect = (CGRect){
        CGRectGetMidX(self.bounds)-self.bounds.size.width/3,
        CGRectGetMidY(self.bounds)-self.bounds.size.height/3-2,
        self.bounds.size.width/1.5,
        self.bounds.size.height/1.5
    };

    _text = [[UILabel alloc] initWithFrame:textRect];
    _text.adjustsFontSizeToFitWidth = YES;
    _text.textAlignment = NSTextAlignmentCenter;
    _text.text = @"0%";
    _text.textColor = _indicatorTextColor;
    [self addSubview:_text];
}

-(CGRect)sizeOfText:(NSString *)text forRect:(CGRect)rect {
    return [text boundingRectWithSize:rect.size options:(NSStringDrawingUsesFontLeading) attributes:@{} context:nil];
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
    dispatch_async(dispatch_get_main_queue(), ^{
        _text.text = [NSString stringWithFormat:@"%i%%",(int)(_progress*100)];
    });
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
     _text.textColor = _indicatorColor;
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

-(void)setIndicatorTextColor:(UIColor *)indicatorTextColor {
    _indicatorTextColor = indicatorTextColor;
    _text.textColor = _indicatorTextColor;
}

@end
