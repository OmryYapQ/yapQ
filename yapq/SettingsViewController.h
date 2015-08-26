//
//  SettingsViewController.h
//  yapq
//
//  Created by yapQ Ltd on 6/26/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Settings.h"
#import "SettingCell.h"
#import "SettingsCellWithSlider.h"
#import "SettingSwitchStateChanged.h"
#import "YViewController.h"
#import "Constants.h"

@interface SettingsViewController : YViewController <UITableViewDataSource,UITableViewDelegate, SettingSwitchStateChanged>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSDictionary *settings;
@property (strong, nonatomic) NSArray *settingKeys;

@end
