//
//  AccountViewController.m
//  yapq
//
//  Created by yapQ Ltd on 6/21/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import "AccountViewController.h"
#import "tToken.h"
//#import <GooglePlus/GooglePlus.h>

@interface AccountViewController () {
    NSIndexPath *indexPathToDelete;
    CGPoint singOutButtonPosition;
    AccountLoadingViewController *alvc;
    BOOL isFacebook, isGooglePlus;
    BOOL isFacebookRenewed;
    //UIDynamicAnimator *animator;
}

@end

@implementation AccountViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    isFacebookRenewed = NO;
    
    // AppDelegate Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.shouldFetchGoogleUserEmail = YES;
    signIn.clientID = GOOGLE_PLUS_APP_ID;
    signIn.scopes = @[ @"profile" ];
    signIn.delegate = self;
    
    isFacebook = [SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook];
    //isGooglePlus = [[GPPSignIn sharedInstance] trySilentAuthentication];
    
    //animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.headerView];
    _userImageView.layer.cornerRadius = 40;
    _userImageView.layer.masksToBounds = YES;
    _userNameLabel.font = [Utilities RobotoRegularFontWithSize:17];
    [self calculateSingOutButtonPosition];
    [self setupHeaderView];
    [self reloadTableView];
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:[NSString stringWithFormat:@"IOS: %@ %@",NSStringFromClass([self class]),[Settings sharedSettings].speechLanguage]];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
}

-(void)setupHeaderView {
    
    if (!isFacebook) {
        [[Settings sharedSettings] removeLoginData];
    }
    float w = [UIScreen mainScreen].bounds.size.width;
    if ([Settings sharedSettings].getLoginToken &&
        [Settings sharedSettings].getLoginAccountName &&
        [Settings sharedSettings].getLoginProfilePictureLink) {
        _loginDescrLabel.alpha = 0.0;
        CGRect oldFrame = _facebookLoginButton.frame;
        _facebookLoginButton.frame =  (CGRect){-(w+100), oldFrame.origin.y, oldFrame.size.width, oldFrame.size.height};
        oldFrame = _googlePlusLoginButton.frame;
        _googlePlusLoginButton.frame =  (CGRect){-(w+100), oldFrame.origin.y, oldFrame.size.width, oldFrame.size.height};
        _userNameLabel.text = [[Settings sharedSettings].getLoginAccountName uppercaseString];
        NSString *uniquePath = [[[Utilities applicationDocumentsDirectory] path] stringByAppendingPathComponent: [Settings sharedSettings].getLoginProfilePictureLink];
        UIImage *img = [UIImage imageWithContentsOfFile:uniquePath];
        _userImageView.image = img;
        [self showLogoutButton:YES];
    }
    else {
        CGRect oldFrame = _userNameLabel.frame;
        _userNameLabel.frame =  (CGRect){w+100, oldFrame.origin.y, oldFrame.size.width, oldFrame.size.height};
        oldFrame = _userImageView.frame;
        _userImageView.frame =  (CGRect){w+100+oldFrame.origin.x, oldFrame.origin.y, oldFrame.size.width, oldFrame.size.height};
        _loginDescrLabel.alpha = 1.0;
         
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)viewDidAppear:(BOOL)animated {
    if (_packageToDownload) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[_listOfPurchasedPackages
                                                                indexOfObject:_packageToDownload] inSection:0];
        FreeDownloadCell *cell = (FreeDownloadCell *)[_tableView cellForRowAtIndexPath:indexPath];
        _packageToDownload = nil;
        [self downloadButtonEvent:cell];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        [self.tableView reloadData];
    }
}

-(void)enterBackground:(id)sender {
    if (alvc && alvc.isAnimated) {
        [alvc stopAnimationAndRemoveFromSuperview];
        alvc.isAnimated = YES;
    }
}

