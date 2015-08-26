//
//  PlacesTableViewController.h
//  YAPP
//
//  Created by yapQ Ltd
//  Copyright (c) 2013 yapQ Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaceViewCell.h"
#import "WebServices.h"
#import "LocationSevice.h"
#import "DescriptionViewController.h"
#import "CautionViewController.h"
#import "LocationDebugViewController.h"
#import "LRSlideMenuController.h"
#import "PlaceButtonFeaturesDelegate.h"
#import <Social/Social.h>
#import <FacebookSDK/FacebookSDK.h>
#import "SiriPlayer.h"
#import "UIDotLoaderIndicatorView.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "ViewInsetsSetupProtocol.h"
#import "DataRequestController.h"
#import "PackageController.h"
#import "LanguagesViewController.h"
#import "GradientView.h"

@class WebViewController;
/**
 * NUmber of cell's loads on startup
 */
#define NUMBER_CELLS_TO_LOAD 3

/**
 * Enum of Caution screen appears option
 *
 * - Show
 *
 * - Hide
 */
typedef NS_ENUM(NSInteger, CautionSceenOptions) {
    CSShow,
    CSHide
};

/**
 * Table View Controller of place feeds
 */
@interface PlacesTableViewController : YViewController <UITableViewDataSource,UITableViewDelegate,LRSlideMenuDelegate, PlaceButtonFeaturesDelegate,
ViewInsetsSetupProtocol, UIAlertViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate> {
}

@property (strong, nonatomic) UIView *loadingView;              // Loading indicator
@property (strong, nonatomic) UIView *noItemFoundMessageView;   // No Items to display view
@property (strong, atomic) NSArray *data;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property BOOL requestSent;                                     // Is request to server already sent?
@property NSInteger currentPlayingIndex;
@property (strong, nonatomic) IBOutlet UIButton *scrollPauseButton;

@property (weak, nonatomic) IBOutlet UIView *routeExpandedView;
@property (weak, nonatomic) IBOutlet UICollectionView *expandViewGrid;
@property (weak, nonatomic) IBOutlet UILabel *lblRouteTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblRouteDistance;
@property (weak, nonatomic) IBOutlet UILabel *lblRouteMustSee;
@property (weak, nonatomic) IBOutlet UIView *viewRouteBottom;
- (IBAction)goButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imgRouteRound;
@property (weak, nonatomic) IBOutlet UIView *routeCollapsedView;
@property (weak, nonatomic) IBOutlet UICollectionView *collapseViewGrid;
@property (weak, nonatomic) IBOutlet UIView *routeGoView;
@property (weak, nonatomic) IBOutlet UILabel *lblRouteCollapsedDistance;
@property (weak, nonatomic) IBOutlet UILabel *lblRouteGoDuration;
@property (strong, nonatomic) IBOutlet UILabel *lblRouteGoTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblRouteGoDirection;
@property (strong, nonatomic) IBOutlet UIImageView *imgRouteGoCompass;
@property (strong, nonatomic) IBOutlet UIImageView *charlieExpanded;
@property (strong, nonatomic) IBOutlet UIImageView *charlieCollapsed;
@property (strong, nonatomic) IBOutlet UIImageView *charlieGo;
@property (nonatomic, assign) BOOL isUserReading;
@property (strong, nonatomic) IBOutlet UIImageView *imgGoBG;

-(void)enterBackground:(id)sender;
-(void)enterForeground:(id)sender;
-(void)reloadLanguage;
-(void)prepareToChangeLanguage;
-(void)popWiki;
-(void)callSearch;
-(void)stopSearch;
-(void)toWiki;

@end
