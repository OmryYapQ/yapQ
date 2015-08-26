

#import "OfflinePlace.h"

@implementation OfflinePlace

-(id)init {
    if (self = [super init]) {
        _isOffline = NO;
    }
    return self;
}

-(BOOL)isSame:(OfflinePlace *)place {
    if (self.p_id == place.p_id) {
        return YES;
    }
    return NO;
}

-(BOOL)isEqual:(id)object {
    return [self isSame:object];
}

-(NSUInteger)hash {
    return self.p_id;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"[%@,%i,%i]",_countryCode,_p_id,_poi];
}

-(void)dispose {
    _countryCode = nil;
    _img_url = nil;
    _locationCode = nil;
    _price = nil;
}

@end
