//
//  PlacesTableViewController.m
//  YAPP
//
//  Created by yapQ Ltd
//  Copyright (c) 2013 yapQ Ltd. All rights reserved.
//

#define ROUTES_NUM_IMAGES       6


#import "PlacesTableViewController.h"
#import <Social/Social.h>
#import "tToken.h"
#import "FLAnimatedImage.h"
#import "PlaceCollectionViewCell.h"
#import "SettingsPlace.h"
#import "OfflinePlace.h"
#import "DBPlace.h"
#import "SwipePlaceFirstCell.h"
#import "SettingsCollectionCell.h"

#define NO_ROUTE_FOUND                      -1
#define NAV_VIEW_DELETE_BUTTON_W            60
#define ROUTE_DISTANCE_TO_CALL_API_METERS   200

@interface ExpandedGridCusotmLayout : UICollectionViewFlowLayout {
    
}
@end
@implementation ExpandedGridCusotmLayout
- (void)prepareLayout {
    [super prepareLayout];
    
    double widthFactor = self.collectionView.bounds.size.width/310.0f;
    int newWidth = 100.0f * widthFactor;
    
    self.minimumInteritemSpacing = 1;
    self.minimumLineSpacing = 1;
    
    self.itemSize = CGSizeMake(newWidth - 1,  80);
}

@end

@interface CollapsedGridCusotmLayout : UICollectionViewFlowLayout {
    
}
@end
@implementation CollapsedGridCusotmLayout
- (void)prepareLayout {
    [super prepareLayout];
    
    double widthFactor = self.collectionView.bounds.size.width/310.0f;
    int newWidth = 60.0f * widthFactor;
    newWidth = (self.collectionView.bounds.size.width -10)/4;
    
    self.minimumInteritemSpacing = 1;
    self.minimumLineSpacing = 1;
    
    self.itemSize = CGSizeMake(newWidth - 1,  50);
}

@end

@interface PlacesTableViewController () {
    
    CautionViewController *cvc;
    //UIDotLoaderIndicatorView *dliv;
    CGPoint scrollStartPoint;
    int scrollDirection;// 1 - up, -1 - down
    float yPos;
    
    BOOL isPauseButtonVisible;
    
    NSString *indorPlaceName;
    BOOL isMenuOpened;
    BOOL isUserMakeScroll;
    
    UIView *statusBarView;
    
    UIRefreshControl *refreshControl;

    BOOL searching;
    NSString *cellWikiUrl;
    NSMutableArray *gridImages;
    
    BOOL expandedRouteShown;
    
    BOOL expanded_guard;
    BOOL loading;
    BOOL show_go_view;
    UIImage *imgMissingRouteImage;
    NSInteger routeId;
    RouteLocation *toRouteLocation;
    BOOL inBG;
    
    CGRect rcInitialTable;
    CGRect rcInitialRouteCollapsed;
    CGRect rcInitialRouteExpanded;
    CGRect rcInitialRouteGo;
    
    BOOL bGoViewSwipedLeft;
    BOOL bStoppedScrolling;
    BOOL bGoViewSwippingRight;
    
    YLocation *lastRouteAPILocation;
    bool compassAnimating;
    int lastCompassCalc;
}

@property (nonatomic, strong) NSMutableDictionary *horizontalCellsXOffsetDictionary;

@end

@implementation PlacesTableViewController

@synthesize data = data;
@synthesize currentPlayingIndex = currentPlayingIndex;
//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController methods
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _requestSent = NO;
    
    statusBarView = [[UIView alloc] initWithFrame: (CGRect){0, 0, self.view.frame.size.width, 20}];
    statusBarView.backgroundColor = [Utilities colorWith255StyleRed:255 green:237 blue:15 alpha:1.0];
    
    //self.tableView.scrollsToTop = YES;
    
    // Navigation Bar
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bar"]
//                                                  forBarMetrics:UIBarMetricsDefault];
//    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    self.navigationController.navigationBar.translucent = YES;
//    self.navigationController.view.backgroundColor = [UIColor clearColor];
    
    UINavigationBar* navigationBar = self.navigationController.navigationBar;
    UIImageView *shadow = [self findHairlineImageViewUnder:navigationBar];
    shadow.hidden = YES;
    [navigationBar setBarTintColor:[UIColor colorWithRed:1.0f green:237./255. blue:15.f/255.0f alpha:1.0f]];
    
    const CGFloat statusBarHeight = 20;    //  Make this dynamic in your own code...
    
    UIView* underlayView = [[UIView alloc] initWithFrame:CGRectMake(0, -statusBarHeight, navigationBar.frame.size.width, navigationBar.frame.size.height + statusBarHeight)];
    [underlayView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    [underlayView setBackgroundColor:[UIColor colorWithRed:1.0f green:237./255. blue:15./255. alpha:1.0f]];
    [underlayView setAlpha:0.36f];
    [navigationBar insertSubview:underlayView atIndex:0];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont
                                                                           fontWithName:@"Roboto-Regular" size:22], NSFontAttributeName,
                                [UIColor blackColor], NSForegroundColorAttributeName, nil];
    [navigationBar setTitleTextAttributes:attributes];
    
    
    currentPlayingIndex = -1;

    // AppDelegate Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    // Adding notification receiver for MPMoviePlayer events
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerStateDidChanged:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:[StreamPlayer sharedPlayer].player];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidFinishPlay:) name:MPMoviePlayerPlaybackDidFinishNotification object:[StreamPlayer sharedPlayer].player];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(placeStartPlaying:) name:PLACE_PLAYING_STATE_CHANGED_NOTIFICATION object:nil];
    
    // Adding notification receiver for Location service
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationServiceReady:) name:LSLocationWasUpdatedNotification object:[LocationService sharedService]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newRouteLocation:) name:LSRouteLocationWasUpdatedNotification object:[LocationService sharedService]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(speedChangesReceiver:) name:LSSpeedChangesNotification object:[LocationService sharedService]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationServiceStatusReceiver:) name:LSLocationChangeStatusNotification object:[LocationService sharedService]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noGPSSignalNotificationReceiver) name:LSLocationNOGPSSignalNotification object:[LocationService sharedService]];
    
    // Adding notificaation receiver for SiriPlayer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(siriPlayerEventMethod:) name:SiriPlayerStartPlayingNotification object:[SiriPlayer sharedPlayer]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(siriPlayerEventMethod:) name:SiriPlayerPausePlayingNNotification object:[SiriPlayer sharedPlayer]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(siriPlayerEventMethod:) name:SiriPlayerFinishPlayingNotification object:[SiriPlayer sharedPlayer]];

    // Adding notification receiver for PackageLoaderController
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(packageLoaded:) name:PL_STATUS_NOTIFICATION_KEY object:nil];
    
    //Adding notification receiver for language change
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(languageChangeNotification:) name:LANGUAGE_CHANGE_NOTIFICATION_KEY object:nil];
    
    // Adding notification receiver for settings change
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsChanged:) name:SETTINGS_CHANGED_NOTIFICATION object:nil];
    
    // adding receiver for compass heading change
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gpsHeadingChange:) name:LSLocationHeadingChanged object:nil];
    
    
    // DEBUG
    /* Opening location debug console with 5 taps on navigation bar
    UITapGestureRecognizer *navSingleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navTap:)];
    navSingleTap.numberOfTapsRequired = 1;
    navSingleTap.numberOfTouchesRequired = 1;
    [self.navigationController.navigationBar addGestureRecognizer:navSingleTap];
    // END DEBUG
    */
    
    
//#warning OPEN GOOGLE ANALITICS
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:[NSString stringWithFormat:@"IOS: %@ %@",NSStringFromClass([self class]),[Settings sharedSettings].speechLanguage]];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    

    self.expandViewGrid.dataSource = self;
    self.collapseViewGrid.dataSource = self;
    
    imgMissingRouteImage = [UIImage imageNamed:@"route_placeholder"];
    
    // the UI is designed for 6 cells !
    gridImages = [[NSMutableArray alloc] initWithCapacity:ROUTES_NUM_IMAGES];
    for (int i =0;i < ROUTES_NUM_IMAGES;++i) {
        [gridImages insertObject:@"" atIndex:0];
    }
    
    /* for testing purposes
    gridImages = [NSArray arrayWithObjects:@"https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/HPIM2097.JPG/299px-HPIM2097.JPG",
                  @"https://upload.wikimedia.org/wikipedia/commons/thumb/2/2e/RabinSquare.jpg/400px-RabinSquare.jpg",
                  @"https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/HPIM2097.JPG/299px-HPIM2097.JPG",
                  @"https://upload.wikimedia.org/wikipedia/commons/thumb/2/2e/RabinSquare.jpg/400px-RabinSquare.jpg",
                  @"https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/HPIM2097.JPG/299px-HPIM2097.JPG",
                  @"https://upload.wikimedia.org/wikipedia/commons/thumb/2/2e/RabinSquare.jpg/400px-RabinSquare.jpg",nil];
    */
    
     /*
    self.routeCollapsedView.layer.borderWidth = 0;
    self.routeCollapsedView.layer.cornerRadius = 14;
    self.routeCollapsedView.layer.masksToBounds = YES;
    
    self.routeCollapsedView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.routeCollapsedView.layer.shadowOffset = CGSizeMake(5, 5);
    self.routeCollapsedView.layer.shadowOpacity = 0.5;
    self.routeCollapsedView.layer.shadowRadius = 1.0;
    */
    
    
    // add tap to collapsed view
    UITapGestureRecognizer *tgr =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(collapsedViewTapped:)];
    [tgr setNumberOfTapsRequired:1];
    [self.routeCollapsedView addGestureRecognizer:tgr];
    
    tgr =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goViewTapped:)];
    [tgr setNumberOfTapsRequired:1];
    [self.routeGoView addGestureRecognizer:tgr];
    
    // add swipe left to go view
    UISwipeGestureRecognizer *lsgr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(goViewSwipedLeft:)];
    [lsgr setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.routeGoView addGestureRecognizer:lsgr];
    
    // add swipe right to go view
    UISwipeGestureRecognizer *rsgr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(goViewSwipedRight:)];
    [rsgr setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.routeGoView addGestureRecognizer:rsgr];
    
    // delete button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.userInteractionEnabled = YES;
    self.routeGoView.userInteractionEnabled = YES;
    button.tag = 1800;
    [button setFrame:CGRectMake(self.view.bounds.size.width, 0, NAV_VIEW_DELETE_BUTTON_W, mainHeaderHeight /*self.routeGoView.frame.size.height*/)];
    [button setTitle:@""  forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"close-go"] forState:UIControlStateNormal];
    button.showsTouchWhenHighlighted = YES;
    button.backgroundColor = UIColor.clearColor;
    [button addTarget:self action:@selector(onGoViewDeleteClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.routeGoView addSubview:button];
    
    self.expandViewGrid.collectionViewLayout = [[ExpandedGridCusotmLayout alloc] init];
    self.collapseViewGrid.collectionViewLayout = [[CollapsedGridCusotmLayout alloc] init];
    
    /*
    [self.tableView setContentInset:UIEdgeInsetsMake(64, // top, left, bottom, right
                                                         self.tableView.contentInset.left,
                                                         self.tableView.contentInset.bottom,
                                                         self.tableView.contentInset.right)];
     */
    
    rcInitialTable = CGRectNull;
    rcInitialRouteCollapsed = CGRectNull;
    rcInitialRouteExpanded = CGRectNull;
    rcInitialRouteGo = CGRectNull;
    
    
    
    NSString *str=[[NSBundle mainBundle] pathForResource:@"charlli" ofType:@"gif"];
    NSData *fileData = [NSData dataWithContentsOfFile:str];
    
    FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:fileData];
    FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc] init];
    imageView.animatedImage = image;
    imageView.frame = self.charlieExpanded.frame;
    imageView.autoresizingMask = self.charlieExpanded.autoresizingMask;
    [self.routeExpandedView addSubview:imageView];
    
    imageView = [[FLAnimatedImageView alloc] init];
    imageView.animatedImage = image;
    imageView.frame = self.charlieCollapsed.frame;
    imageView.autoresizingMask = self.charlieCollapsed.autoresizingMask;
    [self.routeCollapsedView addSubview:imageView];
    
    imageView = [[FLAnimatedImageView alloc] init];
    imageView.animatedImage = image;
    imageView.frame = self.charlieGo.frame;
    imageView.autoresizingMask = self.charlieGo.autoresizingMask;
    [self.routeGoView addSubview:imageView];
    
    
    /*
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(self.view.bounds.size.width/2 - 40,
                                self.view.bounds.size.height/2 - 40,
                                80,
                                80)];
    [button setTitle:@""  forState:UIControlStateNormal];
    button.backgroundColor = UIColor.yellowColor;
    [button addTarget:self action:@selector(testClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    */
    
    self.horizontalCellsXOffsetDictionary = [NSMutableDictionary dictionary];
}

