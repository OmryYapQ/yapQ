//
//  tToken.m
//  yapq
//
//  Created by Yossi Neiman on 4/17/15.
//  Copyright (c) 2015 yapQ . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

void createTtoken() {
#ifdef SEND_NULL_STATISTICS_TOKEN
    //store the string on file
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    // saving a string
    [prefs setObject:@"" forKey:@"tToken"];
    // saving it all
    [prefs synchronize];
#else
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if (![prefs stringForKey:@"tToken"]){ //if the string do not exist enter here
        NSString *url = [NSString stringWithFormat:@"%@platform=%d",
                         ANONYMUS_USER,
                         1
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
            //store the string on file
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            // saving a string
            [prefs setObject:responseString forKey:@"tToken"];
            // saving it all
            [prefs synchronize];
        }];
        
    }
#endif
}

void saveEvent(NSString *event){
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

    NSString *url = [NSString stringWithFormat:@"%@action=%@&tToken=%@",
                     RECORD,
                     event,
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
    #if DEBUG
        NSLog(@"%@",responseString);
    #endif
    }];
    
}