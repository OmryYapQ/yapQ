//
//  RestWeb.m
//  YAPP
//
//  Created by yapQ Ltd on 11/21/13.
//  Copyright (c) 2013 yapQ Ltd. All rights reserved.
//

#import "WebServices.h"
#import "PackageController.h"


@implementation WebServices

+(void)getRouteWithRouteId:(NSInteger)routeId locationStart:(YLocation *)locationStart completion:(void(^)(enum WebServiceRequestStatus status))completionBlock {
    
    Reachability *networkStatus = [Reachability reachabilityForInternetConnection];
    if ([networkStatus currentReachabilityStatus] == NotReachable) {
        completionBlock(WS_ERROR);
        return;
    }
    @try {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        NSString *url = [NSString stringWithFormat:@"%@routeId=%ld&html=1&l=%@&tToken=%@&latitudeFrom=%f&longitudeFrom=%f&devicetype=%d&version=%@&latitudeStart=%f&longitudeStart=%f",
                         GET_ROUTE_API,
                         (long)routeId,
                         [Settings sharedSettings].speechLanguage,
                         [prefs stringForKey:@"tToken"],
                         [LocationService sharedService].currentLatitude,
                         [LocationService sharedService].currentLongitude, // so the back end will know how far we are from the initial isRoute point
                         0,
                         [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"],
                         locationStart.latitude,
                         locationStart.longitude
                         ];
        /*
        NSString *url = [NSString stringWithFormat:@"%@routeId=%ld&html=1&l=%@&tToken=%@",
                         GET_ROUTE_API,
                         (long)routeId,
                         [Settings sharedSettings].speechLanguage,
                         [prefs stringForKey:@"tToken"]
                         ];
        */
#if DEBUG
        NSLog(@"getRouteWithRouteId:%@",url);
#endif
        NSLog(@"getRouteWithRouteId:%@",url);
        
        NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:
                                           [NSURL URLWithString:
                                            url]];
        [theRequest setTimeoutInterval:90];
        __block NSURLResponse *resp = nil;
        __block NSError *error = nil;
        [Utilities taskInSeparatedThread:^{
            NSData *response = [NSURLConnection sendSynchronousRequest: theRequest returningResponse: &resp error: &error];
            NSString *responseString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];

            NSLog(@"getRouteWithRouteId response:%@",responseString);
#if DEBUG
            NSLog(@"%@",responseString);
#endif
            
            if (error) {
                completionBlock(WS_ERROR);
                id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                [tracker send:[[GAIDictionaryBuilder createExceptionWithDescription:[NSString stringWithFormat:@"c:%li,%@",(long)EC_GET_ROUTE_API, error.description]
                                                                          withFatal:[NSNumber numberWithBool:YES]] build]];
            }
            else {
                [[ServerResponse sharedResponse] initUnifiedRouteData:responseString];
                completionBlock(WS_OK);
            }
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
        completionBlock(WS_ERROR);
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createExceptionWithDescription:[NSString stringWithFormat:@"c:%li,%@",(long)EC_GET_ROUTE_API, exception.description]
                                                                  withFatal:[NSNumber numberWithBool:YES]] build]];
    }

}

