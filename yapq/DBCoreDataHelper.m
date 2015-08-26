//
//  DBCoreDataHelper.m
//  NSCoreData
//
//  Created by yapQ Ltd on 2/8/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import "DBCoreDataHelper.h"

@implementation DBCoreDataHelper

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Package Core Data
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////
+(NSArray *)getAllPackages {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = [DBCoreDataSingleton sharedInstance].managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:kTABLE_DBPACKAGE inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"%@",error);
    }
    return fetchedObjects;
}

+(NSArray *)getAllPlaces {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = [DBCoreDataSingleton sharedInstance].managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:kTABLE_DBPLACE inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"%@",error);
    }
    return fetchedObjects;
}

+(NSArray *)getAllPlacesCoord {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = [DBCoreDataSingleton sharedInstance].managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:kTABLE_DBPLACE_COORD inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"%@",error);
    }
    return fetchedObjects;
}

+(NSArray *)getAllPackagesForLanguage:(NSString *)langCode {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = [DBCoreDataSingleton sharedInstance].managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:kTABLE_DBPACKAGE inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"p_lang = %@",langCode];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
    return fetchedObjects;
}

+(NSArray *)getAllPackagesForId:(NSInteger)packageId {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = [DBCoreDataSingleton sharedInstance].managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:kTABLE_DBPACKAGE inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"p_id = %i",packageId];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
    return fetchedObjects;
}

+(DBPackage *)getPackageWithId:(NSInteger)packageId forLanguage:(NSString *)langCode {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = [DBCoreDataSingleton sharedInstance].managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:kTABLE_DBPACKAGE inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"p_id = %i AND p_lang = %@",packageId, langCode];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (error != nil) {
        NSLog(@"%@",error);
        return nil;
    }

    return [fetchedObjects lastObject];
}

+(NSArray *)getPlacesOfPackageWithId:(NSInteger)packageId forLanguage:(NSString *)langCode {
    DBPackage *package = (DBPackage *)[self getPackageWithId:packageId forLanguage:langCode];
    if (!package) {
        return nil;
    }
    NSMutableArray *places = [[NSMutableArray alloc] init];
    for (DBPlace *p in [package places]) {
        Place *place = [PlaceFactoryUtils createPlaceWithDBPlace:p];
        [places addObject:place];
    }
    
    return [places mutableCopy];
}

+(NSArray *)placesForCurrentPlaceWithRadius:(float)radius {
    
    return [self placesForLocation:[YLocation initWithLatitude:[LocationService sharedService].currentLatitude
                                                  andLongitude:[LocationService sharedService].currentLongitude]
                        withRadius:radius];
}

+(NSArray *)placesForLocation:(YLocation *)location fromRadius:(float)minRadius toRadius:(float)maxRadius withMaxRequestRows:(int)maxRows {
    
    const NSUInteger fetchRows = maxRows;
    float radius = 0;
    int i = 0;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = [DBCoreDataSingleton sharedInstance].managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:kTABLE_DBPLACE_COORD inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    //[fetchRequest setFetchLimit:fetchRows];
    //[fetchRequest setFetchOffset:fetchRows*i];
    [fetchRequest setReturnsObjectsAsFaults:YES];
    
    NSArray *array = nil;
    NSError *__autoreleasing error = nil;
    do {
        radius = radius == 0 ? minRadius : radius*2;
        double D = radius * 1.1;
        double const R = 6371009.; // Earth readius in meters
        double meanLatitidue = location.latitude * M_PI / 180.;
        double deltaLatitude = D / R * 180. / M_PI;
        double deltaLongitude = D / (R * cos(meanLatitidue)) * 180. / M_PI;
        double minLatitude = location.latitude - deltaLatitude;
        double maxLatitude = location.latitude + deltaLatitude;
        double minLongitude = location.longitude - deltaLongitude;
        double maxLongitude = location.longitude + deltaLongitude;
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:
                                    @"(%@ <= pc_lon) AND (pc_lon <= %@)"
                                    @"AND (%@ <= pc_lat) AND (pc_lat <= %@)"
                                    @"AND place.package.p_lang = %@",
                                    @(minLongitude), @(maxLongitude), @(minLatitude), @(maxLatitude),[Settings sharedSettings].speechLanguage]];
        
        array = [context executeFetchRequest:fetchRequest error:&error];
        NSPredicate *predicate = [self exactLocationPredicateFromLocation:location withRadius:radius];
        array = [array filteredArrayUsingPredicate:predicate];
        i++;
    }while (array.count < maxRows && radius < maxRadius);
    
    if (array.count > 0) {
        NSMutableArray *places = [[NSMutableArray alloc] init];
        for (DBPlaceCoord *pc in array) {
            double latitude = [pc.pc_lat doubleValue];
            double longitude = [pc.pc_lon doubleValue];
            double distance = [LocationService distanceToLocation:location
                                          fromLocationWithCenter:[YLocation initWithLatitude:latitude
                                                                                andLongitude:longitude]];
            //if (distance <= radius) {
                Place *pl = [PlaceFactoryUtils createPlaceWithDBPlace:pc.place];
                pl.dist = (int)distance;
                [places addObject:pl];
            //}
        }
        array = [places sortedArrayUsingComparator:^NSComparisonResult(Place *p1, Place *p2) {
            if ([p1 isFarFromPlace:p2]) {
                return 1;
            }
            else if ([p2 isFarFromPlace:p1]) {
                return -1;
            }
            return 0;
        }];
    }