-(void)enterForeground:(id)sender {
    if (alvc && alvc.isAnimated) {
        [alvc animateBicycle:CGRectNull];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(packageLoadingStatus:) name:PL_STATUS_NOTIFICATION_KEY object:[PackageController sharedController]];
    //[self isNeedSetupInsets];
    if (_listOfPurchasedPackages.count > 0) {
        
    }
    @try {
        if ([Settings sharedSettings].getLoginToken &&
            [Settings sharedSettings].getLoginAccountName &&
            [Settings sharedSettings].getLoginProfilePictureLink) {
            [self syncDataWithServer];
        }
    }
    @catch (NSException *exception) {
        [self reloadTableView];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PL_STATUS_NOTIFICATION_KEY object:[PackageController sharedController]];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(void)reloadTableView {
    [self loadPackages];
    if (_listOfPurchasedPackages.count == 0) {
        [self showFooterMessageWithText:NSLocalizedString(@"no_installed_packages", nil)];
    }
    else {
        [self hideFooterMessage];
    }
    [_tableView reloadData];
}

-(void)loadPackages {
    NSMutableSet *allPackages = [[NSMutableSet alloc] init];
    NSArray *dbPackagesWithCurrentLanguage = [DBCoreDataHelper getAllPackagesForLanguage:[Settings sharedSettings].speechLanguage];
    for (DBPackage *dbp in dbPackagesWithCurrentLanguage) {
        Package *p = [PackageFactoryUtils fillPackageFromDBPackage:dbp];
        [allPackages addObject:p];
    }
    NSArray *allDbPackages = [DBCoreDataHelper getPurchasedPackages];
    for (DBPurchasedPackages *dbp in allDbPackages) {
        Package *p = [PackageFactoryUtils fillPackageFromDBPurchasedPackage:dbp];
        [allPackages addObject:p];
    }
    _listOfPurchasedPackages = [[allPackages allObjects] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Package *p1 = obj1;
        Package *p2 = obj2;
        return [p1.packageName compare:p2.packageName];
    }];
    
}

-(void)syncDataWithServer {
    [WebServices syncPurchasesWithServer];
    [WebServices getAllPurchasedPackagesWithUserToken:[[Settings sharedSettings] getLoginToken] andCompletionBlock:^(enum WebServiceRequestStatus status, NSString *json) {
        if (json) {
            SBJsonParser *parser = [[SBJsonParser alloc] init];
            NSArray *jsonArr = [parser objectWithString:json];
            for (int i=0;i<jsonArr.count;i++) {
                NSDictionary *pd = [jsonArr objectAtIndex:i];
                Package *package = [PackageFactoryUtils createPackageWithJsonDictionary:pd];
                [DBCoreDataHelper insertPurchasedPackage:package];
            }
            [self reloadTableView];
        }
    }];
}

