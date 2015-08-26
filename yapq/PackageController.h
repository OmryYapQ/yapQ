//
//  PackageController.h
//  yapq
//
//  Created by yapQ Ltd
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PackageLoadingEvents.h"
#import "PackageLoader.h"
#import "PackageFactoryUtils.h"

#define PL_STATUS_NOTIFICATION_KEY @"PackageLoaderNotification"
#define PL_PACKAGE_REMOVED_NOTIFICATION @"PackageRemovedNotification"

@interface PackageController : NSObject <PackageLoadingEvents>

@property (strong, nonatomic) NSMutableSet *packagesFromServer;

@property (strong) NSMutableArray *queue;


@property (strong) PackageLoader *currentPL;

+(PackageController *)sharedController;

-(void)addPackageLoaderToQueue:(PackageLoader *)packageLoader;
-(void)deletePackage:(Package *)package;

-(void)loadPackageListFromJsonString:(NSString *)json;

-(NSArray *)getPackageList;
-(NSUInteger)getNumberOfPackages;
-(void)removeAll;
@end
