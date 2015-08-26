//
//  SiriPlayer.m
//  yapq
//
//  Created by yapQ Ltd on
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import "SiriPlayer.h"

@implementation SiriPlayer

static SiriPlayer *instance = nil;

-(id)init {
    if (self = [super init]) {
        [self initPlayer];
    }
    
    return self;
}

+(SiriPlayer *)sharedPlayer {
    if (!instance) {
        instance = [[SiriPlayer alloc] init];
    }
    
    return instance;
}

-(void)initPlayer {
    _player = [[AVSpeechSynthesizer alloc] init];
    _player.delegate = self;
    
    _isPaused = NO;
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Siri Delegate methods
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////
-(void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didStartSpeechUtterance:(AVSpeechUtterance *)utterance {
    NSLog(@"Siri didStartSpeechUtterance");
    if (_place ==  nil) {
        return;
    }

    if (_isReset && [Utilities currentVersionOfOS] == UTIOS_8) {
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:SiriPlayerStartPlayingNotification object:self userInfo:@{kStatus: SPPlay}];
}

-(void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didPauseSpeechUtterance:(AVSpeechUtterance *)utterance {
    NSLog(@"Siri didPauseSpeechUtterance");
    
}

-(void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance {
    if (_place == nil) {
        return;
    }
    if (synthesizer.isSpeaking) {
        return;
    }
    if (_isReset && [Utilities currentVersionOfOS] == UTIOS_8) {
        _isReset = NO;
        return;
    }
    
    if (!_isPaused) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SiriPlayerFinishPlayingNotification object:self userInfo:@{kStatus: SPFinished}];
    }
    else {
        _isPaused = NO;
    }
}

-(void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didCancelSpeechUtterance:(AVSpeechUtterance *)utterance {
    NSLog(@"Siri didCancelSpeechUtterance");
    
}

-(void)playPlaceAudio:(Place *)place {
    if (place.descr.length == 0) {
        return;
    }
    @try {
        //_player.delegate = self;
        [self pauseWithCompletion:^{
            
        }];
        _place = place;
        [_place setIsPlaying:YES];
        NSLog(@"Play SIRI %@ place",_place.title);
        if ([Utilities currentVersionOfOS] == UTIOS_8) {
            _isReset = YES;
            AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:[self getTestTextWithLang]];
            utterance.volume = 0;
            AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithLanguage:[self defineSpeechLanguage]];
            utterance.voice = voice;
            [_player speakUtterance:utterance];
            //[_player stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
        }
        //_player = nil;
        //[self initPlayer];
        AVSpeechUtterance *speech = [[AVSpeechUtterance alloc] initWithString:_place.descr];
        speech.postUtteranceDelay = 0.0;
        speech.rate = [self getSpeechRate];
        speech.volume = 1.0;
        speech.preUtteranceDelay = 0.0;
        speech.pitchMultiplier = 1.0;
        AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithLanguage:[self defineSpeechLanguage]];
//        AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithLanguage:@" "];
        speech.voice = voice;
        [_player speakUtterance:speech];
        /*if ([Utilities currentVersionOfOS] == UTIOS_8) {
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionDuckOthers error:nil];
            [[AVAudioSession sharedInstance] setActive:YES error:nil];
        }
        else {
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
            [[AVAudioSession sharedInstance] setActive:YES error:nil];
        }*/
    }
    @catch (NSException *exception) {
        
    }
}

-(void)pauseWithCompletion:(void(^)(void))block {
    //[Utilities taskWithDelay:0.5 forBlock:^{
    //[Utilities UITaskInSeparatedBlock:^{
        @try {
            if (_place != nil && _place.isPlaying) {
                [_place setIsPlaying:NO];
                _isPaused = YES;
                NSLog(@"Paused %@ place",_place.title);
                
                /// ========= Solving pause bug
                [_player stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
                if ([Utilities currentVersionOfOS] == UTIOS_7) {
                    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:@""];
                    [_player speakUtterance:utterance];
                    [_player stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
                }
                // =============
            }
            else {
                _isPaused = NO; // Solve play next after pause
            }
            /*if ([Utilities currentVersionOfOS] == UTIOS_8) {
                [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionDuckOthers error:nil];
                [[AVAudioSession sharedInstance] setActive:NO error:nil];
            }
            else {
                [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
                [[AVAudioSession sharedInstance] setActive:NO error:nil];
            }*/
            
            if (block) {
                block();
            }
        }
        @catch (NSException *exception) {
#if DEBUG
            NSLog(@"%@",exception);
#endif
        }
    //}];
    
    //}];
}

-(NSString *)defineSpeechLanguage {
    
    if ([[Settings sharedSettings].speechLanguage isEqualToString:tSpeechEnglish]) {
        return kVoiceEnglish;
    }
    if ([[Settings sharedSettings].speechLanguage isEqualToString:tSpeechHebrew]) {
        return kVoiceHebrew;
    }
    else if ([[Settings sharedSettings].speechLanguage isEqualToString:tSpeechFrench]) {
        return kVoiceFrench;
    }
    else if ([[Settings sharedSettings].speechLanguage isEqualToString:tSpeechSpanish]) {
        return kVoiceSpanish;
    }
    else if ( [[Settings sharedSettings].speechLanguage isEqualToString:tSpeechRussian]) {
        return kVoiceRussian;
    }
    else if ( [[Settings sharedSettings].speechLanguage isEqualToString:tSpeechChinese]) {
        return kVoiceChinese;
    }
    else if ( [[Settings sharedSettings].speechLanguage isEqualToString:tSpeechItalian]) {
        return kVoiceItalian;
    }
    else if ( [[Settings sharedSettings].speechLanguage isEqualToString:tSpeechPolish]) {
        return kVoicePolish;
    }
    else if ( [[Settings sharedSettings].speechLanguage isEqualToString:tSpeechKorean]) {
        return kVoiceKorean;
    }
    else if ( [[Settings sharedSettings].speechLanguage isEqualToString:tSpeechJapanese]) {
        return kVoiceJapanese;
    }
    else if ( [[Settings sharedSettings].speechLanguage isEqualToString:tSpeechGerman]) {
        return kVoiceGerman;
    }
    else if ( [[Settings sharedSettings].speechLanguage isEqualToString:tSpeechDutch]) {
        return kVoiceDutch;
    }
    return kVoiceEnglish;
}

-(NSString *)getTestTextWithLang {
    if ([[Settings sharedSettings].speechLanguage isEqualToString:tSpeechEnglish]) {
        return @"Yapq";
    }
    if ([[Settings sharedSettings].speechLanguage isEqualToString:tSpeechHebrew]) {
        return @"איפקיו";
    }
    else if ([[Settings sharedSettings].speechLanguage isEqualToString:tSpeechFrench]) {
        return @"Ya";
    }
    else if ([[Settings sharedSettings].speechLanguage isEqualToString:tSpeechSpanish]) {
        return @"ya";
    }
    else if ( [[Settings sharedSettings].speechLanguage isEqualToString:tSpeechRussian]) {
        return @"Я";
    }
    else if ( [[Settings sharedSettings].speechLanguage isEqualToString:tSpeechChinese]) {
        return @"雅";
    }
    
    return kVoiceEnglish;
}

-(float)getSpeechRate {
    /*if ([Utilities currentVersionOfOS] == UTIOS_8) {
        return YAP_SPEECH_SPEED_IOS8;
    }*/
    return [[Settings sharedSettings] speechRate];
}

@end
