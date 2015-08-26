//
//  LocationService.h
//  YAPP
//
//  Created by yapQ Ltd
//  Copyright (c) 2013 yapQ Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "WebServices.h"
#import "Utilities.h"
#import "YLocation.h"
#import <math.h>

/**
 * Location Service Notification Keys
 */
#define LSServiceIsReadyNotification @"LocationServiceIsReadyNotification"      // Service is ready
#define LSLocationWasUpdatedNotification @"LocationWasUpdatedNotification"      // Current location was changed
#define LSRouteLocationWasUpdatedNotification @"LocationRWasUpdatedNotification" 
#define LSSpeedChangesNotification @"SpeedChangesNotification"                  // Speed changes
#define LSLocationChangeStatusNotification @"LocationChangeStatusNotification"  // Status of location service
#define LSLocationNOGPSSignalNotification @"LocationNOGPSSignalNotification"    // No GPS signal notification
#define LSLocationHeadingChanged @"headingChanged"
#define HedingKey @"Heading"

#define StatusStart @"StatusStart"  // Location service status Started
#define StatusStop @"StatusStop"    // Location service status Stopped
#define StatusDenide @"StatusDenide"    // Location service disabled

#define LSDebug @"LocationServiceDebug" // Debug Notification key

/**
 * Frequency of service work
 */
#define LSLocationUpdateLessFreq 5*60 // sec
#define LSLocationUpdateMoreFreq 10 // sec

/**
 * Frequency of service stop
 */
#define LSStopLocationUpdateTimeInterval 20 //sec

/**
 * Speed limit of caution screen
 */
#define CAUTION_SPEED (20/3.6) // meter per sec


//latitudeFrom=31.257456&longitudeFrom=34.813140
#define MINI_ISRAEL_LAT 31.842163
#define MINI_ISRAEL_LON 34.969025
#define MINI_ISRAEL_RADIUS 300

typedef NS_ENUM(NSInteger, LSSignalStrength) {
    LSSignalStrengthBest,
    LSSignalStrengthMedium,
    LSSignalStrengthLow,
    LSSignalStrengthNone
};

#define SIGNAL_STATUS_MESSAGE_TIMEINTERVAL 30 // Time interval for showing message about gps signal

/**
 * Class implements singleton of Location service mechanism
 */
@interface LocationService : NSObject <CLLocationManagerDelegate,UIAlertViewDelegate>

@property float speed;                                              // Current speed of device
/** currentLongitude DEPRECATED Yapq 2.0 */
@property float currentLongitude;                                   // Current Longitude
/** currentLatitude DEPRECATED Yapq 2.0 */
@property float currentLatitude;                                    // Current Latitude
@property (strong, nonatomic) YLocation *currentLocation;
@property (strong, nonatomic) CLLocationManager *locationManager;   // LocationManager instance
//@property (strong, nonatomic) YLocation *currentLocation;          // NOT IN USE

@property (strong, nonatomic) NSTimer *updateTimer;                 // Timer for turning ON location manager
@property (assign, nonatomic) NSTimeInterval updateTimeInterval;    // Time interval for turning ON location manager

@property (strong, nonatomic) NSTimer *stopTimer;                   // Timer for turning OFF location manager

@property (strong, nonatomic) NSDate *locationServiceUpTime;        // Time when location service was started
@property (strong, nonatomic) NSTimer *gpsStatusTimer;              // GPS status timer

@property CLProximity lastProximity;                                // Last becon distatnce

@property BOOL isStartRouteMonitoring;

/**
 * Method returns instance of LocationService class
 * @return instnce of current singleton class
 */
+(LocationService *)sharedService;

/**
 * Method turn's ON location manager in IOS
 */
-(void)startUpdate;
/**
 * Method turn's OFF location manager in IOS
 */
-(void)stopUpdate;

+(BOOL)isLocation:(YLocation *)location insideCurrentLocationWithRadius:(float)radius;
+(BOOL)isLocation:(YLocation *)location insideLocationWithCenter:(YLocation *)center andRadius:(float)radius;
+(double)distanceToLocation:(YLocation *)location fromLocationWithCenter:(YLocation *)center;
+(double)distanceFromCurrentLocationToLocation:(YLocation *)location;

+(double)azimuthFromLocation:(YLocation *)location1 LocationToLocation:(YLocation *)location2;

-(BOOL)isSpecificPlace:(YLocation *)location;

-(void)startRoutes;
-(void)stopRoutes;

@end