-(void)testClick {
    [[LocationService sharedService] startUpdate];
}

- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

-(void)viewWillAppear:(BOOL)animated {
    [self.navigationController.view addSubview: statusBarView];

    [self needToShowLoading];
}

-(void)viewWillDisappear:(BOOL)animated {
    //viewIsActive = NO;
    @try {
        [statusBarView removeFromSuperview];
        if (![[self presentedViewController].restorationIdentifier isEqualToString:@"cautionVC"] &&
            ![[self presentedViewController].restorationIdentifier isEqualToString:@"Description"]) {
            if ([[Settings sharedSettings] isSiriLanguage]) {
                [[SiriPlayer sharedPlayer] pauseWithCompletion:nil];
            }
            /*else if ([[Settings sharedSettings].speechLanguage isEqualToString:tSpeechHebrew]) {
             [[StreamPlayer sharedPlayer] pause];
             }*/
        }
    }
    @catch (NSException *exception) {
        
    }
}

-(void)enterBackground:(id)sender {
    inBG = YES;
    
    if (data.count == 0) {
        return;
    }
    /*0L:Uncomment
    if (currentPlayingIndex >= data.count) {
        return;
    }
    Place *p = [data objectAtIndex:currentPlayingIndex];
    if (p.isPlaying) {
        PlaceViewCell *cell = (PlaceViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:currentPlayingIndex inSection:0]];
        [cell pause];
    }
    */
}

-(void)enterForeground:(id)sender {
    inBG = NO;
    
    if (data.count == 0) {
        return;
    }
    
    /*0L:Uncomment
    if (currentPlayingIndex >= data.count) {
        return;
    }
    Place *p = [data objectAtIndex:currentPlayingIndex];
    if (p.isPlaying) {
        PlaceViewCell *cell = (PlaceViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:currentPlayingIndex inSection:0]];
        [cell play];
    }
    */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark LRSlideMenuDelegate
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////

-(BOOL)LRSlideMenuHasLeftMenu {
    return YES;
}

-(BOOL)LRSlideMenuHasRightMenu {
    //0L: add search menu button
    return YES;
}

-(BOOL)menuWillOpen:(LRSlideMenu)menu {
    if (searching) {
        // in the middle of search -> don't allow opening a menu
        return NO;
    }
    
    if (menu == LRSlideMenuLeft) {
        [self scrollViewDidEndDecelerating:nil];
        
        [UIView animateWithDuration:0.3 delay:0.0 options:0 animations:^{
            self.view.alpha = 0.0;

        } completion:^(BOOL finished) {
            
        }];
    }
    else {
        // the search
        
    }
    
    return YES;
}

-(BOOL)menuWillClose:(LRSlideMenu)menu {
    if (menu == LRSlideMenuLeft) {
        [UIView animateWithDuration:0.3 delay:0.0 options:0 animations:^{
            self.view.alpha = 1.0;

        } completion:^(BOOL finished) {
            
        }];
    }
    
    return YES;
}


/*
-(UIButton *)backToYapqButton {
    UIButton *button = [[UIButton alloc] initWithFrame: (CGRect){125, 200, 70, 35}];
}*/

-(void)updateRouteUI:(RouteLocation *)routeLoc {
    if (routeLoc != NULL) {
        self.lblRouteGoTitle.textAlignment = NSTextAlignmentLeft;
        self.lblRouteGoTitle.text = /*@"jddjsdspqqpdd;sd;lasskdskjdskoweowiewoifksfjkfjdkfjdkdjsdalskalska";*/  routeLoc.title;
        
        NSString *labelText = /*@"123456789012345678901234567890123456789012345678901234567890";*/ routeLoc.direction;
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelText];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineHeightMultiple = 0.8;
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [labelText length])];
        self.lblRouteGoDirection.attributedText = attributedString;
        
        long duration = routeLoc.duration;
        if (routeLoc.duration > 99) {
            duration = 99;
        }
        self.lblRouteGoDuration.text = [NSString stringWithFormat:@"%02ld", duration];
    }
    else {
        self.lblRouteGoTitle.textAlignment = NSTextAlignmentCenter;
        self.lblRouteGoTitle.text = @"Please wait...";
        self.lblRouteGoDirection.text = @"";
        self.lblRouteGoDuration.text = @"";
    }
}

/**
 * Notification receiver when the location change
 *
 * @param sender notification object
 */
-(void)locationServiceReady:(id)sender {
    
    if (_requestSent) {
        return;
    }
    
    if ([LocationService sharedService].isStartRouteMonitoring) {
        // this call is not called during routes NAV mode
        return;
    }
    
    [self handleNewGPSLocation];
}

