//
//  LocationDebugViewController.m
//  yapq
//
//  Created by yapQ Ltd on 12/7/13.
//  Copyright (c) 2013 yapQ Ltd. All rights reserved.
//

#import "LocationDebugViewController.h"

@interface LocationDebugViewController ()

@end

@implementation LocationDebugViewController

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
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDebug:) name:LSDebug object:[LocationService sharedService]];
}

-(void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)locationDebug:(id) sender {
    LocationService *ls = [((NSNotification *)sender)  object];
    _textView.text = [NSString stringWithFormat:@"%@\n%@",ls.locationManager.location,_textView.text];
    _textView.textColor = [UIColor whiteColor];
    _signalLabel.text = [NSString stringWithFormat:@"%f", ls.locationManager.location.horizontalAccuracy];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
