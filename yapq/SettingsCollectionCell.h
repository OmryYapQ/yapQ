//
//  SettingsCollectionCell.h
//  YAPQ
//
//  Created by yapQ Ltd
//  Copyright (c) 2015 yapQ Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPButton.h"
#import "LocationSevice.h"
#import "Place.h"
#import "StreamPlayer.h"
#import "Utilities.h"
#import "WebViewController.h"
#import "PlaceButtonFeaturesDelegate.h"
#import "Settings.h"
#import "SiriPlayer.h"


@interface SettingsCollectionCell : UICollectionViewCell

@property (strong, nonatomic) SettingsPlace *place;
@property id<PlaceButtonFeaturesDelegate> VCDelegate;

@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblDescription;
@property (strong, nonatomic) IBOutlet UIView *viewSpeechRate;
@property (strong, nonatomic) IBOutlet UIView *viewSocial;


-(void)cellReset;
-(void)setPlace:(SettingsPlace *)place;

@end
