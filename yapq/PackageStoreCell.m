//
//  PackageStoreCell.m
//  yapq
//
//  Created by yapQ Ltd.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import "PackageStoreCell.h"

@interface PackageStoreCell () {
    
}

@end

@implementation PackageStoreCell

- (void)awakeFromNib
{
    _cellBackgroundView.layer.cornerRadius = 7.0;
    _cellBackgroundView.layer.masksToBounds = YES;
    //_promoCodeOpen.layer.cornerRadius = 5.0;
    _cityLabel.font = [Utilities RobotoLightFontWithSize:21];
    _cityCountryLabel.font = [Utilities RobotoLightFontWithSize:16];
    _simpleDescriptionLabel.font = [Utilities RobotoLightFontWithSize:11];
    _poiLabel.font = [Utilities RobotoLightFontWithSize:14];
    
    if ([[Settings sharedSettings].speechLanguage isEqualToString:tSpeechHebrew]) {
     _cityLabel.textAlignment = NSTextAlignmentRight;
     _simpleDescriptionLabel.textAlignment = NSTextAlignmentRight;
    }
    
    [self cellReset];
    
    _promoCodeOpen.center = CGPointMake([UIScreen mainScreen].bounds.size.width - 100, 248);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(void)cellReset {
    //_packageImageView.image = [UIImage imageNamed:@"placeholder"];
    [_loaderContainerView.circleLoader setProgress:0.0];
    _loaderContainerView.hidden = YES;
    _loaderContainerView.circleLoader.indicatorColor = [Utilities colorWith255StyleRed:255 green:255 blue:255 alpha:1.0];
    _downloadButton.hidden = NO;
    _downloadButton.label.hidden = NO;
}

/**
 Setter of package into cell
 */
-(void)setPackage:(Package *)package {
    _package = package;
    
    _cityLabel.text = _package.packageName ? _package.packageName : _package.packageCity;
    _cityCountryLabel.text = [NSString stringWithFormat:@"%@, %@",_package.packageCity, _package.packageCountry];
    _downloadButton.label.text = [NSString stringWithFormat:@"$ %@",_package.price];
    // Setting attributed string for word "offline" with green color
    NSString *t = [NSString stringWithFormat:NSLocalizedString(@"store_cell_text", nil),_package.packageCity];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:t];
    NSRange range = [t rangeOfString:NSLocalizedString(@"offline",nil)];
    [text addAttribute:NSFontAttributeName
                 value:[Utilities RobotoBoldFontWithSize:11]
                 range:range];
    _simpleDescriptionLabel.attributedText = text;
    
    NSNumber *poiNumber = [NSNumber numberWithInt:_package.numberOfPlaces];
    NSString *numberInFormat = [NSNumberFormatter localizedStringFromNumber:poiNumber numberStyle:NSNumberFormatterDecimalStyle];
    _poiLabel.text = [NSString stringWithFormat:NSLocalizedString(@"places", nil),numberInFormat];
    _packageImageView.image = [UIImage imageNamed:@"missing_photo"];
    // Loading and caching image of package
    if (_package.packageImage.length == 0) {
        return;
    }
    UIImage *img = [Utilities getCachedImage:_package.packageImage];
    if (img) {
        _packageImageView.image = img;
    }
    else {
        [Utilities taskInSeparatedThread:^{
            [Utilities cacheImage:_package.packageImage isOffline:NO];
            UIImage *img = [Utilities getCachedImage:_package.packageImage];
            if (img) {
                _packageImageView.image = img;
            }
        }];
    }
}

-(void)setupAsLoading:(PackageLoader *)packageLoader {
    if (packageLoader.currentStatus == PLS_LOAD_WAITING) {
        // Waiting setup
        [_loaderContainerView startWaitLoading];
    }
    else {
        // Loading in progress
        [_loaderContainerView.circleLoader initDefaults];
        [_loaderContainerView.circleLoader setProgress:0.0];
        _loaderContainerView.circleLoader.indicatorColor = [Utilities colorWith255StyleRed:255 green:255 blue:255 alpha:1.0];
        [_loaderContainerView.circleLoader setProgress:packageLoader.loadingProgres animated:YES];
    }
    _loaderContainerView.hidden = NO;
    _downloadButton.hidden = YES;
    _downloadButton.label.hidden = YES;
}

-(void)startLoadingForPackageLoader:(PackageLoader *)packageLoader {
    [_loaderContainerView stopWaitLoading];
    [_loaderContainerView.circleLoader initDefaults];
    [_loaderContainerView.circleLoader setProgress:0.0];
    _loaderContainerView.circleLoader.indicatorColor = [Utilities colorWith255StyleRed:255 green:255 blue:255 alpha:1.0];
    [_loaderContainerView.circleLoader setProgress:packageLoader.loadingProgres animated:YES];
}

