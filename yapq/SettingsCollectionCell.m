//
//  SettingsCollectionCell.m
//  YAPP
//
//  Created by yapQ Ltd on 13/8/15.
//  Copyright (c) 2015 yapQ Ltd. All rights reserved.
//

#import "SettingsCollectionCell.h"
#import "SettingsPlace.h"

@implementation SettingsCollectionCell

-(void)prepareForReuse {
    //NSLog(@"%@ %i",_place.title,_place.isPlaying);
    [self cellReset];
}

-(void)awakeFromNib {
    self.backgroundColor = [UIColor clearColor];
}

-(void)cellReset {
    self.lblDescription.text = @"";
    self.lblTitle.text = @"";
    self.viewSpeechRate.hidden = YES;
}

- (void)setIsVisible:(Boolean)isVisible {
    NSLog(@"visible place %@",_place);
}

-(void)setPlace:(SettingsPlace *)place {
    _place = place;
    
    if (place.p_id == 0) {
        // speed
        self.lblTitle.text = @"ADJUST SPEECH RATE";
        self.lblDescription.text = @"Drag the circle to change audio speed";
        self.viewSpeechRate.hidden = NO;
        self.viewSocial.hidden = YES;
    }
    else {
        // social
        self.lblTitle.text = @"LET'S GET SOCIAL";
        self.lblDescription.text = @"Upload your photos and save your guides";
        self.viewSpeechRate.hidden = YES;
        self.viewSocial.hidden = NO;
    }
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

@end
