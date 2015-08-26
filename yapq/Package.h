//
//  Package.h
//  yapq
//
//  Created by yapQ Ltd on 5/17/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Settings.h"
#import "Constants.h"
#import "Place.h"
#import "DBPlace.h"
#import "DBPackage.h"
#import "DBPlaceCoord.h"

typedef NS_ENUM(NSInteger, PLPurchaseType) {
    PLPurchaseTypeNONE = -1,
    PLPurchaseTypeQR = 0,
    PLPurchaseTypeAppStore = 1,
    PLPurchaseTypeFree = 4
};

@interface Package : NSObject

@property (nonatomic) NSInteger packageId;
@property (strong, nonatomic) NSString *packageCountry;
@property (strong, nonatomic) NSString *packageCity;
@property (strong, nonatomic) NSString *packageName;
@property (strong, nonatomic) NSString *packageDescription;
@property (nonatomic) int numberOfPlaces;
@property (nonatomic) float radius;
@property (strong, nonatomic) NSString *packageCardCode;
@property (strong, nonatomic) NSDate *packageExpDate; // TWO month from download date
@property (strong, nonatomic) NSString *packageMoreInfoJson;
@property (strong, nonatomic) NSString *packageLink;
@property (strong, nonatomic) NSString *packageImage;
@property (strong, nonatomic) NSString *price;
@property (strong, nonatomic) NSString *packageLang;
@property (nonatomic) PLPurchaseType purchaseType;

@property float distance;

@property (nonatomic) int size; // byte

@property (nonatomic) BOOL wasDisplayed;

@property (strong, nonatomic) NSMutableArray *places;
-(id)init;
-(void)addPlace:(Place *)place;
-(void)removePlaceAtIndex:(NSUInteger)index;
-(NSArray *)getPlacesReadOnly;
-(NSString *)description;



@end
