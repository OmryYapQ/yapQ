//
//  AppDelegate.h
//  yapq
//
//  Created by yapQ Ltd on 12/2/13.
//  Copyright (c) 2013 yapQ Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "LocationSevice.h"
#import "Settings.h"
#import "DBCoreDataHelper.h"
#import <AVFoundation/AVFoundation.h>
#import "LRSlideMenuController.h"
#import "MenuViewController.h"
#import "YMenuViewController.h"
#import "GAI.h"
#import <GooglePlus/GooglePlus.h>
#import <FacebookSDK/FacebookSDK.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,UIAlertViewDelegate> {
    NSTimer *_timer;
}

@property (strong, nonatomic) UIWindow *window;
@property NSTimeInterval timerLastInterval;

@end
