//
//  YLocation.h
//  yapq
//
//  Created by yapQ Ltd on 5/16/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface YLocation : CLLocation

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

-(id)initYLocationWithLatitude:(double)latitude andLongitude:(double)longitude;
+(id)initWithLatitude:(double)latitude andLongitude:(double)longitude;
+(id)initWithLatitude:(double)latitude latMetersOffset:(double)latOffset andLongitude:(double)longitude longMetersOffset:(double)longOffset;

-(BOOL)isLocationinsideLocationWithCenter:(YLocation *)center andRadius:(float)radius;
-(double)distanceToLocationFromLocationWithCenter:(YLocation *)center;

@end
