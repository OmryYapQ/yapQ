//
//  DBPackage.h
//  yapq
//
//  Created by yapQ Ltd on 7/1/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DBPlace;

@interface DBPackage : NSManagedObject

@property (nonatomic, retain) NSString * p_bundle_id;
@property (nonatomic, retain) NSString * p_card_code;
@property (nonatomic, retain) NSString * p_city;
@property (nonatomic, retain) NSString * p_country;
@property (nonatomic, retain) NSString * p_descr;
@property (nonatomic, retain) NSDate * p_exp_date;
@property (nonatomic, retain) NSNumber * p_id;
@property (nonatomic, retain) NSString * p_image;
@property (nonatomic, retain) NSString * p_lang;
@property (nonatomic, retain) NSString * p_link;
@property (nonatomic, retain) NSString * p_more_json;
@property (nonatomic, retain) NSString * p_name;
@property (nonatomic, retain) NSNumber * p_num_of_places;
@property (nonatomic, retain) NSString * p_price;
@property (nonatomic, retain) NSNumber * p_purchase_type;
@property (nonatomic, retain) NSNumber * p_radius;
@property (nonatomic, retain) NSNumber * p_size;
@property (nonatomic, retain) NSSet *places;
@end

@interface DBPackage (CoreDataGeneratedAccessors)

- (void)addPlacesObject:(DBPlace *)value;
- (void)removePlacesObject:(DBPlace *)value;
- (void)addPlaces:(NSSet *)values;
- (void)removePlaces:(NSSet *)values;

@end