-(void)calculateSingOutButtonPosition {
    singOutButtonPosition = CGPointMake(0, self.view.frame.size.height-40);
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _listOfPurchasedPackages.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *myCellId = @"MyPackageCell";
    static NSString *myFreeDownload = @"DownloadCell";
    Package *p = [_listOfPurchasedPackages objectAtIndex:indexPath.row];
    MyPackageAbstractCell *cell = nil;
    
    if (![DBCoreDataHelper isPackageExist:p.packageId forLanguage:[Settings sharedSettings].speechLanguage]) {
        cell = [tableView dequeueReusableCellWithIdentifier:myFreeDownload forIndexPath:indexPath];
        if (!cell) {
            cell = [[FreeDownloadCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:myFreeDownload];
        }
        [cell cellReset];
        // Setup cell as loading
        if ([PackageController sharedController].currentPL.package.packageId == p.packageId) {
            [((FreeDownloadCell*)cell) setupAsLoading:[PackageController sharedController].currentPL];
            ((FreeDownloadCell*)cell).progressLabel.text = [[PackageController sharedController].currentPL messageForCurrentState];
        }
        else {
           // [((FreeDownloadCell*)cell).downloadButton setTitle:NSLocalizedString(@"free", nil) forState:UIControlStateNormal];
            ((FreeDownloadCell*)cell).progressLabel.text = NSLocalizedString(@"for_offline_use", nil);
        }
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:myCellId forIndexPath:indexPath];
        if (!cell) {
            cell = [[MyPackageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:myCellId];
        }
    }

    [cell setPackage:_listOfPurchasedPackages[indexPath.row]];
    cell.delegete = self;
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (_listOfPurchasedPackages.count > 0) {
        return NSLocalizedString(@"my_downloads",nil);
    }
    return @"";
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    
    if (section == 0 && _listOfPurchasedPackages.count > 0) {
        return NSLocalizedString(@"under_purchases_table",nil);

    }
    return nil;
}

/**
 * Notifiaction from package loader about status
 *
 * @param sender - user info of package loader
 */
-(void)packageLoadingStatus:(id)sender {
    NSLog(@"%@",sender);
    NSDictionary *userInfo = [((NSNotification *)sender) userInfo];
    PLStatus status = [[userInfo valueForKey:PL_STATUS_KEY] integerValue];
    PackageLoader *pl = [userInfo valueForKeyPath:PL_PACKAGE_KEY];
    if (status == PLS_LOAD_WAITING) {
        FreeDownloadCell *cell = (FreeDownloadCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:[_listOfPurchasedPackages indexOfObject:pl.package] inSection:0]];
        cell.progressLabel.text = [pl messageForCurrentState];
    }
    else if (status == PLS_LOAD_ERROR) {
        __weak FreeDownloadCell *cell = (FreeDownloadCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:[_listOfPurchasedPackages indexOfObject:pl.package] inSection:0]];
        [Utilities UITaskInSeparatedBlock:^{
            FreeDownloadCell *sCell = cell;
            [sCell cellReset];
        }];
        //[self messageAlert:@"Package downloading error, please try again. Thank you for using yapq."];
        NSLog(@"ERROR With status code %li",status);
    }
    else if (status == PLS_PARSING_ERROR ||
             status == PLS_UNZIP_ERROR) {
        __weak FreeDownloadCell *cell = (FreeDownloadCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:[_listOfPurchasedPackages indexOfObject:pl.package] inSection:0]];
        [Utilities UITaskInSeparatedBlock:^{
            FreeDownloadCell *sCell = cell;
            [sCell cellReset];
        }];
        //[self messageAlert:@"Package saving error, please try to download again. Thank you for using yapq."];
        NSLog(@"ERROR With status code %li",status);
    }
    else if (status == PLS_LOAD_STARTED) {
        FreeDownloadCell *cell = (FreeDownloadCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:[_listOfPurchasedPackages indexOfObject:pl.package] inSection:0]];
        cell.progressLabel.text = [pl messageForCurrentState];
    }
    else if (status == PLS_UNZIP_STARTED) {
        FreeDownloadCell *cell = (FreeDownloadCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:[_listOfPurchasedPackages indexOfObject:pl.package] inSection:0]];
        [Utilities UITaskInSeparatedBlock:^{
            cell.progressLabel.text = [pl messageForCurrentState];
        }];
    }
    else if (status == PLS_PARSING_FINISHED) {
        [self.tableView reloadData];
    }
}
//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark  ViewInsetsSetupProtocol method
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////
/**
 Setting insets for UITableView
 */
-(void)setupViewInsets:(UIEdgeInsets)inset andOffset:(int)offset {
    self.tableView.contentInset = UIEdgeInsetsMake(inset.top, 0, 0, 0);
    //self.tableView.contentOffset = (CGPoint){0,-offset};//self.tableView.contentOffset.y + offset};
}

-(void)isNeedSetupInsets {
    UIView *v = [self.navigationController.view viewWithTag:NO_ITEM_FOUND_MESSAGE_VIEW_TAG];
    if (v) {
        [self setupViewInsets:UIEdgeInsetsMake(105, 0, 0, 0) andOffset:40];
    }
}

-(void)downloadButtonEvent:(FreeDownloadCell *)sender {
    Reachability *networkStatus = [Reachability reachabilityForInternetConnection];
    if ([[Settings sharedSettings] is3GEnabled] == NO && [networkStatus currentReachabilityStatus] != ReachableViaWiFi) {
        [self messageAlert:NSLocalizedString(@"connect_to_wifi_or_enable_data_roaming", nil)];
        [sender cellReset];
        return;
    }
    Package *package = sender.package;
    package.packageExpDate = [NSDate dateWithTimeIntervalSinceNow:TWO_MOTH_IN_SECONDS];
    // Setting language for current language
    package.packageLang = [Settings sharedSettings].speechLanguage;
    PackageLoader *pl = [[PackageLoader alloc] initWithPackage:package];
    if (![pl isEnoughSpaceForLoading]) {
        //[self messageAlert:@"You don't have enough space for loading this package."];
        [sender cellReset];
        return;
    }
    // Adding loading progress observer
    [pl addObserver:sender forKeyPath:kDownloadProgressObserver options:0 context:nil];
    [[PackageController sharedController] addPackageLoaderToQueue:pl];
}

