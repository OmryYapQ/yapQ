//
//  DBPlace.h
//  yapq
//
//  Created by yapQ Ltd on 7/1/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DBPackage, DBPlaceCoord;

@interface DBPlace : NSManagedObject

@property (nonatomic, retain) NSString * pl_audio;
@property (nonatomic, retain) NSString * pl_code_name;
@property (nonatomic, retain) NSString * pl_descr;
@property (nonatomic, retain) NSNumber * pl_fk_id;
@property (nonatomic, retain) NSNumber * pl_id;
@property (nonatomic, retain) NSString * pl_img_url;
@property (nonatomic, retain) NSString * pl_title;
@property (nonatomic, retain) NSString * pl_wiki;
@property (nonatomic, retain) DBPlaceCoord *coord;
@property (nonatomic, retain) DBPackage *package;

@end
