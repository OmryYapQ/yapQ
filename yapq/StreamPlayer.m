//
//  StreamPlayer.m
//  yapq
//
//  Created by yapQ Ltd on 12/3/13.
//  Copyright (c) 2013 yapQ Ltd. All rights reserved.
//

#import "StreamPlayer.h"

@implementation StreamPlayer

static StreamPlayer *instance;

-(id)init {
    if (self = [super init]) {
        
        
    }
    return self;
}

-(void)initPlayer {
    _player = [[MPMoviePlayerController alloc] init] ;
    _player.movieSourceType = MPMovieSourceTypeStreaming;
}

+(StreamPlayer *)sharedPlayer {
    if (!instance) {
        instance = [[StreamPlayer alloc] init];
    }
    
    return instance;
}

-(void)playForCellDelegate:(id<StreamPlayerEventProtocol>) delegate forPlace:(Place *)place {
    
    [self pause];
    _playingCellDelegate = delegate;
    _place = place;
    //NSLog(@"Play %@ place",_place.title);
    [_playingCellDelegate playerWillPlay:_playingCellDelegate withPlace:_place];
    [_playingCellDelegate play:_playingCellDelegate withPlace:_place];
        
        //MPMoviePlayerController *player;
        //[self.view addSubview: [wikiMusicPlayer view]];
    [self initPlayer];
    NSString *address = _place.audio;//@"http://yapp.simplest.co.il/audio/";
    address = [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:address];
    [_player setContentURL:url];
    [_player prepareToPlay];
    [_player setShouldAutoplay: NO];
    [_player play];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
        
    [_playingCellDelegate playerDidPlay:_playingCellDelegate withPlace:_place];
}


-(void)playPlaceAudio:(Place *) place {
    if (place.audio.length == 0) {
        return;
    }
    [self pause];
    _place = place;
    [_place setIsPlaying:YES];
    //NSLog(@"Play %@ place",_place.title);
    [self initPlayer];
    NSString *address = _place.audio;
    address = [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:address];
    [_player setContentURL:url];
    [_player prepareToPlay];
    [_player setShouldAutoplay: NO];
    [_player play];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

-(void)pause {
    if (_place != nil && _place.isPlaying) {
        //NSLog(@"Paused %@ place",_place.title);
        [_place setIsPlaying:NO];
        [_player stop];
    }
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

@end
