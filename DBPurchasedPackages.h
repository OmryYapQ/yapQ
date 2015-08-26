//
//  yapq.h
//  yapq
//
//  Created by yapQ Ltd on 7/1/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DBPurchasedPackages : NSManagedObject

@property (nonatomic, retain) NSString * p_card_code;
@property (nonatomic, retain) NSString * p_city;
@property (nonatomic, retain) NSString * p_country;
@property (nonatomic, retain) NSString * p_descr;
@property (nonatomic, retain) NSNumber * p_id;
@property (nonatomic, retain) NSString * p_image;
@property (nonatomic, retain) NSString * p_name;
@property (nonatomic, retain) NSNumber * p_purchase_type;
@property (nonatomic, retain) NSNumber * p_num_of_places;

@end
