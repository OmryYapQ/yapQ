//
//  Package.m
//  yapq
//
//  Created by yapQ Ltd on 5/17/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import "Package.h"

@implementation Package

-(id)init {
    if (self = [super init]) {
        _radius = DEFAULT_RADIUS;
        _places = [[NSMutableArray alloc] init];
        _packageDescription = @"";
        _packageMoreInfoJson = @"";
        _purchaseType = PLPurchaseTypeNONE;
        _packageLang = [Settings sharedSettings].speechLanguage;
    }
    return self;
}

-(void)addPlace:(Place *)place {
    [_places addObject:place];
    _numberOfPlaces = (int)_places.count;
}

-(void)removePlaceAtIndex:(NSUInteger)index {
    if (index < _places.count) {
        [_places removeObjectAtIndex:index];
        _numberOfPlaces = (int)_places.count;
    }
}

-(NSArray *)getPlacesReadOnly {
    return [_places mutableCopy];
}

-(BOOL)isEqual:(id)object {
    Package *package = object;
    return _packageId == package.packageId;
}

-(NSUInteger)hash {
    return _packageId;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"[id=%li, country=%@, city=%@, name=%@, descr=%@, #pl=%i, code=%@, lang=@%@, expDate=%@]",
            (long)_packageId,
            _packageCountry,
            _packageCity,
            _packageName,
            _packageDescription,
            _numberOfPlaces,
            _packageCardCode,
            _packageLang,
            _packageExpDate];
}

@end
