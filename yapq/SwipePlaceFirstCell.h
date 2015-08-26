
#import <Foundation/Foundation.h>

@interface SwipePlaceFirstCell : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *descr;
@property (strong, nonatomic) NSString *img_url;
/** Indicates if place was loaded from offline DB */
@property (nonatomic) BOOL isOffline;
@property BOOL wasDisplayed;

-(void)dispose;

@end
