//
//  PackageLoadingEvents.h
//  yapq
//
//  Created by yapQ Ltd
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PackageLoadingEvents <NSObject>

@optional
-(void)loadWaiting:(id)packageLoader;

-(void)loadStarted:(id)packageLoader;

-(void)loadFinished:(id)packageLoader;

-(void)loadError:(id)packageLoader;

-(void)unzipStarted:(id)packageLoader;

-(void)unzipFinished:(id)packageLoader;

-(void)unzipError:(id)packageLoader;

-(void)parsingStarted:(id)packageLoader;

-(void)parsingFinished:(id)packageLoader;

-(void)parsingError:(id)packageLoader;

@end
