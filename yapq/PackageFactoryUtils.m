//
//  PackageFactoryUtils.m
//  yapq
//
//  Created by yapQ Ltd on 5/17/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import "PackageFactoryUtils.h"

@implementation PackageFactoryUtils

+(Package *)createPackage {
    return [[Package alloc] init];
}

+(DBPackage *)fillDBPackage:(DBPackage *)dbPackage fromPackage:(Package *)package {
    dbPackage.p_id = [NSNumber numberWithInteger:package.packageId];
    dbPackage.p_city = package.packageCity;
    dbPackage.p_country = package.packageCountry;
    dbPackage.p_name = package.packageName;
    dbPackage.p_descr = package.packageDescription;
    dbPackage.p_image = package.packageImage;
    dbPackage.p_price = package.price;
    dbPackage.p_link = package.packageLink;
    dbPackage.p_lang = package.packageLang;
    dbPackage.p_purchase_type = [NSNumber numberWithInteger:package.purchaseType];
    dbPackage.p_num_of_places = [NSNumber numberWithInt:package.numberOfPlaces];//[NSNumber numberWithInteger:package.places.count];
    dbPackage.p_radius = [NSNumber numberWithInt:package.radius];
    dbPackage.p_card_code = package.packageCardCode;
    dbPackage.p_exp_date = package.packageExpDate;
    dbPackage.p_more_json = package.packageMoreInfoJson;
    
    return dbPackage;
}

+(Package *)fillPackageFromDBPackage:(DBPackage *)dbPackage {
    Package *p = [self createPackage];
    p.packageId = [dbPackage.p_id integerValue];
    p.packageCity = dbPackage.p_city;
    p.packageCountry = dbPackage.p_country;
    p.packageName = dbPackage.p_name;
    p.packageDescription = dbPackage.p_descr;
    p.packageImage = dbPackage.p_image;
    p.packageLink = dbPackage.p_link;
    p.price = [NSString stringWithFormat:@"%@",dbPackage.p_price];
    p.packageLang = [NSString stringWithFormat:@"%@",dbPackage.p_lang];
    p.numberOfPlaces = [dbPackage.p_num_of_places intValue];
    p.radius = [dbPackage.p_radius intValue];
    p.packageCardCode = dbPackage.p_card_code;
    p.packageExpDate = dbPackage.p_exp_date;
    p.packageMoreInfoJson = dbPackage.p_more_json;
    p.purchaseType = [dbPackage.p_purchase_type integerValue];
    
    return p;
}

+(Package *)fillPackageFromDBPurchasedPackage:(DBPurchasedPackages *)dbPackage {
    Package *p = [self createPackage];
    p.packageId = [dbPackage.p_id integerValue];
    p.packageCity = dbPackage.p_city;
    p.packageCountry = dbPackage.p_country;
    p.packageName = dbPackage.p_name;
    p.packageDescription = dbPackage.p_descr;
    p.packageImage = dbPackage.p_image;
    p.numberOfPlaces = [dbPackage.p_num_of_places intValue];
    p.packageCardCode = dbPackage.p_card_code;
    p.purchaseType = [dbPackage.p_purchase_type integerValue];
    return p;
}

+(Package *)createPackageWithJsonDictionary:(NSDictionary *)jsonDictionary {
    Package *p = [self createPackage];
    @try {
        p.packageId = [[jsonDictionary valueForKey:@"id"] intValue];
        p.packageCountry = [jsonDictionary valueForKey:@"countryCode"];
        p.packageCity = [jsonDictionary valueForKey:@"locationCode"];
        p.packageName = [jsonDictionary valueForKey:@"locationCode"];
        p.packageDescription = [jsonDictionary valueForKey:@"sponser"];
        p.numberOfPlaces = [[jsonDictionary valueForKey:@"poi"] intValue];
        p.price = [jsonDictionary valueForKey:@"price"];
        p.packageLang = [Settings sharedSettings].speechLanguage;
        p.packageImage = [jsonDictionary valueForKey:@"img"];
        p.size = [[jsonDictionary valueForKey:@"size"] intValue];
        p.packageExpDate = [NSDate dateWithTimeIntervalSinceNow:TWO_MOTH_IN_SECONDS];
        p.distance = [[jsonDictionary valueForKey:@"distance"] floatValue];
        if ([jsonDictionary valueForKey:@"type"]) {
            p.purchaseType = [[jsonDictionary valueForKey:@"type"] integerValue];
        }
        if ([jsonDictionary valueForKey:@"tid"]) {
            p.packageCardCode = [jsonDictionary valueForKey:@"tid"];
        }
        
        return p;
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception debugDescription]);
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createExceptionWithDescription:[NSString stringWithFormat:@"c:%li,%@",EC_PARSING_SERVER_PACAKGE_JSON,exception.description]
                                                                  withFatal:[NSNumber numberWithBool:YES]] build]];
        return nil;
    }
}

@end
