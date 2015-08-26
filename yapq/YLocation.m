//
//  YLocation.m
//  yapq
//
//  Created by yapQ Ltd on 5/16/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import "YLocation.h"

@implementation YLocation

-(id)initYLocationWithLatitude:(double)latitude andLongitude:(double)longitude {
    if (self = [super initWithLatitude:latitude longitude:longitude]) {
        _latitude = latitude;
        _longitude = longitude;
    }
    return self;
}

+(id)initWithLatitude:(double)latitude andLongitude:(double)longitude {
    YLocation *__autoreleasing location = [[YLocation alloc] initYLocationWithLatitude:latitude andLongitude:longitude];
    return location;
}

+(id)initWithLatitude:(double)latitude latMetersOffset:(double)latOffset andLongitude:(double)longitude longMetersOffset:(double)longOffset {
    double lat = latitude + (180./M_PI)*(latOffset/6378137.0);
    //double lon = longitude + (180./PIx/2)*(longOffset/6378137.0)/cos(PIx * latitude/180.0);
    double lon = longitude + (180./M_PI)*(longOffset/6378137.0)/cos(M_PI * latitude/180.);
    
    //double lat = latitude + 0.0003;
    //double lon = longitude + 0.0003;
    YLocation *__autoreleasing location = [[YLocation alloc] initYLocationWithLatitude:lat andLongitude:lon];
    return location;
}

-(BOOL)isEqual:(YLocation *)other {
    if (_latitude == other.latitude &&
        _longitude == other.longitude) {
        return YES;
    }
    return NO;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"[lat = %lf, lon = %lf]",_latitude,_longitude];
}

-(BOOL)isLocationinsideLocationWithCenter:(YLocation *)center andRadius:(float)radius {
    double distance = [self distanceToLocationFromLocationWithCenter:center];
    
    return distance <= radius;
}

-(double)distanceToLocationFromLocationWithCenter:(YLocation *)center {
    return [self distanceFromLocation:center];
}

@end
