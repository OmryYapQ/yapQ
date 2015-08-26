//
//  StreamPlayer.h
//  yapq
//
//  Created by yapQ Ltd
//  Copyright (c) 2013 yapQ Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "Place.h"
#import "PPButton.h"
#import "StreamPlayerEventProtocol.h"

@interface StreamPlayer : NSObject 

@property id<StreamPlayerEventProtocol> playingCellDelegate;

@property (strong, nonatomic) MPMoviePlayerController *player;

@property (strong, nonatomic) Place *place;


+(StreamPlayer *)sharedPlayer;

-(void)playForCellDelegate:(id<StreamPlayerEventProtocol>) delegate forPlace:(Place *)place;

-(void)playPlaceAudio:(Place *) place;

-(void)pause;

@end
