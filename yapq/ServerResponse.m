//
//  ServerResponse.m
//  YAPP
//
//  Created by yapQ Ltd 
//  Copyright (c) 2013 yapQ Ltd. All rights reserved.
//

#import "ServerResponse.h"
#import "Utilities.h"
#import "LocationSevice.h"

// unified data cell types
#define DATA_TYPE_PLACE_ONE_CELL                0
#define DATA_TYPE_SETTINGS_CELLS                1
#define DATA_TYPE_OFFLINE_CELLS                 2
#define DATA_TYPE_NAV                           3
#define DATA_TYPE_PLACE_SWIPE_CELLS             4

#define ROUTE_BBOX_METERS_OFFSET                50
#define DIST_FROM_POI_METERS                    15


@implementation RouteLocation

-(id) initWithLong:(double)longtitude lat:(double)latitude title:(NSString *)title
         direction:(NSString *)direction duration:(NSInteger)duration andIsPoi:(BOOL)isPoi {
    self = [super init];
    if (self != nil) {
        _latitude = latitude;
        _longtitude = longtitude;
        _title = title;
        _direction = direction;
        _duration = duration;
        _isPoi = isPoi;
    }
    
    return self;
}

@end
/*******************************************************************************************************************/
@implementation GetRoute
-(id) init {
    self = [super init];
    if (self) {
        self.locations = [[NSMutableArray alloc] init];
        
        // initial GO state, current route is from point device to first POI
        headingToRouteIndex = 0;
    }
    
    return self;
}

-(BOOL) isPoint:(YLocation *)point inPolygon:(NSArray *)edges {
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
    
    return ((cn&1) == 1);    // 0 if even (out), and 1 if  odd (in)
}

-(BOOL) isMeInRouteLat:(double)meLat andLong:(double)meLong retToLoc:(RouteLocation **)retToLoc retToLocDistanceKm:(double *)retToLocDistanceKm retIsNewWaypoint:(BOOL *)retIsNewWaypoint {
    *retToLoc = NULL;
    *retToLocDistanceKm = 0;
    *retIsNewWaypoint = FALSE;
    
    BOOL routeEndReached = NO;
    
    if (self.locations > 0) {
        RouteLocation *POI_To = [self.locations objectAtIndex:headingToRouteIndex];
        
        if (POI_To.endReached) {
            // end reached -> don't do anything
            *retToLoc = POI_To;
        }
        else {
            YLocation *ptMe = [YLocation initWithLatitude:meLat andLongitude:meLong];
            double distPOIToMeters = [ptMe distanceToLocationFromLocationWithCenter:[YLocation initWithLatitude:POI_To.latitude andLongitude:POI_To.longtitude]];
            
            BOOL deviceIn2SequentialPOIsBBox = NO;
            
            if (headingToRouteIndex == 0) {
                // we are at the start of the route -> let's check that we are not far away from the starting POI
                if (distPOIToMeters > 300) {
                    deviceIn2SequentialPOIsBBox = NO;
                }
                else {
                    deviceIn2SequentialPOIsBBox = YES;
                }
            }
            else {
                if (YES == [self isRouteEndReached:headingToRouteIndex + 1]) {
                    RouteLocation *POI_From = [self.locations objectAtIndex:headingToRouteIndex - 1];
                    if ([self isDevice:ptMe inBBOXFromPOICurrent:POI_From toPOINext:POI_To]) {
                        deviceIn2SequentialPOIsBBox = YES;
                    }
                }
                else {
                    RouteLocation *POI_ToTo = [self.locations objectAtIndex:headingToRouteIndex + 1];
                    if (YES == POI_ToTo.detectAfter) {
                        if ([self isDevice:ptMe inBBOXFromPOICurrent:POI_To toPOINext:POI_ToTo]) {
                            deviceIn2SequentialPOIsBBox = YES;
                        }
                    }
                    else {
                        RouteLocation *POI_From = [self.locations objectAtIndex:headingToRouteIndex - 1];
                        if ([self isDevice:ptMe inBBOXFromPOICurrent:POI_From toPOINext:POI_To]) {
                            deviceIn2SequentialPOIsBBox = YES;
                        }

                    }
                }
            }
            
            if (YES == deviceIn2SequentialPOIsBBox) {
                // device is in bounding box of the heading to POI and the heading from POI or the device is heading to the first POI
                POI_To.invalid = NO;
                
                // are we after the heading to POI ?
                if ([self isDevice:ptMe afterPOIZone:POI_To andDistance:distPOIToMeters]) {
                    if ([self isRouteEndReached:headingToRouteIndex + 1]) {
                        // we have reached the route end
                        *retToLoc = POI_To;
                        POI_To.endReached = YES;
                    }
                    else {
                        // set the new heading to POI and return it
                        ++headingToRouteIndex;
                        *retIsNewWaypoint = YES;
                        POI_To = [self.locations objectAtIndex:headingToRouteIndex];
                        distPOIToMeters = [ptMe distanceToLocationFromLocationWithCenter:[YLocation initWithLatitude:POI_To.latitude andLongitude:POI_To.longtitude]];
                        *retToLoc = POI_To;
                        *retToLocDistanceKm = distPOIToMeters/1000.0f;
                    }
                }
                else {
                    // we are on our wat to the heading to POI
                    *retToLoc = POI_To;
                    *retToLocDistanceKm = distPOIToMeters/1000.0f;
                }
            }
            else {
                // device is not in BBox
                POI_To.invalid = YES;
                *retToLoc = POI_To;
                *retToLocDistanceKm = distPOIToMeters/1000.0f;
            }
        }
    }
    
    /*
    if (*retToLoc != NULL) {
        if ((*retToLoc).detectAfter) {
            // we are in a minimum distance before the POI, show the next POI text but don't switch to it yet !
            if (NO == [self isRouteEndReached:headingToRouteIndex]) {
                *retToLoc = [self.locations objectAtIndex:headingToRouteIndex + 1];
            }
        }
    }
    */
    
    return routeEndReached;
}

