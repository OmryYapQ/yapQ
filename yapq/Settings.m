//
//  Settings.m
//  yapq
//
//  Created by yapQ Ltd
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import "Settings.h"

@implementation Settings

static Settings *instance = nil;

-(id)init {
    if (self = [super init]) {
        
        [self loadAll];
        [self loadLoginData];
        if (_speechLanguage == nil) {
            [self initLanguageDefaults];
            [self loadAll];
        }
        NSMutableSet *allSettingKeys = [NSMutableSet setWithObjects:k3GInternetSettings,kMemoryCleanSettings,kDistanceUnitsSettings,kSpeechRate, nil];
        NSSet *existingSettingsKeys = [NSSet setWithArray:[_settingEntities allKeys]];
        [allSettingKeys minusSet:existingSettingsKeys];
        if (allSettingKeys.count > 0) {
            [self initDefaults:allSettingKeys];
            [self loadAll];
            //NSLog(@"%@",_settingEntities);
        }
    }
    return self;
}

+(Settings *)sharedSettings {
    if (!instance) {
        instance = [[Settings alloc] init];
    }
    
    return instance;
}

-(void)loadAll {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _speechLanguage = [defaults objectForKey:kSpeechLanguage];
    NSData *achivedSettings = [defaults objectForKey:GLOBAL_SETTINGS];
    _settingEntities = (NSMutableDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:achivedSettings];
    //_settingEntities = [defaults objectForKey:GLOBAL_SETTINGS];
}

-(void)saveParameterForKey:(NSString *)key andValue:(id)value {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:value forKey:key];
    [defaults synchronize];
    [self loadAll];
    if ([key isEqualToString:kSpeechLanguage]) {
        [self saveLocalization];
    }
}
//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Language Settings
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////
+(NSArray *)avaliableLanguages {
    if ([Utilities currentVersionOfOS] == UTIOS_8) {
        return AVALIABLE_LANGS_IOS8;
    }
    else {
        return AVALIABLE_LANGS_IOS7;
    }
    
}
+(NSArray *)avaliableLanguagesNative {
        return AVALIABLE_LANGS_IOS8_NATIVE;
    
}
-(void)initLanguageDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *langs = [NSLocale preferredLanguages];
    if ([[NSLocale canonicalLanguageIdentifierFromString:[langs objectAtIndex:0]]isEqualToString:tSpeechFrench]) {
        [defaults setObject:tSpeechFrench forKey:kSpeechLanguage];
    }
    else if ([[NSLocale canonicalLanguageIdentifierFromString:[langs objectAtIndex:0]]isEqualToString:tSpeechHebrew] &&
             [Utilities currentVersionOfOS] == UTIOS_8) {
        [defaults setObject:tSpeechHebrew forKey:kSpeechLanguage];
    }
    else if ([[NSLocale canonicalLanguageIdentifierFromString:[langs objectAtIndex:0]]isEqualToString:tSpeechSpanish]) {
        [defaults setObject:tSpeechSpanish forKey:kSpeechLanguage];
    }
    else if ([[NSLocale canonicalLanguageIdentifierFromString:[langs objectAtIndex:0]]isEqualToString:tSpeechRussian]) {
        [defaults setObject:tSpeechRussian forKey:kSpeechLanguage];
    }
    else if ([[NSLocale canonicalLanguageIdentifierFromString:[langs objectAtIndex:0]]isEqualToString:tSpeechChinese]) {
        [defaults setObject:tSpeechChinese forKey:kSpeechLanguage];
    }
    else if ([[NSLocale canonicalLanguageIdentifierFromString:[langs objectAtIndex:0]]isEqualToString:tSpeechItalian]) {
        [defaults setObject:tSpeechItalian forKey:kSpeechLanguage];
    }
    else if ([[NSLocale canonicalLanguageIdentifierFromString:[langs objectAtIndex:0]]isEqualToString:tSpeechPolish]) {
        [defaults setObject:tSpeechPolish forKey:kSpeechLanguage];
    }
    else if ([[NSLocale canonicalLanguageIdentifierFromString:[langs objectAtIndex:0]]isEqualToString:tSpeechKorean]) {
        [defaults setObject:tSpeechChinese forKey:kSpeechLanguage];
    }
    else if ([[NSLocale canonicalLanguageIdentifierFromString:[langs objectAtIndex:0]]isEqualToString:tSpeechJapanese]) {
        [defaults setObject:tSpeechJapanese forKey:kSpeechLanguage];
    }
    else if ([[NSLocale canonicalLanguageIdentifierFromString:[langs objectAtIndex:0]]isEqualToString:tSpeechGerman]) {
        [defaults setObject:tSpeechGerman forKey:kSpeechLanguage];
    }
    else if ([[NSLocale canonicalLanguageIdentifierFromString:[langs objectAtIndex:0]]isEqualToString:tSpeechDutch]) {
        [defaults setObject:tSpeechDutch forKey:kSpeechLanguage];
    }
    else {
        [defaults setObject:tSpeechEnglish forKey:kSpeechLanguage];
    }
    [defaults synchronize];
}