//TODO make loading smart with places that already exist
    NSRange range;
    range.location = 0;
    range.length = array.count <= maxRows ? array.count : maxRows;
    return [array subarrayWithRange:range];
}

+(NSPredicate *)exactLocationPredicateFromLocation:(YLocation *)fromLocation withRadius:(float)radius
{
    return [NSPredicate predicateWithBlock:^BOOL(DBPlaceCoord *evaluatedObject, NSDictionary *bindings) {
        YLocation *toLocation = [YLocation initWithLatitude:[evaluatedObject.pc_lat doubleValue] andLongitude:[evaluatedObject.pc_lon doubleValue]];
        double distance = [LocationService distanceToLocation:toLocation
                                      fromLocationWithCenter:fromLocation];
        //evaluatedObject.pc_distance = [NSNumber numberWithDouble:distance];
        return distance <= radius;
    }];
}


+(NSArray *)placesForLocation:(YLocation *)location withRadius:(float)radius {
    const NSUInteger fetchRows = 20;
    int i = 0;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = [DBCoreDataSingleton sharedInstance].managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:kTABLE_DBPLACE_COORD inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchLimit:fetchRows];
    [fetchRequest setFetchOffset:fetchRows*i];
    
    
    NSError *__autoreleasing error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (error  != nil) {
        NSLog(@"%@",error);
        return nil;
    }
    
    NSMutableArray *places = [[NSMutableArray alloc] init];
    @autoreleasepool {
        if (fetchedObjects.count == 0) {
            return [places mutableCopy];
        }
        do {
            for (DBPlaceCoord *pc in fetchedObjects) {
                double latitude = [pc.pc_lat doubleValue];
                double longitude = [pc.pc_lon doubleValue];
                double distance = [LocationService distanceToLocation:location
                                              fromLocationWithCenter:[YLocation initWithLatitude:latitude
                                                                                    andLongitude:longitude]]*1000;
                if (distance <= radius) {
                    Place *pl = [PlaceFactoryUtils createPlaceWithDBPlace:pc.place];
                    pl.dist = (int)distance;
                    [places addObject:pl];
                }
            }
            i++;
            [fetchRequest setFetchOffset:fetchRows*i];
            fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
            
            if (error != nil) {
                return [places mutableCopy];
            }
        }while (fetchedObjects.count > 0);
    }
    
    // Returning places after sort from neares to farest
    return [places sortedArrayUsingComparator:^NSComparisonResult(Place *p1, Place *p2) {
        if ([p1 isFarFromPlace:p2]) {
            return 1;
        }
        else if ([p2 isFarFromPlace:p1]) {
            return -1;
        }
        return 0;
    }];
}

+(BOOL)isEntityExist:(NSInteger)entityId forLanguage:(NSString *)langCode {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = [DBCoreDataSingleton sharedInstance].managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:kTABLE_DBPLACE inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pl_id = %i AND package.p_lang = %@",entityId, langCode];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSUInteger count = [context countForFetchRequest:fetchRequest error:&error];
    if (error != nil) {
        NSLog(@"%@",error);
        return NO;
    }
    return count > 0;
}

