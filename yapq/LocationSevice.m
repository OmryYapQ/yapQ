//
//  LocationSevice.m
//  YAPP
//
//  Created by yapQ Ltd
//  Copyright (c) 2013 yapQ Ltd. All rights reserved.
//

#import "LocationSevice.h"

const double RADIO = 6371;              // Mean radius of Earth in Km

/**
 * Function convert's degries to radians
 * @param val angle in degreis
 * @return angle in radians
 *
 */
double convertToRadians(double val) {
    
    return val * M_PI / 180;
}


@implementation LocationService

static LocationService *instance = NULL;

/**
 * Init components of CLLocationManager
 */
-(id)init {
    if (self = [super init]) {
        _isStartRouteMonitoring = NO;
        
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        
        [self serviceSetup];
    }
    
    return self;
}

-(void)serviceSetup {
    if (self.isStartRouteMonitoring) {
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy=kCLLocationAccuracyBestForNavigation;
        //_locationManager.pausesLocationUpdatesAutomatically = YES;
        _updateTimeInterval = LSLocationUpdateMoreFreq;
        _locationManager.headingFilter = 1; // kCLHeadingFilterNone;
    }
    else {
        _locationManager.distanceFilter = 10;
        _locationManager.desiredAccuracy=kCLLocationAccuracyBest;
        _locationManager.pausesLocationUpdatesAutomatically = YES;
        _updateTimeInterval = LSLocationUpdateLessFreq;
        _locationManager.headingFilter = 1;
    }
}

-(void)serviceReset {
    //_locationManager.distanceFilter = kCLDistanceFilterNone;
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Routes
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////
-(void)startRoutes {
    self.isStartRouteMonitoring = YES;
    [self startUpdate];
}

-(void)stopRoutes {
    self.isStartRouteMonitoring = NO;
    [self stopUpdate];
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public Methods
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////
/**
 * Method returns instance of LocationService class
 * @return instnce of current singleton class
 */
+(LocationService *)sharedService {
    if (!instance) {
        instance = [[LocationService alloc] init];
        
    }
    return instance;
}

/**
 * Method turn's ON location manager in IOS
 */
-(void)startUpdate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    NSLog(@"%@",dateString);
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    _locationServiceUpTime = [dateFormatter dateFromString:dateString];
    
#ifdef USE_HARDCODED_LATLONG
    [self locationManager:nil didUpdateLocations:nil];
#else
    NSLog(@"Started %@",_locationServiceUpTime);
    
    [self serviceSetup];
    
    [_locationManager startUpdatingLocation];
    [_locationManager startMonitoringSignificantLocationChanges];
    [_locationManager startUpdatingHeading];
    [[NSNotificationCenter defaultCenter] postNotificationName:LSLocationChangeStatusNotification object:self userInfo:[NSDictionary dictionaryWithObject:StatusStart forKey:LSLocationChangeStatusNotification]];
#endif
    
}

/**
 * Method turn's OFF location manager in IOS
 */
-(void)stopUpdate {
    if (self.isStartRouteMonitoring) {
        // don't stop GPS service if we are monitoring a route !
        return;
    }
    
    NSLog(@"Stoped %@",[NSDate date]);
    [_locationManager stopMonitoringSignificantLocationChanges];
    [_locationManager stopUpdatingLocation];
   // [self serviceReset];
    [[NSNotificationCenter defaultCenter] postNotificationName:LSLocationChangeStatusNotification object:self userInfo:[NSDictionary dictionaryWithObject:StatusStop forKey:LSLocationChangeStatusNotification]];
}

-(void)gpsStatusMessage {
    
    NSLog(@"NO GPS SIGNAL");
    [[NSNotificationCenter defaultCenter] postNotificationName:LSLocationNOGPSSignalNotification object:self userInfo:nil];
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Methods
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////

/**
 * Calls from location service authorization method
 */
-(void)locationUpdate {
    
    [self startUpdate];
}

/**
 * Calculates distance between two coordinates
 */
-(double)kilometresBetweenPlace1:(CLLocationCoordinate2D) place1 andPlace2:(CLLocationCoordinate2D) place2 {
    
    double dlon = convertToRadians(place2.longitude - place1.longitude);
    double dlat = convertToRadians(place2.latitude - place1.latitude);
    
    double a = ( pow(sin(dlat / 2), 2) + cos(convertToRadians(place1.latitude))) * cos(convertToRadians(place2.latitude)) * pow(sin(dlon / 2), 2);
    double angle = 2 * asin(sqrt(a));
    
    return angle * RADIO;
}

-(BOOL)isNewLocationCorrect:(CLLocation *)location {
    
    NSInteger timeinterval = [location.timestamp timeIntervalSinceDate:_locationServiceUpTime];
    NSLog(@"%li",(long)timeinterval);
    if (timeinterval < 0) {
        return NO;
    }
    
    
    return YES;
}


-(BOOL)isSpecificPlace:(YLocation *)location {
    
    return [LocationService isLocation:location insideCurrentLocationWithRadius:MINI_ISRAEL_RADIUS];
}

-(BOOL)isSamePlace:(CLLocation *)location {
    // Distance between new and current place in meters
    double dist = [self kilometresBetweenPlace1:CLLocationCoordinate2DMake(_currentLocation.latitude,
                                                                           _currentLocation.longitude)
                                      andPlace2:location.coordinate]*1000;
    NSLog(@"%lf",dist);
    // Distance change notification
    if (dist < 5) {
        return YES;
    }
    
    return NO;
}

-(LSSignalStrength)signalStrength:(CLLocationManager *)manager {
    // Signal strength
    if (manager.location.horizontalAccuracy < 0) {
        return LSSignalStrengthNone;
    }
    else if (manager.location.horizontalAccuracy > 200) {
        return LSSignalStrengthLow;
    }
    else if (manager.location.horizontalAccuracy > 48) {
        NSLog(@"Signal %f",manager.location.horizontalAccuracy);
        return LSSignalStrengthMedium;
    }
    else {
        NSLog(@"Signal %f",manager.location.horizontalAccuracy);
        return LSSignalStrengthBest;
    }
}




//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Static methods for geographinc calculations
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////
/**
 * Locations inside current location with radius
 */
+(BOOL)isLocation:(YLocation *)location insideCurrentLocationWithRadius:(float)radius {
    return [self isLocation:location
   insideLocationWithCenter:[YLocation initWithLatitude:[self sharedService].currentLocation.latitude
                                           andLongitude:[self sharedService].currentLocation.longitude]
                  andRadius:radius];
}

/**
 * Location inside location with radius
 */
+(BOOL)isLocation:(YLocation *)location insideLocationWithCenter:(YLocation *)center andRadius:(float)radius {
    
    double distance = [location distanceToLocationFromLocationWithCenter:[YLocation initWithLatitude:center.latitude
                                                                                        andLongitude:center.longitude]];
    
    return distance <= radius;
}

/**
 * Method returns distnace in kilometer between two locations
 */
+(double)distanceToLocation:(YLocation *)location fromLocationWithCenter:(YLocation *)center {
    
    CLLocation *cent = [[CLLocation alloc] initWithLatitude:center.latitude longitude:center.longitude];
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];

    return [cent distanceFromLocation:loc];
}

+(double)distanceFromCurrentLocationToLocation:(YLocation *)location  {
    
    return [location distanceToLocationFromLocationWithCenter:[YLocation initWithLatitude:[self sharedService].currentLocation.latitude
                                                   andLongitude:[self sharedService].currentLocation.longitude]];
}

+(double)azimuthFromLocation:(YLocation *)location1 LocationToLocation:(YLocation *)location2 {
    double dLat = (location1.latitude-location2.latitude) * M_PI / 180;
    double dLon = (location1.longitude-location2.longitude) * M_PI / 180;
    double arc = atan2(dLat , dLon) * 180 / M_PI;
    
    return arc;
}


/***************************************************** Delegate ********************************************************************************************/


//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Compass
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////
-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    if (newHeading.headingAccuracy < 0)
        return;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:LSLocationHeadingChanged object:self userInfo:@{HedingKey:newHeading}];
}

