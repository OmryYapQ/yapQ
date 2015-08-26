//
//  SettingCell.m
//  yapq
//
//  Created by yapQ Ltd on 6/26/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import "SettingCell.h"

@implementation SettingCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    _titleLabel.font = [Utilities RobotoLightFontWithSize:17];
    _descriptionLabel.font = [Utilities RobotoLightFontWithSize:11];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(void)setSettingsEntity:(SettingsEntity *)settingsEntity {
    _settingsEntity = settingsEntity;
    _titleLabel.text = NSLocalizedString(_settingsEntity.entityName,nil);
    _descriptionLabel.text = NSLocalizedString(_settingsEntity.entityDescription,nil);
    _settingSwitch.on = [_settingsEntity getBoolValue];
}

-(IBAction)settingSwithchChangeState:(id)sender {
    
    if ([_settingsKey isEqualToString:kDistanceUnitsSettings]) {
        [[Settings sharedSettings] setSettingsParameterValue:[NSNumber numberWithBool:_settingSwitch.on] forSettingsKey:_settingsKey];
        if (_settingSwitch.on) {
            _settingsEntity.entityDescription = NSLocalizedString(@"Kilometers",nil);
        }
        else {
            _settingsEntity.entityDescription = NSLocalizedString(@"Miles",nil);
        }
        [[Settings sharedSettings] saveSettings];
        _descriptionLabel.text = _settingsEntity.entityDescription;
        
    }else {
        [[Settings sharedSettings] setSettingsParameterValue:[NSNumber numberWithBool:_settingSwitch.on] forSettingsKey:_settingsKey];
        [[Settings sharedSettings] saveSettings];
    }
    [_settingsVCDelegate settingSwitch:sender changeStateForSettings:_settingsEntity];
    
}

@end
