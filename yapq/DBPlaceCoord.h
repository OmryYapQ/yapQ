//
//  DBPlaceCoord.h
//  yapq
//
//  Created by yapQ Ltd on 7/1/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DBPlace;

@interface DBPlaceCoord : NSManagedObject

@property (nonatomic, retain) NSNumber * pc_distance;
@property (nonatomic, retain) NSNumber * pc_lat;
@property (nonatomic, retain) NSNumber * pc_lon;
@property (nonatomic, retain) DBPlace *place;

@end
