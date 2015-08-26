//
//  YWebViewController.m
//  yapq
//
//  Created by yapQ Ltd on 10/16/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import "YWebViewController.h"

@interface YWebViewController ()

@end

@implementation YWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //_webView = [[UIWebView alloc] initWithFrame: (CGRect){0, 0, self.view.frame.size.width, self.view.frame.size.height}];
    _webView.delegate = self;
    //[self.view addSubview:_webView];
    [self initAnimationView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

-(void)viewDidAppear:(BOOL)animated {
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://api.yapq.com/m/"]]];
}

-(void)initAnimationView {
    CGRect frame = [[UIScreen mainScreen] bounds];
    _animationView = [[UIImageView alloc] initWithFrame: (CGRect){(frame.size.width/2)-60,
        (frame.size.height/2)-75, 120, 150}];
    _animationView.alpha = 0.7;
    _animationView.animationImages = @[[UIImage imageNamed:@"Anim/loader20001"],
                                       [UIImage imageNamed:@"Anim/loader20002"],
                                       [UIImage imageNamed:@"Anim/loader20003"],
                                       [UIImage imageNamed:@"Anim/loader20004"],
                                       [UIImage imageNamed:@"Anim/loader20005"],
                                       [UIImage imageNamed:@"Anim/loader20006"],
                                       [UIImage imageNamed:@"Anim/loader20007"],
                                       [UIImage imageNamed:@"Anim/loader20008"],
                                       [UIImage imageNamed:@"Anim/loader20009"],
                                       [UIImage imageNamed:@"Anim/loader20010"],
                                       [UIImage imageNamed:@"Anim/loader20011"],
                                       [UIImage imageNamed:@"Anim/loader20012"],
                                       [UIImage imageNamed:@"Anim/loader20013"],
                                       [UIImage imageNamed:@"Anim/loader20014"],
                                       [UIImage imageNamed:@"Anim/loader20015"],
                                       [UIImage imageNamed:@"Anim/loader20016"],
                                       [UIImage imageNamed:@"Anim/loader20017"],
                                       [UIImage imageNamed:@"Anim/loader20018"]];
    _animationView.animationDuration = 2.0f;
    _animationView.animationRepeatCount = HUGE;
}

-(void)animateBicycle {
    if (![_animationView.superview isEqual:self.view]) {
        [self initAnimationView];
        [_animationView startAnimating];
        [self.view insertSubview:_animationView atIndex:self.view.subviews.count];
    }
}

-(void)stopAnimationAndRemoveFromSuperview {
    [_animationView stopAnimating];
    [_animationView removeFromSuperview];
    _animationView = nil;
}


//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIWebView delegate
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////
-(void)webViewDidStartLoad:(UIWebView *)webView {
    //[self showLoading:YES];
    [self animateBicycle];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    [self showWebViewAnimated:YES];
    //[self showLoading:NO];
    [self stopAnimationAndRemoveFromSuperview];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self showWebViewAnimated:YES];
    //[self showLoading:NO];
    [self stopAnimationAndRemoveFromSuperview];
}

-(void)showWebViewAnimated:(BOOL)animated {
    if (!animated) {
        _webView.alpha = 1.0;
        return;
    }
    [UIView animateKeyframesWithDuration:0.3 delay:0 options:0 animations:^{
        _webView.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
}

@end