-(void)hideRefreshControl:(BOOL)hide {
    if (hide) {
        if (refreshControl != NULL) {
            if (refreshControl.isRefreshing) {
                [refreshControl endRefreshing];
            }
            
            [refreshControl removeTarget:self action:@selector(pullDownToRefresh) forControlEvents:UIControlEventValueChanged];
            [refreshControl removeFromSuperview];
            refreshControl = NULL;
        }
    }
    else {
        if (refreshControl == nil) {
            refreshControl = [[UIRefreshControl alloc] initWithFrame: (CGRect){
                0,
                0,
                self.view.frame.size.width,
                64}];
            
            [refreshControl addTarget:self action:@selector(pullDownToRefresh) forControlEvents:UIControlEventValueChanged];
            [_tableView addSubview:refreshControl];
        }
    }
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark LocationService Notification receivers
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////
-(void)newRouteLocation:(id)sender {
    if (routeId == NO_ROUTE_FOUND) {
        // stopped or no route ID
        return;
    }
    
    if (![LocationService sharedService].isStartRouteMonitoring) {
        // this call is only called during routes NAV mode
        return;
    }
    
    YLocation *currentLocation = [LocationService sharedService].currentLocation;
    NSLog(@"ROUTE ------> got GPS update: lat:%lf long:%lf", currentLocation.latitude, currentLocation.longitude);
    
    RouteLocation *toRouteloc = NULL;
    double routeDistanceKm = 0;
    BOOL isNewWaypoint = FALSE;
    
    BOOL reachedRouteEnd = [[ServerResponse sharedResponse].getRoute isMeInRouteLat:currentLocation.latitude andLong:currentLocation.longitude retToLoc:&toRouteloc
                                                                 retToLocDistanceKm:&routeDistanceKm retIsNewWaypoint:&isNewWaypoint];
    
    if (toRouteloc != NULL) {
        toRouteLocation = toRouteloc;
        
        if (isNewWaypoint) {
            [Utilities vibrate:toRouteloc.isPoi];
        }
        
        if (NO == reachedRouteEnd) {
            [self updateRouteUI:toRouteloc];
            
            double durationMinutes = ceil(((routeDistanceKm)/3.7f) * 60.0f);
            
            if (durationMinutes > 99) {
                durationMinutes = 99;
            }
            self.lblRouteGoDuration.text = [NSString stringWithFormat:@"%02d", (int)durationMinutes];
            
            if (toRouteloc.invalid) {
                // the device is not on track !
                //self.lblRouteGoTitle.backgroundColor = [UIColor colorWithRed:0.9 green:0 blue:0 alpha:1];
                self.lblRouteGoTitle.backgroundColor = UIColor.clearColor;
                //TODO: add some visual que to the user when he is not in the bounding box
            }
            else {
                self.lblRouteGoTitle.backgroundColor = UIColor.clearColor;
            }
        }
        else {
            // reached the end of the route
            self.lblRouteGoTitle.backgroundColor = [UIColor colorWithRed:0 green:0.9 blue:0 alpha:1];
            
            [[LocationService sharedService] stopRoutes];
        }
    }
    
    [self handleNewGPSLocation];
}

-(BOOL)canReloadTable {
    if (self.isUserReading) {
        return NO;
    }
    
    /*0L:Uncomment
    if (data.count > 0 && currentPlayingIndex >= 0 && currentPlayingIndex < data.count) {
        Place *p = [data objectAtIndex:currentPlayingIndex];
        if (p.isPlaying) {
            return NO;
        }
    }
    */
    
    return YES;
}

-(void)showBicycle {
    if (!show_go_view) {
        [self animateBicycle:CGRectNull];
    }
    else {
        int y = self.routeGoView.frame.origin.y + self.routeGoView.frame.size.height;
        [self animateBicycle:CGRectMake(0,
                                        y,
                                        self.view.bounds.size.width,
                                        self.view.bounds.size.height - y)];
    }
}

-(BOOL)checkAndClearDataBeforeRequest {
    BOOL clearToLoad = [self canReloadTable];
    
    if (clearToLoad) {
        // clear all data show bicycle
        [self showBicycle];
        
        [[ServerResponse sharedResponse].places removeAllObjects];
        data = [[ServerResponse sharedResponse] getCopyOfRefereceData];
        loading = YES;
        [self.tableView reloadData];
        loading = NO;
    }
    
    return clearToLoad;
}

-(void)handleNewGPSLocation {
    if (_requestSent) {
        return;
    }
    
    if ([LocationService sharedService].isStartRouteMonitoring) {
        BOOL bCall = FALSE;
        YLocation *currentLocation = [LocationService sharedService].currentLocation;
        
        if (lastRouteAPILocation == NULL) {
            lastRouteAPILocation = [YLocation initWithLatitude:currentLocation.latitude andLongitude:currentLocation.longitude];
            bCall = TRUE;
        }
        else {
            CLLocationDistance distance = [currentLocation distanceFromLocation:lastRouteAPILocation];
            if (distance >= ROUTE_DISTANCE_TO_CALL_API_METERS) {
                lastRouteAPILocation = [YLocation initWithLatitude:currentLocation.latitude andLongitude:currentLocation.longitude];
                bCall = TRUE;
            }
        }
        
        if (bCall) {
            if (NO == [self checkAndClearDataBeforeRequest]) {
                return;
            }

            _requestSent = YES;
            
            [DataRequestController requestDataWithLocation:currentLocation andCompletionBlock:^(enum WebServiceRequestStatus status, NSDictionary *info) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self reloadTableData];
                    [self stopAnimationAndRemoveFromSuperview];
                    _requestSent = NO;
                });
            }];
        }
    }
    else {
        if (NO == [self checkAndClearDataBeforeRequest]) {
            return;
        }
        
        YLocation *currentLocation = [LocationService sharedService].currentLocation;
        
        /* the only need for this call is to clear the table before doing the REST call
        Place *p = nil;
        if (data.count > 0) {
            p = [data objectAtIndex:currentPlayingIndex];
        }
        if (![p isPlaying]) {
            [WebServices isInMiniIsraelBlocking:currentLocation.latitude
                                            lon:currentLocation.longitude
                                     completion:^(enum WebServiceRequestStatus status, BOOL isInside) {
                                         if (isInside && status == WS_OK) {
                                             @try {
                                                 [[ServerResponse sharedResponse].places removeAllObjects];
                                                 data = [[ServerResponse sharedResponse] getCopyOfRefereceData];
                                                 loading = YES;
                                                 [self.tableView reloadData];
                                                 loading = NO;
                                             }
                                             @catch (NSException *exception) {
                                             }
                                             
                                             if (data.count == 0) {
                                                 [self animateBicycle];
                                             }
                                         }
                                     }];
        }
        */
        
        _requestSent = YES;
        
        [DataRequestController requestDataWithLocation:currentLocation andCompletionBlock:^(enum WebServiceRequestStatus status, NSDictionary *info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadTableData];
                
                if (show_go_view) {
                    [self hideRefreshControl:YES];
                }
                else {
                    [self hideRefreshControl:NO];
                    
                    if ([refreshControl isRefreshing]){
                        [refreshControl endRefreshing];
                    }
                }
                
                [self stopAnimationAndRemoveFromSuperview];
                
                _requestSent = NO;
            });
        }];
    }
}

-(void)pullDownToRefresh {
    if ([self canReloadTable]) {
        [[LocationService sharedService] startUpdate];
    }
    else {
        if ([refreshControl isRefreshing]){
            [refreshControl endRefreshing];
        }
    }
}

/**
 * Speed changes notification receiver
 *
 * @param sender notification object
 */
-(void)speedChangesReceiver:(id)sender {
    ////NSLog(@"%@",sender);
    if ([LocationService sharedService].speed > CAUTION_SPEED) {
        [self displayCautionScreen:CSShow];
    }
    else {
        [self displayCautionScreen:CSHide];
    }
}

/**
 * Location service status notification receiver
 *
 * @param sender notification object
 */
-(void)locationServiceStatusReceiver:(id)sender {
    NSDictionary *userInfo = [((NSNotification *)sender) userInfo];
    if ([[userInfo objectForKey:LSLocationChangeStatusNotification] isEqualToString:StatusStart]) {
        // GPS start
        
        //[self.loadingView setHidden:NO];
        //[self animateBicycle];
        [self needToShowLoading];
    }
    else if ([[userInfo objectForKey:LSLocationChangeStatusNotification] isEqualToString:StatusStop]) {
        // GPS stop
        
        //[self.loadingView setHidden:YES];
    }
    else if ([[userInfo objectForKey:LSLocationChangeStatusNotification] isEqualToString:StatusDenide]) {
        // GPS denied
        
        //[self.loadingView setHidden:YES];
        [self stopAnimationAndRemoveFromSuperview];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error",nil) message:NSLocalizedString(@"location_service_disabled_message",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Ok",nil) otherButtonTitles:nil, nil];
        [alert show];
        [self showMessageViewWithText:NSLocalizedString(@"waiting_gps_signal", nil)];
        
    }
}

-(void)noGPSSignalNotificationReceiver {
    [self showMessageViewWithText:NSLocalizedString(@"waiting_gps_signal", nil)];
}


//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Settings changed
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////
-(void)settingsChanged:(id)sender {
    NSDictionary *userInfo = [((NSNotification *)sender) userInfo];
    SettingSaveState state = [[userInfo valueForKey:SETTINGS_SAVE_STATUS] integerValue];
    NSString *settignsEntityKey = [userInfo valueForKey:SETTINGS_ENTITY_CHANGED_KEY];
    if (state == SettingSaveState_SAVED) {
        if ([settignsEntityKey isEqualToString:k3GInternetSettings]) {
            if (self.data.count == 0 &&
                [LocationService sharedService].currentLocation.latitude != 0 &&
                [LocationService sharedService].currentLocation.longitude != 0) {
                [self reloadLanguage];
            }
        }
    }
    else if (state == SettingSaveState_ERROR) {}
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Language change
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////
-(void)languageChangeNotification:(id)sender {
    NSDictionary *userInfo = [((NSNotification *)sender) userInfo];
    LanguageChangeState state = [[userInfo valueForKey:LANGUAGE_CHANGE_STATE_KEY] integerValue];
    if (state == LanguageChangeStatePrepare) {
        [self prepareToChangeLanguage];
    }
    else if (state == LanguageChangeStateReload){
        [self reloadLanguage];
    }
}

-(void)prepareToChangeLanguage {

    [self hidePauseButton];
    [Utilities taskInSeparatedBlock:^{
        if ([[Settings sharedSettings] isSiriLanguage]) {
            [[SiriPlayer sharedPlayer] pauseWithCompletion:nil];
        }
        //[[SiriPlayer sharedPlayer] initPlayer];
        /*else if ([[Settings sharedSettings].speechLanguage isEqualToString:tSpeechHebrew]) {
            [[StreamPlayer sharedPlayer] pause];
        }*/
        currentPlayingIndex = 0;
    }];    
}

-(void)reloadLanguage {
    
    if (_requestSent) {
        return;
    }
    
    if (NO == [self checkAndClearDataBeforeRequest]) {
        return;
    }
    
    
    if ([LocationService sharedService].currentLocation.latitude == 0 ||
        [LocationService sharedService].currentLocation.longitude == 0) {
        return;
    }
    
    _requestSent = YES;
    [DataRequestController requestDataWithLocation:[LocationService sharedService].currentLocation
                                andCompletionBlock:^(enum WebServiceRequestStatus status, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadTableData];
            [self stopAnimationAndRemoveFromSuperview];
            _requestSent = NO;
        });
    }];
}

-(void)callSearch {
    if ([ServerResponse sharedResponse].searchId == NULL) {
        return; // cancel !
    }
    
    if (_requestSent) {
        return;
    }
    
    searching = YES;
    
    [self stopRouteMode];
    [self stopRouteNavMode];
    routeId = NO_ROUTE_FOUND;
    [[ServerResponse sharedResponse].isRoute clearRoute];
    
    // this is the data cached
    [[ServerResponse sharedResponse].places removeAllObjects];
    
    // this is the table data container
    data = [[ServerResponse sharedResponse] getCopyOfRefereceData];
    
    // empty the table
    loading = YES;
    [self.tableView reloadData];
    loading = NO;
}

-(void)stopSearch {
    if ([ServerResponse sharedResponse].searchId == NULL) {
        return; // cancel !
    }
    
    if (searching) {
        // in the middle of the search query
        return;
    }
    
    if (_requestSent) {
        return;
    }
    
    [ServerResponse sharedResponse].searchId = NULL;
    
    // this is the data cached
    [[ServerResponse sharedResponse].places removeAllObjects];
    
    // this is the table data container
    data = [[ServerResponse sharedResponse] getCopyOfRefereceData];
    
    // empty the table
    loading = YES;
    [self.tableView reloadData];
    loading = NO;
    
    if ([LocationService sharedService].currentLocation != NULL) {
        _requestSent = YES;
        
        // searching show the bycycle animation
        [self showBicycle];
        
        [DataRequestController requestDataWithLocation:[LocationService sharedService].currentLocation
                andCompletionBlock:^(enum WebServiceRequestStatus status, NSDictionary *info) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self reloadTableData];
                    
                    [self stopAnimationAndRemoveFromSuperview];
                    _requestSent = NO;
                });
                }];
    }
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark PackageController notification
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////
/**
 Notification about package loading
 */
