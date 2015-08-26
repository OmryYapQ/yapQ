//
//  PackageController.m
//  yapq
//
//  Created by yapQ Ltd
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import "PackageController.h"

@implementation PackageController

static PackageController *instance = nil;

-(id)init {
    if (self = [super init]) {
        _queue = [[NSMutableArray alloc] init];
        _packagesFromServer = [[NSMutableSet alloc] init];
        // Loading packages from DB
        /*NSArray *dbPackages = [DBCoreDataHelper getAllPackages];
        for (DBPackage *dbp in dbPackages) {
            Package *p = [PackageFactoryUtils fillPackageFromDBPackage:dbp];
            [_packagesFromServer addObject:p];
        }*/
        
    }
    return self;
}

+(PackageController *)sharedController {
    if (!instance) {
        instance = [[PackageController alloc] init];
        
    }
    return instance;
}
//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Loading list of packages
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////
-(void)loadPackageListFromJsonString:(NSString *)json {
    _packagesFromServer = [[NSMutableSet alloc] init];
    if (_currentPL) {
        [_packagesFromServer addObject:_currentPL.package];
    }
    for (PackageLoader *pl in _queue) {
        [_packagesFromServer addObject:pl.package];
    }
    if (json == nil) {
        return;
    }
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSArray *jsonArr = [parser objectWithString:json];
    for (int i=0;i<jsonArr.count;i++) {
        NSDictionary *pd = [jsonArr objectAtIndex:i];
        //NSInteger pid = [[pd valueForKey:@"id"] integerValue];
        //if (![DBCoreDataHelper isPackageExist:pid forLanguage:[Settings sharedSettings].speechLanguage]) {
            Package *package = [PackageFactoryUtils createPackageWithJsonDictionary:pd];
            //package.numberOfPlaces = 2000;
            [Utilities cacheImage:package.packageImage isOffline:YES];
            [_packagesFromServer addObject:package];
        //}
    }
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Package Controller utils
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////

-(NSArray *)getPackageList {
    return [[_packagesFromServer allObjects] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Package *p1 = obj1;
        Package *p2 = obj2;
        return p1.distance > p2.distance;//[p1.packageName compare:p2.packageName];
    }];
    return [_packagesFromServer allObjects];
}

-(NSUInteger)getNumberOfPackages {
    return _packagesFromServer.count;
}

-(void)removeAll {
    [_packagesFromServer removeAllObjects];
}

