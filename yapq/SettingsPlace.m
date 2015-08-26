

#import "SettingsPlace.h"

@implementation SettingsPlace

-(id)init {
    if (self = [super init]) {
        _isOffline = NO;
        _wasDisplayed = NO;
    }
    return self;
}

-(BOOL)isSame:(SettingsPlace *)place {
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
    return [NSString stringWithFormat:@"[%i]",_p_id];
}

-(void)dispose {
}

@end
