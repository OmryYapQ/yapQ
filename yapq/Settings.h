//
//  Settings.h
//  yapq
//
//  Created by yapQ Ltd on 1/10/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingsEntity.h"
#import "Utilities.h"


#define kSpeechLanguage @"SpeechLanguageKey"
//------


//----
#define tSpeechEnglish @"en"
#define tSpeechFrench @"fr"
#define tSpeechSpanish @"es"
#define tSpeechRussian @"ru"
#define tSpeechItalian @"it"
#define tSpeechPolish @"pl"
#define tSpeechChinese @"zh"
#define tSpeechKorean @"ko"
#define tSpeechJapanese @"ja"
#define tSpeechHebrew @"he"
#define tSpeechGerman @"de"
#define tSpeechDutch @"nl"
//tSpeechEnglish tSpeechFrench tSpeechSpanish tSpeechRussian tSpeechItalian tSpeechPolish tSpeechChinese tSpeechKorean tSpeechJapanese tSpeechHebrew tSpeechGerman tSpeechDutch
// @"French",@"Spanish",@"Russian",@"Italian",@"Polish",@"Chinese",@"Korean",@"Japanese",@"Hebrew",@"German",@"Dutch",

#define AVALIABLE_LANGS_IOS8 @[@"English",@"French",@"Spanish",@"Russian",@"Italian",@"Polish",@"Chinese",@"Korean",@"Japanese",@"Hebrew",@"German",@"Dutch"]
#define AVALIABLE_LANGS_IOS8_NATIVE @[@"English",@"Français",@"Español",@"Русский",@"Italiano",@"Polski",@"官話 / 官话",@"한국어",@"日本語",@"עברית",@"Deutsch",@"Nederlands"]
#define AVALIABLE_LANGS_IOS7 @[@"English",@"French",@"Spanish",@"Russian",@"Italian",@"Polish",@"Chinese",@"Korean",@"Japanese",@"Hebrew",@"German",@"Dutch"]

#define DEFAULT_RADIUS 2.5

#define SPEECH_SLIDER_MAX_VALUE 0.25
#define SPEECH_SLIDER_MIN_VALUE 0.10

#define k3GInternetSettings @"3GSettings"
#define kMemoryCleanSettings @"MemoryClean"
#define kDistanceUnitsSettings @"UnitSettings"
#define kSpeechRate @"TTS_Speech_reate"
#define kLoginAccountName @"LoginAccountName"
#define kLoginProfilePicture @"LoginProfilePicture"
#define kLoginToken @"FacebookLoginToken"

#define kLoginInProcessValue @"LoginInProcess"

#define GLOBAL_SETTINGS @"GlobalSettings"
#define LOGIN_DATA @"LoginData"

#define SETTINGS_SAVE_STATUS @"SettingsSaveStatus"
#define SETTINGS_ENTITY_CHANGED_KEY @"entityChangedKey"

#define SETTINGS_CHANGED_NOTIFICATION @"SettingsChangedNotification"

typedef NS_ENUM(NSInteger, SettingSaveState) {
    SettingSaveState_SAVED = 0,
    SettingSaveState_ERROR = 1
};

@interface Settings : NSObject

@property (strong, nonatomic) NSString *speechLanguage;
@property (strong, nonatomic) NSMutableDictionary *settingEntities;

@property (strong, nonatomic) SettingsEntity *loginNameEntity;
@property (strong, nonatomic) SettingsEntity *loginPictureEntity;
@property (strong, nonatomic) SettingsEntity *loginTokenEntity;

+(Settings *)sharedSettings;

+(NSArray *)avaliableLanguages;
+(NSArray *)avaliableLanguagesNative;
-(NSString *)languageWithIndex:(int)index;
-(BOOL)isSiriLanguage;
-(void)saveParameterForKey:(NSString *)key andValue:(id)value;
-(void)setSettingsParameterValue:(id)value forSettingsKey:(NSString *)settingsKey;
-(NSDictionary *)settings;

-(void)saveSettings;

-(BOOL)is3GEnabled;

-(BOOL)isAutoCleanMemoryEnabled;

-(BOOL)isKilomenters;

-(float)speechRate;

-(NSString *)getLoginAccountName;
-(void)setLoginAccountName:(NSString *)loginName;

-(NSString *)getLoginProfilePictureLink;
-(void)setLoginProfilePictureLink:(NSString *)pictureLink;

-(NSString *)getLoginToken;
-(void)setLoginToken:(NSString *)loginToken;
-(BOOL)isUserExist;

-(void)loadLoginData;
-(void)saveLoginData;
-(void)removeLoginData;

@end