-(void)packageLoaded:(id)sender {
    NSDictionary *userInfo = [((NSNotification *)sender) userInfo];
    PLStatus status = [[userInfo valueForKey:PL_STATUS_KEY] integerValue];
    if (status == PLS_PARSING_FINISHED) {
        if (data.count == 0) {
            // Calling this method for reload list of places
            // Only if no displayed places
            [self locationServiceReady:nil];
            [self enterForeground:self];
        }
    }
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Table View data manipulating methods
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////

/**
    Method reloads data from shared array in ServerResponse class
 */
-(void)reloadTableData {
    @try {
        if (data.count == 0) {
            // Methods shows loading indicator if needed
            [self needToShowLoading];
            
            currentPlayingIndex = 0;
            data = [[ServerResponse sharedResponse] getCopyOfRefereceData];
            
            loading = YES;
            [self.tableView reloadData];
            loading = NO;
        }
        else if (data.count < [ServerResponse sharedResponse].places.count){
            Place *p = [[ServerResponse sharedResponse] getNext];
            
            if (p) {
                BOOL needToScroll = NO;
                NSIndexPath *last = [[self.tableView indexPathsForVisibleRows] lastObject];
                if (last.row == data.count-1 &&
                    !((Place *)[data objectAtIndex:last.row]).isPlaying &&
                    ((Place *)[data objectAtIndex:last.row]).didPlayed) {
                    
                    needToScroll = YES;
                    currentPlayingIndex = data.count;
                }
                
                data = [[ServerResponse sharedResponse] getCopyOfRefereceData];
                
                loading = YES;
                [self.tableView reloadData];
                loading = NO;
                
                if (needToScroll) {
                    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:currentPlayingIndex inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                    [self playPlaceWithIndex:(int)currentPlayingIndex withDelayTime:1];
                }
            }
        }
    }
    @catch (NSException *exception) {
        loading = YES;
        [self.tableView reloadData];
        loading = NO;
    }
    
    
    [gridImages removeAllObjects];
    
    if ([ServerResponse sharedResponse].isRoute.isFilled == NO) {
        // no route !
        routeId = NO_ROUTE_FOUND;
    }
    else {
        IsRoute *isRoute = [ServerResponse sharedResponse].isRoute;
        routeId = isRoute.routeId;
        
        NSMutableArray *arrPhotos = isRoute.photos;
        self.lblRouteTitle.text = [NSString stringWithFormat:@"%02ld Min walk", (long)isRoute.duration];
        self.lblRouteMustSee.text = [NSString stringWithFormat:@"%ld MUST-SEE PLACES TO VISIT AROUND YOU!", (long)isRoute.numMustSeePlaces];
        self.lblRouteCollapsedDistance.text = [NSString stringWithFormat:@"%ld", (long)isRoute.duration];
        
        for (int i =0; i < ROUTES_NUM_IMAGES;++i) {
            NSString *urlPhoto = @"";
            
            if (i < arrPhotos.count) {
                urlPhoto = [arrPhotos objectAtIndex:i];
            }// missing photos are empty strings !
            
            [gridImages addObject:urlPhoto];
        }
        
        [self.expandViewGrid reloadData];
        [self.collapseViewGrid reloadData];
        
        [self collapseRouteView:NO];
    }
}

/**
 * Starting player with delay
 *
 * @param placeIndex - index of place to play
 *
 * @param delayTime - play with delay time
 */
-(void)playPlaceWithIndex:(int)placeIndex withDelayTime:(int)delayTime {
    [Utilities taskWithDelay:delayTime forBlock:^{
        /*if ([[Settings sharedSettings].speechLanguage isEqualToString:tSpeechHebrew]) {
            [[StreamPlayer sharedPlayer] playPlaceAudio:[data objectAtIndex:placeIndex]];
        }
        else*/
        @try {
            if ([[Settings sharedSettings] isSiriLanguage]) {
                [[SiriPlayer sharedPlayer] playPlaceAudio:[data objectAtIndex:placeIndex]];
            }
        }
        @catch (NSException *exception) {
            
        }
    }];
}

/**
 * Method display's message if no items to display
 */
-(void)needToShowLoading {
    if (searching == YES && _requestSent == NO) {
        _requestSent = YES;
        
        // searching show the bycycle animation
        [self showBicycle];
        
        [DataRequestController requestDataWithLocation:[LocationService sharedService].currentLocation
                                    andCompletionBlock:^(enum WebServiceRequestStatus status, NSDictionary *info) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self reloadTableData];

                    [self stopAnimationAndRemoveFromSuperview];
                    _requestSent = NO;
                    searching = NO;
                });
         }];
        
        // no route !
    }
    else if ([ServerResponse sharedResponse].places.count > 0) {
        [self stopAnimationAndRemoveFromSuperview];
        [self hideMessageView];
    }
    else if ([LocationService sharedService].currentLocation.latitude == 0 &&
             [LocationService sharedService].currentLocation.longitude == 0) {
        [self showBicycle];
    }
    else if (_requestSent) {
        [self showBicycle];
    }
    else {
        // clear table and show no place background
        [self showMessageViewWithText:NSLocalizedString(@"no_place_found_message", nil)];
    }
}

