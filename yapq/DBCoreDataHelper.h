//
//  DBCoreDataHelper.h
//  NSCoreData
//
//  Created by yapQ Ltd
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBConsts.h"
#import "Settings.h"
#import "DBCoreDataSingleton.h"
#import "LocationSevice.h"
#import "PlaceFactoryUtils.h"
#import "PackageFactoryUtils.h"
#import "Place.h"
#import "Package.h"
#import "DBPackage.h"
#import "DBPlace.h"
#import "DBPlaceCoord.h"
#import "DBPurchasedPackages.h"
#import "GAI.h"

@interface DBCoreDataHelper : NSObject

+(NSArray *)getAllPlaces;

+(NSArray *)getAllPlacesCoord;

+(NSArray *)getAllPackages;

+(NSArray *)getAllPackagesForLanguage:(NSString *)langCode;

+(NSArray *)getAllPackagesForId:(NSInteger)packageId;

+(DBPackage *)getPackageWithId:(NSInteger)packageId forLanguage:(NSString *)langCode;

+(NSArray *)getPlacesOfPackageWithId:(NSInteger)packageId forLanguage:(NSString *)langCode;

+(NSArray *)placesForCurrentPlaceWithRadius:(float)radius;

+(NSArray *)placesForLocation:(YLocation *)location withRadius:(float)radius;

+(NSArray *)placesForLocation:(YLocation *)location fromRadius:(float)minRadius toRadius:(float)maxRadius withMaxRequestRows:(int)maxRows;

+(BOOL)insertPackage:(Package *)package forLanguage:(NSString *)langCode;

+(BOOL)insertPlace:(Place *)place forPackageWithId:(NSInteger)packageId andLanguage:(NSString *)langCode;

+(BOOL)updateForPackage:(Package *)package;

+(BOOL)deletePackageWithId:(NSInteger)packageId forLanguage:(NSString *)langCode;

+(NSArray *)fetchAllPlaces;

+(BOOL)isPackageExist:(NSInteger)packageId forLanguage:(NSString *)langCode;

+(BOOL)isPackageExistWithId:(NSInteger)packageID;

+(BOOL)autoDeletePackages;

+(NSArray *)getPurchasedPackages;

+(BOOL)insertPurchasedPackage:(Package *)package;

+(BOOL)isPurchasedPackageExistWithId:(NSInteger)packageID;

@end