-(BOOL) isDevice:(YLocation *)ptDevice afterPOIZone:(RouteLocation *)poi andDistance:(double)distFromPOI  {
    BOOL afterPOI = NO;
    
    if (headingToRouteIndex == 0) {
        if (distFromPOI < DIST_FROM_POI_METERS) {
            // started the route, POI0 is pointing to POI1 and nothing points to POI0
            afterPOI = YES;
        }
    }
    else {
        if (poi.detectAfter == NO) {
            // detect entrance to POI location
            RouteLocation *fromHeadingToPOI = [self.locations objectAtIndex:headingToRouteIndex - 1];
            
            // project into a plane (mercator prjected points are in meters)
            CGPoint ptPrevPOIProjected = [self mercator:fromHeadingToPOI.latitude andLon:fromHeadingToPOI.longtitude];
            CGPoint ptPOIProjected = [self mercator:poi.latitude andLon:poi.longtitude];
            
            // Optimize !
            double distOfSegment = sqrt(
                                           (ptPrevPOIProjected.x - ptPOIProjected.x) * (ptPrevPOIProjected.x - ptPOIProjected.x) +
                            
                                           (ptPrevPOIProjected.y - ptPOIProjected.y) * (ptPrevPOIProjected.y - ptPOIProjected.y)
                                           );
            
            double cmp = 0.3333*distOfSegment; // 1/3 of the distance
            
            if (distFromPOI < cmp) {
                // traveled 2/3 of the distance to the heading POI
                poi.detectAfter = YES;
                afterPOI = YES;
                return afterPOI; // maybe we don't need to detect the after stage ???
            }
        }
        //else {
        if (poi.detectAfter == YES) {
            // is there a POI after this one ?
            if (YES == [self isRouteEndReached:headingToRouteIndex + 1]) {
                afterPOI = YES;
            }
            else {
                // detect that we passed a minimum distance after the POI and go next
                RouteLocation *toHeadingToPOI = [self.locations objectAtIndex:headingToRouteIndex + 1];
                
                // project into a plane (mercator prjected points are in meters)
                CGPoint ptDeviceProjected = [self mercator:ptDevice.latitude andLon:ptDevice.longitude];
                CGPoint ptPOIProjected = [self mercator:poi.latitude andLon:poi.longtitude];
                CGPoint ptNextPOIProjected = [self mercator:toHeadingToPOI.latitude andLon:toHeadingToPOI.longtitude];
                
                //TODO: find a better way
                CGRect rcBBox = [self computeBoundsBetweenPoint:ptPOIProjected andPoint:ptNextPOIProjected withOffset:5];
                if (CGRectContainsPoint(rcBBox, ptDeviceProjected)) {
                    // Optimize !
                    double distOfSegment = sqrt(
                                                   (ptPOIProjected.x - ptNextPOIProjected.x) * (ptPOIProjected.x - ptNextPOIProjected.x) +
                                                   (ptPOIProjected.y - ptNextPOIProjected.y) * (ptPOIProjected.y - ptNextPOIProjected.y)
                                                   );
                    
                    double cmp = 0.6667*distOfSegment; // 2/3 of the distance
                    double distToNextPOIMeters = [ptDevice distanceToLocationFromLocationWithCenter:[YLocation initWithLatitude:toHeadingToPOI.latitude andLongitude:toHeadingToPOI.longtitude]];
                    
                    if (distToNextPOIMeters < cmp) {
                        // traveled 1/3 of the distance to the next heading POI ->
                        afterPOI = YES;
                    }

                    //poi.detectAfter = YES;
                }
            }
        }
    }
    
    return afterPOI;
}