#pragma mark - Table view data source and delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*0L:old implementation
    static NSString *CellIdentifier = @"PlaceViewCell";
    PlaceViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    Place *p = (Place *)[data objectAtIndex:indexPath.row];
    if (cell == nil) {
        cell = [[PlaceViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [cell setPlace:p];
    [cell setVCDelegate:self];
    // //NSLog(@"%@, %i",p.title,p.isPlaying);
    return cell;
    */
    
    
    //omry new nested lists
    // create an horizontal collection cell
    static NSString *CellIdentifier = @"PlaceCollectionViewCell";
    
    PlaceCollectionViewCell *cell = (PlaceCollectionViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[PlaceCollectionViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSMutableArray *dataArray = (NSMutableArray *)[data objectAtIndex:indexPath.row];
    [cell setData:dataArray andIndexPath:indexPath];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // the collection type dictates the height of the collection cell
    CGFloat VCellH = 385;
    
    // heights must correspond to story board 
    NSArray *cellData = [self.data objectAtIndex:indexPath.row];
    id firstHorizCell = [cellData objectAtIndex:0];
    Class cellDataClass = [firstHorizCell class];
    
    if (cellDataClass == [Place class]) {
        VCellH = 385;
    }
    else if (cellDataClass == [OfflinePlace class]) {
        VCellH = 385;
    }
    else if (cellDataClass == [SettingsPlace class]) {
        VCellH = 160;
    }
    else if (cellDataClass == [SwipePlaceFirstCell class]) {
        VCellH = 385;
    }
    
    return VCellH;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(PlaceCollectionViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell  *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // omry new nested lists
    CGFloat hOffset = 0;
    
    // for cells that have more than one cell in the H array show a swipe hint offset
    NSArray *cellData = [self.data objectAtIndex:indexPath.row];
    if (cellData.count > 1) {
        hOffset = 10;
    }
    
    NSInteger index = cell.collectionView.indexPath.row;
    NSString *sKey = [NSString stringWithFormat:@"%ld", (long)index];
    
    if ([self.horizontalCellsXOffsetDictionary objectForKey:sKey] != NULL) {
        NSNumber *numberHOffset = [self.horizontalCellsXOffsetDictionary objectForKey:sKey];
        hOffset = numberHOffset.floatValue;
    }
    
    //[cell.collectionView setContentOffset:CGPointMake(hOffset, 0)];
    
    
    id firstHorizCell = [cellData objectAtIndex:0];
    Class cellDataClass = [firstHorizCell class];
    
    if (cellDataClass == [Place class]) {
        Place *p = (Place *)firstHorizCell;
        if (p.wasDisplayed) {
            return;
        }
        
        UIView *v = [cell viewWithTag:10];
        __block CGPoint point = v.frame.origin;
        [v setFrame:CGRectMake(320, point.y+170, v.frame.size.width, v.frame.size.height)];
        
        [UIView animateWithDuration:0.5
                              delay:0
                            options:0
                         animations:^{
                             [v setFrame:CGRectMake(point.x, point.y, v.frame.size.width, v.frame.size.height)];
                         } completion:^(BOOL finished) {
                             
                             p.wasDisplayed = YES;
                         }];
    }
    else if (cellDataClass == [OfflinePlace class]) {
        return;
    }
    else if (cellDataClass == [SettingsPlace class]) {
        SettingsPlace *p = (SettingsPlace *)firstHorizCell;
        if (p.wasDisplayed) {
            return;
        }
        
        UIView *v = [cell viewWithTag:10];
        __block CGPoint point = v.frame.origin;
        [v setFrame:CGRectMake(320, point.y+170, v.frame.size.width, v.frame.size.height)];
        
        [UIView animateWithDuration:0.5
                              delay:0
                            options:0
                         animations:^{
                             [v setFrame:CGRectMake(point.x, point.y, v.frame.size.width, v.frame.size.height)];
                         } completion:^(BOOL finished) {
                             
                             p.wasDisplayed = YES;
                         }];

    }
    else if (cellDataClass == [SwipePlaceFirstCell class]) {
        SwipePlaceFirstCell *p = (SwipePlaceFirstCell *)firstHorizCell;
        if (p.wasDisplayed) {
            return;
        }
        
        UIView *v = [cell viewWithTag:10];
        __block CGPoint point = v.frame.origin;
        [v setFrame:CGRectMake(320, point.y+170, v.frame.size.width, v.frame.size.height)];
        
        [UIView animateWithDuration:0.5
                              delay:0
                            options:0
                         animations:^{
                             [v setFrame:CGRectMake(point.x, point.y, v.frame.size.width, v.frame.size.height)];
                         } completion:^(BOOL finished) {
                             
                             p.wasDisplayed = YES;
                         }];
    }

    
    /*0L:old implementation
    Place *p = ((PlaceViewCell *)cell).place;
    if (p.wasDisplayed) {
        return;
    }
    PlaceViewCell *pvc = (PlaceViewCell *)cell;
    UIView *v = [pvc viewWithTag:10];
    __block CGPoint point = v.frame.origin;
    [v setFrame:CGRectMake(320, point.y+170, v.frame.size.width, v.frame.size.height)];
    [UIView animateWithDuration:0.5
                          delay:0
                        options:0
                     animations:^{
                         [v setFrame:CGRectMake(point.x, point.y, v.frame.size.width, v.frame.size.height)];
                     } completion:^(BOOL finished) {
                    
                         p.wasDisplayed = YES;
                     }];
    */
    
}



#pragma mark - Insertion row animation methods
#pragma mark - NOT IN USE
/**
 * Inserting new row to UITableView with custome animation
 * @param indexPaths array of indeces of cell to insert
 * @param time delay before insert
 * @param block block of code runs after insert animation complete
 *
 * NOT IN USE !!!!!!!!!!!!!!!!!!!!!!!!!!!
 */
- (void)insertRowsAtIndexPaths:(NSArray *)indexPaths withAnimationDelay:(NSTimeInterval)time withCustomeCompleteBlock:(void(^)(void))block
{
    //[Utilities taskInSeparatedBlock:^{
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:data.count-1 inSection:0]];
    __block CGPoint point = cell.frame.origin;
    [cell setFrame:CGRectMake(320, point.y+170, cell.frame.size.width, cell.frame.size.height)];
    [UIView animateWithDuration:0.5
                          delay:time
                        options:0
                     animations:^{
                         [cell setFrame:CGRectMake(point.x, point.y, cell.frame.size.width, cell.frame.size.height)];
                     } completion:^(BOOL finished) {
                         [self completeInsertAnimationForCell:cell withIndexPath:[NSIndexPath indexPathForItem:data.count-1 inSection:0] withCustomeCompleteBlock:block];
                     }];
    
    //}];
    
}

/**
 * Method of completion block of cell insert animation
 * @param cell inserted cell
 * @param indexPath indext path of inserted cell
 * @param block to run after animation complete
 *
 * NOT IN USE
 */
-(void)completeInsertAnimationForCell:(UITableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath withCustomeCompleteBlock:(void(^)(void))block {
    
    if (block) {
        block();
    }
}
#pragma mark -

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Scroll View
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////

UIEdgeInsets savedInset;
const CGFloat mainHeaderHeight = 80;

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    //performingAutomatedScroll = false;
    NSLog(@"did end scrolling animation");
};

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    bStoppedScrolling = NO;
    
    if (loading) {
        return;
    }
    
    if (scrollView.tag != 987) {
        return;
    }
    
    CGPoint scrollOffset = scrollView.contentOffset;
    //NSLog(@"scroll offset:%f", scrollOffset.y);
    
    if (routeId == NO_ROUTE_FOUND) {
         if (scrollOffset.y >= 40) { // was 40
             if (![self.navigationController isNavigationBarHidden]) {
                 [self.navigationController setNavigationBarHidden:YES animated:YES];
             }
         } else {
             if ([self.navigationController isNavigationBarHidden]) {
                 [self.navigationController setNavigationBarHidden:NO animated:YES];
             }
         }
    }
    else {
         if (scrollOffset.y >= -50) {
             [self collapseRouteView:YES];
         }
         else {
             [self collapseRouteView:NO];
        }
    }
    
    [self needToShowPauseButton];
}

-(void) collapseRouteView:(BOOL)collapse {
    if (collapse) {
        if (!show_go_view && !expanded_guard && expandedRouteShown) {
            // show the collapsed view
            
            expanded_guard = YES;
            self.imgRouteRound.transform = CGAffineTransformIdentity;
            
            CGRect rcStatusBar = [UIApplication sharedApplication].statusBarFrame;
            CGRect rcNavBar = self.navigationController.navigationBar.frame;
            int originY = rcStatusBar.size.height + rcNavBar.size.height;
            
            CGRect rcRouteExpandedTo = CGRectMake(0,
                                                  originY,
                                                  self.view.bounds.size.width,
                                                  0);
            
            // the collapsed route view
            CGRect rcRouteCollapsedTo = CGRectMake(0,
                                                   originY,
                                                   self.view.bounds.size.width,
                                                   mainHeaderHeight);
            
            CGRect rcTableTo = CGRectMake(self.tableView.frame.origin.x,
                                          originY + mainHeaderHeight - 50,
                                          self.tableView.frame.size.width,
                                          self.view.bounds.size.height - (originY + mainHeaderHeight - 50));
            
            self.routeCollapsedView.alpha = 0;
            self.routeCollapsedView.hidden = NO;
            self.routeCollapsedView.frame = CGRectMake(self.view.bounds.size.width,
                                                       originY,
                                                       self.view.bounds.size.width,
                                                       mainHeaderHeight); // start at right offset boundary
            
            savedInset = self.tableView.contentInset;
            
            __weak PlacesTableViewController *weakSelf = self;
            
            [UIView animateWithDuration:0.5 animations:^{
                weakSelf.routeCollapsedView.alpha = 1;
                weakSelf.routeExpandedView.alpha = 0;
                weakSelf.tableView.frame = rcTableTo;
                weakSelf.routeCollapsedView.frame = rcRouteCollapsedTo;
                weakSelf.routeExpandedView.frame = rcRouteExpandedTo;
                /*[weakSelf.tableView setContentInset:UIEdgeInsetsMake(0, // top, left, bottom, right
                 self.tableView.contentInset.left,
                 self.tableView.contentInset.bottom,
                 self.tableView.contentInset.right)];*/
            } completion:^(BOOL finished) {
                self.routeExpandedView.hidden = YES;
                expandedRouteShown = NO;
                expanded_guard = NO;
            }];
            
            //NSLog(@"Hide!!!");
        }
    }
    else {
        if (!show_go_view && !expanded_guard && !expandedRouteShown) {
            // show the expanded view
            
            expanded_guard = YES;
            self.imgRouteRound.transform = CGAffineTransformIdentity;
            
            //return;
            
            int nExpanded = 295;
            
            CGRect rcStatusBar = [UIApplication sharedApplication].statusBarFrame;
            CGRect rcNavBar = self.navigationController.navigationBar.frame;
            int originY = rcStatusBar.size.height + rcNavBar.size.height;
            
            // move to the right
            CGRect rcRouteCollapsedTo = CGRectMake(self.view.bounds.size.width,
                                                   originY,
                                                   self.view.bounds.size.width,
                                                   mainHeaderHeight);
            
            CGRect rcRouteExpandedTo = CGRectMake(0,
                                                  originY - 20,
                                                  self.view.bounds.size.width,
                                                  nExpanded);
            
            CGRect rcTableTo = CGRectMake(self.tableView.frame.origin.x,
                                          originY + nExpanded - 90,
                                          self.tableView.frame.size.width,
                                          self.view.bounds.size.height - (originY + nExpanded - 90));
            
            self.routeExpandedView.alpha = 0;
            self.routeExpandedView.hidden = NO;
            
            __weak PlacesTableViewController *weakSelf = self;
            
            [UIView animateWithDuration:0.5 animations:^{
                weakSelf.routeCollapsedView.alpha = 0;
                weakSelf.routeExpandedView.alpha = 1;
                
                weakSelf.tableView.frame = rcTableTo;
                weakSelf.routeCollapsedView.frame = rcRouteCollapsedTo;
                weakSelf.routeExpandedView.frame = rcRouteExpandedTo;
                //weakSelf.tableView.contentInset = savedInset;
            } completion:^(BOOL finished) {
                self.routeCollapsedView.hidden = YES;
                expandedRouteShown = YES;
                expanded_guard = NO;
            }];
            
            //NSLog(@"Show!!!");
        }
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    isUserMakeScroll = YES;
    bStoppedScrolling = NO;
    scrollStartPoint.y = scrollView.contentOffset.y + scrollView.contentInset.top;
    
    CGPoint scrollOffset = scrollView.contentOffset;
    if (scrollOffset.y < -50) {
    }
    
    NSLog(@"scroll offset:%f", scrollOffset.y);
    
    [self goViewTapped:NULL];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self stoppedScrolling:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self stoppedScrolling:scrollView];
    }
}

- (void)stoppedScrolling:(UIScrollView *)scrollView
{
    bStoppedScrolling = YES;
    
    if (routeId == NO_ROUTE_FOUND) {
        if (YES == [self.navigationController isNavigationBarHidden]) {
            // navigation bar is hidden -> reshow
            [self.navigationController setNavigationBarHidden:NO animated:YES];
        }
    }
}





//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Pause button
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////

-(IBAction)scrollPauseButtonPressed:(id)sender {
    [self prepareToChangeLanguage];
}

-(void)needToShowPauseButton {
    /*0L:Uncomment
    if (data.count > 0 && currentPlayingIndex >= 0 && currentPlayingIndex < data.count) {
        Place *p = [data objectAtIndex:currentPlayingIndex];
        if (p.isPlaying) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:currentPlayingIndex inSection:0];
            if (![_tableView.indexPathsForVisibleRows containsObject:indexPath]) {
                [self showPauseButton];
            }
            else {
                [self hidePauseButton];
            }
        }
    }
    */
}

-(void)showPauseButton {
    if (isPauseButtonVisible) {
        return;
    }
    isPauseButtonVisible = YES;
    _scrollPauseButton.frame = CGRectMake(-_scrollPauseButton.frame.size.width,
                                          _scrollPauseButton.frame.origin.y,
                                          _scrollPauseButton.frame.size.width,
                                          _scrollPauseButton.frame.size.height);
    _scrollPauseButton.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        _scrollPauseButton.frame = CGRectMake(0,
                                              _scrollPauseButton.frame.origin.y,
                                              _scrollPauseButton.frame.size.width,
                                              _scrollPauseButton.frame.size.height);
    } completion:^(BOOL finished) {
        
    }];
}

-(void)hidePauseButton {
    if (!isPauseButtonVisible) {
        return;
    }
    isPauseButtonVisible = NO;
    [UIView animateWithDuration:0.2 animations:^{
        _scrollPauseButton.frame = CGRectMake(-_scrollPauseButton.frame.size.width,
                                              _scrollPauseButton.frame.origin.y,
                                              _scrollPauseButton.frame.size.width,
                                              _scrollPauseButton.frame.size.height);
    } completion:^(BOOL finished) {
        _scrollPauseButton.hidden = YES;
    }];
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Segue
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"ToWiki"]) {
        // disable the click on text opens Wiki feature
        return NO;
    }
    
    return TRUE;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"OpenText"]) {
        _isUserReading = YES;
        
        if ([Utilities currentVersionOfOS] == UTIOS_8) {
            DescriptionViewController *dvc = [segue destinationViewController];
            PlaceViewCell *cell = (PlaceViewCell *)[[[[sender superview] superview] superview] superview];
            dvc.text = cell.place.descr;
            dvc.titleLabelPopUp = cell.place.title;
            cellWikiUrl = cell.place.wiki;
        }
        else {
            DescriptionViewController *dvc = [segue destinationViewController];
            PlaceViewCell *cell = (PlaceViewCell *)[[[[sender superview] superview] superview] superview];
            dvc.text = cell.place.descr;
            dvc.titleLabelPopUp = cell.place.title;
            cellWikiUrl = cell.place.wiki;
        }
    }
    else if ([segue.identifier isEqualToString:@"ToWiki"]) {
        _isUserReading = YES;
        
        if ([Utilities currentVersionOfOS] == UTIOS_8) {
            WebViewController *vc = [segue destinationViewController];
            PlaceViewCell *cell = (PlaceViewCell *)[[[sender superview] superview] superview];
            vc.urlToView = cell.place.wiki;
        }
        else {
            PlaceViewCell *cell = (PlaceViewCell *)[[[[[sender superview] superview] superview] superview] superview];
            WebViewController *vc = [segue destinationViewController];
            vc.urlToView = cell.place.wiki;
        }
    }
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Top Bar
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////

