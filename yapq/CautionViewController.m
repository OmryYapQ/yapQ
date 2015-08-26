//
//  CautionViewController.m
//  yapq
//
//  Created by yapQ Ltd on 12/6/13.
//  Copyright (c) 2013 yapQ Ltd. All rights reserved.
//

#import "CautionViewController.h"

@interface CautionViewController ()

@end

@implementation CautionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _cautionPresented = NO;
    _neverShow = NO;
}

-(void)viewWillAppear:(BOOL)animated {
    _cautionPresented = YES;
    NSLog(@"Caution will appear");
}

/*-(void)viewDidAppear:(BOOL)animated {
    _cautionPresented = YES;
}

-(void)viewDidDisappear:(BOOL)animated {
    _cautionPresented = NO;
}*/

-(void)viewDidDisappear:(BOOL)animated {
    _cautionPresented = NO;
    NSLog(@"Caution will disappear");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)close:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"warning", nil)
                                                    message: NSLocalizedString(@"caution_screen_alert_message", nil)
                                                   delegate:self
                                          cancelButtonTitle: NSLocalizedString(@"Ok", nil)
                                          otherButtonTitles: NSLocalizedString(@"not_driver", nil), nil];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        
    }
    else if (buttonIndex == 1) {
        [self dismissViewControllerAnimated:YES completion:^{
            _neverShow = YES;
        }];
    }
}

@end