-(BOOL) isRouteEndReached:(int)index {
    return index >= self.locations.count;
}

// project into a plane
-(CGPoint) mercator:(double)latitude andLon:(double)longitude {
    double radius = 6378137.;
    double max = 85.0511287798;
    double radians = M_PI / 180.;
    
    CGPoint point;
    
    point.x = radius * longitude * radians;
    point.y = MAX(MIN(max, latitude), -max) * radians;
    point.y = radius * log(tan((M_PI / 4.) + (point.y / 2.)));
    
    return point;
}

-(CGRect) computeBoundsBetweenPoint:(CGPoint)p1 andPoint:(CGPoint)p2 withOffset:(int)offset {
    int dx = p2.x - p1.x;
    int dy = p2.y - p1.y;
    
    int x =  (dx < 0 ? p2.x : p1.x);
    int y =  (dy < 0 ? p2.y : p1.y);
    int w =  abs(dx);
    int h =  abs(dy);
    
    return CGRectMake(x - offset,
                      y - offset,
                      w + offset*2,
                      h + offset*2);
}

-(BOOL) isDevice:(YLocation *)ptDevice inBBOXFromPOICurrent:(RouteLocation *)poiFrom toPOINext:(RouteLocation *)poiTo {
    return YES;
    // project the WGS points onto a cartezian plane
    CGPoint ptMeProjected = [self mercator:ptDevice.latitude andLon:ptDevice.longitude];
    CGPoint ptFromProjected = [self mercator:poiFrom.latitude andLon:poiFrom.longtitude];
    CGPoint ptToProjected = [self mercator:poiTo.latitude andLon:poiTo.longtitude];
    
    // compute the bounding recatngle with offset
    CGRect rcBoundingBox = [self computeBoundsBetweenPoint:ptFromProjected andPoint:ptToProjected withOffset:ROUTE_BBOX_METERS_OFFSET];
    
    BOOL ptDeviceInBox = CGRectContainsPoint(rcBoundingBox, ptMeProjected);
    return ptDeviceInBox;
    
    
    // p0 ------ p1
    // |          |
    // p3 ------ p2
    YLocation *p0 = [YLocation initWithLatitude:poiFrom.latitude latMetersOffset:-ROUTE_BBOX_METERS_OFFSET
                                   andLongitude:poiFrom.longtitude longMetersOffset:-ROUTE_BBOX_METERS_OFFSET]; // p0
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
    
    BOOL inPolygon = [self isPoint:ptDevice inPolygon:arrPolygon];
    return inPolygon;
}

-(BOOL) checkTimeToPointIndex:(int)index withDistanceMeters:(double)distanceMeters {
    BOOL ret = NO;
 
    NSLog(@"ROUTE ------> checking index:%d with distance from me:%lf [METERS]", index, distanceMeters);
 
    // if the distance is 0 minutes then skip to the next location
    double durationMinutes = ((distanceMeters / 1000.0f)/3.7f) * 60.0f; // 3.7 km/hour
    
    if (durationMinutes >= 1) {
        NSLog(@"FOUND ROUTE to index:%d duration:%lf [MINUTES]", index, durationMinutes);
    }
 
    return ret;
}

@end

/*******************************************************************************************************************/
@implementation IsRoute

-(void)clearRoute {
    _isFilled = NO;
}

@end

/*******************************************************************************************************************/
@implementation ServerResponse(PRIVATE)

-(Place *)isExist:(NSInteger) newId {
    for (Place *p in [ServerResponse sharedResponse].places) {
        if (p.p_id == newId) {
            return p;
        }
    }
    
    return nil;
}

@end

@implementation ServerResponse

static ServerResponse *instance;

-(id)init {
    if (self = [super init]) {
        currentIndex = -1;
    }
    
    return self;
}

+(ServerResponse *)sharedResponse {
    
    if (!instance) {
        instance = [[ServerResponse alloc] init];
        instance.places = [[NSMutableArray alloc] init];
        instance.isRoute = [[IsRoute alloc] init];
        instance.isRoute.isFilled = NO;
        instance.getRoute = nil; // no active get route
    }
    return instance;
}

