//
//  PackageStoreCell.h
//  yapq
//
//  Created by yapQ Ltd.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Package.h"
#import "UICircleFilledLoader.h"
#import "Utilities.h"
#import "PackageLoader.h"
#import "PromoCodeView.h"
#import "StoreDownloadButton.h"

/**
 PackageStoreCellButtonEvents protoclor
 */
@protocol PackageStoreCellButtonEvents <NSObject>
/** Method call's when download button pressed */
-(void)downloadButtonEvent:(id)cell;
/** Method call's when scan barcode button pressed */
-(void)scanBarCodeButtonEvent:(id)cell;

/** Methods of open close animation of QR Scanner */
@optional
-(void)qrScannerBeginOpenAnimation:(id)cell;
-(void)qrScannerDidEndOpenAnimation:(id)cell;

-(void)qrScannerBaginCloseAnimation:(id)cell;
-(void)qrScannerDidEndCloseAnimation:(id)cell;

@end

////////////////////////////////////////////////////////////////////////////
/**
 Container view of circle loader
 */
@interface LoaderContainerView : UIView
/** Instance of circle loader */
@property (strong, nonatomic) IBOutlet UICircleFilledLoader  *circleLoader;
/** Instance of waiting loader layer */
@property (strong, nonatomic) CAShapeLayer *waitingLayer;

/** Start waiting animation */
-(void)startWaitLoading;
/** Stop waiting animation */
-(void)stopWaitLoading;
@end
////////////////////////////////////////////////////////////////////////////

/**
 Class of cell backgroung view.
 Used for drawing line on it and border around.
 Implement only drawRect method
 */
@interface PackageStoreCellBackgroundView : UIView

@end
////////////////////////////////////////////////////////////////////////////

/**
 Class of PackageStoreCell view
 */
@interface PackageStoreCell : UITableViewCell

/** Cell backgorund view. @see PackageStoreCellBackgroundView */
@property (strong, nonatomic) IBOutlet PackageStoreCellBackgroundView *cellBackgroundView;
@property (strong, nonatomic) IBOutlet UILabel *cityLabel;
@property (strong, nonatomic) IBOutlet UIImageView *packageImageView;
@property (strong, nonatomic) IBOutlet UILabel *cityCountryLabel;
@property (strong, nonatomic) IBOutlet UILabel *poiLabel;
@property (strong, nonatomic) IBOutlet UILabel *simpleDescriptionLabel;

@property (strong, nonatomic) IBOutlet UIButton *promoCodeOpen;
@property (strong, nonatomic) IBOutlet StoreDownloadButton *downloadButton;
/** Loader view container. @see LoaderContainerView */
@property (strong, nonatomic) IBOutlet LoaderContainerView *loaderContainerView;
/** Scanner preview view */
@property (strong, nonatomic) IBOutlet PromoCodeView *promoCodeView;
/**
 Package imageView holder. It also holds Download button
 */
@property (strong, nonatomic) IBOutlet UIView *imageViewHolder;

/** Package of current cell */
@property (strong, nonatomic) Package *package;

/** Delegate of PackageStoreViewController */
@property id<PackageStoreCellButtonEvents> vcDelegate;

/**
 Reset ui components of cell
 */
-(void)cellReset;
/**
 Setup cell as in load procees
 */
-(void)setupAsLoading:(PackageLoader *)packageLoader;
/**
 Open QR Scanner
 */
-(void)openQRScanner;
/**
 Close QR Scanner
 */
-(void)closeQRScanner;
/**
 Setting loading indicator view
 */
-(void)startLoadingForPackageLoader:(PackageLoader *)packageLoader;
/**
 Setting waiting indicator view
 */
-(void)startWaitingForPackageLoader:(PackageLoader *)packageLoader;

@end
