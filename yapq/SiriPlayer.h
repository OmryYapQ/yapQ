//
//  SiriPlayer.h
//  yapq
//
//  Created by yapQ Ltd on 1/14/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "Place.h"
#import "Settings.h"

#define YAP_SPEECH_SPEED_IOS8 0.14
#define YAP_SPEECH_SPEED_IOS7 0.14

#define SiriPlayerStartPlayingNotification @"SiriStartPlaying"
#define SiriPlayerFinishPlayingNotification @"SiriFinishPlaying"
#define SiriPlayerPausePlayingNNotification @"SiriPausePlaying"

#define kPlayer @"SiriPlayer"
#define kStatus @"SiriPlayerStatus"

#define SPPlay @"Play"
#define SPPause @"Pause"
#define SPFinished @"Finished"

#define kVoiceEnglish @"en-US"
#define kVoiceHebrew @"he-IL"
#define kVoiceFrench @"fr-FR"
#define kVoiceSpanish @"es-MX"
#define kVoiceRussian @"ru-RU"
#define kVoiceChinese @"zh-HK"
#define kVoiceItalian @"it-IT"
#define kVoicePolish @"pl-PL"
#define kVoiceKorean @"ko-KR"
#define kVoiceJapanese @"ja-JP"
#define kVoiceGerman @"de-DE"
#define kVoiceDutch @"nl-NL"



@interface SiriPlayer : NSObject <AVSpeechSynthesizerDelegate>


@property (strong, nonatomic) AVSpeechSynthesizer *player;

@property (strong) Place *place;

@property BOOL isPaused;

@property BOOL isReset;

+(SiriPlayer *)sharedPlayer;

-(void)initPlayer;


-(void)playPlaceAudio:(Place *) place;

-(void)pauseWithCompletion:(void(^)(void))block;

@end