+(void)loadPlacesWithLocation:(YLocation *)location completion:(void(^)(enum WebServiceRequestStatus status))completionBlock {

    Reachability *networkStatus = [Reachability reachabilityForInternetConnection];
    if ([networkStatus currentReachabilityStatus] == NotReachable) {
        completionBlock(WS_ERROR);
        return;
    }
    @try {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *url = [NSString stringWithFormat:@"%@latitudeFrom=%f&longitudeFrom=%f&l=%@&tToken=%@&devicetype=%d&version=%@",
                         PLACES_API,
                          location.latitude, location.longitude,
                         [Settings sharedSettings].speechLanguage,
                         [prefs stringForKey:@"tToken"],
                         0,
                         [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"]
                         ];
        //url = @"https://test.yapq.com/api.php?latitudeFrom=32.057793&longitudeFrom=34.762656&l=en&tToken=";
#if DEBUG
        //NSLog(@"%@",url);
#endif
        
        NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:
                                           [NSURL URLWithString:
                                            url]];
        [theRequest setTimeoutInterval:90];
        __block NSURLResponse *resp = nil;
        __block NSError *error = nil;
        [Utilities taskInSeparatedThread:^{
            NSData *response = [NSURLConnection sendSynchronousRequest: theRequest returningResponse: &resp error: &error];
            NSString *responseString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
#if DEBUG
            //NSLog(@"%@",responseString);
#endif
            
            if (error) {
                completionBlock(WS_ERROR);
                id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                [tracker send:[[GAIDictionaryBuilder createExceptionWithDescription:[NSString stringWithFormat:@"c:%li,%@",(long)EC_LOADPLACES_API, error.description]
                                                                          withFatal:[NSNumber numberWithBool:YES]] build]];
            }
            else {
                [[ServerResponse sharedResponse] initUnifiedData:responseString];
                completionBlock(WS_OK);
            }
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
        completionBlock(WS_ERROR);
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createExceptionWithDescription:[NSString stringWithFormat:@"c:%li,%@",(long)EC_LOADPLACES_API, exception.description]
                                                                  withFatal:[NSNumber numberWithBool:YES]] build]];
    }
}

+(void)loadPlacesWithMustSeeId:(NSNumber *)mustSeeId andLocation:(YLocation *)location completion:(void(^)(enum WebServiceRequestStatus status))completionBlock {
    
    Reachability *networkStatus = [Reachability reachabilityForInternetConnection];
    if ([networkStatus currentReachabilityStatus] == NotReachable) {
        completionBlock(WS_ERROR);
        return;
    }
    @try {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *url = [NSString stringWithFormat:@"%@mustSeeId=%d&l=%@&tToken=%@&devicetype=%d&version=%@&latitudeFrom=%f&longitudeFrom=%f",
                         PLACES_API,
                         mustSeeId.intValue,
                         [Settings sharedSettings].speechLanguage,
                         [prefs stringForKey:@"tToken"],
                         0,
                         [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"],
                         location.latitude, location.longitude
                         ];
#if DEBUG
        //NSLog(@"%@",url);
#endif
        
        NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:
                                           [NSURL URLWithString:
                                            url]];
        [theRequest setTimeoutInterval:90];
        __block NSURLResponse *resp = nil;
        __block NSError *error = nil;
        
        [Utilities taskInSeparatedThread:^{
            NSData *response = [NSURLConnection sendSynchronousRequest: theRequest returningResponse: &resp error: &error];
            NSString *responseString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
#if DEBUG
            //NSLog(@"%@",responseString);
#endif
            
            if (error) {
                completionBlock(WS_ERROR);
                id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                [tracker send:[[GAIDictionaryBuilder createExceptionWithDescription:[NSString stringWithFormat:@"c:%li,%@",(long)EC_SEARCHPLACES_API, error.description]
                                                        withFatal:[NSNumber numberWithBool:YES]] build]];
            }
            else {
                [[ServerResponse sharedResponse] initUnifiedData:responseString];
                completionBlock(WS_OK);
            }
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
        completionBlock(WS_ERROR);
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createExceptionWithDescription:[NSString stringWithFormat:@"c:%li,%@",(long)EC_SEARCHPLACES_API, exception.description]
                                                withFatal:[NSNumber numberWithBool:YES]] build]];
    }
}

