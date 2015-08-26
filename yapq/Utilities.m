

/**
 * @author yapQ Ltd
 * Copyright (c) 2013 yapQ Ltd. All rights reserved.
 */
#import "Utilities.h"
#import <AudioToolbox/AudioToolbox.h>


// Semi-axes of WGS-84 geoidal reference
#define WGS84_a             6378137.0  // Major semiaxis [m]
#define WGS84_b             6356752.3  // Minor semiaxis [m]

@implementation Utilities

+(UTOSVersion)currentVersionOfOS {
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 5.0 && version <= 5.9) {
        return UTIOS_5;
    }
    else if (version >= 6.0 && version <= 6.9) {
        return UTIOS_6;
    } else if (version >= 7.0 && version <= 7.9){
        return UTIOS_7;
    }
    else if (version >= 8.0 && version <= 8.9) {
        return UTIOS_8;
    }
    return UTIOS_6;
}

+(NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

+(void)taskInSeparatedBlock:(void(^)(void)) block {
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    
    dispatch_sync(queue, ^{
        block();
    });
}

+(void)taskInSeparatedThread:(void(^)(void)) block {
    if (block) {
        [NSThread detachNewThreadSelector:@selector(executeBlock:) toTarget:self withObject:block];
    }
}

+(void)executeBlock:(void(^)(void)) block {
    block();
}

+(void)taskWithDelay:(NSInteger)delay forBlock:(void(^)(void)) block {
    if (block) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,delay*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            block();
        });
    }
}

+(void)executeBlockWithUserInfo:(NSDictionary *) userInfo {
    
    NSTimeInterval delay = [[userInfo valueForKey:@"Delay"] integerValue];
    void (^block)(void) = [userInfo valueForKey:@"Block"];
    [NSThread sleepForTimeInterval:delay];
    if (block) {
        block();
    }
}

+(void)UITaskInSeparatedBlock:(void(^)(void)) block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (block) {
                block();
            }
        });
    });
}

+(NSString *) md5:(NSString *) input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
    
}

+(BOOL)validateEmailWithString:(NSString*)email
{
    if ([email isEqualToString:@""]) {
        return YES;
    }
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+(NSString *)urlEncodeForString:(NSString *)string byUsingEncoding:(NSStringEncoding)encoding {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (CFStringRef)string,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                                 CFStringConvertNSStringEncodingToEncoding(encoding)));
}

+(void)clearCacheOnAppLoad {
    [Utilities taskInSeparatedBlock:^{
        NSDirectoryEnumerator *dic = [[NSFileManager defaultManager] enumeratorAtPath:TMP];
        NSString *file = nil;
        while (file = [dic nextObject]) {
            NSLog(@"%@",file);
            [[NSFileManager defaultManager] removeItemAtPath:[TMP stringByAppendingPathComponent: file] error:nil];
        }
    }];
}

+(void)cacheImage:(NSString *)ImageURLString isOffline:(BOOL)isOffline
{
    NSURL *ImageURL = [NSURL URLWithString: ImageURLString];
    
    NSString *filename = [Utilities md5:ImageURLString];
    NSString *uniquePath = [TMP stringByAppendingPathComponent: filename];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath: uniquePath])
    {

        NSError *error = nil;
        NSData *data = nil;
        if (isOffline) {
            data = [NSData dataWithContentsOfFile:ImageURLString];
        }else {
            //data = [NSData dataWithContentsOfURL:ImageURL options:NSDataReadingMappedAlways error:&error];
            NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:ImageURL];
            [theRequest setTimeoutInterval:60];
            NSURLResponse *resp = nil;
            NSError *error = nil;
            data = [NSURLConnection sendSynchronousRequest: theRequest returningResponse: &resp error: &error];
        }
        if (error) {
            NSLog(@"%@",error);
        }
        //NSData *data = [[NSData alloc] initWithContentsOfURL: ImageURL];
        UIImage *image = [[UIImage alloc] initWithData: data];
        
        // Is it PNG or JPG/JPEG?
        // Running the image representation function writes the data from the image to a file
        if([ImageURLString rangeOfString: @".png" options: NSCaseInsensitiveSearch].location != NSNotFound)
        {
            [UIImagePNGRepresentation(image) writeToFile: uniquePath atomically: YES];
        }
        else if(
                [ImageURLString rangeOfString: @".jpg" options: NSCaseInsensitiveSearch].location != NSNotFound ||
                [ImageURLString rangeOfString: @".jpeg" options: NSCaseInsensitiveSearch].location != NSNotFound
                )
        {
            [UIImageJPEGRepresentation(image, 100) writeToFile: uniquePath atomically: YES];
        }
    }
}


+(UIImage *)getCachedImage:(NSString *)ImageURLString
{
    NSString *filename = [Utilities md5:ImageURLString];
    NSString *uniquePath = [TMP stringByAppendingPathComponent: filename];
    
    UIImage *image = nil;
    
    // Check for a cached version
    if([[NSFileManager defaultManager] fileExistsAtPath: uniquePath])
    {
        image = [UIImage imageWithContentsOfFile: uniquePath]; // this is the cached image
    }
    
    return image;
}