-(void)deleteButtonEvent:(MyPackageCell *)sender {
    indexPathToDelete = [_tableView indexPathForCell:sender];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"delete", nil) message:NSLocalizedString(@"delete_package_message", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"no", nil) otherButtonTitles:NSLocalizedString(@"yes", nil), nil];
    [alert show];
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Accounts
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////

-(IBAction)facebookButtonPressed:(id)sender {
    
    if (![SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        [[Settings sharedSettings] removeLoginData];
        [self messageAlert:NSLocalizedString(@"connect_device_to_facebook", nil)];
        return;
    }
    [self showLoadingViewController:YES];
    
    ACAccountStore *__block accountStore = [[ACAccountStore alloc] init];
    ACAccountType *__block facebookAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    NSDictionary *options = @{ACFacebookAppIdKey : facebookAppId,
                              ACFacebookPermissionsKey : @[@"email"],
                              ACFacebookAudienceKey : ACFacebookAudienceFriends};
    
    [accountStore requestAccessToAccountsWithType:facebookAccountType options:options completion:^(BOOL granted, NSError *error)
     {
         NSLog(@"%@",error);
         if (granted)
         {
             NSArray *accounts = [accountStore accountsWithAccountType:facebookAccountType];
             if (accounts.count > 0) {
                 ACAccount *__block account = accounts[0];
                 ACAccountCredential *cred = [account credential];
                 NSDictionary *accountData = [account valueForKey:kProperty];
                 NSLog(@"%@",account);
                 NSLog(@"%@",accountData);
                 NSLog(@"%@",[accountData valueForKey:kUserFullName]);
                 NSLog(@"%@",[accountData valueForKey:kEmail]);
                 NSLog(@"%@",[accountData valueForKey:kUid]);
                 NSLog(@"%@",cred.oauthToken);
                 
                 NSString *imageUrl = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=120&height=120",[accountData valueForKey:kUid]];
                 NSString *__block imagePath = [self loadUserImageWithUrl:imageUrl];
   
                 [WebServices createAccountFacebookUid:[accountData valueForKey:kUid]  orGoogleUid:nil sessionToken:cred.oauthToken andCompletionBlock:^(enum WebServiceRequestStatus status, NSString *accountToken) {
                     if (status == WS_OK && accountToken) {
                         [self saveAccountToSettingName:[accountData valueForKey:kUserFullName] accessToken:accountToken andImagePath:imagePath];
                         [Utilities UITaskInSeparatedBlock:^{
                             _userNameLabel.text = [[accountData valueForKey:kUserFullName] uppercaseString];
                             [self showLoadingViewController:NO];
                             _userImageView.image = [UIImage imageWithContentsOfFile:imagePath];
                             [self animateLogin];
                         }];
                         [self syncDataWithServer];
                     }
                     else if (status == WS_ERROR && [accountToken isEqualToString:@"190"]) {
                         if (!isFacebookRenewed) {
                             [Utilities taskWithDelay:0.1 forBlock:^{
                                 [self requstRenew:account andAccountStore:accountStore];
                             }];
                         }
                         else {
                             [Utilities UITaskInSeparatedBlock:^{
                                 [self showLoadingViewController:NO];
                             }];
                         }
                     }
                     else {
                         [Utilities UITaskInSeparatedBlock:^{
                             [self showLoadingViewController:NO];
                         }];
                     }
                 }];
             }
             else {
                 [Utilities UITaskInSeparatedBlock:^{
                     [self showLoadingViewController:NO];
                 }];
             }
             
         } else {
             NSLog(@"%@",error);
             [Utilities UITaskInSeparatedBlock:^{
                 [self showLoadingViewController:NO];
             }];
         }
    }];
     
}

-(void)requstRenew:(ACAccount *)account andAccountStore:(ACAccountStore *)accountStore {
    [accountStore renewCredentialsForAccount:account completion:^(ACAccountCredentialRenewResult renewResult, NSError *error) {
        
        switch (renewResult) {
            case ACAccountCredentialRenewResultRenewed: {
                isFacebookRenewed = YES;
                [self facebookButtonPressed:nil];
                /*ACAccountCredential *cred = [account credential];
                NSDictionary *accountData = [account valueForKey:kProperty];
                NSLog(@"%@",account);
                NSLog(@"%@",accountData);
                NSLog(@"%@",[accountData valueForKey:kUserFullName]);
                NSLog(@"%@",[accountData valueForKey:kEmail]);
                NSLog(@"%@",[accountData valueForKey:kUid]);
                NSLog(@"%@",cred.oauthToken);
                NSString *imageUrl = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=80&height=80",[accountData valueForKey:kUid]];
                NSString *__block imagePath = [self loadUserImageWithUrl:imageUrl];
                [WebServices createAccountFacebookUid:[accountData valueForKey:kUid]  orGoogleUid:nil sessionToken:cred.oauthToken andCompletionBlock:^(enum WebServiceRequestStatus status, NSString *accountToken) {
                    if (status == WS_OK && accountToken) {
                        [self saveAccountToSettingName:[accountData valueForKey:kUserFullName] accessToken:accountToken andImagePath:imagePath];
                        [Utilities UITaskInSeparatedBlock:^{
                            _userNameLabel.text = [[accountData valueForKey:kUserFullName] uppercaseString];
                            [self showLoadingViewController:NO];
                            _userImageView.image = [UIImage imageWithContentsOfFile:imagePath];
                            [self animateLogin];
                        }];
                        [self syncDataWithServer];
                    }
                    else {
                        [Utilities UITaskInSeparatedBlock:^{
                            [self showLoadingViewController:NO];
                        }];
                        
                    }
                }];
                NSLog(@"Good to go");*/
            }
                break;
            case ACAccountCredentialRenewResultRejected: {
                NSLog(@"User declined permission");
                [Utilities UITaskInSeparatedBlock:^{
                    [self showLoadingViewController:NO];
                }];
            }
                break;
            case ACAccountCredentialRenewResultFailed: {
                NSLog(@"non-user-initiated cancel, you may attempt to retry");
                [Utilities UITaskInSeparatedBlock:^{
                    [self showLoadingViewController:NO];
                }];
            }
                break;
            default:
                break;
        }
    }];
}

-(void)saveAccountToSettingName:(NSString *)accountName accessToken:(NSString *)accessToken andImagePath:(NSString *)imagePath {
    Settings *settings = [Settings sharedSettings];
    [settings setLoginAccountName:accountName];
    //[settings setLoginProfilePictureLink:imagePath];
    [settings setLoginProfilePictureLink:@"profileImage.png"];
    [settings setLoginToken:accessToken];
    [settings saveLoginData];
    [settings loadLoginData];
}

-(IBAction)googlePlusButtonPressed:(id)sender {
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    [signIn authenticate];
    [signIn disconnect];
    [self showLoadingViewController:YES];
}

- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error {
    if (error) {
        [self showLoadingViewController:NO];
        NSLog(@"%@",error);
        [self messageAlert:NSLocalizedString(@"simple_error_message_on_login", nil)];
        return;
    }
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    GTLServicePlus* plusService = [[[GTLServicePlus alloc] init] autorelease];
    plusService.retryEnabled = YES;
    [plusService setAuthorizer:signIn.authentication];
    GTLQueryPlus *query = [GTLQueryPlus queryForPeopleGetWithUserId:@"me"];
    [plusService executeQuery:query
            completionHandler:^(GTLServiceTicket *ticket,
                                GTLPlusPerson *person,
                                NSError *error) {
                if (error) {
                    NSLog(@"Error: %@", error);
                     [self messageAlert:NSLocalizedString(@"simple_error_message_on_login", nil)];
                    [self showLoadingViewController:NO];
                } else {
                    [self sendGooglePlusPersonToServer:person];
                }
            }];
    
    NSLog(@"Received error %@ and auth object %@",error, auth);
}

-(void)sendGooglePlusPersonToServer:(GTLPlusPerson *)person {
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    NSLog(@"%@",signIn.authentication.accessToken);
    NSString *imagePath = [self loadUserImageWithUrl: person.image.url];
    [WebServices createAccountFacebookUid:nil
                              orGoogleUid:person.identifier
                             sessionToken:signIn.authentication.accessToken
                       andCompletionBlock:^(enum WebServiceRequestStatus status, NSString *accountToken) {
        if (accountToken) {
             Settings *settings = [Settings sharedSettings];
             [settings setLoginAccountName:person.displayName];
             [settings setLoginProfilePictureLink:imagePath];
             [settings setLoginToken:accountToken];
             [settings saveLoginData];
             [settings loadLoginData];
             [Utilities UITaskInSeparatedBlock:^{
                 _userNameLabel.text = [person.displayName uppercaseString];
                 [self showLoadingViewController:NO];
                 _userImageView.image = [UIImage imageWithContentsOfFile:imagePath];
                 [self animateLogin];
             }];
            [self syncDataWithServer];
        }
        else {
            [self showLoadingViewController:NO];
        }
                           
    }];
}

- (void)presentSignInViewController:(UIViewController *)viewController {
    // This is an example of how you can implement it if your app is navigation-based.
    [[self navigationController] pushViewController:viewController animated:YES];
}

-(IBAction)logout:(id)sender {
    [[GPPSignIn sharedInstance] signOut];
    [[Settings sharedSettings] removeLoginData];
    [self animateLogout];
}

-(NSString *)loadUserImageWithUrl:(NSString *)url {
    
    NSURL *ImageURL = [NSURL URLWithString: url];

    NSString *filename = @"profileImage.png";
    NSString *uniquePath = [[[Utilities applicationDocumentsDirectory] path] stringByAppendingPathComponent: filename];

    NSError *error = nil;
    NSData *data = nil;
    data = [NSData dataWithContentsOfURL:ImageURL options:NSDataReadingMappedIfSafe error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
    UIImage *image = [[UIImage alloc] initWithData: data];
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, 0, colorSpace, kCGBitmapByteOrderDefault);
    CGContextDrawImage(context, imageRect, [image CGImage]);
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CFRelease(imageRef);
    
    [UIImagePNGRepresentation(newImage) writeToFile: uniquePath atomically: YES];

    return uniquePath;
}

-(void)animateLogin {
    float w = [UIScreen mainScreen].bounds.size.width;
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        _loginDescrLabel.alpha = 0.0;
    } completion:^(BOOL finished) {
        
    }];
    [UIView animateWithDuration:0.6
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
        _facebookLoginButton.frame =  (CGRect){-w, 40,
            _facebookLoginButton.frame.size.width,
            _facebookLoginButton.frame.size.height};
    } completion:^(BOOL finished) {
        
    }];
    [UIView animateWithDuration:0.6
                          delay:0.1
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
        _googlePlusLoginButton.frame =  (CGRect){-w, 100,
            _googlePlusLoginButton.frame.size.width,
            _googlePlusLoginButton.frame.size.height};
    } completion:^(BOOL finished) {
        
    }];
    [UIView animateWithDuration:0.6
                          delay:0.2
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        _userNameLabel.frame =  (CGRect){(w/2)-(_userNameLabel.frame.size.width/2), 15,
            _userNameLabel.frame.size.width,
            _userNameLabel.frame.size.height};
    } completion:^(BOOL finished) {
        
    }];
    [UIView animateWithDuration:0.6
                          delay:0.3
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        _userImageView.frame =  (CGRect){(w/2)-(_userImageView.frame.size.width/2), 60,
            _userImageView.frame.size.width,
            _userImageView.frame.size.height};
    } completion:^(BOOL finished) {
        
    }];
    [self showLogoutButton:YES];
}

