//
//  ServerResponse.h
//  YAPP
//
//  Created by yapQ Ltd on 11/21/13.
//  Copyright (c) 2013 yapQ Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Place.h"
#import "SBJson.h"
#import "PlaceFactoryUtils.h"

/*******************************************************************************************************************/
@interface IsRoute : NSObject {
}

@property (strong, nonatomic) NSMutableArray *photos; // sorted
@property (nonatomic, assign) NSInteger routeId;
@property (nonatomic, assign) NSInteger duration;
@property (nonatomic, assign) BOOL isFilled;
@property (nonatomic, assign) double latCompass;
@property (nonatomic, assign) double longCompass;
@property (nonatomic, assign) NSInteger numMustSeePlaces;

-(void) clearRoute;

@end

/*******************************************************************************************************************/
@interface RouteLocation : NSObject {
}

-(id) initWithLong:(double)longtitude lat:(double)latitude title:(NSString *)title
         direction:(NSString *)direction duration:(NSInteger)duration andIsPoi:(BOOL)isPoi;

@property (readonly, nonatomic) double longtitude;
@property (readonly, nonatomic) double latitude;
@property (readonly, nonatomic) NSString *title;
@property (readonly, nonatomic) NSString *direction;
@property (readonly, nonatomic) NSInteger duration;
@property (assign, nonatomic) BOOL invalid;
@property (assign, nonatomic) BOOL endReached;
@property (assign, nonatomic) BOOL detectAfter;
@property (assign, nonatomic) BOOL isPoi;

@end

/*******************************************************************************************************************/
@interface GetRoute : NSObject {
    // on GO it is pointing to first POI
    int headingToRouteIndex;
}

-(id) init;
-(BOOL) isMeInRouteLat:(double)meLat andLong:(double)meLong retToLoc:(RouteLocation **)retToLoc retToLocDistanceKm:(double *)retToLocDistanceKm retIsNewWaypoint:(BOOL *)retIsNewWaypoint;

@property (strong, nonatomic) NSMutableArray *locations;
@property (assign, nonatomic, readonly) NSInteger current;

@end

/*******************************************************************************************************************/
@interface ServerResponse : NSObject {
    long currentIndex;
}

@property (strong, atomic) NSMutableArray *places;

@property (strong, atomic) IsRoute *isRoute;

@property (strong, atomic) GetRoute *getRoute;

@property (strong, atomic) NSNumber *searchId;

+(ServerResponse *)sharedResponse;
//-(void)initData:(NSString *)json; // old places API call
-(void)initUnifiedData:(NSString *)json; // new places API call
-(void)initUnifiedRouteData:(NSString *)json; // getRoute API call

-(BOOL)hasMore;
-(Place *)getNext;

-(NSArray *)getCopyOfRefereceData;

-(RouteLocation *)getRouteLocationWithLat:(double)lat andLong:(double)lng;

@end
