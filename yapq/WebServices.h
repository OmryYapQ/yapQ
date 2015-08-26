//
//  RestWeb.h
//  YAPP
//
//  Created by yapQ Ltd on 11/21/13.
//  Copyright (c) 2013 yapQ Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utilities.h"
#import "Constants.h"
#import "ServerResponse.h"
#import "Settings.h"
#import "YLocation.h"
#import "Reachability.h"
#import "Package.h"

NS_ENUM(NSInteger, WebServiceRequestStatus) {
    WS_OK,WS_ERROR,WS_NOCONNECTIVITY
};

@interface WebServices : NSObject

+(void)getRouteWithRouteId:(NSInteger)routeId locationStart:(YLocation *)locationStart completion:(void(^)(enum WebServiceRequestStatus status))completionBlock;

+(void)loadPlacesWithLocation:(YLocation *)location completion:(void(^)(enum WebServiceRequestStatus status))completionBlock;

+(void)loadPlacesWithMustSeeId:(NSNumber *)mustSeeId andLocation:(YLocation *)location completion:(void(^)(enum WebServiceRequestStatus status))completionBlock;

+(void)reportProblemBlocking:(Place *)place withCompletionBlock:(void(^)(enum WebServiceRequestStatus status))completionBlock;

+(void)loadListOfPackagesWithSearchQuery:(NSString *)searchText withCompletionBlock:(void(^)(enum WebServiceRequestStatus status))completionBlock;

+(void)getOfflinePackageLink:(NSInteger)packageId withUserHash:(NSString *)hash andCompletionBlock:(void(^)(enum WebServiceRequestStatus status, NSDictionary *responseDictionary))completionBlock;

+(void)varifyPurchaseWithPackage:(Package *)package
                    purchaseCode:(NSString *)code
                       userToken:(NSString *)userToken
              andCompletionBlock:(void(^)(enum WebServiceRequestStatus status, NSDictionary *responseDictionary))completionBlock;

+(void)createAccountFacebookUid:(NSString *)fid orGoogleUid:(NSString *)gid sessionToken:(NSString *)token andCompletionBlock:(void(^)(enum WebServiceRequestStatus status, NSString *accountToken))completionBlock;

+(void)syncPurchasesWithServer;

//+(void)syncPurchasesWithToken:(NSString *)token packageIds:(NSString *)packageIds andKey:(NSString *)key;

+(void)getAllPurchasedPackagesWithUserToken:(NSString *)userToken andCompletionBlock:(void(^)(enum WebServiceRequestStatus status, NSString *json))completionBlock;

+(void)registreForPushNOtificationWithToken:(NSString *)token andCompletionBlock:(void(^)(enum WebServiceRequestStatus status, NSString *appVersion))completionBlock;

+(void)isInMiniIsraelBlocking:(double)lat lon:(double)lon completion:(void(^)(enum WebServiceRequestStatus status,BOOL isInside))completionBlock;

@end
