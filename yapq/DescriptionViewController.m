//
//  DescriptionViewController.m
//  yapq
//
//  Created by yapQ Ltd on 12/5/13.
//  Copyright (c) 2013 yapQ Ltd. All rights reserved.
//

#import "DescriptionViewController.h"
#import "PlacesTableViewController.h"

@interface DescriptionViewController ()

@end

@implementation DescriptionViewController

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
    _textView.font = [Utilities RobotoLightFontWithSize:19];
    _titleView.font = [Utilities RobotoLightFontWithSize:25];
    
    _wikipeidaButton.font =[Utilities RobotoLightFontWithSize:14];
    _sourceLable.font = [Utilities RobotoLightFontWithSize:14];

}

-(void)viewWillAppear:(BOOL)animated {
    //make the ttl bold
    _titleView.font = [UIFont fontWithName:@"Arial-BoldItalic" size:25.0];
    
    if ([[Settings sharedSettings].speechLanguage isEqualToString:tSpeechHebrew]) {
        _textView.textAlignment = NSTextAlignmentRight;
        _titleView.textAlignment = NSTextAlignmentRight;
    }
    else {
        _textView.textAlignment = NSTextAlignmentLeft;
        _titleView.textAlignment = NSTextAlignmentLeft;
    }
    _textView.text = _text;
    _textView.editable = NO;
    _titleView.text = _titleLabelPopUp;
}

-(IBAction)closeButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        ((PlacesTableViewController *)[LRSlideMenuController sharedInstance].topViewController).isUserReading = NO;;
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goToWiki:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        [((PlacesTableViewController *)[LRSlideMenuController sharedInstance].topViewController) toWiki];
    }];
}
@end
