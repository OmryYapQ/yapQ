//
//  SettingCell.h
//  yapq
//
//  Created by yapQ Ltd on 6/26/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsEntity.h"
#import "Settings.h"
#import "Utilities.h"   
#import "SettingSwitchStateChanged.h"

@interface SettingCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UISwitch *settingSwitch;

@property (strong, nonatomic) SettingsEntity *settingsEntity;
@property (strong, nonatomic) NSString *settingsKey;

@property id settingsVCDelegate;

@end