+(BOOL)insertPackage:(Package *)package forLanguage:(NSString *)langCode {
    
    @autoreleasepool {
        NSManagedObjectContext *context = [DBCoreDataSingleton sharedInstance].managedObjectContext;
        [context lock];
        // Check if package already exist
        DBPackage *dbPackage = [self getPackageWithId:package.packageId forLanguage:langCode];
        
        // Inserting packages to table of purchased packages
        [self insertPurchasedPackage:package];
        @try {
            NSError *__autoreleasing error;
            if (dbPackage == nil) {
                // Package not exist
                dbPackage = [NSEntityDescription insertNewObjectForEntityForName:kTABLE_DBPACKAGE inManagedObjectContext:context];
                [PackageFactoryUtils fillDBPackage:dbPackage fromPackage:package];
                // Saving package in core data
                if (![context save:&error]) {
                    NSLog(@"%@",error);
                    @throw [NSException exceptionWithName:[NSString stringWithFormat:@"P_id:%li code:%i, %@",(long)package.packageId,EC_PACKAGE_INSERT,error]
                                                   reason:error.description userInfo:nil];
                }
            }
#if DEBUG
            NSLog(@"%@",dbPackage);
#endif
            // Inserting places
            for (Place *p in package.places) {
                if ([self isEntityExist:p.p_id forLanguage:package.packageLang]) {
                    continue;
                }
                DBPlace *dbPlace = [NSEntityDescription insertNewObjectForEntityForName:kTABLE_DBPLACE inManagedObjectContext:context];
                [PlaceFactoryUtils fillDBPlace:dbPlace fromPlace:p];
                DBPlaceCoord *dbPlaceCoord = [NSEntityDescription insertNewObjectForEntityForName:kTABLE_DBPLACE_COORD inManagedObjectContext:context];
                dbPlaceCoord.pc_distance = [NSNumber numberWithInteger:p.dist];
                dbPlaceCoord.pc_lat = [NSNumber numberWithDouble:p.lan];
                dbPlaceCoord.pc_lon = [NSNumber numberWithDouble:p.lon];
                dbPlace.coord = dbPlaceCoord;
                [dbPackage addPlacesObject:dbPlace];
                
#if DEBUG
                NSLog(@"%@",dbPlace);
#endif
            }
            if (![context save:&error]) {
                NSLog(@"%@",error);
                [self deletePackageWithId:package.packageId forLanguage:package.packageLang];
                @throw [NSException exceptionWithName:[NSString stringWithFormat:@"code:%i, %@",EC_PLACE_INSERT,error]
                                               reason:error.description userInfo:nil];
            }
        }
        @catch (NSException *exception) {
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createExceptionWithDescription:exception.description
                                                                      withFatal:[NSNumber numberWithBool:YES]] build]];
            if (dbPackage != nil) {
                [self deletePackageWithId:package.packageId forLanguage:package.packageLang];
            }
            return NO;
        }
        @finally {
            [context unlock];
        }
        
    }
    return YES;
}

+(BOOL)insertPlace:(Place *)place forPackageWithId:(NSInteger)packageId andLanguage:(NSString *)langCode {
    @autoreleasepool {
        NSManagedObjectContext *context = [DBCoreDataSingleton sharedInstance].managedObjectContext;
        [context lock];
        // Check if package already exist
        DBPackage *dbPackage = [self getPackageWithId:packageId forLanguage:langCode];

        @try {
            if (!dbPackage) {
                return NO;
            }
            NSError *__autoreleasing error;
            if ([self isEntityExist:place.p_id forLanguage:langCode]) {
                return YES;
            }
            DBPlace *dbPlace = [NSEntityDescription insertNewObjectForEntityForName:kTABLE_DBPLACE inManagedObjectContext:context];
            [PlaceFactoryUtils fillDBPlace:dbPlace fromPlace:place];
            DBPlaceCoord *dbPlaceCoord = [NSEntityDescription insertNewObjectForEntityForName:kTABLE_DBPLACE_COORD inManagedObjectContext:context];
            dbPlaceCoord.pc_distance = [NSNumber numberWithInteger:place.dist];
            dbPlaceCoord.pc_lat = [NSNumber numberWithDouble:place.lan];
            dbPlaceCoord.pc_lon = [NSNumber numberWithDouble:place.lon];
            dbPlace.coord = dbPlaceCoord;
            [dbPackage addPlacesObject:dbPlace];
#if DEBUG
        NSLog(@"%@",dbPlace);
#endif
            if (![context save:&error]) {
                NSLog(@"%@",error);
                return NO;
            }
        }
        @catch (NSException *exception) {
            return NO;
        }
        @finally {
            [context unlock];
        }
        
    }
    return YES;
}

