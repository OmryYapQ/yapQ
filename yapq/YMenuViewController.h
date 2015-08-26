//
//  YMenuViewController.h
//  yapq
//
//  Created by yapQ Ltd on 6/21/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LRSlideMenuController.h"
#import "WebViewController.h"
#import <MessageUI/MessageUI.h>

@interface YMenuView : UIView

@end

@interface YMenuViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,MFMessageComposeViewControllerDelegate,UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *menuTableView;
@property (strong, nonatomic) NSArray *menuStructure;
@property (strong, nonatomic) NSArray *imageNames;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;

-(void)setLocalization;

@end
