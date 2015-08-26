//
//  MenuTableViewCell.h
//  yapq
//
//  Created by yapQ Ltd
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Settings.h"
#import "PlacesTableViewController.h"
#import "LRSlideMenuController.h"

@interface MenuTableViewCell : UITableViewCell <UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *innerTable;
@property (strong, nonatomic) NSArray *innerTableData;

@end
