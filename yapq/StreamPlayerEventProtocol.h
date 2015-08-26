//
//  StreamPlayerEventProtocol.h
//  yapq
//
//  Created by yapQ Ltd on 12/3/13.
//  Copyright (c) 2013 yapQ Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Place.h"

@protocol StreamPlayerEventProtocol <NSObject>

-(void)play:(id<StreamPlayerEventProtocol>)receiver withPlace:(Place *) place;
-(void)pause:(id<StreamPlayerEventProtocol>)receiver withPlace:(Place *) place;

@optional
-(void)playerWillPlay:(id<StreamPlayerEventProtocol>)receiver withPlace:(Place *) place;
-(void)playerDidPlay:(id<StreamPlayerEventProtocol>)receiver withPlace:(Place *) place;
-(void)playerWillPause:(id<StreamPlayerEventProtocol>)receiver withPlace:(Place *) place;
-(void)playerDidPause:(id<StreamPlayerEventProtocol>)receiver withPlace:(Place *) place;

@end
