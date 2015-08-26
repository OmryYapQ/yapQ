//
//  UICircleLabledLoader.h
//  UICircleLoader
//
//  Created by yapQ Ltd on 6/7/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * Circle loader with progress label indicator.
 *
 * Indicator can be initialized from IB and code.
 *
 * Indicator is thread safety, animation performs on main thread.
 *
 * @author yapQ Ltd
 *
 * @version 1.0
 */
@interface UICircleLabeledLoader : UIControl

/**
 * Background color of indicator view
 */
@property (strong, nonatomic) UIColor *indicatorViewColor;

/**
 * Color of loader background
 */
@property (strong, nonatomic) UIColor *indicatorBackgroundColor;

/**
 * Color of progress indicator
 */
@property (strong, nonatomic) UIColor *indicatorColor;

/**
 * Color of progress text
 */
@property (strong, nonatomic) UIColor *indicatorTextColor;

/**
 * Percent of progress
 */
@property (nonatomic) float progress;

/**
 * Width of progress indicator
 */
@property (nonatomic)int indicatorLineWidth;

/**
 * Changing progress of loader
 *
 * Method runs in main thread
 */
-(void)setProgress:(float)progress animated:(BOOL)isAnimated;

@end
