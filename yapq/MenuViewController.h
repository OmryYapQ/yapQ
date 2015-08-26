//
//  MenuViewController.h
//  yapq
//
//  Created by yapQ Ltd on 1/10/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Settings.h"
#import "LRSlideMenuController.h"
#import "WebViewController.h"
#import "MenuTableViewCell.h"


@interface MenuViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) NSDictionary *menuStructure;

@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
