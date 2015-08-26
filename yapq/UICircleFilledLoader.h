//
//  UICircleFilledLoader.h
//  UICircleLoader
//
//  Created by yapQ Ltd on 6/4/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utilities.h"

#define LINE_WIDTH 4
#define RADIUS_OFFSET LINE_WIDTH*2 // Offset of radius


/**
 * Circle filled loader indicator.
 *
 * Indicator can be initialized from IB and code.
 *
 * Indicator is thread safety, animation performs on main thread.
 *
 * @author yapQ Ltd
 *
 * @version 1.0
 */
@interface UICircleFilledLoader : UIControl

/**
 * Background color of indicator view
 */
@property (strong, nonatomic) UIColor *indicatorViewColor;

/**
 * Color of progress indicator
 */
@property (strong, nonatomic) UIColor *indicatorColor;

/**
 * Percent of progress
 */
@property (nonatomic) float progress;


/**
 * Changing progress of loader
 *
 * Method runs in main thread
 */
-(void)setProgress:(float)progress animated:(BOOL)isAnimated;

-(void)initDefaults;

@end