-(void)initUnifiedRouteData:(NSString *)json {
    if (json == nil) {
        return;
    }
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    self.getRoute = [[GetRoute alloc] init];
    
    // it is an array with objects
    NSArray *jsonArr = [parser objectWithString:json];
    
    for (int i=0;i<jsonArr.count;i++) {
        /*
         "fromX": 32.0666064,
         "fromY": 34.7750424,
         "title": "Pagoda House",
         "direction": "Head east on Maze St ",
         "mins": 0,
         "icon": "left.png"
         */
        
        NSDictionary *pd = [jsonArr objectAtIndex:i];
        
        //TODO: lat and long are mixed up !!!!
        double longtitude = [[pd objectForKey:@"fromX"] doubleValue];
        double latitude = [[pd objectForKey:@"fromY"] doubleValue];
        NSString *title = [pd objectForKey:@"title"];
        NSString *direction = [pd objectForKey:@"direction"];
        NSInteger duration = [[pd objectForKey:@"mins"] integerValue];
        BOOL isPoi = [[pd objectForKey:@"isPoi"] boolValue];
        
        RouteLocation *rl = [[RouteLocation alloc] initWithLong:longtitude lat:latitude title:title direction:direction duration:duration andIsPoi:isPoi];
        [self.getRoute.locations addObject:rl];
    }
}

