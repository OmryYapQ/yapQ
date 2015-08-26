//
//  StoreLoadingView.h
//  yapq
//
//  Created by yapQ Ltd.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIDotLoaderIndicatorView.h"

@interface StoreLoadingView : UIView

@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) UIDotLoaderIndicatorView *loadingIndicator;

-(void)startLoading;
-(void)stopLoading;

@end
