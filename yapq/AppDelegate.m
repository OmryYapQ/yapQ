//
//  AppDelegate.m
//  yapq
//
//  Created by yapQ Ltd on 12/2/13.
//  Copyright (c) 2013 yapQ Ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "YWebViewController.h"
#import "tToken.h"
#import "SearchViewController.h"
#import "SQLiteDBManager.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    /*
    if ([Utilities currentVersionOfOS] == UTIOS_5 || [Utilities currentVersionOfOS] == UTIOS_6) {
        YWebViewController *webView = [[YWebViewController alloc] initWithNibName:@"YWebViewController" bundle:nil];
        _window.rootViewController = webView;
        return YES;
    }
    */
    
    //0L: init the DB (copy if needed)
    [[SQLiteDBManager sharedInstance] createDB];
    

    application.idleTimerDisabled = YES;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_1" bundle:nil];
    LRSlideMenuController *mc = [LRSlideMenuController sharedInstance];
    [mc setLeftImageName:@"menu_img"];
    [mc setRightImageName:@"search"]; //0L: set right menu image name
    
    // this is the settings left menu that slides in when pressing the menu button
    YMenuViewController *mvc = [storyboard instantiateViewControllerWithIdentifier:@"YMenuVC"];
//    [mvc setLocalization];
    mc.leftMenu = mvc;
    
    
    [LRSlideMenuController sharedInstance].menuOpenOffset = 60;
    [LRSlideMenuController sharedInstance].slideMenuDuration = 0.2;
    [[LRSlideMenuController sharedInstance] setEnableSwipeGesture: NO];
    // Override point for customization after application launch.
    //[CLLocationManager locationServicesEnabled];
    [Utilities clearCacheOnAppLoad];
    
    
    if ([[Settings sharedSettings] isAutoCleanMemoryEnabled]) {
        [DBCoreDataHelper autoDeletePackages];
    }
    
    /*NSArray *voices = [AVSpeechSynthesisVoice speechVoices];
    for (AVSpeechSynthesisVoice *v in voices) {
        NSLog(@"%@",[v language]);
    }*/
    
    if ([Utilities currentVersionOfOS] == UTIOS_8) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionDuckOthers error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
    }
    else {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
    }
    
    
    //[application registerForRemoteNotificationTypes: UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    //#warning OPEN GOOGLE ANALITICS
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 60;
    
    // Optional: set Logger to VERBOSE for debug information.
    //[[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    
    // Initialize tracker. Replace with your tracking ID.
    [[GAI sharedInstance] trackerWithTrackingId:GA_ID];
    
    
    //get Anonymous toekn if needed
    createTtoken();    
    
    
    
    [FBSettings setDefaultAppID:@"645536292171084"];
    [FBAppEvents activateApp];
    
    [self createUpdateTimer];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    
    NSString *token = [[NSString stringWithFormat:@"%@", newDeviceToken] stringByReplacingOccurrencesOfString:@"<" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    [WebServices registreForPushNOtificationWithToken:token andCompletionBlock:^(enum WebServiceRequestStatus status, NSString *appVersion) {
        if (status == WS_OK) {
            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
            NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
#if DEBUG
            NSLog(@"push token: %@",token);
            NSLog(@"server: %@,inner %@",appVersion,majorVersion);
#endif
            NSUInteger lenght = majorVersion.length >= appVersion.length ? appVersion.length : majorVersion.length;
            BOOL isNewVersion = NO;
            for (int i=0; i<lenght; i++) {
                if ([majorVersion characterAtIndex:i] < [appVersion characterAtIndex:i]) {
                    isNewVersion = YES;
                    break;
                }
            }
            if (isNewVersion) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"App Update" message:@"You using old version of app." delegate:self cancelButtonTitle:@"Update" otherButtonTitles:nil, nil];
                [alert show];
            }

        }
    }];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APPSTORE_URL]];
    }
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"%@",userInfo);
}

- (BOOL)application: (UIApplication *)application
            openURL: (NSURL *)url
  sourceApplication: (NSString *)sourceApplication
         annotation: (id)annotation {
    //NSLog(@"usrl = %@, sa = %@, anot = %@",url,sourceApplication,annotation);
    if (sourceApplication != nil) {
        return [GPPURLHandler handleURL:url
                      sourceApplication:sourceApplication
                             annotation:annotation];
    }
    return YES;
}

