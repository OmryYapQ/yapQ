//
//  NSCoreDataSingleton.h
//  NSCoreData
//
//  Created by yapQ Ltd
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
/*****************************************************************************************
 *
 * For DEBUG Core Data add "-com.apple.CoreData.SQLDebug 1" to Arguments Passed On Launch.
 *
 *****************************************************************************************/

/**
 * Core Data model file name, it must be the same name as Model file in XCode.
 */
#define MODEL_FILE_NAME @"offline_db"

/**
 * Name of database file saved in documents directory
 */
#define DB_FILE_NAME @"pgs.db"

@interface DBCoreDataSingleton : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

+(DBCoreDataSingleton *)sharedInstance;

@end