-(BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
    return false;
    //    if(!manager.heading)
    //        return YES; // Got nothing, We can assume we got to calibrate.
    //    else if( manager.heading.headingAccuracy < 0 )
    //        return YES; // 0 means invalid heading, need to calibrate
    //    else if( manager.heading.headingAccuracy > 30 )
    //        return YES; // 5 degrees is a small value correct for my needs, too.
    //    else return NO;
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    NSLog(@"%@",error);
}

-(void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error {
    NSLog(@"Some error %@",error);
    NSLog(@"%@",manager.location);
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Core Location Delegate Methods
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"did authorized?");
    switch (status) {
        case kCLAuthorizationStatusAuthorized:
        {
            NSLog(@"Authorized");
            [self locationUpdate];
            _gpsStatusTimer = [NSTimer scheduledTimerWithTimeInterval:SIGNAL_STATUS_MESSAGE_TIMEINTERVAL target:self selector:@selector(gpsStatusMessage) userInfo:nil repeats:NO];//[NSTimer timerWithTimeInterval:SIGNAL_STATUS_MESSAGE_TIMEINTERVAL target:self selector:@selector(gpsStatusMessage) userInfo:nil repeats:NO];
            break;
        }
        case kCLAuthorizationStatusDenied: {
            NSLog(@"Denied");
            [[NSNotificationCenter defaultCenter] postNotificationName:LSLocationChangeStatusNotification object:self userInfo:[NSDictionary dictionaryWithObject:StatusDenide forKey:LSLocationChangeStatusNotification]];
        }
            break;
        case kCLAuthorizationStatusNotDetermined:
            NSLog(@"NotDetermined");
            //[_locationManager performSelector:@selector(requestWhenInUseAuthorization) withObject:nil];
            if ([Utilities currentVersionOfOS] == UTIOS_8) {
                [_locationManager requestAlwaysAuthorization];
            }
            else {
                [self startUpdate];
            }
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            NSLog(@"Authorized When In Use");
            [self locationUpdate];
            _gpsStatusTimer = [NSTimer scheduledTimerWithTimeInterval:SIGNAL_STATUS_MESSAGE_TIMEINTERVAL target:self selector:@selector(gpsStatusMessage) userInfo:nil repeats:NO];//[NSTimer timerWithTimeInterval:SIGNAL_STATUS_MESSAGE_TIMEINTERVAL target:self selector:@selector(gpsStatusMessage) userInfo:nil repeats:NO];
            break;
        case kCLAuthorizationStatusRestricted:
            NSLog(@"Restricted");
            
            break;
        default:
            break;
    }
    if (status == kCLAuthorizationStatusAuthorized) {
        
    }
}