+(void)reportProblemBlocking:(Place *)place withCompletionBlock:(void(^)(enum WebServiceRequestStatus status))completionBlock {
    
    @try {
        NSString *url = [NSString stringWithFormat:@"%@id=%li",REPORT_API,(long)place.p_id];
#if DEBUG
        NSLog(@"%@",url);
#endif
        
        NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:
                                           [NSURL URLWithString:
                                            url]];
        [theRequest setTimeoutInterval:30];
        __block NSURLResponse *resp = nil;
        __block NSError *error = nil;
        [Utilities taskInSeparatedThread:^{
            NSData *response = [NSURLConnection sendSynchronousRequest: theRequest returningResponse: &resp error: &error];
            NSString *responseString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
#if DEBUG
            NSLog(@"%@",responseString);
#endif
            
            
            completionBlock(WS_OK);
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
        completionBlock(WS_ERROR);
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createExceptionWithDescription:[NSString stringWithFormat:@"c:%li,%@",(long)EC_REPORT_API, exception.description]
                                                                  withFatal:[NSNumber numberWithBool:YES]] build]];
    }
}

+(void)loadListOfPackagesWithSearchQuery:(NSString *)searchText withCompletionBlock:(void(^)(enum WebServiceRequestStatus status))completionBlock {
    @try {
        //תל
        NSString *url = PACKAGE_API;
        if ([LocationService sharedService].currentLocation.latitude != 0 &&
            [LocationService sharedService].currentLocation.longitude != 0) {
            url = [NSString stringWithFormat:@"%@latitudeFrom=%lf&longitudeFrom=%lf&l=%@",url,[LocationService sharedService].currentLocation.latitude,[LocationService sharedService].currentLocation.longitude,[Settings sharedSettings].speechLanguage];
        }
        else {
            url = [NSString stringWithFormat:@"%@l=%@",url,[Settings sharedSettings].speechLanguage];
        }
        if (searchText) {
            url = [NSString stringWithFormat:@"%@&q=%@",url,searchText];
            
        }
#if DEBUG
        NSLog(@"%@",url);
#endif
        NSString *urlEncoded = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *theURL = [NSURL URLWithString:urlEncoded];

        NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL];
        [theRequest setTimeoutInterval:60];
        __block NSURLResponse *resp = nil;
        __block NSError *error = nil;
        [Utilities taskInSeparatedThread:^{
            NSData *response = [NSURLConnection sendSynchronousRequest: theRequest returningResponse: &resp error: &error];
            NSString *responseString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
#if DEBUG
            NSLog(@"%@",responseString);
#endif
            [[PackageController sharedController] loadPackageListFromJsonString:responseString];
            completionBlock(WS_OK);
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
        completionBlock(WS_ERROR);
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createExceptionWithDescription:[NSString stringWithFormat:@"c:%li,%@",(long)EC_PACAKGE_LIST_LOAD_API, exception.description]
                                                                  withFatal:[NSNumber numberWithBool:YES]] build]];
    }
}

+(void)getOfflinePackageLink:(NSInteger)packageId withUserHash:(NSString *)hash andCompletionBlock:(void(^)(enum WebServiceRequestStatus status, NSDictionary *responseDictionary))completionBlock {
    @try {
        //load tToken
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        NSString *url = [NSString stringWithFormat:@"%@pid=%li&hash=%@&l=%@&tToken=%@",OFFLINE_API,(long)packageId,hash,[Settings sharedSettings].speechLanguage, [prefs stringForKey:@"tToken"]];
#if DEBUG
        NSLog(@"%@",url);
#endif
        
        NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:
                                           [NSURL URLWithString:
                                            url]];
        [theRequest setTimeoutInterval:30];
        __block NSURLResponse *resp = nil;
        __block NSError *error = nil;
        [Utilities taskInSeparatedThread:^{
            NSData *response = [NSURLConnection sendSynchronousRequest: theRequest returningResponse: &resp error: &error];
            NSString *responseString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
            SBJsonParser *parser = [[SBJsonParser alloc] init];
            NSArray *array = [parser objectWithString:responseString];
#if DEBUG
            NSLog(@"%@",responseString);
#endif
            if (array.count > 0) {
                completionBlock(WS_OK,array[0]);
            }
            else {
                completionBlock(WS_ERROR,nil);
                id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                [tracker send:[[GAIDictionaryBuilder createExceptionWithDescription:[NSString stringWithFormat:@"c:%i,%@",EC_OFFLINE_PACKAGE_LINK_API, error.description]
                                                                          withFatal:[NSNumber numberWithBool:YES]] build]];
            }
            
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
        completionBlock(WS_ERROR,nil);
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createExceptionWithDescription:[NSString stringWithFormat:@"c:%i,%@",EC_OFFLINE_PACKAGE_LINK_API, exception.description]
                                                                  withFatal:[NSNumber numberWithBool:YES]] build]];
    }
}

