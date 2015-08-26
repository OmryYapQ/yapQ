//
//  PlaceButtonFeaturesDelegate.h
//  yapq
//
//  Created by yapQ Ltd on 1/11/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PlaceButtonFeaturesDelegate <NSObject>

@optional
-(void)toWaze:(NSString *)url;
-(void)toWiki:(NSString *)url;
-(void)toReport:(Place *)place;
-(void)toFacebookShare:(Place *)placeToShare;

@end
