//
//  main.m
//  yapq
//
//  Created by yapQ Ltd on 12/2/13.
//  Copyright (c) 2013 yapQ Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "WebServices.h"
#import "YLocation.h"
#import "GTBoundingBox.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiandsToDegrees(x) (x * 180.0 / M_PI)

#define ROUTE_BBOX_METERS_OFFSET        50
@interface TestClass : NSObject
@end
@implementation TestClass

+(BOOL) isPoint:(YLocation *)point inPolygon:(NSArray *)edges {
    int    cn = 0;    // the  crossing number counter
    
    // loop through all edges of the polygon
    long n = edges.count - 1;
    
    for (int i=0; i<n; i++) {    // edge from V[i]  to V[i+1]
        YLocation *edgei = [edges objectAtIndex:i];
        YLocation *edgeiplus1 = [edges objectAtIndex:i + 1];
        
        if (((edgei.latitude <= point.latitude) && (edgeiplus1.latitude > point.latitude))     // an upward crossing
            || ((edgei.latitude > point.latitude) && (edgeiplus1.latitude <=  point.latitude))) { // a downward crossing
            // compute  the actual edge-ray intersect x-coordinate
            double vt = (double)(point.latitude  - edgei.latitude) / (edgeiplus1.latitude - edgei.latitude);
            
            if (point.longitude <  edgei.longitude + vt * (edgeiplus1.longitude - edgei.longitude)) { // P.x < intersect
                ++cn;   // a valid crossing of y=P.y right of P.x
            }
        }
    }
    
    return (cn&1);    // 0 if even (out), and 1 if  odd (in)
}

+(BOOL) isDevice:(YLocation *)ptDevice inBBOXFromPOICurrent:(RouteLocation *)poiFrom toPOINext:(RouteLocation *)poiTo {
    // p0 ------ p1
    // |          |
    // p3 ------ p2
    YLocation *p0 = [YLocation initWithLatitude:poiFrom.latitude latMetersOffset:+ROUTE_BBOX_METERS_OFFSET
                                   andLongitude:poiFrom.longtitude longMetersOffset:0]; // p0
    YLocation *p1 = [YLocation initWithLatitude:poiTo.latitude latMetersOffset:-ROUTE_BBOX_METERS_OFFSET
                                   andLongitude:poiTo.longtitude longMetersOffset:+ROUTE_BBOX_METERS_OFFSET]; // p1
    YLocation *p2 = [YLocation initWithLatitude:poiTo.latitude latMetersOffset:+ROUTE_BBOX_METERS_OFFSET
                                   andLongitude:poiTo.longtitude longMetersOffset:+ROUTE_BBOX_METERS_OFFSET]; // p2
    YLocation *p3 = [YLocation initWithLatitude:poiFrom.latitude latMetersOffset:+ROUTE_BBOX_METERS_OFFSET
                                   andLongitude:poiFrom.longtitude longMetersOffset:-ROUTE_BBOX_METERS_OFFSET]; // p3
    
    NSArray *arrPolygon = [NSArray arrayWithObjects:p0, p1, p2, p3, p0, nil];
    
    NSLog(@"ROUTE ------> checking point:(Lat:%lf long:%lf) in polygon:\n" \
      @"\ttl (Lat:%lf long:%lf)\n" \
      @"\ttr (Lat:%lf long:%lf)\n" \
      @"\tbr (Lat:%lf long:%lf)\n" \
      @"\tbl (Lat:%lf long:%lf)\n" \
      @"\ttl (Lat:%lf long:%lf)\n",
      ptDevice.latitude, ptDevice.longitude,
      p0.latitude, p0.longitude,
      p1.latitude, p1.longitude,
      p2.latitude, p2.longitude,
      p3.latitude, p3.longitude,
      p0.latitude, p0.longitude);
    
    return [self isPoint:ptDevice inPolygon:arrPolygon];
}

typedef struct  {
    double x;
    double y;
}CGPoint2;

