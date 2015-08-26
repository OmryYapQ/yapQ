//
//  SettingsCellWithSlider.h
//  yapq
//
//  Created by yapQ Ltd on 10/15/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Settings.h"
#import "SiriPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface SettingsCellWithSlider : UITableViewCell 

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UISlider *rateSlider;
@property (strong, nonatomic) SettingsEntity *settingsEntity;
@property (strong, nonatomic) NSString *settingsKey;

@property id settingsVCDelegate;

@end