-(UIView *)noItemFoundMessageView {
    if (!_noItemFoundMessageView) {
        _noItemFoundMessageView = [[UIView alloc] initWithFrame:CGRectMake(0, 66, self.view.bounds.size.width, 0)];
        _noItemFoundMessageView.tag = NO_ITEM_FOUND_MESSAGE_VIEW_TAG; // Tag 11
        _noItemFoundMessageView.backgroundColor = [UIColor colorWithRed:245./255. green:245./255. blue:245./255. alpha:0.1];
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 310, 30)];
        l.tag = NO_ITEM_FOUND_MESSAGE_VIEW_LABEL_TAG; // TAG 10
        l.alpha = 0.0;
        //l.text = NSLocalizedString(@"No places to display", nil);
        l.textAlignment = NSTextAlignmentCenter;
        l.textColor = [UIColor colorWithRed:126./255. green:126./255. blue:126./255. alpha:1.0];
        [_noItemFoundMessageView addSubview:l];
    }
    
    return _noItemFoundMessageView;
    
}

-(void)showMessageViewWithText:(NSString *)text {
    
    [((UILabel *)[[self noItemFoundMessageView] viewWithTag:NO_ITEM_FOUND_MESSAGE_VIEW_LABEL_TAG]) setText:text];
    if ([[self noItemFoundMessageView] isDescendantOfView:self.view]) {
        return;
    }
    
    CGRect frame = CGRectMake(0,
                              self.view.bounds.size.height - 40,
                              self.view.bounds.size.width,
                              40);
    self.tableView.contentInset = UIEdgeInsetsMake(self.tableView.contentInset.top,
                                                   self.tableView.contentInset.left,
                                                   self.tableView.contentInset.bottom + 40,
                                                   self.tableView.contentInset.right); // top, left, bottom, right
    
    UIView *v = [self noItemFoundMessageView];
    v.backgroundColor = UIColor.lightGrayColor;
    v.frame = frame;
    [self.view addSubview:v];
    
    /*
    [UIView animateWithDuration:0.3 delay:0 options:0 animations:^{
        //[self noItemFoundMessageView].frame = frame;
        // Calculating inset for displaying message view
        /[self setupInset:UIEdgeInsetsMake(105, 0, 0, 0) andOffset:-frame.size.height];
    } completion:^(BOOL finished) {*/
        [UIView animateWithDuration:0.3 delay:0 options:0 animations:^{
            [[self noItemFoundMessageView] viewWithTag:NO_ITEM_FOUND_MESSAGE_VIEW_LABEL_TAG].alpha = 1.0;
        } completion:^(BOOL finished) {
            
        }];
    //}];
}

- (IBAction)goButtonClicked:(id)sender {
    if (expanded_guard || show_go_view || (refreshControl != NULL && refreshControl.isRefreshing)) {
        return;
    }
    
    [self hideRefreshControl:YES];
    
    
    expanded_guard = YES;
    
    [DataRequestController requestRouteWithRouteId:routeId locationStart:[YLocation initWithLatitude:[ServerResponse sharedResponse].isRoute.latCompass andLongitude:[ServerResponse sharedResponse].isRoute.longCompass]
                                andCompletionBlock:^(enum WebServiceRequestStatus status, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status == WS_OK) {
                // no route location yet -> start getting GPS updates !
                [[LocationService sharedService] startRoutes];
            }
            else {
                //TODO: what to do when call fails ?
            }
        });
    }];
    
    CGRect rcStatusBar = [UIApplication sharedApplication].statusBarFrame;
    CGRect rcNavBar = self.navigationController.navigationBar.frame;
    int originY = rcStatusBar.size.height + rcNavBar.size.height;
    
    CGRect rcRouteExpandedTo = CGRectMake(0,
                                          originY,
                                          self.view.bounds.size.width,
                                          0);
    
    // the collapsed route view
    CGRect rcRouteCollapsedTo = CGRectMake(0,
                                           originY,
                                           self.view.bounds.size.width + NAV_VIEW_DELETE_BUTTON_W,
                                           mainHeaderHeight);
    
    CGRect rcTableTo = CGRectMake(self.tableView.frame.origin.x,
                                  originY + mainHeaderHeight - 60,
                                  self.tableView.frame.size.width,
                                  self.view.bounds.size.height - (originY + mainHeaderHeight - 60));
    
    self.routeGoView.alpha = 0;
    self.routeGoView.frame = CGRectMake(self.view.bounds.size.width,
                                        originY,
                                        self.view.bounds.size.width + NAV_VIEW_DELETE_BUTTON_W,
                                        mainHeaderHeight); // start at right offset boundary
    
    int imgGoBgW = (400 * self.view.bounds.size.width)/320.;
    self.imgGoBG.frame = CGRectMake(0, 0,
                                    imgGoBgW,
                                    self.routeGoView.frame.size.height);
    
    self.routeGoView.hidden = NO;
    
    savedInset = self.tableView.contentInset;
    
    self.routeGoView.hidden = NO;
    
    //savedInset = self.tableView.contentInset;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.routeGoView.alpha = 1;
        self.routeExpandedView.alpha = 0;
        self.tableView.frame = rcTableTo;
        self.routeGoView.frame = rcRouteCollapsedTo;
        //self.navigationController.navigationBar.frame = rcNavbar;
        self.routeExpandedView.frame = rcRouteExpandedTo;
        /*[self.tableView setContentInset:UIEdgeInsetsMake(savedInset.top + mainHeaderHeight, // top, left, bottom, right
                                                         self.tableView.contentInset.left,
                                                         self.tableView.contentInset.bottom,
                                                         self.tableView.contentInset.right)];*/
    } completion:^(BOOL finished) {
        self.routeExpandedView.hidden = YES;
        expandedRouteShown = NO;
        expanded_guard = NO;
        show_go_view = YES;
    }];
 
    //NSLog(@"Hide!!!");
}

-(void)hideMessageView {
    
    if (![[self noItemFoundMessageView] isDescendantOfView:self.view]) {
        return;
    }
    
    [UIView animateWithDuration:0.2 delay:0 options:0 animations:^{
        [[self noItemFoundMessageView] viewWithTag:NO_ITEM_FOUND_MESSAGE_VIEW_LABEL_TAG].alpha = 0.0;
    } completion:^(BOOL finished) {
        [_noItemFoundMessageView removeFromSuperview];
        _noItemFoundMessageView = NULL;
        
        self.tableView.contentInset = UIEdgeInsetsMake(self.tableView.contentInset.top,
                                                       self.tableView.contentInset.left,
                                                       self.tableView.contentInset.bottom - 40,
                                                       self.tableView.contentInset.right); // top, left, bottom, right
        /*
        [UIView animateWithDuration:0.3 delay:0 options:0 animations:^{
            // Calculating inset for displaying message view
            [self noItemFoundMessageView].frame = CGRectMake(self.tableView.frame.origin.x, 64, 320, 0);
            [self setupInset:UIEdgeInsetsMake(65, 0, 0, 0)
                   andOffset:0];
        } completion:^(BOOL finished) {
            [_noItemFoundMessageView removeFromSuperview];
        }];
        */
    }];
}

/*
 * Calculating inset and offset for view 
 * @param inset - height of message view + navigation bar view
 * @param offset - height of message view
 */
-(void)setupInset:(UIEdgeInsets)inset andOffset:(int)offset {
    /*NSArray *vcs = self.navigationController.viewControllers;
    for (UIViewController *vc in vcs) {
        if ([vc conformsToProtocol:@protocol(ViewInsetsSetupProtocol)]) {
            [((id<ViewInsetsSetupProtocol>)vc) setupViewInsets:inset andOffset:offset];
        }
    }*/
    //[self setupInset:inset andOffset:offset];
    [self setupViewInsets:inset andOffset:offset];
}
/**
 * ViewInsetsSetupProtocol method
 */
