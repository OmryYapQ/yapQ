//
//  PlaceViewCell.m
//  YAPP
//
//  Created by yapQ Ltd on 12/2/13.
//  Copyright (c) 2013 yapQ Ltd. All rights reserved.
//

#import "PlaceViewCell.h"
#import "tToken.h"

CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;}
CGFloat RadiansToDegrees(CGFloat radians) {return radians * 180 / M_PI;}

@implementation PlaceViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)prepareForReuse {
    //NSLog(@"%@ %i",_place.title,_place.isPlaying);
    [self cellReset];
}

-(void)awakeFromNib {
    self.backgroundColor = [UIColor clearColor];
    _descriptionLabel.font = [Utilities RobotoLightFontWithSize:17];
    _titleLabel.font = [Utilities RobotoLightFontWithSize:21];
    _distance.font = [Utilities RobotoLightFontWithSize:17];
    
    //corner to the meter label
    CAShapeLayer * maskLayer = [CAShapeLayer layer];
    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect: self.bounds byRoundingCorners: UIRectCornerTopLeft | UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii: (CGSize){4.0, 4.0}].CGPath;
    
    _meterLabel.layer.mask = maskLayer;
    _distanceHebrew.layer.mask = maskLayer;

    _shareButton.hidden = NO;
    _shareHebrew.hidden = NO;
    _reportButton.hidden = TRUE;
    
    //float image right on herbew layout
    if ([[Settings sharedSettings].speechLanguage isEqualToString:tSpeechHebrew]) {
        _shareButton.imageEdgeInsets = UIEdgeInsetsMake(0., _shareButton.frame.size.width - (32 + 15.), 0., 0.);
        _shareButton.titleEdgeInsets = UIEdgeInsetsMake(0., 0., 0., 32);
        _naviButton.imageEdgeInsets = UIEdgeInsetsMake(0., _naviButton.frame.size.width - (32 + 15.), 0., 0.);
        _naviButton.titleEdgeInsets = UIEdgeInsetsMake(0., 0., 0., 32);
        _readMore.imageEdgeInsets = UIEdgeInsetsMake(0., _readMore.frame.size.width - (32 + 15.), 0., 0.);
        _readMore.titleEdgeInsets = UIEdgeInsetsMake(0., 0., 0., 32);
        _naviButton.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2  , 24);
        _shareButton.center = CGPointMake([UIScreen mainScreen].bounds.size.width - 68, 24);
        _readMore.center = CGPointMake(60, 24);
    }else{
        _naviButton.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2  , 22);
        _shareButton.center = CGPointMake([UIScreen mainScreen].bounds.size.width - 68, 22);
        _readMore.center = CGPointMake(60, 24);
    }
    UIInterpolatingMotionEffect *motionEffect;
    motionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y"
                                                                   type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    motionEffect.minimumRelativeValue = @(20);
    motionEffect.maximumRelativeValue = @(-20);
    
    UIInterpolatingMotionEffect *motionHot = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    motionHot.minimumRelativeValue =  @(20);
    motionHot.maximumRelativeValue = @(-20);
    
    [_placeImageView addMotionEffect:motionHot];
    [_placeImageView addMotionEffect:motionEffect];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)cellReset {
    //_placeImageView.frame = CGRectMake(20, 43, 260, 160);
    _placeImageView.image = [UIImage imageNamed:@"missing_photo"];

    _titleLabel.text = @"";
    _descriptionLabel.text = @"";
}

- (void)setIsVisible:(Boolean)isVisible {
    NSLog(@"visible place %@",_place);
}