-(void)showLogoutButton:(BOOL)show {
    
    if (show) {
        _logoutView.backgroundColor = [UIColor colorWithRed:239.0f/255.0f
                                                      green:243.0f/255.0f
                                                       blue:247.0f/255.0f
                                                      alpha:1.0f];
        [UIView animateWithDuration:0.4
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             _logoutView.frame =  (CGRect){singOutButtonPosition.x,
                                 singOutButtonPosition.y,
                                 _logoutView.frame.size.width,
                                 _logoutView.frame.size.height};
                         } completion:^(BOOL finished) {
                             
                         }];
    }
    else {
        [UIView animateWithDuration:0.4
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             _logoutView.frame =  (CGRect){0,
                                 self.view.frame.size.height,
                                 _logoutView.frame.size.width,
                                 _logoutView.frame.size.height};
                         } completion:^(BOOL finished) {
                             
                         }];
    }
}

-(void)animateLogout {
    
    float w = [UIScreen mainScreen].bounds.size.width;
    
    [UIView animateWithDuration:0.6 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        _userNameLabel.frame =  (CGRect){w+20, 15, _userNameLabel.frame.size.width, _userNameLabel.frame.size.height};
    } completion:^(BOOL finished) {
        
    }];
    [UIView animateWithDuration:0.6 delay:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
        _userImageView.frame =  (CGRect){w+50, 60, _userImageView.frame.size.width, _userImageView.frame.size.height};
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.6 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            _loginDescrLabel.alpha = 1.0;
        } completion:^(BOOL finished) {
            
        }];
    }];
    [UIView animateWithDuration:0.6 delay:0.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _facebookLoginButton.frame =  (CGRect){10, 40, _facebookLoginButton.frame.size.width, _facebookLoginButton.frame.size.height};
    } completion:^(BOOL finished) {
        
    }];
    [UIView animateWithDuration:0.6 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _googlePlusLoginButton.frame =  (CGRect){10, 100, _googlePlusLoginButton.frame.size.width, _googlePlusLoginButton.frame.size.height};
    } completion:^(BOOL finished) {
        
    }];
    [self showLogoutButton:NO];
}

