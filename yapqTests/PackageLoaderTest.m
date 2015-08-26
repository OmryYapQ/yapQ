//
//  PackageLoaderTest.m
//  yapq
//
//  Created by yapQ Ltd on 6/14/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import "PackageLoaderTest.h"

@implementation PackageLoaderTest

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TEST MEHODS
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////
-(void)testLoadStart {
    //_currentStatus = PLS_LOAD_STARTED;
    [Utilities taskInSeparatedThread:^{
        //[_delegate loadStarted:self];
        [NSThread sleepForTimeInterval:5];
        [self testLoadFinished];
    }];
}

-(void)testLoadFinished {
    //_currentStatus = PLS_LOAD_FINISHED;
    [Utilities taskInSeparatedThread:^{
        //[self updateProgressValueWithValue:0.8];
        //[_delegate loadFinished:self];
        
        //[NSThread sleepForTimeInterval:5];
    }];
}

-(void)testUnzipStart {
    //_currentStatus = PLS_UNZIP_STARTED;
    [Utilities taskInSeparatedThread:^{
        //[self.delegate unzipStarted:self];
        [NSThread sleepForTimeInterval:5];
        [self testUnzipFinished];
    }];
}

-(void)testUnzipFinished {
    //_currentStatus = PLS_UNZIP_FINISHED;
    [Utilities taskInSeparatedThread:^{
        //[self updateProgressValueWithValue:0.1];
        //[self.delegate unzipFinished:self];
        //[NSThread sleepForTimeInterval:5];
    }];
}

-(void)testParsingStarted {
    //_currentStatus = PLS_PARSING_STARTED;
    [Utilities taskInSeparatedThread:^{
       // [self.delegate parsingStarted:self];
        [NSThread sleepForTimeInterval:5];
        [self testParsingFinished];
    }];
}

-(void)testParsingFinished {
    //_currentStatus = PLS_PARSING_FINISHED;
    [Utilities taskInSeparatedThread:^{
       // [self updateProgressValueWithValue:0.1];
       // [self.delegate parsingFinished:self];
        //[NSThread sleepForTimeInterval:5];
    }];
}


@end