-(void)applicationDidBecomeActive:(UIApplication *)application {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // stop the update timer
    [_timer invalidate];
    _timer = NULL;
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidEnterBackgroundNotification object:nil];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[LocationService sharedService] stopUpdate];
    //[[LocationSevice sharedService].stopTimer invalidate];
    [[LocationService sharedService].updateTimer invalidate];
    [[UIApplication sharedApplication] beginBackgroundTaskWithName:@"GPS Update" expirationHandler:^{
        [[LocationService sharedService] stopUpdate];
        //[[LocationSevice sharedService].stopTimer invalidate];
        [[LocationService sharedService].updateTimer invalidate];
    }];
    [LocationService sharedService].updateTimeInterval = LSLocationUpdateLessFreq;
    [[LocationService sharedService] startUpdate];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillEnterForegroundNotification object:nil];
    [[LocationService sharedService] stopUpdate];
    //[[LocationSevice sharedService].stopTimer invalidate];
    [[LocationService sharedService].updateTimer invalidate];
    [LocationService sharedService].updateTimeInterval = LSLocationUpdateMoreFreq;
    [[LocationService sharedService] startUpdate];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    // must see places database update timer
    [self createUpdateTimer];
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    if ([Utilities currentVersionOfOS] == UTIOS_8) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionDuckOthers error:nil];
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
    }
    else {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
    }

    [[LocationService sharedService] stopUpdate];
    //[[LocationSevice sharedService].stopTimer invalidate];
    [[LocationService sharedService].updateTimer invalidate];
    [[LocationService sharedService].locationManager stopUpdatingHeading];
}

-(void) onTimer:(NSTimer *)timer
{
    if (([[NSDate date] timeIntervalSince1970] - self.timerLastInterval) >= MUST_SEE_DB_UPDATE_INTERVAL_SEC) {
        Reachability *networkStatus = [Reachability reachabilityForInternetConnection];
        if ([networkStatus currentReachabilityStatus] != NotReachable) {
            @try {
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                NSString *url = [NSString stringWithFormat:@"%@tToken=%@",
                                 SYNC_PLACES,
                                 [prefs stringForKey:@"tToken"]
                                 ];
                
                NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:
                                                   [NSURL URLWithString:
                                                    url]];
                [theRequest setTimeoutInterval:90];
                __block NSURLResponse *resp = nil;
                __block NSError *error = nil;
                
                [Utilities taskInSeparatedThread:^{
                    NSData *response = [NSURLConnection sendSynchronousRequest: theRequest returningResponse: &resp error: &error];
                    NSString *responseString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
                    
                    if (!error) {
                        [self performSelectorOnMainThread:@selector(updateMustSeeDB:) withObject:responseString waitUntilDone:YES];
                    }
                    
                    // error or not set next trigger to be far away -> not to hammer the server !
                    self.timerLastInterval = [[NSDate date] timeIntervalSince1970];
                    [[NSUserDefaults standardUserDefaults] setDouble:self.timerLastInterval forKey:LAST_MUST_SEE_SEC];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }];
            }
            @catch (NSException *exception) {

            }
        }
    }
}

-(void) updateMustSeeDB:(NSString *)responseString
{
    [[SQLiteDBManager sharedInstance] updateMustSeePlacesWithResponseString:responseString];
}

-(void) createUpdateTimer
{
    if (NULL == _timer) {
        // update the must see places sqlite DB
        self.timerLastInterval = [[NSDate date] timeIntervalSince1970];
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:LAST_MUST_SEE_SEC] != NULL) {
            self.timerLastInterval = [[NSUserDefaults standardUserDefaults] doubleForKey:LAST_MUST_SEE_SEC];
        }
        else {
            [[NSUserDefaults standardUserDefaults] setDouble:self.timerLastInterval forKey:LAST_MUST_SEE_SEC];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        // every 1 second timer
        _timer = [NSTimer scheduledTimerWithTimeInterval:2
                                                  target:self
                                                selector:@selector(onTimer:)
                                                userInfo:nil
                                                 repeats:YES];
    }

}

@end
