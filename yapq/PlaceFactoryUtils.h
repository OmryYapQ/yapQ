//
//  PlaceFactoryUtils.h
//  yapq
//
//  Created by yapQ Ltd on 5/16/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Place;
@class SettingsPlace;
@class OfflinePlace;
@class DBPlace;
@class SwipePlaceFirstCell;

@interface PlaceFactoryUtils : NSObject

+(Place *)createPlaceWithDBPlace:(DBPlace *)dbPlace;
+(Place *)createPlaceWithJsonDictionary:(NSDictionary *)jsonDictionary;
+(SettingsPlace *)createSettingsPlaceWithJsonDictionary:(NSDictionary *)jsonDictionary;
+(OfflinePlace *)createOfflinePlaceWithJsonDictionary:(NSDictionary *)jsonDictionary;
+(SwipePlaceFirstCell *)createSwipePlaceFirstCellWithJsonDictionary:(NSDictionary *)jsonDictionary;

+(Place *)createPlace:(Place *)place withJsonDictionary:(NSDictionary *)jsonDictionary;

+(DBPlace *)fillDBPlace:(DBPlace *)dbPlace fromPlace:(Place *)place;

@end