+(BOOL)updateForPackage:(Package *)package {
    NSArray *packages = [self getAllPackagesForId:package.packageId];
    NSManagedObjectContext *context = [DBCoreDataSingleton sharedInstance].managedObjectContext;
    [context lock];
    NSError *error = nil;
    for (DBPackage *p in packages) {
        //if (p.p_card_code == nil || package.purchaseType != [p.p_purchase_type integerValue]) {
        p.p_card_code = package.packageCardCode;
        p.p_purchase_type = [NSNumber numberWithInteger:package.purchaseType];
        [context save:&error];
       // }
    }
    [context unlock];
    return YES;
}

+(BOOL)deletePackageWithId:(NSInteger)packageId forLanguage:(NSString *)langCode {
    
    NSManagedObjectContext *context = [DBCoreDataSingleton sharedInstance].managedObjectContext;
    [context lock];
    NSError *__autoreleasing error;
    DBPackage *o = [self getPackageWithId:packageId forLanguage:langCode];
    /*if (![o validateForDelete:&error]) {
        NSLog(@"%@",error);
        return NO;
    }*/
    [context deleteObject:o];
    
    if (![context save:&error]) {
        NSLog(@"ERROR %@",error);
        [context unlock];
        return NO;
    }
    [context unlock];
    return YES;
}

+(NSArray *)fetchAllPlaces {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = [DBCoreDataSingleton sharedInstance].managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:kTABLE_DBPLACE inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"%@",error);
    }
    return fetchedObjects;
}

+(BOOL)isPackageExist:(NSInteger)packageId forLanguage:(NSString *)langCode {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = [DBCoreDataSingleton sharedInstance].managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:kTABLE_DBPACKAGE inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"p_id = %i AND p_lang = %@",packageId, langCode];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSUInteger count = [context countForFetchRequest:fetchRequest error:&error];
    if (error != nil) {
        NSLog(@"%@",error);
        return NO;
    }
    return count > 0;
}

+(BOOL)isPackageExistWithId:(NSInteger)packageID {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = [DBCoreDataSingleton sharedInstance].managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:kTABLE_DBPACKAGE inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"p_id = %i",packageID];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSUInteger count = [context countForFetchRequest:fetchRequest error:&error];
    if (error != nil) {
        NSLog(@"%@",error);
        return NO;
    }
    return count > 0;
}

+(BOOL)autoDeletePackages {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = [DBCoreDataSingleton sharedInstance].managedObjectContext;
    [context lock];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kTABLE_DBPACKAGE inManagedObjectContext:context];
    NSDate *today = [NSDate date];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"p_exp_date <= %@",today];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    for (DBPackage *p in fetchedObjects) {
        [context deleteObject:p];
        if (![context save:&error]) {
            NSLog(@"%@",error);
        }
    }
    [context unlock];
    return YES;
}

+(NSArray *)getPurchasedPackages {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = [DBCoreDataSingleton sharedInstance].managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:kTABLE_DBPURCHASED_PACKAGES inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"%@",error);
    }
    return fetchedObjects;
}

+(BOOL)insertPurchasedPackage:(Package *)package {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = [DBCoreDataSingleton sharedInstance].managedObjectContext;
    [context lock];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kTABLE_DBPURCHASED_PACKAGES inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"p_id = %i",package.packageId];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *obj = [context executeFetchRequest:fetchRequest error:&error];
    if (error != nil) {
        NSLog(@"%@",error);
        [context unlock];
        return NO;
    }
    if (obj.count == 0) {
        DBPurchasedPackages *dbPackage = [NSEntityDescription insertNewObjectForEntityForName:kTABLE_DBPURCHASED_PACKAGES
                                                                       inManagedObjectContext:context];
        dbPackage.p_id = [NSNumber numberWithInteger:package.packageId];
        dbPackage.p_name = package.packageName;
        dbPackage.p_city = package.packageCity;
        dbPackage.p_country = package.packageCountry;
        dbPackage.p_num_of_places = [NSNumber numberWithInteger:package.numberOfPlaces];
        dbPackage.p_descr = package.packageDescription;
        dbPackage.p_card_code = package.packageCardCode;
        dbPackage.p_purchase_type = [NSNumber numberWithInteger:package.purchaseType];
        dbPackage.p_image = package.packageImage;
        
        if (![context save:&error]) {
            NSLog(@"%@",error);
            [context unlock];
            return NO;
        }
        [context unlock];
        return YES;
    }
    else {
        DBPurchasedPackages *pp = [obj lastObject];
        pp.p_num_of_places = [NSNumber numberWithInteger:package.numberOfPlaces];
        if (![context save:&error]) {
            NSLog(@"%@",error);
            [context unlock];
            return NO;
        }
    }
    [context unlock];
    return NO;
}

