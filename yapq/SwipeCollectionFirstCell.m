//
//  SwipeCollectionFirstCell.m
//  YAPP
//
//  Created by yapQ Ltd on 13/8/15.
//  Copyright (c) 2015 yapQ Ltd. All rights reserved.
//

#import "SwipeCollectionFirstCell.h"
#import "tToken.h"
#import "SwipePlaceFirstCell.h"

@implementation SwipeCollectionFirstCell

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

-(void)cellReset {
    //_placeImageView.frame = CGRectMake(20, 43, 260, 160);
    _placeImageView.image = [UIImage imageNamed:@"missing_photo"];

    _titleLabel.text = @"";
    _descriptionLabel.text = @"";
}

- (void)setIsVisible:(Boolean)isVisible {
    NSLog(@"visible place %@",_place);
}

-(void)setPlace:(SwipePlaceFirstCell *)place {
    _place = place;
   
    /*
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
    */
}

-(void)loadOfflineImage {
    /*
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
    */
}

-(void)loadOnlineImage {
    /*
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
    */
}

-(IBAction)openWiki:(id)sender {
    saveEvent(@"readMore");
    //[_VCDelegate toWiki:_place.wiki];
}

-(IBAction)report:(id)sender {
    saveEvent(@"report");
    //[_VCDelegate toReport:_place];
}

-(IBAction)facebookShare:(id)sender {
    saveEvent(@"share");
    //[_VCDelegate toFacebookShare:_place];
    
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
