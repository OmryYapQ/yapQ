//
//  PPButton.m
//  yapq
//
//  Created by yapQ Ltd on 12/2/13.
//  Copyright (c) 2013 yapQ Ltd. All rights reserved.
//

#import "PPButton.h"
#import "tToken.h"

@implementation PPButton


-(void)play {
    //NSLog(@"Play");
    _isPlaying = YES;
    //[Utilities UITaskInSeparatedBlock:^{
        [[UILoadingIndicator sharedIndicator] startAnimationInView:self];
        [self setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
   
    //}];
    
}

-(void)pause {
    if (!_isPlaying) {
        return;
    }
    _isPlaying = NO;
    //NSLog(@"Pause");
    //[Utilities UITaskInSeparatedBlock:^{
        [[UILoadingIndicator sharedIndicator] stopAnimation];
        [self setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        
    //}];
}


@end
