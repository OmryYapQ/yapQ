//
//  SettingSwitchStateChanged.h
//  yapq
//
//  Created by yapQ Ltd on 6/26/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SettingSwitchStateChanged <NSObject>

-(void)settingSwitch:(id)sSwitch changeStateForSettings:(id)settingEntity;

@end