-(void)setPlace:(Place *)place {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(headingNotification:) name:LSLocationHeadingChanged object:nil];
    //NSString *speedUnits = nil;
    _place = place;
    _titleLabel.text = [_place.title capitalizedString];
    _descriptionLabel.text = _place.descr;

    
    if ([[Settings sharedSettings].speechLanguage isEqualToString:tSpeechHebrew]) {
        _titleLabel.textAlignment = NSTextAlignmentRight;
        _descriptionLabel.textAlignment = NSTextAlignmentRight;
    }
    else {
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _descriptionLabel.textAlignment = NSTextAlignmentLeft;
    }
    [self calculatingBearing];
    //if ([[Settings sharedSettings].speechLanguage isEqualToString:tSpeechHebrew]) {
    //    _titleLabel.textAlignment = NSTextAlignmentRight;
    //    _descriptionLabel.textAlignment = NSTextAlignmentRight;
    //    if (place.dist > 1000) {
    //        speedUnits = @"ק׳׳מ";
    //    }
    //    else {
    //        speedUnits = @"מ";
    //    }
    //}
    //else {
    //    _titleLabel.textAlignment = NSTextAlignmentLeft;
    //    _descriptionLabel.textAlignment = NSTextAlignmentLeft;
    //}
    [self setUnitsOfDistanceLabel];
    
    if (_place.isPlaying) {
        [self play];
    }
    else {
        [self pause];
    }

    if (_place.img_url.length == 0) {
        return;
    }
    if (_place.isOffline) {
        [self loadOfflineImage];
    }
    else {
        [self loadOnlineImage];
    }
    
    // those were YES for beacons
    _reportButton.hidden = NO;
    _naviButton.hidden = NO;
    _distance.hidden = NO;
    
    if ([ServerResponse sharedResponse].searchId != NULL) {
        // in search don't show the distance label
        _distance.hidden = YES;
    }
}

-(void)setUnitsOfDistanceLabel {
    if ([[Settings sharedSettings] isKilomenters]) {
        NSString *distUnits = nil;
        if (_place.dist > 1000) {
            distUnits = @"km";
        }
        else {
            distUnits = @"m";
        }
        if (_place.dist > 1000) {
            _distance.text = [NSString stringWithFormat:@"%.1f %@",_place.dist/1000.,distUnits];
        }
        else {
            _distance.text = [NSString stringWithFormat:@"%li %@",(long)_place.dist,distUnits];
        }
    }
    else {
        _distance.text = [NSString stringWithFormat:@"%.1f miles",_place.dist/1609.34];
    }
}

-(void)loadOfflineImage {
    UIImage *img = [Utilities getCachedImage:_place.img_url];
    if (img) {
        _placeImageView.image = img;
    }
    else {
        [Utilities taskInSeparatedThread:^{
            [Utilities cacheImage:_place.img_url isOffline:YES];
            UIImage *img = [Utilities getCachedImage:_place.img_url];
            if (img) {
                _placeImageView.image = img;
            }
        }];
    }
}

-(void)loadOnlineImage {

    UIImage *img = [Utilities getCachedImage:_place.img_url];
    if (img) {
        _placeImageView.image = img;

    }
    else {
        [Utilities taskInSeparatedThread:^{
            [Utilities cacheImage:_place.img_url isOffline:NO];
            UIImage *img = [Utilities getCachedImage:_place.img_url];
            if (img) {
                _placeImageView.image = img;
            }
        }];
    }
}

-(IBAction)routeToPlace:(id)sender {
    NSString *mapsLink = nil;
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:GOOGLE_MAPS_URL_SCHEME]]) {
        mapsLink = [NSString stringWithFormat:@"%@?daddr=%lf,%lf&saddr=%lf,%lf&directionsmode=walking&x-success=yapq://?resume=true&x-source=yapq",GOOGLE_MAPS_URL_SCHEME,_place.lan,_place.lon,[LocationService sharedService].currentLatitude,
                    [LocationService sharedService].currentLongitude];
    }
    else  {
        mapsLink = [NSString stringWithFormat:@"http://maps.apple.com/maps?daddr=%lf,%lf&saddr=%lf,%lf",_place.lan,_place.lon,
                    [LocationService sharedService].currentLatitude,
                    [LocationService sharedService].currentLongitude];
    }
    [_VCDelegate toWaze:mapsLink];
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:mapsLink]];
    
    //log event
    saveEvent(@"navigate");
}

