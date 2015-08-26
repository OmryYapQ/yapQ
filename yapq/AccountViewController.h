//
//  AccountViewController.h
//  yapq
//
//  Created by yapQ Ltd on 6/21/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "DeletePackageCell.h"
#import "PackageController.h"
#import "MyPackageCell.h"
#import "FreeDownloadCell.h"
#import "ViewInsetsSetupProtocol.h"
#import "YViewController.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <FacebookSDK/FacebookSDK.h>
#import "Settings.h"

#ifdef __OBJC__
#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#endif

//@class GTLPlusPerson;
//@class GTLServicePlus;
//@class GTMOAuth2Authentication;

static NSString *kProperty = @"properties";
static NSString *kUserFullName = @"ACUIAccountSimpleDisplayName";
static NSString *kEmail = @"ACUIDisplayUsername";
static NSString *kUid = @"uid";
static NSString *facebookAppId = @"645536292171084";

@interface AccountLoadingViewController : YViewController

@end

@interface AccountViewController : YViewController <UITableViewDataSource,UITableViewDelegate,MyPackageCellEvents,ViewInsetsSetupProtocol, UIAlertViewDelegate, GPPSignInDelegate>

@property (strong, nonatomic) IBOutlet UIView *logoutView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *listOfPurchasedPackages;

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIButton *facebookLoginButton;
@property (strong, nonatomic) IBOutlet UIButton *googlePlusLoginButton;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *userImageView;
@property (strong, nonatomic) IBOutlet UILabel *loginDescrLabel;

@property (strong, nonatomic) Package *packageToDownload;

@end