-(NSString *)languageWithIndex:(int)index {
    if ([Utilities currentVersionOfOS] == UTIOS_8) {
//#define tSpeechEnglish @"en"-
//#define tSpeechFrench @"fr"-
//#define tSpeechSpanish @"es"-
//#define tSpeechRussian @"ru"-
//#define tSpeechItalian @"it"-
//#define tSpeechPolish @"pl"-
//#define tSpeechChinese @"zh"-
//#define tSpeechKorean @"ko"-
//#define tSpeechJapanese @"ja"-
//#define tSpeechHebrew @"he"-
//#define tSpeechGerman @"de"
//#define tSpeechDutch @"nl"
        switch (index) {
            case 0:
                return tSpeechEnglish;
            case 1:
                return tSpeechFrench;
            case 2:
                return tSpeechSpanish;
            case 3:
                return tSpeechRussian;
            case 4:
                return tSpeechItalian;
            case 5:
                return tSpeechPolish;
            case 6:
                return tSpeechChinese;
            case 7:
                return tSpeechKorean;
            case 8:
                return tSpeechJapanese;
            case 9:
                return tSpeechHebrew;
            case 10:
                return tSpeechGerman;
            case 11:
                return tSpeechDutch;
            default:
                return tSpeechEnglish;
        }
    }
    else {
        switch (index) {
            case 0:
                return tSpeechEnglish;
            case 1:
                return tSpeechFrench;
            case 2:
                return tSpeechSpanish;
            case 3:
                return tSpeechRussian;
            case 4:
                return tSpeechItalian;
            case 5:
                return tSpeechPolish;
            case 6:
                return tSpeechChinese;
            case 7:
                return tSpeechKorean;
            case 8:
                return tSpeechJapanese;
            case 9:
                return tSpeechHebrew;
            case 10:
                return tSpeechGerman;
            case 11:
                return tSpeechDutch;
            default:
                return tSpeechEnglish;
        }
    }
    
}

-(BOOL)isSiriLanguage {
    //tSpeechEnglish tSpeechFrench tSpeechSpanish tSpeechRussian tSpeechItalian tSpeechPolish tSpeechChinese tSpeechKorean tSpeechJapanese tSpeechHebrew tSpeechGerman tSpeechDutch
    if ([self.speechLanguage isEqualToString:tSpeechEnglish] ||
        [self.speechLanguage isEqualToString:tSpeechFrench] ||
        [self.speechLanguage isEqualToString:tSpeechSpanish] ||
        [self.speechLanguage isEqualToString:tSpeechRussian] ||
        [self.speechLanguage isEqualToString:tSpeechItalian] ||
        [self.speechLanguage isEqualToString:tSpeechPolish] ||
        [self.speechLanguage isEqualToString:tSpeechChinese] ||
        [self.speechLanguage isEqualToString:tSpeechKorean] ||
        [self.speechLanguage isEqualToString:tSpeechJapanese] ||
        [self.speechLanguage isEqualToString:tSpeechGerman] ||
        [self.speechLanguage isEqualToString:tSpeechDutch] ||
        [self.speechLanguage isEqualToString:tSpeechHebrew]) {
        return YES;
    }
    return NO;
}


