//
//  SettingsCellWithSlider.m
//  yapq
//
//  Created by yapQ Ltd on 10/15/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import "SettingsCellWithSlider.h"

@implementation SettingsCellWithSlider

- (void)awakeFromNib {
    _titleLabel.font = [Utilities RobotoLightFontWithSize:17];
    [_rateSlider setContinuous:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

-(void)setSettingsEntity:(SettingsEntity *)settingsEntity {
    _settingsEntity = settingsEntity;
    _titleLabel.text = NSLocalizedString(_settingsEntity.entityName,nil);
    _rateSlider.value = [_settingsEntity.value floatValue]/SPEECH_SLIDER_MAX_VALUE;
}

-(IBAction)sliderValueChanged:(id)sender {
    float newRate = _rateSlider.value * SPEECH_SLIDER_MAX_VALUE;
    [[Settings sharedSettings] setSettingsParameterValue:[NSNumber numberWithFloat:newRate] forSettingsKey:_settingsKey];
    [[Settings sharedSettings] saveSettings];
    //[_settingsVCDelegate settingSwitch:sender changeStateForSettings:_settingsEntity];
    [Utilities taskWithDelay:1 forBlock:^{
        [self speechTest];
    }];

}

-(IBAction)sliderReleased:(id)sender {
}

-(void)speechTest {
    AVSpeechSynthesizer *player = [[AVSpeechSynthesizer alloc] init];
    AVSpeechUtterance *speech = [[AVSpeechUtterance alloc] initWithString:[self getTestTextWithLang]];
    speech.postUtteranceDelay = 0.0;
    speech.rate = _rateSlider.value * SPEECH_SLIDER_MAX_VALUE;
    speech.volume = 1.0;
    speech.preUtteranceDelay = 0.0;
    speech.pitchMultiplier = 1.0;
    AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithLanguage:[self defineSpeechLanguage]];
    speech.voice = voice;
    [player speakUtterance:speech];
}
//2015-03-08 23:59:09.230 SpeechMe[10269:1683795] ar-SA
//2015-03-08 23:59:09.232 SpeechMe[10269:1683795] en-ZA
//2015-03-08 23:59:09.232 SpeechMe[10269:1683795] nl-BE
//2015-03-08 23:59:09.232 SpeechMe[10269:1683795] en-AU
//2015-03-08 23:59:09.232 SpeechMe[10269:1683795] th-TH
//2015-03-08 23:59:09.233 SpeechMe[10269:1683795] de-DE
//2015-03-08 23:59:09.233 SpeechMe[10269:1683795] en-US
//2015-03-08 23:59:09.233 SpeechMe[10269:1683795] pt-BR
//2015-03-08 23:59:09.233 SpeechMe[10269:1683795] pl-PL
//2015-03-08 23:59:09.233 SpeechMe[10269:1683795] en-IE
//2015-03-08 23:59:09.233 SpeechMe[10269:1683795] el-GR
//2015-03-08 23:59:09.234 SpeechMe[10269:1683795] id-ID
//2015-03-08 23:59:09.234 SpeechMe[10269:1683795] sv-SE
//2015-03-08 23:59:09.234 SpeechMe[10269:1683795] tr-TR
//2015-03-08 23:59:09.234 SpeechMe[10269:1683795] pt-PT
//2015-03-08 23:59:09.234 SpeechMe[10269:1683795] ja-JP
//2015-03-08 23:59:09.235 SpeechMe[10269:1683795] ko-KR
//2015-03-08 23:59:09.235 SpeechMe[10269:1683795] hu-HU
//2015-03-08 23:59:09.235 SpeechMe[10269:1683795] cs-CZ
//2015-03-08 23:59:09.235 SpeechMe[10269:1683795] da-DK
//2015-03-08 23:59:09.236 SpeechMe[10269:1683795] es-MX
//2015-03-08 23:59:09.236 SpeechMe[10269:1683795] fr-CA
//2015-03-08 23:59:09.236 SpeechMe[10269:1683795] nl-NL
//2015-03-08 23:59:09.236 SpeechMe[10269:1683795] fi-FI
//2015-03-08 23:59:09.236 SpeechMe[10269:1683795] es-ES
//2015-03-08 23:59:09.237 SpeechMe[10269:1683795] it-IT
//2015-03-08 23:59:09.237 SpeechMe[10269:1683795] he-IL
//2015-03-08 23:59:09.237 SpeechMe[10269:1683795] no-NO
//2015-03-08 23:59:09.237 SpeechMe[10269:1683795] ro-RO
//2015-03-08 23:59:09.237 SpeechMe[10269:1683795] zh-HK
//2015-03-08 23:59:09.238 SpeechMe[10269:1683795] zh-TW
//2015-03-08 23:59:09.238 SpeechMe[10269:1683795] sk-SK
//2015-03-08 23:59:09.238 SpeechMe[10269:1683795] zh-CN
//2015-03-08 23:59:09.238 SpeechMe[10269:1683795] ru-RU
//2015-03-08 23:59:09.239 SpeechMe[10269:1683795] en-GB
//2015-03-08 23:59:09.239 SpeechMe[10269:1683795] fr-FR
//2015-03-08 23:59:09.239 SpeechMe[10269:1683795] hi-IN

//#define tSpeechEnglish @"en" -
//#define tSpeechFrench @"fr"-
//#define tSpeechSpanish @"es"-
//#define tSpeechRussian @"ru"-
//#define tSpeechItalian @"it"2
//#define tSpeechPolish @"pl"2
//#define tSpeechChinese @"zh"-
//#define tSpeechKorean @"ko"2
//#define tSpeechJapanese @"ja"2
//#define tSpeechHebrew @"he"-
//#define tSpeechGerman @"de"
//#define tSpeechDutch @"nl"
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
        return @"Enjoy your travel with yap Q";
    }
    if ([[Settings sharedSettings].speechLanguage isEqualToString:tSpeechHebrew]) {
        return @" טיול מהנה מיאפקיו";
    }
    else if ([[Settings sharedSettings].speechLanguage isEqualToString:tSpeechFrench]) {
        return @"Profitez de votre Voyage avec yap Q";
    }
    else if ([[Settings sharedSettings].speechLanguage isEqualToString:tSpeechSpanish]) {
        return @"Nautige oma reisi koos yap Q";
    }
    else if ( [[Settings sharedSettings].speechLanguage isEqualToString:tSpeechRussian]) {
        return @"Приятного путешествия с япкю";
    }
    else if ( [[Settings sharedSettings].speechLanguage isEqualToString:tSpeechChinese]) {
        return @"祝您有邑Q旅行";
    }
    
    return kVoiceEnglish;
}

@end
