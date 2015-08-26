//
//  SwipeCollectionFirstCell.h
//  YAPP
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


#define APPLE_MAPS_URL_SCHEME @"http://maps.apple.com/maps"
#define GOOGLE_MAPS_URL_SCHEME @"comgooglemaps-x-callback://"
#define WAZE_URL_SCHEME @"waze://"

@interface SwipeCollectionFirstCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *meterLabel;
@property (strong, nonatomic) SwipePlaceFirstCell *place;
@property (strong) IBOutlet PPButton *playPauseButton;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *distance;
@property (strong, nonatomic) IBOutlet UIImageView *placeImageView;

@property (weak, nonatomic) IBOutlet UIButton *shareHebrew;
@property (weak, nonatomic) IBOutlet UIButton *navigateHebrew;
@property (weak, nonatomic) IBOutlet UIButton *readMoreHebrew;

@property (weak, nonatomic) IBOutlet UILabel *distanceHebrew;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (strong, nonatomic) IBOutlet UIButton *reportButton;
@property (strong, nonatomic) IBOutlet UIButton *naviButton;
//@property (strong, nonatomic) IBOutlet UIButton *wikiButton;
@property (weak, nonatomic) IBOutlet UIButton *readMore;

@property (strong, nonatomic) IBOutlet UIView *compassArrow;

@property float bearingDirection;

@property id<PlaceButtonFeaturesDelegate> VCDelegate;

-(void)cellReset;
-(void)setPlace:(SwipePlaceFirstCell *)place;

-(IBAction)buttonAction:(id)sender;

-(void)play;
-(void)pause;

@end
