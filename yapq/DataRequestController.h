//
//  DataRequestController.h
//  yapq
//
//  Created by yapQ Ltd.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebServices.h"
#import "Settings.h"
#import "YLocation.h"
#import "DBCoreDataHelper.h"
#import "Utilities.h"

@interface DataRequestController : NSObject

+(void)requestDataWithLocation:(YLocation *)location
            andCompletionBlock:(void(^)(enum WebServiceRequestStatus status,NSDictionary *info))completionBLock;

+(void)requestRouteWithRouteId:(NSInteger)routeId locationStart:(YLocation *)locationStart
            andCompletionBlock:(void(^)(enum WebServiceRequestStatus status,NSDictionary *info))completionBLock;

@end