+(BOOL)isPurchasedPackageExistWithId:(NSInteger)packageID {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = [DBCoreDataSingleton sharedInstance].managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:kTABLE_DBPURCHASED_PACKAGES inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"p_id = %i",packageID];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSUInteger count = [context countForFetchRequest:fetchRequest error:&error];
    if (error != nil) {
        NSLog(@"%@",error);
        return NO;
    }
    return count > 0;
}

@end


/* ========= Fetch object from Core Data =================
 
 NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
 NSEntityDescription *entity = [NSEntityDescription entityForName:@"<#Entity name#>" inManagedObjectContext:<#context#>];
 [fetchRequest setEntity:entity];
 
 NSError *error = nil;
 NSArray *fetchedObjects = [<#context#> executeFetchRequest:fetchRequest error:&error];
 if (fetchedObjects == nil) {
 <#Error handling code#>
 }
 ==========================================================*/


/* =================== Fetch object from Core Data with predicate (constrain or condition) ===================
 
 NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
 NSEntityDescription *entity = [NSEntityDescription entityForName:@"<#Entity name#>" inManagedObjectContext:<#context#>];
 [fetchRequest setEntity:entity];
 
 NSPredicate *predicate = [NSPredicate predicateWithFormat:@"<#Predicate string#>", <#Predicate arguments#>];
 [fetchRequest setPredicate:predicate];
 
 NSError *error = nil;
 NSArray *fetchedObjects = [<#context#> executeFetchRequest:fetchRequest error:&error];
 if (fetchedObjects == nil) {
 <#Error handling code#>
 }
 ==========================================================*/

/* ====================== Fetch object from Core Data with data sort ===================
 
 NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
 NSEntityDescription *entity = [NSEntityDescription entityForName:@"<#Entity name#>"
 inManagedObjectContext:<#context#>];
 [fetchRequest setEntity:entity];
 
 NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"<#Sort key#>"
 ascending:YES];
 NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
 [fetchRequest setSortDescriptors:sortDescriptors];
 
 NSError *error = nil;
 NSArray *fetchedObjects = [<#context#> executeFetchRequest:fetchRequest error:&error];
 if (fetchedObjects == nil) {
 // Handle the error
 }
 ==========================================================*/

/* ====================== Insert new object into Core Data DB ==========================
 
 NSManagedObjectContext *context = [appDelegate managedObjectContext];
 NSManagedObject *newObject = [NSEntityDescription insertNewObjectForEntityForName:@"< EntityName >" inManagedObjectContext:context];
 < Fill your fields in your object >
 NSError *error;
 [context save:&error];
 ==========================================================*/

/* ====================== Delete object with objectId from Core Data ========================
 
 NSFetchRequest *fechedRequest = [[NSFetchRequest alloc]init];
 NSEntityDescription *entity = [NSEntityDescription entityForName:@"<# EntityName #>" inManagedObjectContext:mContext];
 [fechedRequest setEntity:entity];
 NSError *error;
 
 NSManagedObjectID *objectID = [[mContext persistentStoreCoordinator] managedObjectIDForURIRepresentation:productID];
 NSManagedObject *object = [mContext objectWithID:objectID];
 
 <# EntityName #> *o = (<# EntityName #> *)object;
 if (![o validateForDelete:&error]) {
 return NO;
 }
 [mContext deleteObject:o];
 
 if (![mContext save:&error]) {
 return NO;
 }
 ==========================================================*/

/* ======================= Update object data in Core Data ============================
 
 NSFetchRequest *fechedRequest = [[NSFetchRequest alloc]init];
 NSEntityDescription *entity = [NSEntityDescription entityForName:@"<# EntityName#>" inManagedObjectContext:mContext];
 [fechedRequest setEntity:entity];
 NSError *error;
 
 NSManagedObjectID *objectID = [[mContext persistentStoreCoordinator] managedObjectIDForURIRepresentation:productID];
 NSManagedObject *object = [mContext objectWithID:objectID];
 
 <# EntityName #> *o = (<# EntityName #> *)object;
 
 // Update object fields
 
 if (![o validateForUpdate:&error]) {
 return NO;
 }
 
 if (![mContext save:&error]) {
 return NO;
 }
 ==========================================================*/


