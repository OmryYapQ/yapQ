//
//  SettingsViewController.m
//  yapq
//
//  Created by yapQ Ltd on 6/26/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import "SettingsViewController.h"


@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _settingKeys = @[k3GInternetSettings,kMemoryCleanSettings,kDistanceUnitsSettings,kSpeechRate];
    _settings = [[Settings sharedSettings] settings];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:[NSString stringWithFormat:@"IOS: %@ %@",NSStringFromClass([self class]),[Settings sharedSettings].speechLanguage]];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableView
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_settings allKeys].count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SettingCell";
    static NSString *CellIdentifier_2 = @"SettingCell_2";
    UITableViewCell *cell = nil;
    SettingsEntity *se = (SettingsEntity *)[_settings valueForKey:_settingKeys[indexPath.row]];
    if ([_settingKeys[indexPath.row] isEqualToString:kSpeechRate]) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_2 forIndexPath:indexPath];
        [((SettingsCellWithSlider *)cell) setSettingsEntity:se];
        ((SettingsCellWithSlider *)cell).settingsKey = _settingKeys[indexPath.row];
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        ((SettingCell *)cell).settingsVCDelegate = self;
        // Setup cell as loading
        [((SettingCell *)cell) setSettingsEntity:se];
        ((SettingCell *)cell).settingsKey = _settingKeys[indexPath.row];
    }
    
    
    return cell;
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark SettingSwitchDelegate
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////
-(void)settingSwitch:(id)sSwitch changeStateForSettings:(id)settingEntity {
    //[self.tableView reloadData];
}

@end