-(void)saveLocalization {
    NSArray *supportedLanguages;
    if ([_speechLanguage isEqualToString:tSpeechEnglish]) {
        supportedLanguages = [NSArray arrayWithObjects:tSpeechEnglish,tSpeechHebrew, nil];
    }
    else if ([_speechLanguage isEqualToString:tSpeechHebrew]) {
        supportedLanguages = [NSArray arrayWithObjects:tSpeechHebrew,tSpeechEnglish, nil];
    }
    else if ([_speechLanguage isEqualToString:tSpeechFrench]) {
        supportedLanguages = [NSArray arrayWithObjects:tSpeechFrench,tSpeechEnglish, nil];
    }
    else if ([_speechLanguage isEqualToString:tSpeechChinese]) {
        supportedLanguages = [NSArray arrayWithObjects:tSpeechChinese,tSpeechEnglish, nil];
    }
    else if ([_speechLanguage isEqualToString:tSpeechRussian]) {
        supportedLanguages = [NSArray arrayWithObjects:tSpeechRussian,tSpeechEnglish, nil];
    }
    else if ([_speechLanguage isEqualToString:tSpeechSpanish]) {
        supportedLanguages = [NSArray arrayWithObjects:tSpeechSpanish,tSpeechEnglish, nil];
    }
    else if ([_speechLanguage isEqualToString:tSpeechItalian]) {
        supportedLanguages = [NSArray arrayWithObjects:tSpeechItalian,tSpeechEnglish, nil];
    }
    else if ([_speechLanguage isEqualToString:tSpeechPolish]) {
        supportedLanguages = [NSArray arrayWithObjects:tSpeechPolish,tSpeechEnglish, nil];
    }
    else if ([_speechLanguage isEqualToString:tSpeechKorean]) {
        supportedLanguages = [NSArray arrayWithObjects:tSpeechKorean,tSpeechEnglish, nil];
    }
    else if ([_speechLanguage isEqualToString:tSpeechJapanese]) {
        supportedLanguages = [NSArray arrayWithObjects:tSpeechJapanese,tSpeechEnglish, nil];
    }
    else if ([_speechLanguage isEqualToString:tSpeechGerman]) {
        supportedLanguages = [NSArray arrayWithObjects:tSpeechGerman,tSpeechEnglish, nil];
    }
    else if ([_speechLanguage isEqualToString:tSpeechDutch]) {
        supportedLanguages = [NSArray arrayWithObjects:tSpeechDutch,tSpeechEnglish, nil];
    }
    [[NSUserDefaults standardUserDefaults] setObject:supportedLanguages forKey:@"AppleLanguages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self loadAll];

}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark App Settings
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////
-(void)initDefaults:(NSSet *)needToInitKeys {
    
    if ([needToInitKeys containsObject:k3GInternetSettings]) {
        _settingEntities = [[NSMutableDictionary alloc] init];
        SettingsEntity *internetSettings = [[SettingsEntity alloc] init];
        internetSettings.entityName = @"Data Roaming";
        internetSettings.entityDescription = @"Enable 3G network connection when WiFi is not available.";
        internetSettings.value = [NSNumber numberWithBool:YES];
        //[_settingEntities setValue:internetSettings forKey:k3GInternetSettings];
        [_settingEntities setObject:internetSettings forKey:k3GInternetSettings];
    }
    
    if ([needToInitKeys containsObject:kMemoryCleanSettings]) {
        SettingsEntity *memoryCleanSettings = [[SettingsEntity alloc] init];
        memoryCleanSettings.entityName = @"Free Memory";
        memoryCleanSettings.entityDescription = @"Delete City you won’t need.\nYou can always redownload it later.";
        memoryCleanSettings.value = [NSNumber numberWithBool:YES];
        
        [_settingEntities setObject:memoryCleanSettings forKey:kMemoryCleanSettings];
    }
    
    if ([needToInitKeys containsObject:kDistanceUnitsSettings]) {
        SettingsEntity *distanceUnitsSettings = [[SettingsEntity alloc] init];
        distanceUnitsSettings.entityName = @"Units";
        distanceUnitsSettings.entityDescription = @"Kilometers";
        distanceUnitsSettings.value = [NSNumber numberWithBool:YES];
        
        [_settingEntities setObject:distanceUnitsSettings forKey:kDistanceUnitsSettings];
    }
    
    if ([needToInitKeys containsObject:kSpeechRate]) {
        float rate = 0.11;
        SettingsEntity *speechRate = [[SettingsEntity alloc] init];
        speechRate.entityName = @"Speech rate";
        speechRate.entityDescription = @"";
        speechRate.value = [NSNumber numberWithFloat:rate];
        
        [_settingEntities setObject:speechRate forKey:kSpeechRate];
    }
    
    [self saveSettings];
}

-(void)saveSettings {
    NSData* archiveData = [NSKeyedArchiver archivedDataWithRootObject:_settingEntities];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:archiveData forKey:GLOBAL_SETTINGS];
    [defaults synchronize];
}

