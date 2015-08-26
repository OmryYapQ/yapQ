

#import "SwipePlaceFirstCell.h"

@implementation SwipePlaceFirstCell

-(id)init {
    if (self = [super init]) {
        _isOffline = NO;
        _wasDisplayed = NO;
    }
    return self;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"[%@,%@]",_title,_descr];
}

-(void)dispose {
    _title = nil;
    _descr = nil;
    _img_url = nil;
}

@end
