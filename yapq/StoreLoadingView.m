//
//  StoreLoadingView.m
//  yapq
//
//  Created by yapQ Ltd
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import "StoreLoadingView.h"

@implementation StoreLoadingView

-(void)awakeFromNib {
    [self initLoader];
}

-(void)initLoader {
    _loadingIndicator = [[UIDotLoaderIndicatorView alloc] initWithSize:INDICATOR_MEDIUM atPosition:CGPointMake(135, 50) tintColor:[UIColor darkGrayColor] animationSpeed:0.7];
    [self addSubview:_loadingIndicator];
}

-(void)startLoading {
    [_loadingIndicator startAnimation];
    [self setHidden:NO];
}

-(void)stopLoading {
    [_loadingIndicator stopAnimation];
    [self setHidden:YES];
}


@end
