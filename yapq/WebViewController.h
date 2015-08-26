//
//  AboutViewController.h
//  yapq
//
//  Created by yapQ Ltd on 1/10/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "Utilities.h"
#import "LRSlideMenuController.h"
#import "PlacesTableViewController.h"
#import "UIDotLoaderIndicatorView.h"
#import "YViewController.h"

@interface WebViewController : YViewController <UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *aboutView;
@property (strong, nonatomic) NSString *urlToView;

@end