static int firstTime = 0;
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    /*
    if (firstTime < 1) {
        if ([_gpsStatusTimer isValid]) {
            [_gpsStatusTimer invalidate];
        }
        
        _currentLongitude = [manager location].coordinate.longitude;
        _currentLatitude = [manager location].coordinate.latitude;
        _currentLocation = [YLocation initWithLatitude:_currentLatitude andLongitude:_currentLongitude];
        [[NSNotificationCenter defaultCenter] postNotificationName:LSLocationWasUpdatedNotification object:self userInfo:nil];
        ++firstTime;
        return;
    }
    */
    
    
    // Debug notification
    [[NSNotificationCenter defaultCenter] postNotificationName:LSDebug object:self];
    NSLog(@"%@",manager.location);
    
    LSSignalStrength strength = [self signalStrength:manager];
    if (strength == LSSignalStrengthNone || strength == LSSignalStrengthLow) {
        return;
    }
    
    if (![self isNewLocationCorrect:manager.location]) {
        return;
    }
    else if (![self isSamePlace:manager.location]) {
        //return;
    }
    else {
        if (_locationManager.distanceFilter == kCLDistanceFilterNone) {
            
        }
    }
    
    if ([_gpsStatusTimer isValid]) {
        [_gpsStatusTimer invalidate];
    }
    
    // Speed change notification
    _speed = [manager location].speed;
    if ( (_speed >= 0) && (NO == _isStartRouteMonitoring) ) {
        [[NSNotificationCenter defaultCenter] postNotificationName:LSSpeedChangesNotification object:self];
    }
    
    /*void (^dataLoadedCompletionBlock)(void) = ^{
     [self servicePauseSetup];
     };*/
    
#ifdef USE_HARDCODED_LATLONG
    // for testing purposes
    _currentLongitude = 34.762656;
    _currentLatitude = 32.057793;
#else
    _currentLongitude = [manager location].coordinate.longitude;
    _currentLatitude = [manager location].coordinate.latitude;
    
#endif
    _currentLocation = [YLocation initWithLatitude:_currentLatitude andLongitude:_currentLongitude];
    
    
    if (self.isStartRouteMonitoring) {
        [[NSNotificationCenter defaultCenter] postNotificationName:LSRouteLocationWasUpdatedNotification object:self userInfo:nil/*[NSDictionary dictionaryWithObject:_currentLocation forKey:@"Location"]*/];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:LSLocationWasUpdatedNotification object:self userInfo:nil/*[NSDictionary dictionaryWithObject:_currentLocation forKey:@"Location"]*/];
    }
    
    if (self.isStartRouteMonitoring) {
        // in route mode we update more frequently and don't stop the GPS
        _updateTimeInterval = LSLocationUpdateMoreFreq;
    }
    else if ([self isSpecificPlace:[YLocation initWithLatitude:MINI_ISRAEL_LAT andLongitude:MINI_ISRAEL_LON]]) {
        // in mini israel we update more frequently and don't stop the GPS
        _updateTimeInterval = LSLocationUpdateMoreFreq;
    }
    else {
        // not in mini israel
        _updateTimeInterval = LSLocationUpdateLessFreq;
        
        // If device is pluged in to charger location service will not stop's
        UIDeviceBatteryState deviceBatteryState = [UIDevice currentDevice].batteryState;
        if (!(deviceBatteryState == UIDeviceBatteryStateCharging || deviceBatteryState == UIDeviceBatteryStateFull)) {
            
            // Stop timer
            /* if (![_stopTimer isValid]) {
             _stopTimer = [NSTimer scheduledTimerWithTimeInterval:LSStopLocationUpdateTimeInterval target:self selector:@selector(stopUpdate) userInfo:Nil repeats:NO];
             }*/
            [self stopUpdate];
        
            // Start timer
            if (![_updateTimer isValid]) {
                _updateTimer = [NSTimer scheduledTimerWithTimeInterval:_updateTimeInterval target:self selector:@selector(startUpdate) userInfo:nil repeats:NO];
            }
        }
    }
}

@end
