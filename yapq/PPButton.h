//
//  PPButton.h
//  yapq
//
//  Created by yapQ Ltd on 12/2/13.
//  Copyright (c) 2013 yapQ Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UILoadingIndicator.h"
#import "Utilities.h"

@interface PPButton : UIButton

@property (assign) BOOL isPlaying;

-(void)play;
-(void)pause;

@end