-(void)setSettingsParameterValue:(id)value forSettingsKey:(NSString *)settingsKey {
    @try {
        SettingsEntity *se = [_settingEntities valueForKey:settingsKey];
        [se setValue:value];
        [_settingEntities setObject:se forKey:settingsKey];
        [self saveSettings];
        NSDictionary *userInfo = @{SETTINGS_SAVE_STATUS: [NSNumber numberWithInteger:SettingSaveState_SAVED], SETTINGS_ENTITY_CHANGED_KEY: settingsKey};
        [[NSNotificationCenter defaultCenter] postNotificationName:SETTINGS_CHANGED_NOTIFICATION object:nil userInfo:userInfo];
    }
    @catch (NSException *exception) {
        NSDictionary *userInfo = @{SETTINGS_SAVE_STATUS: [NSNumber numberWithInteger:SettingSaveState_ERROR]};
        [[NSNotificationCenter defaultCenter] postNotificationName:SETTINGS_CHANGED_NOTIFICATION object:nil userInfo:userInfo];
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createExceptionWithDescription:[NSString stringWithFormat:@"c:%i,%@",EC_SETTING_CHANGE_NOTIFICATION,exception.description]
                                                                  withFatal:[NSNumber numberWithBool:YES]] build]];
    }
}

-(NSDictionary *)settings {
    return [_settingEntities mutableCopy];
}

-(BOOL)is3GEnabled {
    SettingsEntity *se = [_settingEntities valueForKey:k3GInternetSettings];
    return [se.value boolValue];
}

-(BOOL)isAutoCleanMemoryEnabled {
    SettingsEntity *se = [_settingEntities valueForKey:kMemoryCleanSettings];
    return [se.value boolValue];
}

-(BOOL)isKilomenters {
    SettingsEntity *se = [_settingEntities valueForKey:kDistanceUnitsSettings];
    return [se.value boolValue];
}

-(float)speechRate {
    SettingsEntity *se = [_settingEntities valueForKey:kSpeechRate];
    return [se.value floatValue];
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Login Data
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////
-(NSString *)getLoginAccountName {
    return _loginNameEntity.value;
}

-(void)setLoginAccountName:(NSString *)loginName {
    if (!_loginNameEntity) {
        _loginNameEntity = [[SettingsEntity alloc] init];
        _loginNameEntity.entityName = @"User name";
        _loginNameEntity.entityDescription = @"user name";
    }
    _loginNameEntity.value = loginName;
}

-(NSString *)getLoginProfilePictureLink {
    return _loginPictureEntity.value;
}

-(void)setLoginProfilePictureLink:(NSString *)pictureLink {
    if (!_loginPictureEntity) {
        _loginPictureEntity = [[SettingsEntity alloc] init];
        _loginPictureEntity.entityName = @"User picture";
        _loginPictureEntity.entityDescription = @"user picture";
    }
    _loginPictureEntity.value = pictureLink;
}

-(NSString *)getLoginToken {
    return _loginTokenEntity.value;
}

-(void)setLoginToken:(NSString *)loginToken {
    if (!_loginTokenEntity) {
        _loginTokenEntity = [[SettingsEntity alloc] init];
        _loginTokenEntity.entityName = @"Login token";
        _loginTokenEntity.entityDescription = @"login token";
    }
    _loginTokenEntity.value = loginToken;
}

-(void)removeLoginData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:LOGIN_DATA];
    _loginNameEntity = nil;
    _loginPictureEntity = nil;
    _loginTokenEntity = nil;
    [defaults synchronize];
}

-(void)loadLoginData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *achivedSettings = [defaults objectForKey:LOGIN_DATA];
    NSDictionary *loginData = (NSMutableDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:achivedSettings];
    
    _loginNameEntity = [loginData valueForKey:kLoginAccountName];
    _loginPictureEntity = [loginData valueForKey:kLoginProfilePicture];
    _loginTokenEntity = [loginData valueForKey:kLoginToken];
}

-(void)saveLoginData {
    NSMutableDictionary *loginData = [[NSMutableDictionary alloc] init];
    if (_loginTokenEntity) {
        [loginData setObject:_loginNameEntity forKey:kLoginAccountName];
    }
    if (_loginPictureEntity) {
        [loginData setObject:_loginPictureEntity forKey:kLoginProfilePicture];
    }
    if (_loginTokenEntity) {
        [loginData setObject:_loginTokenEntity forKey:kLoginToken];
    }
    if (loginData.count == 3) {
        NSData* archiveData = [NSKeyedArchiver archivedDataWithRootObject:loginData];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:archiveData forKey:LOGIN_DATA];
        [defaults synchronize];
    }
}

-(BOOL)isUserExist {
    return [self getLoginToken] != nil &&
    [self getLoginAccountName] != nil;
}

@end