-(BOOL)isExistWithId:(int)Id {
    for (Package *p in [_packagesFromServer allObjects]) {
        if (p.packageId == Id) {
            return YES;
        }
    }
    return NO;
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Downloading controll part
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////

-(void)addPackageLoaderToQueue:(PackageLoader *)packageLoader {
    
    // Sending notification about package waiting in queue
    [self loadWaiting:packageLoader];
    
    
    if (_currentPL == nil) {
        _currentPL = packageLoader;
        [self start:_currentPL];
    }
    else {
        [_queue addObject:packageLoader];
    }
}

-(void)loadNext {
    if (_queue.count == 0) {
        _currentPL = nil;
        return;
    }
    else if (_currentPL == nil && _queue.count > 0) {
        _currentPL = [_queue objectAtIndex:0];
        [_queue removeObjectAtIndex:0];
        [self start:_currentPL];
    }
}

-(void)start:(PackageLoader *)packageLoader {
    //__weak PackageLoader *weakPackageLoader = packageLoader;
    
    _currentPL.delegate = self;
    [_currentPL loadPackage];
    /*[Utilities UITaskInSeparatedBlock:^{
        PackageLoader *strongLodader = weakPackageLoader;
        
    }];*/
}

-(void)notificationWithUserInfo:(NSDictionary *)userInfo {
    [[NSNotificationCenter defaultCenter] postNotificationName:PL_STATUS_NOTIFICATION_KEY object:self userInfo:userInfo];
}

-(void)deletePackage:(Package *)package {
    [DBCoreDataHelper deletePackageWithId:package.packageId forLanguage:package.packageLang];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [[[Utilities applicationDocumentsDirectory] path] stringByAppendingPathComponent:[Utilities md5:package.packageName]];
    [fileManager removeItemAtPath:path error:nil];
}

-(void)onError {
    [_currentPL cleanAll];
    _currentPL = nil;
    [self loadNext];
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Package Loader Events
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////

// Waiting to load start
-(void)loadWaiting:(PackageLoader *)packageLoader {
    NSDictionary *userInfo = @{PL_STATUS_KEY: [NSNumber numberWithInteger:packageLoader.currentStatus],
                               PL_PACKAGE_KEY: packageLoader};
    [self notificationWithUserInfo:userInfo];
}

// Starting loading
-(void)loadStarted:(PackageLoader *)packageLoader {
    NSDictionary *userInfo = @{PL_STATUS_KEY: [NSNumber numberWithInteger:packageLoader.currentStatus],
                               PL_PACKAGE_KEY: packageLoader};
    [self notificationWithUserInfo:userInfo];
}

// Loading finished
-(void)loadFinished:(PackageLoader *)packageLoader {
    NSDictionary *userInfo = @{PL_STATUS_KEY: [NSNumber numberWithInteger:packageLoader.currentStatus],
                               PL_PACKAGE_KEY: packageLoader};
    [self notificationWithUserInfo:userInfo];
    
    // Unzip after loading finished
    __weak PackageLoader *weakPackageLoader = _currentPL;
    [Utilities taskInSeparatedThread:^{
        PackageLoader *strongPackageLoader = weakPackageLoader;
        [NSThread sleepForTimeInterval:1];
        [strongPackageLoader unzipPackage];
    }];
    
}

// Loading error
-(void)loadError:(PackageLoader *)packageLoader {
    NSDictionary *userInfo = @{PL_STATUS_KEY: [NSNumber numberWithInteger:packageLoader.currentStatus],
                               PL_PACKAGE_KEY: packageLoader};
    [self notificationWithUserInfo:userInfo];
    
    // Try to load next
    [self onError];
}

// Unzip started
-(void)unzipStarted:(PackageLoader *)packageLoader {
    NSDictionary *userInfo = @{PL_STATUS_KEY: [NSNumber numberWithInteger:packageLoader.currentStatus],
                               PL_PACKAGE_KEY: packageLoader};
    [self notificationWithUserInfo:userInfo];
}

// Unzip finished
-(void)unzipFinished:(PackageLoader *)packageLoader {
    NSDictionary *userInfo = @{PL_STATUS_KEY: [NSNumber numberWithInteger:packageLoader.currentStatus],
                               PL_PACKAGE_KEY: packageLoader};
    [self notificationWithUserInfo:userInfo];
    
    // Unziping finished
    __weak PackageLoader *weakPackageLoader = _currentPL;
    [Utilities taskInSeparatedThread:^{
        PackageLoader *strongPackageLoader = weakPackageLoader;
        [NSThread sleepForTimeInterval:1];
        [strongPackageLoader loadPackageToDB];
    }];
    
}

// Unzip error
-(void)unzipError:(PackageLoader *)packageLoader {
    NSDictionary *userInfo = @{PL_STATUS_KEY: [NSNumber numberWithInteger:packageLoader.currentStatus],
                               PL_PACKAGE_KEY: packageLoader};
    [self notificationWithUserInfo:userInfo];
    
    // Try to load next
    [self onError];
}

// Parsing and loading to db started
-(void)parsingStarted:(PackageLoader *)packageLoader {
    NSDictionary *userInfo = @{PL_STATUS_KEY: [NSNumber numberWithInteger:packageLoader.currentStatus],
                               PL_PACKAGE_KEY: packageLoader};
    [self notificationWithUserInfo:userInfo];
}

// Parsing and loading to db finished
-(void)parsingFinished:(PackageLoader *)packageLoader {
    NSDictionary *userInfo = @{PL_STATUS_KEY: [NSNumber numberWithInteger:packageLoader.currentStatus],
                               PL_PACKAGE_KEY: packageLoader};
    [_packagesFromServer removeObject:packageLoader.package];
    [self notificationWithUserInfo:userInfo];
    [_currentPL cleanAll];
    _currentPL = nil;
    [self loadNext];
}

// Parsing and loading to db error
-(void)parsingError:(PackageLoader *)packageLoader {
    NSDictionary *userInfo = @{PL_STATUS_KEY: [NSNumber numberWithInteger:packageLoader.currentStatus],
                               PL_PACKAGE_KEY: packageLoader};
    [self notificationWithUserInfo:userInfo];
    // Trying to load next
    [self onError];
}

@end