-(void)setupViewInsets:(UIEdgeInsets)inset andOffset:(int)offset {
    self.tableView.contentInset = inset;
    self.tableView.contentOffset = (CGPoint){0,self.tableView.contentOffset.y+offset};
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark MPMoviePlayerController Notification
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////

/**
 * Notification for player change it's state
 *
 * @param sender player instance
 */
-(void)playerStateDidChanged:(id)sender {
    /*MPMoviePlayerController *mpc = [StreamPlayer sharedPlayer].player;
    //  //NSLog(@"State is: %i",mpc.playbackState);
    if (mpc.playbackState == MPMoviePlaybackStatePlaying) {
        //NSLog(@"Playing");
        Place *p = [StreamPlayer sharedPlayer].place;
        currentPlayingIndex = [data indexOfObject:p];
    }
    else if (mpc.playbackState == MPMoviePlaybackStateStopped) {
        //NSLog(@"Stopped playerStateDidChanged");
        
    }
    else if (mpc.playbackState == MPMoviePlaybackStatePaused) {
        //NSLog(@"Paused playerStateDidChanged");
        
    }*/
}

-(void)playerDidFinishPlay:(id)sender {
    //NSLog(@"Track finished");
    ////NSLog(@"%@",sender);
    /*NSDictionary *userInfo = [((NSNotification *)sender) userInfo];
    MPMoviePlayerController *mpc = [((NSNotification *)sender)  object];
    NSInteger reason = [[userInfo valueForKey:@"MPMoviePlayerPlaybackDidFinishReasonUserInfoKey"] integerValue];
    if (reason == MPMovieFinishReasonPlaybackEnded) {
        //NSLog(@"Ended");
        if (mpc.playbackState == MPMoviePlaybackStateStopped) {
            //NSLog(@"Ended Stopped playerDidFinishPlay");
        }
        else if (mpc.playbackState == MPMoviePlaybackStatePaused) {
            //NSLog(@"Ended Paused playerDidFinishPlay");
            Place *p = [data objectAtIndex:currentPlayingIndex];
            [p setIsPlaying:NO];
            currentPlayingIndex++;
            if (currentPlayingIndex < data.count) {
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:currentPlayingIndex inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                [Utilities taskWithDelay:1 forBlock:^{
                    [[StreamPlayer sharedPlayer] playPlaceAudio:[data objectAtIndex:currentPlayingIndex]];
                }];
            }
        }
    }
    else if (reason == MPMovieFinishReasonUserExited) {
        //NSLog(@"Exited");
    }
    else if (reason == MPMovieFinishReasonPlaybackError) {
        //NSLog(@"Error");
        Place *p = [data objectAtIndex:currentPlayingIndex];
        [p setIsPlaying:NO];
    }*/
}

-(void)placeStartPlaying:(id)sender {
   
    NSDictionary *userInfo = [((NSNotification *)sender) userInfo];
    Place *p = [((NSNotification *)sender) object];
    //NSLog(@"%@",userInfo);
    NSInteger index = [data indexOfObject:p];
    PlayingState state = [[userInfo objectForKey:STATUS_KEY] integerValue];
    if (state == PPLAY) {
        PlaceViewCell *cell = (PlaceViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
        [cell play];
    }
    else {
        PlaceViewCell *cell = (PlaceViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
        [cell pause];
    }
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark SiriPlayer Notifications
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////

-(void)siriPlayerEventMethod:(id)sender {
    
    NSDictionary *userInfo = [((NSNotification *)sender) userInfo];
    //SiriPlayer *siriPlayer = [((NSNotification *)sender) object];
    NSString *status = [userInfo valueForKey:kStatus];
    if ([status isEqualToString:SPPlay]) {
        @try {
            //NSLog(@"Siri start playing");
            Place *p = [SiriPlayer sharedPlayer].place;
            currentPlayingIndex = [data indexOfObject:p];
            [self needToShowPauseButton];
        }
        @catch (NSException *exception) {
            
        }
    }
    else if ([status isEqualToString:SPPause]) {
        //NSLog(@"Siri paused");
        /*//NSLog(@"Ended Paused playerDidFinishPlay");
        Place *p = [data objectAtIndex:currentPlayingIndex];
        [p setIsPlaying:NO];
        currentPlayingIndex++;
        if (currentPlayingIndex < data.count) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:currentPlayingIndex inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            [Utilities operationWithDelay:1 forBlock:^{
                [[SiriPlayer sharedPlayer] playPlaceAudio:[data objectAtIndex:currentPlayingIndex]];
            }];
        }*/
    }
    else if ([status isEqualToString:SPFinished]) {
        @try {
            isUserMakeScroll = NO;
            //NSLog(@"Siri start finished");
            if (data.count == 0) {
                return;
            }
            Place *p = [data objectAtIndex:currentPlayingIndex];
            [p setIsPlaying:NO];
            currentPlayingIndex++;
            if (currentPlayingIndex < data.count) {
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:currentPlayingIndex inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                [Utilities taskWithDelay:1 forBlock:^{
                    [[SiriPlayer sharedPlayer] playPlaceAudio:[data objectAtIndex:currentPlayingIndex]];
                }];
            }
        }
        @catch (NSException *exception) {
            currentPlayingIndex = 0;
        }

    }
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Caution Screen
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////


-(void)displayCautionScreen:(CautionSceenOptions)options {
    
    if (cvc.neverShow) {
        return;
    }
    if (options == CSShow) {
        if (cvc.cautionPresented) {
            return;
        }
        if (!cvc) {
            cvc = [self.storyboard instantiateViewControllerWithIdentifier:@"cautionVC"];
        }
        
        [self presentViewController:cvc animated:YES completion:^{
        }];
        cvc.cautionPresented = YES;
    }
    else if (options == CSHide){
        [cvc dismissViewControllerAnimated:YES completion:^{
            
        }];
        cvc.cautionPresented = NO;
    }
}

-(void)showCautionView {
    if (!cvc) {
        cvc = [self.storyboard instantiateViewControllerWithIdentifier:@"cautionVC"];
    }
    [self presentViewController:cvc animated:YES completion:^{
        
    }];
}

-(void)collapsedViewTapped:(UIGestureRecognizer *)gr {
    if (loading || !bStoppedScrolling) {
        return;
    }
    
    [self collapseRouteView:NO];
}

-(void)goViewTapped:(UIGestureRecognizer *)gr {
    if (loading) {
        return;
    }
    
    if (!bGoViewSwipedLeft) {
        return;
    }
    
    if (bGoViewSwippingRight) {
        return;
    }
    
    bGoViewSwippingRight = true;
    
    CGRect rcFrame = CGRectMake(0,
                                self.routeGoView.frame.origin.y,
                                self.routeGoView.frame.size.width,
                                self.routeGoView.frame.size.height);
    
    [UIView animateWithDuration:0.3 animations:^{
        self.routeGoView.frame = rcFrame;
    } completion:^(BOOL finished) {
        bGoViewSwipedLeft = false;
        bGoViewSwippingRight = false;
    }];
}

-(void)onGoViewDeleteClicked {
    [self stopRouteNavMode];
}

-(void)stopRouteMode {
    // stop the isRoute expanded\collapse mode
    if (show_go_view || routeId == NO_ROUTE_FOUND) {
        // in route nav mode or there is no route
        return;
    }
    
    if (expandedRouteShown) {
        // remove the expanded view completely
        CGRect rcRouteCollapsedTo = CGRectMake(0,
                                               self.routeExpandedView.frame.origin.y - self.routeExpandedView.frame.size.height,
                                               self.routeExpandedView.frame.size.width,
                                               self.routeExpandedView.frame.size.height);
        
        CGRect rcTableTo = CGRectMake(self.tableView.frame.origin.x,
                                      0,
                                      self.tableView.frame.size.width,
                                      self.view.bounds.size.height);
        
        
        savedInset = self.tableView.contentInset;
        
        //savedInset = self.tableView.contentInset;
        
        [UIView animateWithDuration:0.5 animations:^{
            self.routeExpandedView.alpha = 0;
            self.tableView.frame = rcTableTo;
            self.routeExpandedView.frame = rcRouteCollapsedTo;
        } completion:^(BOOL finished) {
            self.routeGoView.hidden = YES;
            self.routeCollapsedView.hidden = YES;
            self.routeExpandedView.hidden = YES;
            
            toRouteLocation = NULL;
            routeId = NO_ROUTE_FOUND;
            expandedRouteShown = NO;
            expanded_guard = NO;
            show_go_view = NO;
            bGoViewSwipedLeft = false;
            
        }];

    }
    else {
        // remove the collapsed view completely
        CGRect rcRouteCollapsedTo = CGRectMake(0,
                                               self.routeCollapsedView.frame.origin.y - self.routeCollapsedView.frame.size.height,
                                               self.routeCollapsedView.frame.size.width,
                                               self.routeCollapsedView.frame.size.height);
        
        CGRect rcTableTo = CGRectMake(self.tableView.frame.origin.x,
                                      0,
                                      self.tableView.frame.size.width,
                                      self.view.bounds.size.height);
        
        
        savedInset = self.tableView.contentInset;
        
        //savedInset = self.tableView.contentInset;
        
        [UIView animateWithDuration:0.5 animations:^{
            self.routeCollapsedView.alpha = 0;
            self.tableView.frame = rcTableTo;
            self.routeCollapsedView.frame = rcRouteCollapsedTo;
        } completion:^(BOOL finished) {
            self.routeGoView.hidden = YES;
            self.routeCollapsedView.hidden = YES;
            self.routeExpandedView.hidden = YES;
            
            toRouteLocation = NULL;
            expandedRouteShown = NO;
            expanded_guard = NO;
            show_go_view = NO;
            bGoViewSwipedLeft = false;
        }];

    }
}

-(void)stopRouteNavMode {
    // stop the route navigation mode
    if (!show_go_view) {
        // not in search mode !
        return;
    }
    
    [self hideRefreshControl:NO];
    
    
    // hide the navigation panel
    [[LocationService sharedService] stopRoutes];
    
    toRouteLocation = NULL;
    routeId = NO_ROUTE_FOUND;
    lastRouteAPILocation = NULL;
    
    CGRect rcRouteCollapsedTo = CGRectMake(0,
                                           self.routeGoView.frame.origin.y - self.routeGoView.frame.size.height,
                                           self.routeGoView.frame.size.width,
                                           self.routeGoView.frame.size.height);
    
    CGRect rcTableTo = CGRectMake(self.tableView.frame.origin.x,
                                  self.tableView.frame.origin.y - self.routeGoView.frame.size.height,
                                  self.tableView.frame.size.width,
                                  self.view.bounds.size.height - (self.tableView.frame.origin.y - self.routeGoView.frame.size.height));
    
    
    savedInset = self.tableView.contentInset;
    
    //savedInset = self.tableView.contentInset;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.routeGoView.alpha = 0;
        self.tableView.frame = rcTableTo;
        self.routeGoView.frame = rcRouteCollapsedTo;
    } completion:^(BOOL finished) {
        self.routeGoView.hidden = YES;
        self.routeCollapsedView.hidden = YES;
        self.routeExpandedView.hidden = YES;
        
        [self updateRouteUI:NULL];
        
        toRouteLocation = NULL;
        expandedRouteShown = NO;
        expanded_guard = NO;
        show_go_view = NO;
        bGoViewSwipedLeft = false;
        
        // go back to normal mode
        [[LocationService sharedService] startUpdate];
    }];
}

-(void)goViewSwipedLeft:(UIGestureRecognizer *)gr {
    if (loading) {
        return;
    }
    
    if (!bGoViewSwipedLeft) {
        bGoViewSwipedLeft = true;
        
        UIButton *button = (UIButton *)[self.routeGoView viewWithTag:1800];
        
        CGRect rcFrame = CGRectMake(self.routeGoView.frame.origin.x - button.frame.size.width,
                                    self.routeGoView.frame.origin.y,
                                    self.routeGoView.frame.size.width,
                                    self.routeGoView.frame.size.height);
        
        [UIView animateWithDuration:0.3 animations:^{
            self.routeGoView.frame = rcFrame;
        } completion:^(BOOL finished) {
        }];
    }
}

-(void)goViewSwipedRight:(UIGestureRecognizer *)gr {
    [self goViewTapped:nil];
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark PlaceButtonFeatures Delegate
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////
-(void)toWaze:(NSString *)url {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

-(void)toWiki {
    if (cellWikiUrl == NULL || cellWikiUrl.length == 0) {
        return;
    }
    
    _isUserReading  = YES;
    
    WebViewController *vc = [[LRSlideMenuController sharedInstance].storyboard instantiateViewControllerWithIdentifier:@"AboutVC"];
    vc.urlToView = cellWikiUrl;
    
    [[LRSlideMenuController sharedInstance] pushViewController:vc animated:YES];
    
    /*
    [self presentViewController:vc animated:YES completion:^{
        
    }];*/
}

-(void)toFacebookShare:(Place *)placeToShare {

       
        NSString *shareUrl = [NSString stringWithFormat:@"http://tool.yapq.com/map.php?id=%ld&l=en", (long)placeToShare.p_id];
        
        NSArray * activityItems = @[[NSString stringWithFormat: NSLocalizedString(@"I just visited %@, join to me with yapQ", nil),placeToShare.title], [NSURL URLWithString:shareUrl]];
        NSArray * applicationActivities = nil;
        NSArray * excludeActivities = @[UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypePostToWeibo, UIActivityTypePrint, UIActivityTypeAirDrop, UIActivityTypeAddToReadingList];
        
        UIActivityViewController * activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:applicationActivities];
        activityController.excludedActivityTypes = excludeActivities;
        
        [self presentViewController:activityController animated:YES completion:nil];
        
        saveEvent(@"share");
        
    
}

-(void)toReport:(Place *)place {
    [WebServices reportProblemBlocking:place withCompletionBlock:^(enum WebServiceRequestStatus status){
        
    }];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"report_title", nil) message:NSLocalizedString(@"report_message", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil, nil];
    [alert show];
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Gesture
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////

-(void)navTap:(id) sender {
    //LocationDebugViewController *ldvc = [self.storyboard instantiateViewControllerWithIdentifier:@"LocDebug"];
    //[self presentViewController:ldvc animated:YES completion:^{
        
    //}];
    if (![[self noItemFoundMessageView] isDescendantOfView:self.navigationController.view]) {
        [self showMessageViewWithText:@"Test"];
    }
    else {
        [self hideMessageView];
    }
    
}

- (void)popWiki{
    
    //NSLog(@"XXXXXXXXXX");
}

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiandsToDegrees(x) (x * 180.0 / M_PI)


// project into a plane
-(CGPoint) mercator:(double)latitude andLon:(double)longitude {
    double radius = 6378137.;
    double max = 85.0511287798;
    double radians = M_PI / 180.;
    
    CGPoint point;
    
    point.x = radius * longitude * radians;
    point.y = MAX(MIN(max, latitude), -max) * radians;
    point.y = radius * log(tan((M_PI / 4.) + (point.y / 2.)));
    
    return point;
}

-(float) bearingBetweenStartLocation:(YLocation *)startLocation andEndLocation:(YLocation *)endLocation{
    CLLocation *northPoint = [[CLLocation alloc] initWithLatitude:(startLocation.coordinate.latitude)+.01 longitude:endLocation.coordinate.longitude];
    float magA = [northPoint distanceFromLocation:startLocation];
    float magB = [endLocation distanceFromLocation:startLocation];
    CLLocation *startLat = [[CLLocation alloc] initWithLatitude:startLocation.coordinate.latitude longitude:0];
    CLLocation *endLat = [[CLLocation alloc] initWithLatitude:endLocation.coordinate.latitude longitude:0];
    float aDotB = magA*[endLat distanceFromLocation:startLat];
    float retDeg = radiandsToDegrees(acosf(aDotB/(magA*magB)));
    
    return retDeg;
}

-(float) bearingBetweenStartLocation2:(YLocation *)startLocation andEndLocation:(YLocation *)endLocation{
    /*
    Δφ = ln( tan( latB / 2 + π / 4 ) / tan( latA / 2 + π / 4) )
    Δlon = abs( lonA - lonB )
    bearing :  θ = atan2( Δlon ,  Δφ )
    
    Note: 1) ln = natural log      2) if Δlon > 180°  then   Δlon = Δlon (mod 180).
    */
    
    float deltaPhi = log( tan(endLocation.latitude/2 + M_PI_4) / tan(startLocation.latitude/2 + M_PI_4) );
    float deltaLong = fabs(startLocation.longitude - endLocation.longitude);
    
    if (deltaLong > 180) {
        deltaLong = fmod(deltaLong, 180.f);
    }
    
    float bearing = atan2(deltaLong, deltaPhi);
    return radiandsToDegrees(bearing);
}

-(int) bearingBetweenStartLocation3:(YLocation *)startLocation andEndLocation:(YLocation *)endLocation{
    float lat1 = degreesToRadians(startLocation.latitude);
    float lat2 = degreesToRadians(endLocation.latitude);
    float long1 = degreesToRadians(endLocation.longitude);
    float long2 = degreesToRadians(startLocation.longitude);
    float dLon = long1 - long2;
    
    float y = sin(dLon) * cos(lat2);
    float x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    int bearingDeg = (int)(radiandsToDegrees(atan2(y, x)) + 0.5f);
    int ret = (bearingDeg + 360) % 360;
    return ret;
}

-(void)gpsHeadingChange:(id)sender {
    if (YES == inBG || expanded_guard) {
        return;
    }
    
    NSDictionary *userInfo = [((NSNotification *)sender) userInfo];
    CLHeading *gpsHeading = [userInfo valueForKey:HedingKey];
    
    CLLocationDirection  theHeadingDeg = ((gpsHeading.trueHeading > 0) ? gpsHeading.trueHeading : gpsHeading.magneticHeading);
    
    // Adjust for device rotation.
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    
    switch (orientation)
    {
        case UIDeviceOrientationPortraitUpsideDown:
            theHeadingDeg = theHeadingDeg + 180.0f;
            break;
        case UIDeviceOrientationLandscapeLeft:
            theHeadingDeg = theHeadingDeg + 90.0f;
            break;
        case UIDeviceOrientationLandscapeRight:
            theHeadingDeg = theHeadingDeg + 270.0f;
            break;
        default:
            break;
    }
    theHeadingDeg = fmod(theHeadingDeg, 360.);

    
    
    if (expandedRouteShown) {
        if ([ServerResponse sharedResponse].isRoute && [ServerResponse sharedResponse].isRoute.isFilled) {
            double arcToNorth = [LocationService azimuthFromLocation:[LocationService sharedService].currentLocation LocationToLocation:[YLocation initWithLatitude:81.3 andLongitude: -110.8]];
            double arcToPlace = [LocationService azimuthFromLocation:[LocationService sharedService].currentLocation
                                    LocationToLocation:[YLocation initWithLatitude:[ServerResponse sharedResponse].isRoute.latCompass andLongitude:[ServerResponse sharedResponse].isRoute.longCompass]];
            double angle = arcToPlace - arcToNorth;
            float heading = theHeadingDeg+40; //in degrees
            float headingRadians = ((angle + heading)*M_PI/180); //assuming needle points to top of iphone. convert to radians
            self.imgRouteRound.transform = CGAffineTransformMakeRotation(headingRadians);
        }
    }
    else if (show_go_view) {
        if (toRouteLocation != NULL) {
        
            /*
            double arcToNorth = [LocationService azimuthFromLocation:[LocationService sharedService].currentLocation LocationToLocation:[YLocation initWithLatitude:81.3 andLongitude: -110.8]];
            double arcToPlace = [LocationService azimuthFromLocation:[LocationService sharedService].currentLocation
                                                  LocationToLocation:[YLocation initWithLatitude:toRouteLocation.latitude andLongitude:toRouteLocation.longtitude]];
            double angle = arcToPlace - arcToNorth;
            float heading = theHeadingDeg + 40; //in degrees
            float headingRadians = ((angle + heading)*M_PI/180); //assuming needle points to top of iphone. convert to radians
            self.imgRouteGoCompass.transform = CGAffineTransformMakeRotation(headingRadians);
            */
        
            
            
            YLocation *currentLocation = /*[YLocation initWithLatitude:32.064525604248047 andLongitude:34.774215698242188];*/  [LocationService sharedService].currentLocation;
            /*
            //RouteLocation *toRouteLocation = [[RouteLocation alloc] initWithLong:34.774709 lat:32.064841 title:@"" direction:@"" andDuration:0]; // ahad ahhm ben zakai crossing
            RouteLocation *toRouteLocation = [[RouteLocation alloc] initWithLong:34.774309 lat:32.065793 title:@"" direction:@"" andDuration:0];   // ben zakai nontifiori crossing
            //RouteLocation *toRouteLocation = [[RouteLocation alloc] initWithLong:34.7722057 lat:32.0653684 	title:@"" direction:@"" andDuration:0];   // montifiori alenby crossing
            */
        
            
            int bearingDeg = [self bearingBetweenStartLocation3:currentLocation
                                               andEndLocation:[YLocation initWithLatitude:toRouteLocation.latitude andLongitude:toRouteLocation.longtitude]];
            
            if (!compassAnimating) {
                compassAnimating = true;
                
                int calculation = bearingDeg  - theHeadingDeg;
                if (calculation != lastCompassCalc) {
                    [UIView animateWithDuration:0.5 animations:^{
                        self.imgRouteGoCompass.transform = CGAffineTransformMakeRotation(degreesToRadians(calculation));
                    } completion:^(BOOL finished) {
                        lastCompassCalc = calculation;
                        compassAnimating = false;
                    }];
                }
                else {
                    compassAnimating = false;
                }
            }
            // don't change anything -> waiting for animation to finish
        }
    }
}

/*
- (BOOL)prefersStatusBarHidden {
    return YES;
}
*/

/******************************************************************* Expanded View **********************************/
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView.tag == 555) {
        // expanded view collection view
        return gridImages.count;
    }
    
    // routes bar
    if (gridImages.count == 0) {
        return 0;
    }
    
    // show 4 first images for the collapsed routes bar
    return 4;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifierExpanded = @"ExpandedGridCell";
    static NSString *identifierCollapsed = @"CollapsedGridCell";
    
    UICollectionViewCell *cell = NULL;
    __weak UIImageView *iv = NULL;
    
    if (collectionView.tag == 555) {
        // expanded view collection view
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifierExpanded forIndexPath:indexPath];
        iv = (UIImageView *)[cell viewWithTag:666];
    }
    else {
        // collapsed view
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifierCollapsed forIndexPath:indexPath];
        iv = (UIImageView *)[cell viewWithTag:556];
    }
    
    NSString *url = [gridImages objectAtIndex:indexPath.row];
    
    [self setImage:url forImageView:iv];
    
    return cell;
}

-(void) setImage:(NSString *)url forImageView:(UIImageView *)iv {
    if (url.length > 0) {
        UIImage *img = [Utilities getCachedImage:url];
        if (img) {
            iv.image = img;
        }
        else {
            [Utilities taskInSeparatedThread:^{
                [Utilities cacheImage:url isOffline:NO];
                UIImage *img = [Utilities getCachedImage:url];
                if (img) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        iv.image = img;
                    });
                }
            }];
        }
    }
    else {// use placeholder
        iv.image = imgMissingRouteImage;
    }
}

@end
