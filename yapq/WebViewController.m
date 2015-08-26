//
//  AboutViewController.m
//  yapq
//
//  Created by yapQ Ltd
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController () {
    //UIDotLoaderIndicatorView *dliv;
}

@end

@implementation WebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _aboutView.scrollView.contentInset = UIEdgeInsetsMake(65, 0, 0, 0);
    _aboutView.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated {
    
}
-(void)viewDidAppear:(BOOL)animated {
    NSLog(@"URL to open: %@",_urlToView);
    [Utilities taskInSeparatedThread:^{
        [_aboutView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_urlToView]]];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)close:(id)sender {
    [((PlacesTableViewController *)[LRSlideMenuController sharedInstance].topViewController) enterBackground:nil];
    [((PlacesTableViewController *)[LRSlideMenuController sharedInstance].topViewController) enterForeground:nil];
    
    [self dismissViewControllerAnimated:YES completion:^{
        ((PlacesTableViewController *)[LRSlideMenuController sharedInstance].topViewController).isUserReading = NO;
    }];
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIWebView delegate
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////
-(void)webViewDidStartLoad:(UIWebView *)webView {
    //[self showLoading:YES];
    [self animateBicycle:CGRectNull];
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
        _aboutView.alpha = 1.0;
        return;
    }
    [UIView animateKeyframesWithDuration:0.3 delay:0 options:0 animations:^{
        _aboutView.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
}

@end
