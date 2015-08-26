
#import <Foundation/Foundation.h>

@interface OfflinePlace : NSObject

@property (nonatomic, assign) NSInteger p_id;
@property (nonatomic, strong) NSString *countryCode;
@property (nonatomic, strong) NSString *img_url;
@property (nonatomic, strong) NSString *locationCode;
@property (nonatomic, assign) NSInteger poi;
@property (nonatomic, strong) NSString *price;
@property (nonatomic, assign) NSInteger size;
@property (nonatomic) BOOL isOffline;

-(BOOL)isSame:(OfflinePlace *)place;

-(void)dispose;

@end
