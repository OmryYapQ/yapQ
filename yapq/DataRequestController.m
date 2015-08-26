//
//  DataRequestController.m
//  yapq
//
//  Created by yapQ Ltd.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import "DataRequestController.h"

@interface DataRequestController(Private)

+(void)CoreDataRequestWithLocation:(YLocation *)location
             andWithCompletionBlock:(void(^)(enum WebServiceRequestStatus status,NSDictionary *info))completionBLock;
@end

@implementation DataRequestController

+(void)requestDataWithLocation:(YLocation *)location
            andCompletionBlock:(void(^)(enum WebServiceRequestStatus status,NSDictionary *info))completionBLock {

    Reachability *networkStatus = [Reachability reachabilityForInternetConnection];
    if ([[Settings sharedSettings] is3GEnabled] == NO && [networkStatus currentReachabilityStatus] != ReachableViaWiFi) {
        // no connectivity load from local store !
        [self CoreDataRequestWithLocation:location andWithCompletionBlock:^(enum WebServiceRequestStatus status, NSDictionary *info) {
            completionBLock(WS_OK,nil);
        }];
        return;
    }
    
    // try to call the server
    if ([ServerResponse sharedResponse].searchId == NULL) {
        // not in search mode
        [WebServices loadPlacesWithLocation:location completion:^(enum WebServiceRequestStatus status) {
            if (status == WS_OK) {
                completionBLock(WS_OK,nil);
            }
            else if (status == WS_ERROR){
                [self CoreDataRequestWithLocation:location andWithCompletionBlock:^(enum WebServiceRequestStatus status, NSDictionary *info) {
                    completionBLock(WS_OK,nil);
                }];
            }
        }];
    }
    else {
        // in search mode
        [WebServices loadPlacesWithMustSeeId:[ServerResponse sharedResponse].searchId andLocation:location completion:^(enum WebServiceRequestStatus status) {
            if (status == WS_OK) {
                completionBLock(WS_OK,nil);
            }
            else if (status == WS_ERROR){
                // call server error -> fetch from local core data store
                [self CoreDataRequestWithLocation:location andWithCompletionBlock:^(enum WebServiceRequestStatus status, NSDictionary *info) {
                    completionBLock(WS_OK,nil);
                }];
            }
        }];
    }
}

+(void)CoreDataRequestWithLocation:(YLocation *)location
            andWithCompletionBlock:(void(^)(enum WebServiceRequestStatus status,NSDictionary *info))completionBLock {
    // load places from local core data store
    
    //YLocation *l = [YLocation initWithLatitude:31.789480 andLongitude:35.202689];
    NSArray *places = [DBCoreDataHelper placesForLocation:location fromRadius:200 toRadius:2500 withMaxRequestRows:7];
    [ServerResponse sharedResponse].places = [places mutableCopy];
    //NSLog(@"%@",places);
    completionBLock(WS_OK,nil);
}

+(void)requestRouteWithRouteId:(NSInteger)routeId locationStart:(YLocation *)locationStart
            andCompletionBlock:(void(^)(enum WebServiceRequestStatus status,NSDictionary *info))completionBLock {
    Reachability *networkStatus = [Reachability reachabilityForInternetConnection];
    if ([[Settings sharedSettings] is3GEnabled] == NO && [networkStatus currentReachabilityStatus] != ReachableViaWiFi) {
        // no connectivity: what to do TBD  !
        completionBLock(WS_NOCONNECTIVITY,nil);
        return;
    }
    
    // try to call the server
    [WebServices getRouteWithRouteId:routeId locationStart:locationStart completion:^(enum WebServiceRequestStatus status) {
        if (status == WS_OK) {
            completionBLock(WS_OK,nil);
        }
        else if (status == WS_ERROR){
            completionBLock(WS_ERROR,nil);
        }
    }];
}

@end