+(double) distanceToPoint:(CGPoint2)p fromLineSegmentBetween:(CGPoint2)l1 and:(CGPoint2)l2
{
    double A = p.x - l1.x;
    double B = p.y - l1.y;
    double C = l2.x - l1.x;
    double D = l2.y - l1.y;
    
    double dot = A * C + B * D;
    double len_sq = C * C + D * D;
    double param = dot / len_sq;
    
    double xx, yy;
    
    if (param < 0 || (l1.x == l2.x && l1.y == l2.y)) {
        xx = l1.x;
        yy = l1.y;
    }
    else if (param > 1) {
        xx = l2.x;
        yy = l2.y;
    }
    else {
        xx = l1.x + param * C;
        yy = l1.y + param * D;
    }
    
    double dx = p.x - xx;
    double dy = p.y - yy;
    
    return sqrt(dx * dx + dy * dy);
}

+(double) distanceToPoint1:(CGPoint2)p fromLineSegmentBetween:(CGPoint2)l1 and:(CGPoint2)l2
{
    double A = p.x - l1.x;
    double B = p.y - l1.y;
    double C = l2.x - l1.x;
    double D = l2.y - l1.y;
    
    double dot = A * C + B * D;
    double len_sq = C * C + D * D;
    double param = dot / len_sq;
    
    double xx, yy;
    
    if (param < 0 || (l1.x == l2.x && l1.y == l2.y)) {
        xx = l1.x;
        yy = l1.y;
    }
    else if (param > 1) {
        xx = l2.x;
        yy = l2.y;
    }
    else {
        xx = l1.x + param * C;
        yy = l1.y + param * D;
    }
    
    MKMapPoint pp;
    pp.x = p.x;
    pp.y = p.y;
    return MKMetersBetweenMapPoints(pp, MKMapPointMake(xx, yy));
}

typedef struct {
    CGPoint2 corner1;
    CGPoint2 corner2;
}BoundingBox;

+(BoundingBox) findBoundingBoxForGivenLocations:(NSArray *)coordinates
{
    double west = 0.0;
    double east = 0.0;
    double north = 0.0;
    double south = 0.0;
    
    for (int lc = 0; lc < coordinates.count; lc++) {
        YLocation *loc = [coordinates objectAtIndex:lc];
        if (lc == 0) {
            north = loc.latitude;
            south = loc.latitude;
            west = loc.longitude;
            east = loc.longitude;
        }
        else {
            if (loc.latitude > north) {
                north = loc.latitude;
            }
            else if (loc.latitude < south) {
                south = loc.latitude;
            }
            if (loc.longitude < west) {
                west = loc.longitude;
            }
            else if (loc.longitude > east) {
                east = loc.longitude;
            }
        }
    }
    
    // OPTIONAL - Add some extra "padding" for better map display
    double padding = 0.01;
    north = north + padding;
    south = south - padding;
    west = west - padding;
    east = east + padding;
    
    BoundingBox ret;
    ret.corner1.y = south;
    ret.corner1.x = west;
    
    ret.corner2.y = north;
    ret.corner2.x = east;
    return ret;
}

typedef struct {
    CGPoint2 topLeft;
    CGPoint2 topRight;
    CGPoint2 bottomRight;
    CGPoint2 bottomLeft;
}GeoRect;

+(/*GeoRect*/CGRect) computeBounds:(CGPoint2)p1 andPoint:(CGPoint2)p2 {
    double dx = p2.x - p1.x;
    double dy = p2.y - p1.y;
    
    double x =  (dx < 0 ? p2.x : p1.x);
    double y =  (dy < 0 ? p2.y : p1.y);
    double w =  fabs(dx);
    double h =  fabs(dy);
    
    /*
    GeoRect gr;
    gr.topLeft.x = x;
    gr.topLeft.y = y;
    gr.topRight.x = x + w;
    gr.topRight.y = y;
    gr.bottomRight.x = x + w;
    gr.bottomRight.y = y + h;
    gr.bottomLeft.x = x;
    gr.bottomLeft.y = y + h;
    */
    
    int offsetMeters = 20;
    return CGRectMake((int)x - offsetMeters, (int)y - offsetMeters, (int)w + offsetMeters*2, (int)h + offsetMeters*2);
}

