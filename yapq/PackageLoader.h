//
//  PackageLoader.h
//  yapq
//
//  Created by yapQ Ltd
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBCoreDataHelper.h"
#import "Package.h"
#import "PlaceFactoryUtils.h"
#import "Utilities.h"
#import "PackageLoadingEvents.h"
#import "ZipFile.h"
#import "FileInZipInfo.h"
#import "ZipReadStream.h"
#import "ZipException.h"
#import "SBJson.h"
#import <YAJL/YAJL.h>
#import "JSONKit.h"


#define PL_STATUS_KEY @"StatusKey"
#define PL_ERROR_KEY @"UserDataKey"
#define PL_PACKAGE_KEY @"PackageKey"

#define TEMP_ZIP_NAME @"temp_"
#define TEMP_EXT @".zip"

#define IMG_DIR_NAME @"img"
#define DATA_FILE_NAME @"data.json"

#define kDownloadProgressObserver @"downloadProgress"
#define KPackageLoaderStatus @"packageLoaderStatus"

#define PACKAGE_ZIP_URL @"zipUrl"
#define HASH_KEY @"hash"

#define MAX_LOAD_VALUE_PERCENT 0.6
#define MAX_UNZIP_VALUE_PERCENT 0.2
#define MAX_PARSING_VALUE_PERCENT 0.2

typedef NS_ENUM(NSInteger, PLStatus)  {
    PLS_LOAD_WAITING = 0,
    PLS_LOAD_STARTED = 10,
    PLS_LOAD_FINISHED = 11,
    PLS_LOAD_ERROR = 12,
    PLS_UNZIP_STARTED = 20,
    PLS_UNZIP_FINISHED = 21,
    PLS_UNZIP_ERROR = 22,
    PLS_PARSING_STARTED = 30,
    PLS_PARSING_FINISHED = 31,
    PLS_PARSING_ERROR = 32
};

@interface PackageLoader : NSObject <NSURLConnectionDelegate,NSURLConnectionDataDelegate,YAJLParserDelegate> {
    NSURLConnection *connection;
    NSMutableDictionary *observers;
}

@property (strong, nonatomic) Package *package;
@property (strong, nonatomic) NSString *filePath;
@property (strong, nonatomic) NSString *extractedFilePath;
@property long long contentLength;
// Progress value, value from 0 to 1
// Downloading max value 0.8
// Unzip 0.1
// Parsing 0.1
@property float loadingProgres;

@property (nonatomic) PLStatus currentStatus;
@property (strong, nonatomic) NSError *error;

@property id<PackageLoadingEvents> delegate;



-(id)initWithPackage:(Package *)package;

-(NSString *)messageForCurrentState;

-(BOOL)isEnoughSpaceForLoading;

-(void)loadPackage;

-(void)unzipPackage;

-(void)loadPackageToDB;

-(void)cleanAll;

-(void)removePackageZip;

-(void)removeExtractedZip;

-(void)setStatus:(PLStatus)status;

@end