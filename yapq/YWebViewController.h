//
//  YWebViewController.h
//  yapq
//
//  Created by yapQ Ltd on 10/16/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YWebViewController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) UIImageView *animationView;

@end