// project into a plane
+(CGPoint2) mercator:(YLocation *)P {
    double radius = 6378137.;
    double max = 85.0511287798;
    double radians = M_PI / 180.;
    
    CGPoint2 point;
    
    point.x = radius * P.longitude * radians;
    point.y = MAX(MIN(max, P.latitude), -max) * radians;
    point.y = radius * log(tan((M_PI / 4.) + (point.y / 2.)));
    
    return point;
}

/* sinosodial projection
 (x1, y1) = (lon1 * cos(lat1), lat1) and
 
 (x2, y2) = (lon2 * cos(lat2), lat2)
*/
//http://gis.stackexchange.com/questions/4139/quick-way-to-determine-if-facing-a-given-lat-lon-pair-with-a-heading

+(float) bearingBetweenStartLocation:(YLocation *)startLocation andEndLocation:(YLocation *)endLocation{
    CLLocation *northPoint = [[CLLocation alloc] initWithLatitude:(startLocation.coordinate.latitude)+.01 longitude:endLocation.coordinate.longitude];
    float magA = [northPoint distanceFromLocation:startLocation];
    float magB = [endLocation distanceFromLocation:startLocation];
    CLLocation *startLat = [[CLLocation alloc] initWithLatitude:startLocation.coordinate.latitude longitude:0];
    CLLocation *endLat = [[CLLocation alloc] initWithLatitude:endLocation.coordinate.latitude longitude:0];
    float aDotB = magA*[endLat distanceFromLocation:startLat];
    float retDeg = acosf(aDotB/(magA*magB));
    
    return retDeg;
}

+(float) bearingBetweenStartLocation2:(YLocation *)startLocation andEndLocation:(YLocation *)endLocation{
    /*
     Δφ = ln( tan( latB / 2 + π / 4 ) / tan( latA / 2 + π / 4) )
     Δlon = abs( lonA - lonB )
     bearing :  θ = atan2( Δlon ,  Δφ )
     
     Note: 1) ln = natural log      2) if Δlon > 180°  then   Δlon = Δlon (mod 180).
     */
    
    float deltaPhi = log( tan(degreesToRadians(endLocation.latitude/2) + M_PI_4) / tan(degreesToRadians(startLocation.latitude/2) + M_PI_4) );
    float deltaLong = fabs(startLocation.longitude - endLocation.longitude);
    
    if (deltaLong > 180) {
        deltaLong = fmod(deltaLong, 180.f);
    }
    
    float bearing = atan2(deltaLong, deltaPhi);
    return radiandsToDegrees(bearing);
}

+(float) bearingBetweenStartLocation3:(YLocation *)startLocation andEndLocation:(YLocation *)endLocation{
    float lat1 = degreesToRadians(startLocation.latitude);
    float lat2 = degreesToRadians(endLocation.latitude);
    float long1 = degreesToRadians(endLocation.longitude);
    float long2 = degreesToRadians(startLocation.longitude);
    float dLon = long1 - long2;

    float y = sin(dLon) * cos(lat2);
    float x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    int bearingDeg = (int)(radiandsToDegrees(atan2(y, x)) + 0.5f);
    int ret = (bearingDeg + 360) % 360;
    return ret;
}

@end

int pnpoly(int nvert, double *vertx, double *verty, double testx, double testy)
{
    int i, j, c = 0;
    
    for (i = 0, j = nvert-1; i < nvert; j = i++) {
        if ( ((verty[i]>testy) != (verty[j]>testy)) &&
            (testx < (vertx[j]-vertx[i]) * (testy-verty[i]) / (verty[j]-verty[i]) + vertx[i]) )
            c = !c;
    }
    
    return c;
}