-(IBAction)openWiki:(id)sender {
    saveEvent(@"readMore");
    [_VCDelegate toWiki:_place.wiki];
}

-(IBAction)report:(id)sender {
    saveEvent(@"report");
    [_VCDelegate toReport:_place];
}

-(IBAction)facebookShare:(id)sender {
    saveEvent(@"share");
    [_VCDelegate toFacebookShare:_place];
    
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Compass
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////
- (void)calculatingBearing {
    /*float lat1 = DegreesToRadians([LocationSevice sharedService].currentLocation.latitude);
    float lng1 = DegreesToRadians([LocationSevice sharedService].currentLocation.longitude);
    float lat2 = DegreesToRadians(_place.lan);
    float lng2 = DegreesToRadians(_place.lon);
    float deltalng = lng2 - lng1;
    double y = sin(deltalng) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltalng);
    double bearing = atan2(y, x) + 2 * M_PI;
    float bearingDegrees = RadiansToDegrees(bearing);
    bearingDegrees = (int)bearingDegrees % 360;
    self.bearingDirection = bearingDegrees+180;
    NSLog(@"%@ degree: %d",_place.title, (int)bearingDegrees);*/
    
}

-(void)headingNotification:(id)sender {
    NSDictionary *userInfo = [((NSNotification *)sender) userInfo];
    [self headingChanged:[userInfo valueForKey:HedingKey]];
}

-(void)headingChanged:(CLHeading *)newHeading {
    //double distToNorth = [LocationSevice distanceFromCurrentLocationToLocation:[YLocation initWithLatitude:81.3 andLongitude: -110.8]];
    double arcToNorth = [LocationService azimuthFromLocation:[LocationService sharedService].currentLocation LocationToLocation:[YLocation initWithLatitude:81.3 andLongitude: -110.8]];
    double arcToPlace = [LocationService azimuthFromLocation:[LocationService sharedService].currentLocation LocationToLocation:[YLocation initWithLatitude:_place.lan andLongitude: _place.lon]];
    double angle = arcToPlace - arcToNorth;
    float heading = newHeading.magneticHeading+40; //in degrees
    float headingDegrees = ((angle + heading)*M_PI/180); //assuming needle points to top of iphone. convert to radians
    //headingDegrees +=_bearingDirection;
    //NSLog(@"dir: %d", (int)_bearingDirection);
    //NSLog(@"deg: %d", (int)headingDegrees);
    self.compassArrow.transform = CGAffineTransformMakeRotation(-headingDegrees);
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark PPButton Protocol
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////
-(IBAction)buttonAction:(id)sender {
    
    if (_playPauseButton.isPlaying) { // Pause action
        [self pause];
        /*if ([[Settings sharedSettings].speechLanguage isEqualToString:tSpeechHebrew]) {
            [[StreamPlayer sharedPlayer] pause];
        }
        else*/ if ([[Settings sharedSettings] isSiriLanguage]) {
            [[SiriPlayer sharedPlayer] pauseWithCompletion:nil];
        }
        //record event pause
        saveEvent(@"listenPause");
    }
    else { // Play action
        [self play];
        /*if ([[Settings sharedSettings].speechLanguage isEqualToString:tSpeechHebrew]) {
            [[StreamPlayer sharedPlayer] playPlaceAudio:_place];
        }
        else */if ([[Settings sharedSettings] isSiriLanguage]) {
            [[SiriPlayer sharedPlayer] playPlaceAudio:_place];
        }
        //record event play
        saveEvent(@"listenStart");
    }
}


-(void)play {
    [_playPauseButton play];
}

-(void)pause {
    [_playPauseButton pause];
}


@end
