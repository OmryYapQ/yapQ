
/**
 * @author yapQ Ltd
 * Copyright (c) 2013 yapQ Ltd. All rights reserved.
 */
#import <Foundation/Foundation.h>
#import <zlib.h>
#import <CommonCrypto/CommonCrypto.h>
#import "ErrorCodes.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "YLocation.h"

typedef NS_ENUM(NSInteger, UTOSVersion) {
    UTIOS_5,
    UTIOS_6,
    UTIOS_7,
    UTIOS_8
};

#define KEYBOARD_H 216

#define TMP NSTemporaryDirectory()
#define DOC NSDocumentDirectory()

#define LANGUAGE_KEY @"Lang"

@interface Utilities : NSObject

+(UTOSVersion)currentVersionOfOS;
+(NSURL *)applicationDocumentsDirectory;
+(void)taskInSeparatedBlock:(void(^)(void)) block;
+(void)taskInSeparatedThread:(void(^)(void)) block;
+(void)UITaskInSeparatedBlock:(void(^)(void)) block;
//+(void)calculationAsyncTaskInSeparatedThread:(void(^)(void)) block;
+(void)taskWithDelay:(NSInteger)delay forBlock:(void(^)(void)) block;

+(void)cacheImage:(NSString *)ImageURLString isOffline:(BOOL)isOffline;
+(UIImage *)getCachedImage:(NSString *)ImageURLString;
+(NSString *)imagePathMD5FromPackageName:(NSString *)packageName;
+(void)clearCacheOnAppLoad;

+(UIColor *)colorWith255StyleRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha;

+(NSString *)md5:(NSString *)input;
+(BOOL)validateEmailWithString:(NSString*)email;
+(NSString *)urlEncodeForString:(NSString *)string byUsingEncoding:(NSStringEncoding)encoding;

+(NSString *)defaultLanguage;

+(void)showLabelWithMessage:(NSString *)message inView:(UIView *)view;
+(void)hideLabelWithTag:(int)tag fromView:(UIView *)view;

+(UIFont *)RobotoLightFontWithSize:(float)size;
+(UIFont *)RobotoRegularFontWithSize:(float)size;
+(UIFont *)RobotoBoldFontWithSize:(float)size;

+(CGRect) getBoundingBoxForCenter:(YLocation *)point withHalfSideInMeters:(double)halfSideMeters;
+(double) getDistanceBetweenGPSCoord1:(YLocation *)loc1 andGPSLoc2:(YLocation *)loc2;

+(double) deg2rad:(double)degrees;
+(double) rad2deg:(double)radians;

+(void) vibrate:(BOOL)twice;

@end