+(void)varifyPurchaseWithPackage:(Package *)package
                    purchaseCode:(NSString *)code
                       userToken:(NSString *)userToken
              andCompletionBlock:(void(^)(enum WebServiceRequestStatus status, NSDictionary *responseDictionary))completionBlock {
    @try {

        //load tToken
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        NSString *url = [NSString stringWithFormat:@"%@?tToken=%@",VARIFIER_API,[prefs stringForKey:@"tToken"]];
#if DEBUG
        NSLog(@"%@",url);
#endif
        __block NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
        [request setHTTPShouldHandleCookies:NO];
        [request setTimeoutInterval:30];
        [request setURL:[NSURL URLWithString:url]];
        [request setHTTPMethod:@"POST"];
        NSString *boundary = @"---------------------------14737809831466499882746641449";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
        
        NSMutableData *body = [NSMutableData data];
        //NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        //[request addValue:contentType forHTTPHeaderField:@"Content-Type"];
        
        // Package id
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Disposition: form-data; name=\"id\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%li",(long)package.packageId] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        // Purchase type
        if (package.purchaseType > -1) {
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Disposition: form-data; name=\"type\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"%li",(long)package.purchaseType] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            if (package.purchaseType == PLPurchaseTypeQR) {
                // QR Code
                [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[@"Content-Disposition: form-data; name=\"secret\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"%@",package.packageCardCode] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            }
            else if (package.purchaseType == PLPurchaseTypeAppStore) {
                NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
                NSData *receipt = [NSData dataWithContentsOfURL:receiptURL];
                // Secret
                [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[@"Content-Disposition: form-data; name=\"secret\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"%@",[receipt base64EncodedStringWithOptions:0]] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                
                // Transaction id
                [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[@"Content-Disposition: form-data; name=\"tid\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"%@",package.packageCardCode] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            }
            else if (package.purchaseType == PLPurchaseTypeFree) {
                
            }
        }
        if (userToken) {
            // User token
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Disposition: form-data; name=\"loginToken\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"%@",userToken] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        }

        [request setHTTPBody:body];
        //NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [Utilities taskInSeparatedThread:^{
            NSData *returnedData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
            NSString *responseString = [[NSString alloc] initWithData:returnedData encoding:NSUTF8StringEncoding];
#if DEBUG
            NSLog(@"Response is: %@",responseString);
#endif
            //SBJsonParser *parser = [[SBJsonParser alloc] init];
            //NSArray *array = [parser objectWithString:responseString];
            if (responseString.length > 0) {
                completionBlock(WS_OK,@{HASH_KEY: responseString});
            }
            else {
                NSLog(@"xxxxxxx");
                completionBlock(WS_ERROR,nil);
                id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                [tracker send:[[GAIDictionaryBuilder createExceptionWithDescription:[NSString stringWithFormat:@"c:%i %@",EC_VARIFIER_API, responseString]
                                                                          withFatal:[NSNumber numberWithBool:YES]] build]];
            }
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
        completionBlock(WS_ERROR,nil);
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createExceptionWithDescription:[NSString stringWithFormat:@"c:%i,%@",EC_VARIFIER_API, exception.description]
                                                                  withFatal:[NSNumber numberWithBool:YES]] build]];
    }
}

+(void)createAccountFacebookUid:(NSString *)fid
                    orGoogleUid:(NSString *)gid
                   sessionToken:(NSString *)token
             andCompletionBlock:(void(^)(enum WebServiceRequestStatus status, NSString *accountToken))completionBlock {
    @try {
        NSString *url = [NSString stringWithFormat:@"%@session=%@",ACCOUNT_API,token];
        if (fid) {
            url = [NSString stringWithFormat:@"%@&fbid=%@",url,fid];
        }
        else if (gid) {
            url = [NSString stringWithFormat:@"%@&gid=%@",url,gid];
        }
        else {
            completionBlock(WS_ERROR,nil);
            return;
        }
        
#if DEBUG
        NSLog(@"%@",url);
#endif
        NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:
                                           [NSURL URLWithString:
                                            url]];
        [theRequest setTimeoutInterval:30];
        __block NSURLResponse *resp = nil;
        __block NSError *error = nil;
        [Utilities taskInSeparatedThread:^{
            NSData *response = [NSURLConnection sendSynchronousRequest: theRequest returningResponse: &resp error: &error];
            NSString *responseString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
#if DEBUG
            NSLog(@"%@",responseString);
#endif
            if ([responseString isEqualToString:@"190"]) {
                completionBlock(WS_ERROR,responseString);
            }
            else if (![responseString isEqualToString:@"0"] && responseString.length > 5) {
                completionBlock(WS_OK,responseString);
            }
            else {
                completionBlock(WS_ERROR,nil);
                id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                [tracker send:[[GAIDictionaryBuilder createExceptionWithDescription:[NSString stringWithFormat:@"c:%i,%@",EC_CREATE_ACCOUNT_API, error.description]
                                                                          withFatal:[NSNumber numberWithBool:YES]] build]];
            }
            
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
        completionBlock(WS_ERROR,nil);
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createExceptionWithDescription:[NSString stringWithFormat:@"c:%i,%@",EC_CREATE_ACCOUNT_API, exception.description]
                                                                  withFatal:[NSNumber numberWithBool:YES]] build]];
    }
}

+(void)syncPurchasesWithServer {
    
    if (![[Settings sharedSettings] getLoginToken]) {
        return;
    }
    NSArray *purchasedPackages = [DBCoreDataHelper getPurchasedPackages];
    NSMutableString *ids = [[NSMutableString alloc] init];
    int sum = 0;
    if (purchasedPackages.count == 0) {
        return;
    }
    for (int i = 0; i < purchasedPackages.count - 1; i++) {
        DBPurchasedPackages *dbpp = purchasedPackages[i];
        [ids appendString:[NSString stringWithFormat:@"%@,%@,%@|",dbpp.p_id,dbpp.p_card_code,dbpp.p_purchase_type]];
        sum += [dbpp.p_id integerValue]%7;
    }
    DBPurchasedPackages *dbpp = [purchasedPackages lastObject];
    [ids appendString:[NSString stringWithFormat:@"%@,%@,%@",dbpp.p_id,dbpp.p_card_code,dbpp.p_purchase_type]];
    sum += [dbpp.p_id integerValue]%7;
    
    NSString *key = [Utilities md5:[NSString stringWithFormat:@"yap%iq",sum]];
    NSRange range;
    range.location = 7;
    range.length = 7;
    //NSLog(@"%@",key);
    key = [key substringWithRange:range];
    //NSLog(@"%@",key);
    [self syncPurchasesWithToken:[[Settings sharedSettings] getLoginToken] packageIds:ids andKey:key];
    
}

+(void)syncPurchasesWithToken:(NSString *)token packageIds:(NSString *)packageIds andKey:(NSString *)key {
    
    @try {
        NSString *url = [NSString stringWithFormat:@"%@token=%@&id=%@&key=%@",SYNC_PACKAGES_API,token,packageIds,key];
#if DEBUG
        NSLog(@"%@",url);
#endif
        NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:
                                           [NSURL URLWithString:
                                            url]];
        [theRequest setTimeoutInterval:30];
        __block NSURLResponse *resp = nil;
        __block NSError *error = nil;
        [Utilities taskInSeparatedThread:^{
            int count = 3;
            do {
                [NSURLConnection sendSynchronousRequest: theRequest returningResponse: &resp error: &error];
                count--;
            } while (count > 0 && error);
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createExceptionWithDescription:[NSString stringWithFormat:@"c:%i,%@",EC_SYNC_API, exception.description]
                                                                  withFatal:[NSNumber numberWithBool:YES]] build]];
    }
}

