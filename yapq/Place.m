

#import "Place.h"

@implementation Place

-(id)init {
    if (self = [super init]) {
        _isPlaying = NO;
        _didPlayed = NO;
        _wasDisplayed = NO;
        _isOffline = NO;
    }
    return self;
}

-(BOOL)isSame:(Place *)place {
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
    return [NSString stringWithFormat:@"[%@,%i,%i]",_title,_p_id,_dist];
}

-(void)setIsPlaying:(BOOL)isPlaying {
    _isPlaying = isPlaying;
    if (isPlaying) {
        [[NSNotificationCenter defaultCenter] postNotificationName:PLACE_PLAYING_STATE_CHANGED_NOTIFICATION object:self userInfo:@{STATUS_KEY: [NSNumber numberWithInt:PPLAY]}];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:PLACE_PLAYING_STATE_CHANGED_NOTIFICATION object:self userInfo:@{STATUS_KEY: [NSNumber numberWithInt:PSTOP]}];
    }
}

-(void)dispose {
    _title = nil;
    _descr = nil;
    _img_url = nil;
    _code_name = nil;
    _audio = nil;
    _wiki = nil;
}

-(BOOL)isFarFromPlace:(Place *)place {
    return self.dist > place.dist;
}

@end