-(void)initUnifiedData:(NSString *)json {
    if (json == nil) {
        return;
    }
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    
    // it is an array with objects
    NSArray *jsonArr = [parser objectWithString:json];
    
    for (int i=0;i<jsonArr.count;i++) {
        NSDictionary *pd = [jsonArr objectAtIndex:i];
        
        NSInteger dataType = [[pd objectForKey:@"type"] integerValue];
        switch (dataType) {
            case DATA_TYPE_PLACE_ONE_CELL: {
                continue;
                
                NSArray *arrDataIn = [pd objectForKey:@"data"];
                
                if (arrDataIn != NULL) {
                    /*0L:old implementation
                    if (arrDataIn.count != 1) {
                        continue; // remove when nested cells are in place !
                    }
                    */
                    
                    // remove to support nested cells
                    NSMutableArray *arrDataOut = [[NSMutableArray alloc] initWithCapacity:arrDataIn.count];
                    
                    for (int j = 0;j < arrDataIn.count;++j) {
                        NSDictionary *dataCell = [arrDataIn objectAtIndex:j];
                        Place *place = [PlaceFactoryUtils createPlaceWithJsonDictionary:dataCell];
                        [arrDataOut addObject:place];
                    }
                    
                    [_places addObject:arrDataOut];
                    
                    /*0L:old implementation
                    NSDictionary *dataCell = [arrDataIn objectAtIndex:0];
                    Place *place = [PlaceFactoryUtils createPlaceWithJsonDictionary:dataCell];
                    [_places addObject:place];
                    */
                    
                    // the data is cleared if we are here -> no need to check existance and to update location !

                }
                break;
            }
            case DATA_TYPE_PLACE_SWIPE_CELLS: {
                // remove when nested cells are in place
                //continue;
                
                NSArray *arrDataIn = [pd objectForKey:@"data"];
                if (arrDataIn != NULL && arrDataIn.count == 1) {
                    NSDictionary *dictData = [arrDataIn objectAtIndex:0];
                    
                    SwipePlaceFirstCell *firstCell = [PlaceFactoryUtils createSwipePlaceFirstCellWithJsonDictionary:dictData];
                    NSArray *placeCellsArr = [dictData objectForKey:@"data"];
                    NSMutableArray *arrDataOut = NULL;
                    
                    if (placeCellsArr == NULL) {
                        arrDataOut = [[NSMutableArray alloc] initWithCapacity:1];
                    }
                    else {
                        arrDataOut = [[NSMutableArray alloc] initWithCapacity:placeCellsArr.count + 1];
                    }
                    [arrDataOut addObject:firstCell];
                    
                    for (int j = 0;j < placeCellsArr.count;++j) {
                        NSDictionary *dataCell = [placeCellsArr objectAtIndex:j];
                        Place *place = [PlaceFactoryUtils createPlaceWithJsonDictionary:dataCell];
                        [arrDataOut addObject:place];
                    }
                    
                    [_places addObject:arrDataOut];
                    
                    // the data is cleared if we are here -> no need to check existance
                    /*
                     NSInteger newId = [[dataCell objectForKey:@"id"] integerValue];
                     Place *ep = [self isExist:newId];
                     if (ep == nil) {
                     */
                    
                    /*
                     }
                     else {
                     if ([dataCell valueForKey:@"distance"] != nil) {
                     ep.dist = [[dataCell valueForKey:@"distance"] integerValue];
                     }
                     }
                     */
                }
                break;
            }
            case DATA_TYPE_SETTINGS_CELLS: {
                // remove when nested cells are in place
                //continue;
                
                NSArray *arrDataIn = [pd objectForKey:@"data"];
                if (arrDataIn != NULL) {
                    NSMutableArray *arrDataOut = [[NSMutableArray alloc] initWithCapacity:arrDataIn.count];
                    
                    for (int j = 0;j < arrDataIn.count;++j) {
                        NSDictionary *dataCell = [arrDataIn objectAtIndex:j];
                        SettingsPlace *place = [PlaceFactoryUtils createSettingsPlaceWithJsonDictionary:dataCell];
                        [arrDataOut addObject:place];
                    }
                    
                    [_places addObject:arrDataOut];
                }
                break;
            }
            case DATA_TYPE_OFFLINE_CELLS: {
                // remove when nested cells are in place
                continue;
                
                NSArray *arrDataIn = [pd objectForKey:@"data"];
                if (arrDataIn != NULL) {
                    NSMutableArray *arrDataOut = [[NSMutableArray alloc] initWithCapacity:arrDataIn.count];
                    
                    for (int j = 0;j < arrDataIn.count;++j) {
                        NSDictionary *dataCell = [arrDataIn objectAtIndex:j];
                        OfflinePlace *place = [PlaceFactoryUtils createOfflinePlaceWithJsonDictionary:dataCell];
                        [arrDataOut addObject:place];
                    }
                    
                    [_places addObject:arrDataOut];
                }
                break;
            }
            case DATA_TYPE_NAV: {
                if (self.isRoute.isFilled == NO) { // only if there is no active route !
                    NSArray *arrData = [pd objectForKey:@"data"];
                    if (arrData != NULL && arrData.count > 0) {
                        NSDictionary *dataCell = [arrData objectAtIndex:0];
                        if (NO == [dataCell isEqual:[NSNull null]]) {
                            NSInteger routeId = [[dataCell objectForKey:@"id"] integerValue];
                            self.isRoute.routeId = routeId;
                            
                            NSInteger duration = [[dataCell objectForKey:@"duration"] integerValue];
                            self.isRoute.duration = duration;
                            
                            NSInteger numMustSeePlaces = [[dataCell objectForKey:@"count"] integerValue];
                            self.isRoute.numMustSeePlaces = numMustSeePlaces;
                            
                            double lat = [[dataCell objectForKey:@"sLat"] doubleValue];
                            self.isRoute.latCompass = lat;
                            double lng = [[dataCell objectForKey:@"sLon"] doubleValue];
                            self.isRoute.longCompass = lng;
                            
                            [self.isRoute.photos removeAllObjects];
                            NSDictionary *photos = dataCell[@"photos"];
                            
                            if (photos.count > 0) {
                                self.isRoute.photos = [[NSMutableArray alloc] initWithCapacity:photos.allKeys.count];
                                
                                for (NSString *photoNumber in photos.allKeys) {
                                    NSString *photoUrl = photos[photoNumber];
                                    [self.isRoute.photos addObject:photoUrl];
                                }
                            }
                            else {
                                self.isRoute.photos = [[NSMutableArray alloc] init];
                            }
                            
                            self.isRoute.isFilled = YES;
                        }
                    }
                }
                
                break;
            }
        }
    }

    if (_places.count > 0 && currentIndex < 0) {
        currentIndex = 0;
    }
}

-(BOOL)hasMore {
    if (currentIndex < 0) {
        return NO;
    }
    else if (currentIndex < _places.count) {
        return YES;
    }
    return NO;
}

-(NSArray *)getCopyOfRefereceData {
    currentIndex = _places.count - 1;
    return [_places mutableCopy];
}

-(Place *)getNext {
    Place *p = nil;
    if ([self hasMore]) {
        p = [_places objectAtIndex:currentIndex];
        currentIndex++;
    }
    return p;
}

-(RouteLocation *)getRouteLocationWithLat:(double)lat andLong:(double)lng {
    RouteLocation *ret = NULL;
    
    if (self.getRoute != NULL) {
        if (self.getRoute.current < self.getRoute.locations.count) {
            ret = [self.getRoute.locations objectAtIndex:self.getRoute.current];
        }
    }
    
    return ret;
}

@end