double get_perp(double X1, double Y1, double X2, double Y2, double meX, double meY) {
    double XX = X2 - X1;
    double YY = Y2 - Y1;
    double ShortestLength = ((XX * (meX - X1)) + (YY * (meY - Y1))) / ((XX * XX) + (YY * YY));
    return ShortestLength;
}


int main(int argc, char * argv[])
{
    /*
    @autoreleasepool {
        YLocation *currentLocation = [YLocation initWithLatitude:32.064525604248047 andLongitude:34.774215698242188]; //  [LocationService sharedService].currentLocation;
        //RouteLocation *toRouteLocation = [[RouteLocation alloc] initWithLong:34.774709 lat:32.064841 title:@"" direction:@"" andDuration:0]; // ahad ahhm ben zakai crossing
        //RouteLocation *toRouteLocation = [[RouteLocation alloc] initWithLong:34.774309 lat:32.065793 title:@"" direction:@"" andDuration:0];   // ben zakai nontifiori crossing
        RouteLocation *toRouteLocation = [[RouteLocation alloc] initWithLong:34.7722057 lat:32.0653684 	title:@"" direction:@"" andDuration:0];   // montifiori alenby crossing
        
        
        
        float bearingDeg = [TestClass bearingBetweenStartLocation:currentLocation
                                              andEndLocation:[YLocation initWithLatitude:toRouteLocation.latitude andLongitude:toRouteLocation.longtitude]];
        
        float bearingDeg1 = [TestClass bearingBetweenStartLocation2:currentLocation
                                                andEndLocation:[YLocation initWithLatitude:toRouteLocation.latitude andLongitude:toRouteLocation.longtitude]];
        
        float bearingDeg2 = [TestClass bearingBetweenStartLocation3:currentLocation
                                                     andEndLocation:[YLocation initWithLatitude:toRouteLocation.latitude andLongitude:toRouteLocation.longtitude]];
        
        int k = 0;
        ++k;
        
    }
    */
    
    /*
    @autoreleasepool {
     
        YLocation *ptMe = [YLocation initWithLatitude:32.066229957642065 andLongitude:34.773693582421117];  // far
        //YLocation *ptMe = [YLocation initWithLatitude:32.065784454345703 andLongitude:34.774063110351563];
        CGPoint2 ptMeProjected = [TestClass mercator:ptMe];
        
        RouteLocation *rl0 = [[RouteLocation alloc] initWithLong:34.774223600000006 lat:32.065780800000006 title:@"" direction:@"" andDuration:0];
        RouteLocation *rl1 = [[RouteLocation alloc] initWithLong:34.772205700000008 lat:32.065368399999997 title:@"" direction:@"" andDuration:0];
        CGPoint2 rl0Projected = [TestClass mercator:[YLocation initWithLatitude:rl0.latitude andLongitude:rl0.longtitude]];
        CGPoint2 rl1Projected = [TestClass mercator:[YLocation initWithLatitude:rl1.latitude andLongitude:rl1.longtitude]];
        
        CGRect rcBBBBB = [TestClass computeBounds:rl0Projected andPoint:rl1Projected];
        BOOL bBBBB = CGRectContainsPoint(rcBBBBB, CGPointMake(ptMeProjected.x, ptMeProjected.y));
        
        
        BoundingBox bb = [TestClass findBoundingBoxForGivenLocations:[NSArray arrayWithObjects:[YLocation initWithLatitude:rl0.latitude andLongitude:rl0.longtitude],
                                                     [YLocation initWithLatitude:rl1.latitude andLongitude:rl1.longtitude],
                                                      nil]];
        //GeoRect rcBB = [TestClass computeBounds:bb.corner1 andPoint:bb.corner2];
        
        
        
        double dddd = [TestClass distanceToPoint1:ptMeProjected fromLineSegmentBetween:rl0Projected and:rl1Projected];
        
        
        double distance = get_perp(rl0Projected.x, rl0Projected.y, rl1Projected.x, rl1Projected.y, ptMeProjected.x, ptMeProjected.y);
        
        
        GTBoundingBox *bbox = [[GTBoundingBox alloc] init];
        
        CLLocationCoordinate2D strl0;
        strl0.latitude = rl0.latitude;
        strl0.longitude = rl0.longtitude;
        
        CLLocationCoordinate2D strl1;
        strl1.latitude = rl1.latitude;
        strl1.longitude = rl1.longtitude;

        [bbox expandToIncludeCoordinate:strl0];
        [bbox expandToIncludeCoordinate:strl1];
        
        CLLocationCoordinate2D strme;
        strme.latitude = ptMe.latitude;
        strme.longitude = ptMe.longitude;

        
        BOOL coordinateInRegion = [bbox containsCoordinate:strme];
    
        
        
        
        if ([TestClass isDevice:ptMe inBBOXFromPOICurrent:rl0 toPOINext:rl1]) {
            int k = 0;
            ++k;
        }
     
        
        
        
        YLocation *rl00 = [YLocation initWithLatitude:32.065780800000006f andLongitude:34.774223600000006f];
        YLocation *rl11 = [YLocation initWithLatitude:32.065368399999997f andLongitude:34.772205700000008f];
        
        YLocation *p00 = [YLocation initWithLatitude:rl00.latitude latMetersOffset:-ROUTE_BBOX_METERS_OFFSET
                                       andLongitude:rl00.longitude longMetersOffset:-ROUTE_BBOX_METERS_OFFSET]; // p0
        YLocation *p11 = [YLocation initWithLatitude:rl11.latitude latMetersOffset:-ROUTE_BBOX_METERS_OFFSET
                                       andLongitude:rl11.longitude longMetersOffset:+ROUTE_BBOX_METERS_OFFSET]; // p1
        YLocation *p22 = [YLocation initWithLatitude:rl11.latitude latMetersOffset:+ROUTE_BBOX_METERS_OFFSET
                                       andLongitude:rl11.longitude longMetersOffset:+ROUTE_BBOX_METERS_OFFSET]; // p2
        YLocation *p33 = [YLocation initWithLatitude:rl00.latitude latMetersOffset:+ROUTE_BBOX_METERS_OFFSET
                                       andLongitude:rl00.longitude longMetersOffset:-ROUTE_BBOX_METERS_OFFSET]; // p3
        
        NSArray *arrPolygonn = [NSArray arrayWithObjects:p00, p11, p22, p33, p00, nil];
        BOOL b = [TestClass isPoint:ptMe inPolygon:arrPolygonn];
        
        
        double arrx[5];
        arrx[0] = p00.longitude;
        arrx[1] = p11.longitude;
        arrx[2] = p22.longitude;
        arrx[3] = p33.longitude;
        arrx[4] = p00.longitude;
        
        double arry[5];
        arry[0] = p00.latitude;
        arry[1] = p11.latitude;
        arry[2] = p22.latitude;
        arry[3] = p33.latitude;
        arry[4] = p00.latitude;
        
        int cn = pnpoly(4, arrx, arry, ptMe.longitude, ptMe.latitude);
        
        return 0;
    }
    */
    
    @autoreleasepool {
        int retVal;
        @try {
            retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        }
        @catch (NSException *exception) {
            NSLog(@"Gosh!!! %@", [exception callStackSymbols]);
            NSString *model = [[UIDevice currentDevice] model];
            NSString *version = [[UIDevice currentDevice] systemVersion];
            NSArray *backtrace = [exception callStackSymbols];
            NSString *descr = [NSString stringWithFormat:@"%@.%@.%@.Backtrace:%@",model,version,exception.description,backtrace];
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createExceptionWithDescription:descr
                                                                      withFatal:[NSNumber numberWithBool:YES]] build]];
            @throw;
        }

        return retVal;
    }
    
}