+(NSString *)imagePathMD5FromPackageName:(NSString *)packageName {
    NSString *packageNameMd5 = [Utilities md5:packageName];
    NSString *path = [[[Utilities applicationDocumentsDirectory] path] stringByAppendingPathComponent:packageNameMd5];
    return path;
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Color
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////
+(UIColor *)colorWith255StyleRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha {
    return [UIColor colorWithRed:red/255. green:green/255. blue:blue/255. alpha:alpha];
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Language
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////

+(NSString *)defaultLanguage {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *lang = [defaults valueForKeyPath:LANGUAGE_KEY];
    if (!lang) {
        [defaults setObject:@"en" forKey:LANGUAGE_KEY];
        [defaults synchronize];
        return @"en";
    }
    
    return lang;
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark View components
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////
+(void)showLabelWithMessage:(NSString *)message inView:(UIView *)view {
    if ([view viewWithTag:123] != nil) {
        UILabel *label = (UILabel *)[view viewWithTag:123];
        [label setText:message];
        return;
    }
    CGRect textRect = [message boundingRectWithSize:CGSizeMake(view.frame.size.width, MAXFLOAT)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}
                                            context:nil];
    float x = (view.frame.size.width/2.)-textRect.size.width/2.;
    UILabel *label = [[UILabel alloc]
                      initWithFrame: (CGRect){x, 100, textRect.size.width, textRect.size.height}];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor grayColor];
    label.text = message;
    [view addSubview:label];
}

+(void)hideLabelWithTag:(int)tag fromView:(UIView *)view {
    UILabel *label = (UILabel *)[view viewWithTag:tag];
    [label removeFromSuperview];
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIFonts
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////
+(UIFont *)RobotoLightFontWithSize:(float)size {
    return [UIFont fontWithName:@"Roboto-Light" size:size];
}

+(UIFont *)RobotoRegularFontWithSize:(float)size {
    return [UIFont fontWithName:@"Roboto-Regular" size:size];
}

+(UIFont *)RobotoBoldFontWithSize:(float)size {
    return [UIFont fontWithName:@"Roboto-Bold" size:size];
}


// 'halfSideMeters' is the half length of the bounding box you want in kilometers.
+(CGRect) getBoundingBoxForCenter:(YLocation *)point withHalfSideInMeters:(double)halfSideMeters {
    // Bounding box surrounding the point at given coordinates,
    // assuming local approximation of Earth surface as a sphere
    // of radius given by WGS84
    double lat = [self deg2rad:point.latitude];
    double lon = [self deg2rad:point.longitude];
    
    // Radius of Earth at given latitude
    double radius = [self WGS84EarthRadius:lat];
    
    // Radius of the parallel at given latitude
    double pradius = radius * cos(lat);
    
    double latMin = lat - halfSideMeters / radius;
    double latMax = lat + halfSideMeters / radius;
    double lonMin = lon - halfSideMeters / pradius;
    double lonMax = lon + halfSideMeters / pradius;
    
    CGRect ret = CGRectMake(lonMin,
                            latMax,
                            fabs(lonMax - lonMin),
                            fabs(latMin - latMax));
    
    return ret;
}

// Earth radius at a given latitude, according to the WGS-84 ellipsoid [m]
+(double) WGS84EarthRadius:(double)lat {
    // http://en.wikipedia.org/wiki/Earth_radius
    
    double An = WGS84_a * WGS84_a * cos(lat);
    double Bn = WGS84_b * WGS84_b * sin(lat);
    double Ad = WGS84_a * cos(lat);
    double Bd = WGS84_b * sin(lat);
    
    return sqrt((An*An + Bn*Bn) / (Ad*Ad + Bd*Bd));
}

+(double) getDistanceBetweenGPSCoord1:(YLocation *)loc1 andGPSLoc2:(YLocation *)loc2 {
    // Approximate Equirectangular -- works if (lat1,lon1) ~ (lat2,lon2)
    int R = 6371; // km
    double x = (loc2.longitude - loc1.longitude) * cos((loc1.latitude + loc2.latitude) / 2);
    double y = (loc2.latitude - loc1.latitude);
    double distance = sqrt(x * x + y * y) * R;
    return distance;
}
+(double) deg2rad:(double)degrees {
    return M_PI * degrees/180.0;
}

+(double) rad2deg:(double)radians {
    return 180.0*radians/M_PI;
}

+(void) vibrate:(BOOL)twice {
    if (twice) {
        if (AudioServicesAddSystemSoundCompletion (kSystemSoundID_Vibrate,NULL,NULL,
                                                   vibrateTwiceFinishedCB,
                                                   NULL) == 0) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
    }
    else {
        if (AudioServicesAddSystemSoundCompletion (kSystemSoundID_Vibrate,NULL,NULL,
                                                   vibrateOnceFinishedCB,
                                                   NULL) == 0) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
    }
}

static void vibrateTwiceFinishedCB (SystemSoundID  mySSID, void* userData) {
    AudioServicesRemoveSystemSoundCompletion (mySSID);
    [Utilities vibrate:NO];
}

static void vibrateOnceFinishedCB (SystemSoundID  mySSID, void* userData) {
    AudioServicesRemoveSystemSoundCompletion (mySSID);
}

@end