+(void)getAllPurchasedPackagesWithUserToken:(NSString *)userToken andCompletionBlock:(void(^)(enum WebServiceRequestStatus status, NSString *json))completionBlock {
    @try {
        NSString *url = [NSString stringWithFormat:@"%@token=%@&l=%@",GET_ALL_PURCHASES_API,userToken,[Settings sharedSettings].speechLanguage];
#if DEBUG
        NSLog(@"%@",url);
#endif
        NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:
                                           [NSURL URLWithString:
                                            url]];
        [theRequest setTimeoutInterval:60];
        __block NSURLResponse *resp = nil;
        __block NSError *error = nil;
        [Utilities taskInSeparatedThread:^{
            NSData *response = [NSURLConnection sendSynchronousRequest: theRequest returningResponse: &resp error: &error];
            NSString *responseString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
#if DEBUG
            NSLog(@"%@",responseString);
#endif
            completionBlock(WS_OK,responseString);
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
        completionBlock(WS_ERROR,nil);
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createExceptionWithDescription:[NSString stringWithFormat:@"c:%i,%@",EC_GET_ALL_PACKAGES_API, exception.description]
                                                                  withFatal:[NSNumber numberWithBool:YES]] build]];
    }
}

+(void)registreForPushNOtificationWithToken:(NSString *)token andCompletionBlock:(void(^)(enum WebServiceRequestStatus status, NSString *appVersion))completionBlock {
    @try {
        NSString *url = [NSString stringWithFormat:@"%@pToken=%@&type=%i",PUSH_API,token,1];
#if DEBUG
        NSLog(@"%@",url);
#endif
        NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:
                                           [NSURL URLWithString:
                                            url]];
        [theRequest setTimeoutInterval:30];
        __block NSURLResponse *resp = nil;
        __block NSError *error = nil;
        [Utilities taskInSeparatedThread:^{
            NSData *response = [NSURLConnection sendSynchronousRequest: theRequest returningResponse: &resp error: &error];
            NSString *responseString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
            completionBlock(WS_OK,responseString);
        }];
    }
    @catch (NSException *exception) {
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createExceptionWithDescription:[NSString stringWithFormat:@"c:%i,%@",EC_PUSH_REGISTER_API, exception.description]
                                                                  withFatal:[NSNumber numberWithBool:YES]] build]];
    }
}

+(void)isInMiniIsraelBlocking:(double)lat lon:(double)lon completion:(void(^)(enum WebServiceRequestStatus status,BOOL isInside))completionBlock {
    @try {
        NSString *url = [NSString stringWithFormat:@"http://api.yapq.com/ifInside.php?latitudeFrom=%lf&longitudeFrom=%lf",lat,lon];
        NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        [theRequest setTimeoutInterval:60];
        NSURLResponse *resp = nil;
        NSError *error = nil;
        NSData *response = [NSURLConnection sendSynchronousRequest: theRequest returningResponse: &resp error: &error];
        NSString *responseString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        
#if DEBUG
        NSLog(@"%@",responseString);
#endif
        float dist = [responseString floatValue];
        if (dist > 0) {
            completionBlock(WS_OK,true);
        }
        else {
            completionBlock(WS_OK,false);
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
        completionBlock(WS_ERROR,false);
    }

}

@end