-(void)startWaitingForPackageLoader:(PackageLoader *)packageLoader {
    if (_loaderContainerView.hidden == YES) {
        [_loaderContainerView startWaitLoading];
        _loaderContainerView.hidden = NO;
        _downloadButton.hidden = YES;
        _downloadButton.label.hidden = YES;
    }
}

-(BOOL)isEqual:(id)object {
    if (object == self) {
        return YES;
    }
    
    if (![super isEqual:object]) {
        return NO;
    }
    return NO;
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Buttons Action
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////
-(IBAction)downloadButtonPressed:(id)sender {
    [_vcDelegate downloadButtonEvent:self];
    // Start waiting animation
    [self startWaitingForPackageLoader:nil];
}

-(IBAction)scanBarCodeButtonPressed:(id)sender {
    [_vcDelegate scanBarCodeButtonEvent:self];
    [self openQRScanner];
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark QR Scanner
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////
-(void)openQRScanner {
    _promoCodeView.nOne.text = @"";
    _promoCodeView.nTwo.text = @"";
    _promoCodeView.nThree.text = @"";
    _promoCodeView.nFour.text = @"";
    
    [_vcDelegate qrScannerBeginOpenAnimation:self];
    [UIView transitionFromView:_imageViewHolder toView:_promoCodeView duration:1.0 options:UIViewAnimationOptionTransitionFlipFromLeft completion:^(BOOL finished) {
        [_vcDelegate qrScannerDidEndOpenAnimation:self];
    }];
}

-(void)closeQRScanner {
    [_vcDelegate qrScannerBaginCloseAnimation:self];
    [UIView transitionFromView:_promoCodeView toView:_imageViewHolder duration:1.0 options:UIViewAnimationOptionTransitionFlipFromLeft completion:^(BOOL finished) {
        [_vcDelegate qrScannerDidEndCloseAnimation:self];
    }];
}
//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Loading progress observer
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////
/**
 Observer of loading progress for specific PackageLoader
 */
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:kDownloadProgressObserver]) {
        float progress = [[change valueForKeyPath:NSKeyValueChangeNewKey] floatValue];
        NSLog(@"%f",progress);
        [Utilities UITaskInSeparatedBlock:^{
            [_loaderContainerView.circleLoader setProgress:progress animated:YES];
        }];
        
    }
}

@end

/**
 Implementation of LoaderContainerView
 */
@implementation LoaderContainerView

-(void)awakeFromNib {
    
    _circleLoader = [[UICircleFilledLoader alloc] initWithFrame: (CGRect){1, 1, 78, 78}];

    [self addSubview: _circleLoader];
    // Init layer of waiting loader
    self.layer.cornerRadius = self.bounds.size.width/2.0;
    _waitingLayer = [[CAShapeLayer alloc] init];
    _waitingLayer.fillColor = nil;
    _waitingLayer.frame = self.bounds;
    _waitingLayer.strokeColor = [UIColor whiteColor].CGColor;
    _waitingLayer.lineWidth = 3;
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _waitingLayer.path = [UIBezierPath bezierPathWithArcCenter:center
                                                       radius:self.bounds.size.width/2 - 4
                                                   startAngle:-M_PI_2
                                                     endAngle:-M_PI_2 + 2 * M_PI-0.5
                                                    clockwise:YES].CGPath;

}

-(void)startWaitLoading {
    _circleLoader.hidden = YES;
    _waitingLayer.hidden = NO;
    //_circleLoader.alpha = 0;
    [self.layer addSublayer:_waitingLayer];
    // Rotating animation setup
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0];
    rotationAnimation.duration = 1.5;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = HUGE_VALF;
    [_waitingLayer addAnimation:rotationAnimation forKey:@"WaitingAnimation"];
}

-(void)stopWaitLoading {
    _circleLoader.hidden = NO;
    _waitingLayer.hidden = YES;
    [_waitingLayer removeFromSuperlayer];
    [_waitingLayer removeAnimationForKey:@"WaitingAnimation"];
}

@end

/**
 Implementation of PackageStoreCellBackgroundView
 */
@implementation PackageStoreCellBackgroundView

-(void)awakeFromNib {
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = [UIColor colorWithRed:233./255. green:233./255. blue:233./255. alpha:1.0].CGColor;
}

-(void)drawRect:(CGRect)rect {
    
   /* UIBezierPath *path = [[UIBezierPath alloc] init];
    path.lineWidth = 1.0;
    [path moveToPoint:CGPointMake(14, 285)];
    [path addLineToPoint:CGPointMake(272, 285)];
    [[UIColor colorWithRed:220./255. green:220./255. blue:220./255. alpha:1.0] setStroke];
    [path stroke];*/
}

@end