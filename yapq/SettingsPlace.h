
#import <Foundation/Foundation.h>


@interface SettingsPlace : NSObject

@property (nonatomic, assign) NSInteger p_id;

@property (nonatomic) BOOL isOffline;
@property BOOL wasDisplayed;

-(BOOL)isSame:(SettingsPlace *)place;

-(void)dispose;

@end
