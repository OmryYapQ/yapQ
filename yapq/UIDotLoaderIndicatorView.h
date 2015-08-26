//
//  UIDotLoaderIndicatorView.h
//  Dot Loading Indicator
//
//  Created by yapQ Ltd
//  Copyright (c) 2013 yapQ Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
/**
 * Small size of indicator
 */
#define INDICATOR_SMALL CGSizeMake(41,17)
/**
 * Medium size of indicator
 */
#define INDICATOR_MEDIUM CGSizeMake(50,20)
/**
 * Large size of indicator
 */
#define INDICATOR_LARGE CGSizeMake(65,25)

/**
 * Default color
 */
#define DEFAULT_COLOR [UIColor clearColor]

/**
 * Space size between dots
 */
#define SPACE_W 5

/**
 * Default animation speed
 */
#define DEFAULT_ANIM_SPEED 0.5

/**
 * Indicator size type
 */
typedef CGSize DLIndicatorSize;

@protocol UIDotLoaderIndicatorDelegate <NSObject>

@optional
-(void)indicatorWillStartAnimating;
-(void)indicatorWillStopAnimating;
-(void)indicatorDidStartAnimating;
-(void)indicatorDidStopAnimating;

@end

@interface UIDotLoaderIndicatorView : UIView {
    
    float a;
    float b;
    float c;
}

/**
 * Color of indicator dots
 */
@property (strong, nonatomic) UIColor *tintColor;
/**
 * Dot views
 */
@property (strong, nonatomic) UIView *dot_1;
@property (strong, nonatomic) UIView *dot_2;
@property (strong, nonatomic) UIView *dot_3;

/**
 * Left direction of animation
 */
@property (nonatomic) BOOL animateLeft;

/**
 * Animation speed
 */
@property (nonatomic) double speed;

/**
 * UIDotLoaderIndicator delegate
 */
@property id<UIDotLoaderIndicatorDelegate> delegate;

/**
 * Init indicator with size color and position
 *
 * @param size - size of dots
 * @param point - position of indicator
 * @param color - color of indicator
 */
- (id)initWithSize:(DLIndicatorSize)size atPosition:(CGPoint)point tintColor:(UIColor *)color;

/**
 * Init indicator with size color and position
 *
 * @param size - size of dots
 * @param point - position of indicator
 * @param color - color of indicator
 * @param speed - animation speed. Value must be between 0.0 and 1.0.
 */
-(id)initWithSize:(DLIndicatorSize)size atPosition:(CGPoint)point tintColor:(UIColor *)color animationSpeed:(double)speed;

/**
 * Start animation
 */
-(void)startAnimation;

/**
 * Stop animation
 */
-(void)stopAnimation;

/*
 * Stop and remove from superview
 *
 * @param isRemove - if true remove, else don't remove
 */
-(void)stopAndRemoveFromSuperView:(BOOL) isRemove;

@end
