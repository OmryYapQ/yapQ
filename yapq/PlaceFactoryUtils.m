//
//  PlaceFactoryUtils.m
//  yapq
//
//  Created by yapQ Ltd on 5/16/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import "PlaceFactoryUtils.h"
#import "Place.h"
#import "SettingsPlace.h"
#import "OfflinePlace.h"
#import "DBPackage.h"
#import "DBPlace.h"
#import "DBPlaceCoord.h"
#import "SwipePlaceFirstCell.h"

@implementation PlaceFactoryUtils

+(Place *)createPlaceWithDBPlace:(DBPlace *)dbPlace {
    Place *p = [[Place alloc] init];
    p.isOffline = YES;
    p.p_id = [dbPlace.pl_id intValue];
    p.title = dbPlace.pl_title;
    p.descr = dbPlace.pl_descr;
    p.dist = [dbPlace.coord.pc_distance intValue];
    p.img_url = dbPlace.pl_img_url;
    p.lan = [dbPlace.coord.pc_lat doubleValue];
    p.lon = [dbPlace.coord.pc_lon doubleValue];
    p.audio = dbPlace.pl_audio;
    p.wiki = dbPlace.pl_wiki;
    
    return p;
}

+(Place *)createPlaceWithJsonDictionary:(NSDictionary *)jsonDictionary {
    Place *place = [[Place alloc] init];
    place.isOffline = NO;
    
    if ([jsonDictionary objectForKey:@"id"]) {
        place.p_id = [[jsonDictionary objectForKey:@"id"] integerValue];
    }
    if ([jsonDictionary objectForKey:@"name"]) {
        place.title = [jsonDictionary objectForKey:@"name"];
    }
    if ([jsonDictionary objectForKey:@"distance"]) {
        place.dist = [[jsonDictionary objectForKey:@"distance"] integerValue];
    }
    if ([jsonDictionary objectForKey:@"description"]) {
        place.descr = [[NSString stringWithFormat:@"%@",[jsonDictionary objectForKey:@"description"]]
                       stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    }
    if ([jsonDictionary objectForKey:@"img"]) {
        place.img_url = [jsonDictionary objectForKey:@"img"];
    }
    if ([jsonDictionary objectForKey:@"coX"]) {
        place.lan = [[jsonDictionary objectForKey:@"coX"] doubleValue];
    }
    if ([jsonDictionary objectForKey:@"coY"]) {
        place.lon = [[jsonDictionary objectForKey:@"coY"] doubleValue];
    }
    if ([jsonDictionary objectForKey:@"codeName"]) {
        place.code_name = [jsonDictionary objectForKey:@"codeName"];
    }
    if ([jsonDictionary objectForKey:@"mobileUrl"]) {
        place.wiki = [jsonDictionary objectForKey:@"mobileUrl"];
    }
    
    return place;
}

+(SettingsPlace *)createSettingsPlaceWithJsonDictionary:(NSDictionary *)jsonDictionary {
    /*
     [{id = 0;},
     {id = 1;}
     )
     */
    SettingsPlace *place = [[SettingsPlace alloc] init];
    
    if ([jsonDictionary objectForKey:@"id"]) {
        place.p_id = [[jsonDictionary objectForKey:@"id"] integerValue];
    }
    return place;
}

+(OfflinePlace *)createOfflinePlaceWithJsonDictionary:(NSDictionary *)jsonDictionary {
    /*
    {
        countryCode = Israel;
        id = 3;
        img = "https://upload.wikimedia.org/wikipedia/he/thumb/7/7f/Allenbytelaviv14.jpg/240px-Allenbytelaviv14.jpg";
        locationCode = Jerusalem;
        poi = 252525;
        price = "0.99";
        size = 1000;
    }
    */
    OfflinePlace *place = [[OfflinePlace alloc] init];
    
    if ([jsonDictionary objectForKey:@"countryCode"]) {
        place.countryCode = [jsonDictionary objectForKey:@"countryCode"];
    }
    if ([jsonDictionary objectForKey:@"id"]) {
        place.p_id = [[jsonDictionary objectForKey:@"id"] integerValue];
    }
    if ([jsonDictionary objectForKey:@"img"]) {
        place.img_url = [jsonDictionary objectForKey:@"img"];
    }
    if ([jsonDictionary objectForKey:@"locationCode"]) {
        place.locationCode = [jsonDictionary objectForKey:@"locationCode"];
    }
    if ([jsonDictionary objectForKey:@"poi"]) {
        place.poi = [[jsonDictionary objectForKey:@"poi"] integerValue];
    }
    if ([jsonDictionary objectForKey:@"price"]) {
        place.price = [jsonDictionary objectForKey:@"price"];
    }
    if ([jsonDictionary objectForKey:@"size"]) {
        place.size = [[jsonDictionary objectForKey:@"size"] integerValue];
    }
    return place;
}

+(Place *)createPlace:(Place *)place withJsonDictionary:(NSDictionary *)jsonDictionary {
    place.isOffline = NO;
    if ([jsonDictionary objectForKey:@"id"]) {
        place.p_id = [[jsonDictionary objectForKey:@"id"] integerValue];
    }
    if ([jsonDictionary objectForKey:@"name"]) {
        place.title = [jsonDictionary objectForKey:@"name"];
    }
    if ([jsonDictionary objectForKey:@"distance"]) {
        place.dist = [[jsonDictionary objectForKey:@"distance"] integerValue];
    }
    if ([jsonDictionary objectForKey:@"description"]) {
        place.descr = [[NSString stringWithFormat:@"%@",[jsonDictionary objectForKey:@"description"]]
                       stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    }
    if ([jsonDictionary objectForKey:@"img"]) {
        place.img_url = [jsonDictionary objectForKey:@"img"];
    }
    else {
        place.img_url = @"";
    }
    if ([jsonDictionary objectForKey:@"coX"]) {
        place.lan = [[jsonDictionary objectForKey:@"coX"] doubleValue];
    }
    if ([jsonDictionary objectForKey:@"coY"]) {
        place.lon = [[jsonDictionary objectForKey:@"coY"] doubleValue];
    }
    if ([jsonDictionary objectForKey:@"codeName"]) {
        place.code_name = [jsonDictionary objectForKey:@"codeName"];
    }
    if ([jsonDictionary objectForKey:@"mobileUrl"]) {
        place.wiki = [jsonDictionary objectForKey:@"mobileUrl"];
    }
  
    return place;
}

+(SwipePlaceFirstCell *)createSwipePlaceFirstCellWithJsonDictionary:(NSDictionary *)jsonDictionary {
    SwipePlaceFirstCell *place = [[SwipePlaceFirstCell alloc] init];
    
    if ([jsonDictionary objectForKey:@"name"]) {
        place.title = [jsonDictionary objectForKey:@"name"];
    }
    if ([jsonDictionary objectForKey:@"description"]) {
        place.descr = [[NSString stringWithFormat:@"%@",[jsonDictionary objectForKey:@"description"]]
                       stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    }
    if ([jsonDictionary objectForKey:@"img"]) {
        place.img_url = [jsonDictionary objectForKey:@"img"];
    }

    return place;
}

+(DBPlace *)fillDBPlace:(DBPlace *)dbPlace fromPlace:(Place *)place {
    dbPlace.pl_id = [NSNumber numberWithInteger:place.p_id];
    dbPlace.pl_title = place.title;
    dbPlace.pl_descr = place.descr;
    dbPlace.pl_img_url = place.img_url;
    dbPlace.pl_code_name = place.code_name;
    dbPlace.pl_audio = place.audio;
    dbPlace.pl_wiki = place.wiki;
    
    return dbPlace;
}


@end
