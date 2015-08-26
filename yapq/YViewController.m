//
//  YViewController.m
//  yapq
//
//  Created by yapQ Ltd on 6/27/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import "YViewController.h"

@interface YViewController () {
    /** Instance of dot loader */
    UIDotLoaderIndicatorView *dliv;
}

@end

@implementation YViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Navigation Bar
    //self.navigationItem.rightBarButtonItem = [self rightBarView];
    self.navigationItem.titleView = [self titleView];
    // Initializing of Dot loader
    dliv = [[UIDotLoaderIndicatorView alloc] initWithSize:INDICATOR_MEDIUM atPosition:CGPointMake(90, 15) tintColor:[UIColor darkGrayColor] animationSpeed:0.7];
}

-(void)animateBicycle:(CGRect)rcCover {
    if (NO == _isAnimated/*![_animationView.superview isEqual:self.view]*/) {
        _isAnimated = YES;
        
        CGRect frame = [[UIScreen mainScreen] bounds];
        
        if (NO == CGRectIsNull(rcCover)) {
            frame = rcCover;
        }
        
        _animationView = [[UIView alloc] initWithFrame:frame];
        _animationView.backgroundColor = [UIColor colorWithWhite:255 alpha:1];
        
        UIImageView *player = [[UIImageView alloc] initWithFrame: (CGRect){(frame.size.width/2)-60,
            (frame.size.height/2)-75, 120, 150}];
        player.alpha = 0.7;
        player.animationImages = @[[UIImage imageNamed:@"Anim/loader20001"],
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
        player.animationDuration = 2.0f;
        player.animationRepeatCount = HUGE;
        player.tag = 8936;
        [_animationView addSubview:player];
        
        [player startAnimating];
        [self.view insertSubview:_animationView atIndex:self.view.subviews.count];
    }
}

-(void)stopAnimationAndRemoveFromSuperview {
    if (_isAnimated) {
        UIImageView *player = (UIImageView *)[_animationView viewWithTag:8936];
        [player stopAnimating];
        
        [_animationView removeFromSuperview];
        _animationView = nil;
        _isAnimated = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Top Bar
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////
-(UIView *)leftBarView {
    UIImageView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"yapq_New_Logo"]]; //old was yapp_small
    //TODO: NEW YAPQ LOGO
    view.frame = CGRectMake(50, 14, 50, 18);
    return view;//[[UIBarButtonItem alloc] initWithCustomView:view];
}

-(UIBarButtonItem *)rightBarView {
    UIImageView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon"]];
    return [[UIBarButtonItem alloc] initWithCustomView:view];
}

-(UIView *)titleView {
    if (self.navigationItem.titleView != Nil) {
        return self.navigationItem.titleView;
    }
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 44)];
    [v addSubview:[self leftBarView]];
    return v;
}

- (IBAction)showSearch:(id)sender {
}

-(IBAction)backHome:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)showLoading:(BOOL)show {
    
    if (show) {
        [[self titleView] addSubview:dliv];
        [dliv startAnimation];
    }
    else {
        [dliv stopAndRemoveFromSuperView:YES];
    }
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
