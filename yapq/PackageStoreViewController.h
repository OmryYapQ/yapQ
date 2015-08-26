//
//  PackageStoreViewController.h
//  yapq
//
//  Created by yapQ Ltd
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LRSlideMenuController.h"
#import "PackageStoreCell.h"
#import "WebServices.h"
#import "UIDotLoaderIndicatorView.h"
#import "PackageController.h"
#import <AVFoundation/AVFoundation.h>
#import <StoreKit/StoreKit.h>
#import "ViewInsetsSetupProtocol.h"
#import "YViewController.h"
#import "AccountViewController.h"



/**
  Class used for drawing lines in UITableView header view around word "DOWNLOAD"
 */
@interface PackageStoreTableHeaderView : UIView

@property (strong, nonatomic) IBOutlet UILabel *viewLabel;

@end
/**
 Class for customizing SearchBar view
 */
@interface PackageStoreSearchBar : UISearchBar

@property (strong, nonatomic) UIButton *cancelButton;

@end

/**
 Package Store View Controller
 */
@interface PackageStoreViewController : YViewController <LRSlideMenuDelegate,PackageStoreCellButtonEvents,UITableViewDataSource, UITableViewDelegate,AVCaptureMetadataOutputObjectsDelegate, SKPaymentTransactionObserver, SKProductsRequestDelegate,ViewInsetsSetupProtocol,UISearchBarDelegate,UITextFieldDelegate,CodeInputEvent>
/** Header of UITableView */
@property (strong, nonatomic) IBOutlet PackageStoreTableHeaderView *tableHeaderView;    // UITableView header view
/** Dots loading view */
@property (strong, nonatomic) UIView *loadingView;                                      // Loading indicator
/** Content UITableView */
@property (strong, nonatomic) IBOutlet UITableView *tableView;                          // UITableView of packages
/** List of packages loaded from server */
@property (strong, nonatomic) NSArray *listOfPackages;                                  // List of packages

@property (strong, nonatomic) IBOutlet PackageStoreSearchBar *storeSearchBar;

@end
