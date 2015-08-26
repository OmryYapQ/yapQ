//
//  PackageFactoryUtils.h
//  yapq
//
//  Created by yapQ Ltd on 5/17/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Package.h" 
#import "Settings.h"
#import "DBPurchasedPackages.h"
#import "Utilities.h"

@interface PackageFactoryUtils : NSObject

+(Package *)createPackage;
+(DBPackage *)fillDBPackage:(DBPackage *)dbPackage fromPackage:(Package *)package;
+(Package *)fillPackageFromDBPackage:(DBPackage *)dbPackage;
+(Package *)createPackageWithJsonDictionary:(NSDictionary *)jsonDictionary;
+(Package *)fillPackageFromDBPurchasedPackage:(DBPurchasedPackages *)dbPackage;

@end