-(void)showLoadingViewController:(BOOL)show {
    if (show) {
        if (!alvc) {
            alvc = [self.storyboard instantiateViewControllerWithIdentifier:@"AccountLoadingVC"];
        }
        UIGraphicsBeginImageContext(self.navigationController.view.bounds.size);
        [self.navigationController.view.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        //Blur the UIImage with a CIFilter
        CIImage *imageToBlur = [CIImage imageWithCGImage:viewImage.CGImage];
        CIFilter *gaussianBlurFilter = [CIFilter filterWithName: @"CIGaussianBlur"];
        [gaussianBlurFilter setValue:imageToBlur forKey: @"inputImage"];
        [gaussianBlurFilter setValue:[NSNumber numberWithFloat: 1.7] forKey: @"inputRadius"];
        CIImage *resultImage = [gaussianBlurFilter valueForKey: @"outputImage"];
        UIImage *endImage = [[UIImage alloc] initWithCIImage:resultImage];
        
        //Place the UIImage in a UIImageView
        CGRect frame =  (CGRect){-2, -2, self.view.bounds.size.width+4, self.view.bounds.size.height+4};
        UIImageView *newView = [[UIImageView alloc] initWithFrame:frame];
        newView.image = endImage;
        [alvc.view addSubview:newView];
        alvc.view.alpha = 0.0;
        [alvc animateBicycle:CGRectNull];
        [self.navigationController.view addSubview:alvc.view];
        [UIView animateWithDuration:0.5 animations:^{
            alvc.view.alpha = 1.0;
        } completion:^(BOOL finished) {
            
        }];
        
    }
    else {
        [alvc.view removeFromSuperview];
        [alvc stopAnimationAndRemoveFromSuperview];
    }
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark AlertView
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        Package *p = _listOfPurchasedPackages[indexPathToDelete.row];
        //NSString *imgPath = [Utilities imagePathMD5FromPackageName:p.packageName];
        //[[NSFileManager defaultManager] removeItemAtPath:imgPath error:nil];
        [DBCoreDataHelper deletePackageWithId:p.packageId forLanguage:p.packageLang];
        NSMutableArray *array = [_listOfPurchasedPackages mutableCopy];
        [array removeObject:p];
        _listOfPurchasedPackages = [array mutableCopy];
        [_tableView beginUpdates];
        [_tableView deleteRowsAtIndexPaths:@[indexPathToDelete] withRowAnimation:UITableViewRowAnimationRight];
        [_tableView endUpdates];
        [self reloadTableView];
    }
}

#pragma Footer message view
-(void)showFooterMessageWithText:(NSString *)text {
    UILabel *l = (UILabel *)[_tableView.tableFooterView viewWithTag:STORE_FOOTER_LABEL_TAG];
    if (_tableView.tableFooterView.alpha < 1) {
        l.text = text;
        [self animateFooterViewForAlpha:1.0];
    }
    else {
        l.text = text;
    }
}

-(void)hideFooterMessage {
    if (_tableView.tableFooterView.alpha >= 1) {
        [self animateFooterViewForAlpha:0.0];
    }
}

-(void)animateFooterViewForAlpha:(float)alpha {
    [UIView animateWithDuration:0.5 animations:^{
        _tableView.tableFooterView.alpha = alpha;
    }];
}

-(void)messageAlert:(NSString *)message {
    [Utilities UITaskInSeparatedBlock:^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                                              otherButtonTitles:nil, nil];
        [alert show];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

@implementation AccountLoadingViewController


@end
