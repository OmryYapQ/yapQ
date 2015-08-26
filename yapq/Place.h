
#import <Foundation/Foundation.h>


#define PLACE_PLAYING_STATE_CHANGED_NOTIFICATION @"PlayingStateChanged"
#define STATUS_KEY @"Status"


typedef NS_ENUM(NSInteger, PlayingState) {
    PPLAY = 1,
    PSTOP = 2
};

@interface Place : NSObject

@property (nonatomic, assign) NSInteger p_id;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *descr;
@property (strong, nonatomic) NSString *img_url;
@property (nonatomic, assign) double lan;
@property (nonatomic, assign) double lon;
@property (nonatomic, assign) NSInteger dist;
@property (strong, nonatomic) NSString *code_name;
@property (strong, nonatomic) NSString *audio;
@property (strong, nonatomic) NSString *wiki;

@property (nonatomic, assign) BOOL isPlaying;
@property BOOL didPlayed;
@property BOOL wasDisplayed;

/** Indicates if place was loaded from offline DB */
@property (nonatomic) BOOL isOffline;

-(BOOL)isSame:(Place *)place;

-(BOOL)isFarFromPlace:(Place *)place;

-(void)dispose;

@end
