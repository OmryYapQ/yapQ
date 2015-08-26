//
//  PackageStoreViewController.m
//  yapq
//
//  Created by yapQ Ltd
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import "PackageStoreViewController.h"
#import "tToken.h"
/**
 Private category of PackgeStoreViewController
 */
@interface PackageStoreViewController () {
    
    /** Start point of scroll view when QR Scanner opened */
    CGPoint startPosition;
    /** Flag if QR Scanner opened */
    BOOL isScannerOpen;
    /** Flag if scroll view draged, used only when QR Scanner opened */
    BOOL isDraged;
    /** Index of cell with opened QR Scanner or In-app purchase*/
    NSUInteger purchasingCellIndex;
    /** Flag show if metadata received */
    BOOL isMetaDataReceived;
    /** Flag displayes if there is in-app purchase proccess active */
    BOOL inAppPurchaseProcess;
    
    BOOL searchReaultDisplayed;
    
    NSString *textInSearchBar;
}

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@end

@implementation PackageStoreViewController

-(void)awakeFromNib {
    // Initializing of Dot loader
    //dliv = [[UIDotLoaderIndicatorView alloc] initWithSize:INDICATOR_MEDIUM atPosition:CGPointMake(90, 15) tintColor:[UIColor darkGrayColor] animationSpeed:0.7];
}
/**
 LRSlideMenuDelegate method for left menu
 */
-(BOOL)LRSlideMenuHasLeftMenu {
    return NO;
}
/**
 LRSlideMenuDelegate method for right menu
 */
-(BOOL)LRSlideMenuHasRightMenu {
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.storeSearchBar = (PackageStoreSearchBar *)[_tableHeaderView viewWithTag:1001];
    
    if ([Utilities currentVersionOfOS] == UTIOS_8) {
        CGRect sbFrame = _storeSearchBar.frame;
        float w = [UIScreen mainScreen].bounds.size.width;
        float x = w - sbFrame.origin.x - 57;
        _storeSearchBar.cancelButton = [[UIButton alloc] initWithFrame: (CGRect){x, 3, 40, 40}];
        
        [_storeSearchBar.cancelButton setImage:[UIImage imageNamed:@"clear.png"] forState:UIControlStateNormal];
        [_storeSearchBar.cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_storeSearchBar.cancelButton addTarget:self action:@selector(clearSearch) forControlEvents:UIControlEventTouchUpInside];
        _storeSearchBar.cancelButton.hidden = YES;
        [_storeSearchBar addSubview:_storeSearchBar.cancelButton];
        
        
        
    }
    else {
        for (UIView *v in self.storeSearchBar.subviews) {
            for (UITextField *tf in v.subviews) {
                if ([tf isKindOfClass: [UITextField class]]) {
                    tf.delegate = self;
                    tf.tag = 1000;
                    break;
                }
            }
        }
    }
    if ([_storeSearchBar respondsToSelector:@selector(setKeyboardAppearance:)]) {
        [_storeSearchBar setKeyboardAppearance:UIKeyboardAppearanceAlert];
    }
    if ([_storeSearchBar respondsToSelector:@selector(setReturnKeyType:)]) {
        [_storeSearchBar setReturnKeyType:UIReturnKeySearch];
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(packageLoadingStatus:) name:PL_STATUS_NOTIFICATION_KEY object:[PackageController sharedController]];
    Reachability *networkStatus = [Reachability reachabilityForInternetConnection];
    if ([[Settings sharedSettings] is3GEnabled] == NO && [networkStatus currentReachabilityStatus] != ReachableViaWiFi) {
        [self messageAlert:NSLocalizedString(@"connect_to_wifi_or_enable_data_roaming", nil)];
        return;
    }
    _listOfPackages = [[PackageController sharedController] getPackageList];
    [self reloadTableView];
    //[self showLoading:YES];
    [self animateBicycle:CGRectNull];
    
    [self loadDataWithQuery:nil];
    
    /*UINavigationBar* navigationBar = self.navigationController.navigationBar;
    
    [navigationBar setBarTintColor:[UIColor colorWithRed:1.0f green:237./255. blue:15.f/255.0f alpha:1.0f]];
    
    const CGFloat statusBarHeight = 20;    //  Make this dynamic in your own code...
    
    UIView* underlayView = [[UIView alloc] initWithFrame:CGRectMake(0, -statusBarHeight, navigationBar.frame.size.width, navigationBar.frame.size.height + statusBarHeight)];
    [underlayView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    [underlayView setBackgroundColor:[UIColor colorWithRed:1.0f green:237./255. blue:15./255. alpha:1.0f]];
    [underlayView setAlpha:0.36f];
    [navigationBar insertSubview:underlayView atIndex:0];*/
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:[NSString stringWithFormat:@"IOS: %@ %@",NSStringFromClass([self class]),[Settings sharedSettings].speechLanguage]];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];



}

-(void)loadDataWithQuery:(NSString *)query {
    __weak PackageStoreViewController *svc = self;
    // Request packages from server
    [WebServices loadListOfPackagesWithSearchQuery:query withCompletionBlock:^(enum WebServiceRequestStatus status) {
        [NSThread sleepForTimeInterval:1];
        PackageStoreViewController *strongSVC = svc;
        if (status == WS_OK) {
            [strongSVC reloadTableView];
        }
        if (status == WS_ERROR || _listOfPackages.count == 0) {
            NSLog(@"Error during loading list of packages");
            [svc showFooterMessageWithText:NSLocalizedString(@"no_packages_found", nil)];
        }
    }];
}

-(void)viewWillAppear:(BOOL)animated {
    
    // Register notification receiver for PackageLoader status updates
    
    // Calculating insets if some message shown under navigation bar
    //[self isNeedSetupInsets];
    if (_listOfPackages.count > 0) {
        
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [[PackageController sharedController] removeAll];
    // Remove notification receiver
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PL_STATUS_NOTIFICATION_KEY object:[PackageController sharedController]];
}

/**
 Reloading UITabelView with data from server
 */
-(void)reloadTableView {
    if (_listOfPackages.count < [[PackageController sharedController] getNumberOfPackages]) {
        _listOfPackages = [[PackageController sharedController] getPackageList];
        [self.tableView reloadData];
        [self hideFooterMessage];
    }
    else if (_listOfPackages.count == 0) {
        //[self showFooterMessageWithText:@"No packages found"];
    }
    //[self showLoading:NO];
    [self stopAnimationAndRemoveFromSuperview];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

/**
 * Notifiaction from package loader about status
 *
 * @param sender - user info of package loader
 */
-(void)packageLoadingStatus:(id)sender {
    //NSLog(@"%@",sender);
    NSDictionary *userInfo = [((NSNotification *)sender) userInfo];
    PLStatus status = [[userInfo valueForKey:PL_STATUS_KEY] integerValue];
    PackageLoader *pl = [userInfo valueForKeyPath:PL_PACKAGE_KEY];
    if (status == PLS_LOAD_WAITING) {
       PackageStoreCell *cell = (PackageStoreCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:[_listOfPackages indexOfObject:pl.package] inSection:0]];
        [cell startWaitingForPackageLoader:pl];
    }
    else if (status == PLS_LOAD_ERROR) {
        __weak PackageStoreCell *cell = (PackageStoreCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:[_listOfPackages indexOfObject:pl.package] inSection:0]];
        [Utilities UITaskInSeparatedBlock:^{
            PackageStoreCell *sCell = cell;
            [sCell cellReset];
        }];
        [self messageAlert:NSLocalizedString(@"simple_error_message_on_download", nil)];
        NSLog(@"ERROR With status code %i",status);
    }
    else if (status == PLS_PARSING_ERROR ||
             status == PLS_UNZIP_ERROR) {
        __weak PackageStoreCell *cell = (PackageStoreCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:[_listOfPackages indexOfObject:pl.package] inSection:0]];
        [Utilities UITaskInSeparatedBlock:^{
            PackageStoreCell *sCell = cell;
            [sCell cellReset];
        }];
        [self messageAlert:NSLocalizedString(@"simple_error_message_on_download", nil)];
        NSLog(@"ERROR With status code %i",status);
    }
    else if (status == PLS_LOAD_STARTED) {
        PackageStoreCell *cell = (PackageStoreCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:[_listOfPackages indexOfObject:pl.package] inSection:0]];
        [Utilities UITaskInSeparatedBlock:^{
            [cell startLoadingForPackageLoader:pl];
            [self.tableView reloadData];
        }];
    }
    else if (status == PLS_UNZIP_STARTED) {

    }
    else if (status == PLS_PARSING_FINISHED) {
        /*NSUInteger index = [_listOfPackages indexOfObject:pl.package];
        //[[PackageController sharedController].packagesFromServer removeObject:pl.package];
        _listOfPackages = [[PackageController sharedController] getPackageList];
        NSArray *rows = @[[NSIndexPath indexPathForRow:index inSection:0]];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:rows withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView endUpdates];*/
        [self.tableView reloadData];
        
        // [WebServices syncPurchasesWithServer];
        // Saving purchase id of package in db
        // [DBCoreDataHelper updateForPackage:_listOfPackages[index]];
    }
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableView
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _listOfPackages.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *buyCellIdentifier = @"PackageCell";
    PackageStoreCell *cell = [tableView dequeueReusableCellWithIdentifier:buyCellIdentifier forIndexPath:indexPath];
    // Setup cell as loading
    Package *p = _listOfPackages[indexPath.row];
    [cell cellReset];
    cell.vcDelegate = self;
    [cell setPackage: p];
    if ([PackageController sharedController].currentPL.package.packageId == p.packageId) {
        [cell setupAsLoading:[PackageController sharedController].currentPL];
    }
    else if ([DBCoreDataHelper isPurchasedPackageExistWithId:p.packageId] || [p.price floatValue] == 0) {
        cell.downloadButton.label.text = NSLocalizedString(@"free", nil);
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 338;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Package *p = ((PackageStoreCell *)cell).package;
    if (p.wasDisplayed) {
        return;
    }
    PackageStoreCell *psCell = (PackageStoreCell *)cell;
    __block CGPoint point = psCell.cellBackgroundView.frame.origin;
    [psCell.cellBackgroundView setFrame:(CGRect){320,
        point.y+170,
        psCell.cellBackgroundView.frame.size.width,
        psCell.cellBackgroundView.frame.size.height}];
    [UIView animateWithDuration:0.5
                          delay:0
                        options:0
                     animations:^{
                         [psCell.cellBackgroundView setFrame:(CGRect){point.x,
                             point.y,
                             psCell.cellBackgroundView.frame.size.width,
                             psCell.cellBackgroundView.frame.size.height}];
                     } completion:^(BOOL finished) {
                         
                         p.wasDisplayed = YES;
                     }];
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark In-App purchase
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////
-(void)downloadButtonEvent:(PackageStoreCell *)cell {
    inAppPurchaseProcess = YES;
    purchasingCellIndex = [_tableView indexPathForCell:cell].row;
//#warning USE P
    Package *p = _listOfPackages[purchasingCellIndex];
    //if ([DBCoreDataHelper isPackageExist:p.packageId forLanguage:[Settings sharedSettings].speechLanguage]) {
    if ([DBCoreDataHelper isPurchasedPackageExistWithId:p.packageId]) {
        return;
    }
    if ([p.price floatValue] == 0) {
        p.purchaseType = PLPurchaseTypeFree;
        [self downloadAsInAppPurchase:cell];
        return;
    }
    NSSet *set = [NSSet setWithObject:[NSString stringWithFormat:@"%@%li",IN_APP_PURCHASE_UID_TEMPLETE,(long)p.packageId]];
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
    request.delegate = self;
    [request start];
}

-(void)downloadAsInAppPurchase:(PackageStoreCell *)cell {
    // Calling method for QR download because it has the same logic
    [self downloadWithQRCode:cell];
    
    @try {


        if (cell.package.purchaseType == PLPurchaseTypeAppStore) {
            saveEvent(@"purchase_iOS");
        }
        else {
            saveEvent(@"purchase_iOS_Cupoon");
        }

    }
    @catch (NSException *exception) {
        
    }
}

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}

-(void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    
}

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    // Adding observer to In-App purchase observer
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    NSArray *allProducts = response.products;
    if (allProducts.count > 0) {
        //NSLog(@"%@",[allProducts[0] productIdentifier]);
        SKPayment *payment = [SKPayment paymentWithProduct:allProducts[0]];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }else {
        PackageStoreCell *cell = (PackageStoreCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:purchasingCellIndex inSection:0]];
        [cell cellReset];
    }
    
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction
{
    //NSLog(@"Transaction Completed");
    PackageStoreCell *cell = (PackageStoreCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:purchasingCellIndex inSection:0]];
    // Saving transaction id
    //NSLog(@"transaction.transactionIdentifier = %@",transaction.transactionIdentifier);
    //NSLog(@"transaction.transactionIdentifier = %@",transaction.originalTransaction.transactionIdentifier);
    if (transaction.originalTransaction.transactionIdentifier == nil && transaction.transactionIdentifier != nil) {
        cell.package.packageCardCode = transaction.transactionIdentifier;
        //NSLog(@"transaction.transactionIdentifier = %@",transaction.transactionIdentifier);
        //NSLog(@"transaction.transactionIdentifier = %@",transaction.originalTransaction.transactionIdentifier);
        // Setting transaction type
        cell.package.purchaseType = PLPurchaseTypeAppStore;
        
        [DBCoreDataHelper insertPurchasedPackage:cell.package];
        [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
        inAppPurchaseProcess = NO;
        [self downloadAsInAppPurchase:cell];
    }
    else if (transaction.originalTransaction.transactionIdentifier != nil){
        cell.package.packageCardCode = transaction.originalTransaction.transactionIdentifier;
        cell.package.purchaseType = PLPurchaseTypeAppStore;
        
        [DBCoreDataHelper insertPurchasedPackage:cell.package];
        [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
        inAppPurchaseProcess = NO;
        [self downloadAsInAppPurchase:cell];
    }
    else {
        [self failedTransaction:transaction];
    }
    
    [[SKPaymentQueue defaultQueue]removeTransactionObserver:self];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
//#warning IMPLEMENT RESTORE OPERATION
    //NSLog(@"Transaction Restored");
    // You can create a method to record the transaction.
    // [self recordTransaction: transaction];
    
    // You should make the update to your app based on what was purchased and inform user.
    // [self provideContent: transaction.payment.productIdentifier];
    
    // Finally, remove the transaction from the payment queue.
    PackageStoreCell *cell = (PackageStoreCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:purchasingCellIndex inSection:0]];
    // Saving transaction id
    cell.package.packageCardCode = transaction.originalTransaction.transactionIdentifier;
   // NSLog(@"transaction.transactionIdentifier = %@",transaction.transactionIdentifier);
   // NSLog(@"transaction.transactionIdentifier = %@",transaction.originalTransaction.transactionIdentifier);
    
    // Setting transaction type
    cell.package.purchaseType = PLPurchaseTypeAppStore;
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    inAppPurchaseProcess = NO;
    [[SKPaymentQueue defaultQueue]removeTransactionObserver:self];
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
    //[activityIndicator stopAnimating];
    //if (transaction.error.code != SKErrorPaymentCancelled)
    //{
        NSLog(@"%@",transaction.error.description);
        // Display an error here.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"purchase_unsuccessful", nil)
                                                        message:NSLocalizedString(@"try_repurchase", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                                              otherButtonTitles:nil];
        [alert show];
    //}
    //else {
       // [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    //}
    PackageStoreCell *cell = (PackageStoreCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:purchasingCellIndex inSection:0]];
    [cell cellReset];
    [self.tableView reloadData];
    // Finally, remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    [[SKPaymentQueue defaultQueue]removeTransactionObserver:self];
    inAppPurchaseProcess = NO;
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark QR Scanner Setups
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////
-(void)scanBarCodeButtonEvent:(PackageStoreCell *)cell {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    purchasingCellIndex = indexPath.row;
    Package *p = _listOfPackages[purchasingCellIndex];
    if ([DBCoreDataHelper isPackageExist:p.packageId forLanguage:[Settings sharedSettings].speechLanguage]) {
        return;
    }
    [self.tableView scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:YES];
}

-(void)downloadWithQRCode:(PackageStoreCell *) cell {
    
    PackageLoader *pl = [[PackageLoader alloc] initWithPackage:cell.package];
    if (![pl isEnoughSpaceForLoading]) {
        [self messageAlert:NSLocalizedString(@"no_space_on_device", nil)];
        [cell cellReset];
        return;
    }
    // Adding loading progress observer
    [pl addObserver:cell forKeyPath:kDownloadProgressObserver options:0 context:nil];
    [[PackageController sharedController] addPackageLoaderToQueue:pl];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:[NSString stringWithFormat:@"IOS:Purchase or Gift %@ package",cell.package.packageName]];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

-(void)qrScannerBaginCloseAnimation:(id)cell {
    isDraged = NO;
    isScannerOpen = NO;
}

-(void)qrScannerBeginOpenAnimation:(PackageStoreCell *)cell {}

/**
 Sending request for download after scanning QR
 */
-(void)qrScannerDidEndCloseAnimation:(PackageStoreCell *)cell {
    // Only if metadata received sending request to server
    //if ([DBCoreDataHelper isPackageExist:cell.package.packageId forLanguage:[Settings sharedSettings].speechLanguage]) {
    if ([DBCoreDataHelper isPurchasedPackageExistWithId:cell.package.packageId]) {
        [self performSegueWithIdentifier:@"AccountFromStore" sender:cell];
    }
    else if (isMetaDataReceived) {
        [self downloadWithQRCode:cell];
    }
}

/**
  Opening QR scanner after flip ends
 */
-(void)qrScannerDidEndOpenAnimation:(PackageStoreCell *)cell {
    isScannerOpen = YES;
    [self setupForScanningInView:cell.promoCodeView];
}

-(void)closeQRScannerWithReceivedMetadata:(NSString *)metadata {
    PackageStoreCell *cell = (PackageStoreCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:purchasingCellIndex inSection:0]];
    if (isMetaDataReceived) {
        // Setting metadata as package card code
        cell.package.packageCardCode = metadata;
        // Setting type as QR
        cell.package.purchaseType = PLPurchaseTypeQR;
    }
    [cell closeQRScanner];
}

/**
 Setup and start QR Scanner for read
 */
-(void)setupForScanningInView:(PromoCodeView *)view {

    [view.nOne becomeFirstResponder];
    view.inputDelegate = self;
    isMetaDataReceived = NO; // Flag say's about starting new scanning
    
    /*NSError *error;
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (!input) {
        NSLog(@"%@", [error localizedDescription]);
        return;
    }
    
    _captureSession = [[AVCaptureSession alloc] init];
    [_captureSession addInput:input];
    
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [_captureSession addOutput:captureMetadataOutput];
    
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("QRScannerQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];

    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_videoPreviewLayer setFrame:view.layer.bounds];
    [view.layer addSublayer:_videoPreviewLayer];
    
    [_captureSession startRunning];*/
}

/**
 Stoping QR Scanner
 */
-(void)stopScanning {
    //[_captureSession stopRunning];
    //_captureSession = nil;
    //[_videoPreviewLayer removeFromSuperlayer];
}

/**
 QR Scanner metadata receiver
 */
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects != nil && [metadataObjects count] > 0 && !isMetaDataReceived) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            
            //NSLog(@"%@",[metadataObj stringValue]);
            NSString *metadata = [metadataObj stringValue];
            if (metadata.length > 0) {
                isMetaDataReceived = YES;
            }
            [Utilities UITaskInSeparatedBlock:^{
                [self stopScanning];
                [self closeQRScannerWithReceivedMetadata:metadata];
            }];
        }
    }

}

-(void)codeEntered:(NSString *)code {
    [Utilities UITaskInSeparatedBlock:^{
        if (code.length > 0) {
            isMetaDataReceived = YES;
        }
        [self closeQRScannerWithReceivedMetadata:code];
    }];
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark ScrollViewDelegate
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    float newY = abs(scrollView.contentOffset.y);
    if (abs(newY - abs(startPosition.y)) >= 20 && isScannerOpen && isDraged) {
        //NSLog(@"Close %d",abs(startPosition.y) - abs(scrollView.contentOffset.y));
        isDraged = NO;
        isScannerOpen = NO;
        [self closeQRScannerWithReceivedMetadata:nil];
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    startPosition = scrollView.contentOffset;
    isDraged = YES;
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Search
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////

-(void)clearSearch {
    _storeSearchBar.cancelButton.hidden = YES;
    [self searchBarCancelButtonClicked:(UISearchBar *)[_tableHeaderView viewWithTag:1001]];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    if (searchBar.text.length > 0) {
        [self animateBicycle:CGRectNull];
        _listOfPackages = nil;
        [self.tableView reloadData];
        [self loadDataWithQuery:searchBar.text];
        searchReaultDisplayed = YES;
    }
}
/*
-(UISearchDisplayController *)searchDisplayController {
    return nil;
}
*/

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    //[searchBar setShowsCancelButton:YES animated:YES];
    if ([Utilities currentVersionOfOS] == UTIOS_8) {
        _storeSearchBar.cancelButton.hidden = NO;
    }
    return YES;
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
    if (searchReaultDisplayed) {
        [self animateBicycle:CGRectNull];
        _listOfPackages = nil;
        [self.tableView reloadData];
        [self loadDataWithQuery:nil];
        searchReaultDisplayed = NO;
    }
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    
    
    if (searchText.length == 0) {
        if ([Utilities currentVersionOfOS] == UTIOS_8) {
            _storeSearchBar.cancelButton.hidden = YES;
        }
        [searchBar resignFirstResponder];
        [_storeSearchBar resignFirstResponder];
        [[_storeSearchBar viewWithTag:1000] resignFirstResponder];
    }
}

-(BOOL)textFieldShouldClear:(UITextField *)textField {
    
    textField.text = @"";
    [self searchBarCancelButtonClicked:(UISearchBar *)[_tableHeaderView viewWithTag:1001]];
    return NO;
}


//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Segue
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"AccountFromStore"]) {
        Package *p = _listOfPackages[purchasingCellIndex];
        if (![DBCoreDataHelper isPackageExist:p.packageId forLanguage:[Settings sharedSettings].speechLanguage]) {
            AccountViewController *avc = segue.destinationViewController;
            avc.packageToDownload = p;
        }
    }
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"AccountFromStore"]) {
        Package *p = _listOfPackages[purchasingCellIndex];
        if ([DBCoreDataHelper isPurchasedPackageExistWithId:p.packageId]) {
            PackageStoreCell *cell = (PackageStoreCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:purchasingCellIndex inSection:0]];
            [cell cellReset];
            
            return YES;
        }
    }
    return NO;
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Alerts
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////
-(void)showFooterMessageWithText:(NSString *)text {
    UILabel *l = (UILabel *)[self.view viewWithTag:STORE_FOOTER_LABEL_TAG];
    if (l.alpha < 1) {
        l.text = text;
        [self animateFooterViewForAlpha:1.0];
    }
    else {
        l.text = text;
    }
}

-(void)hideFooterMessage {
    UILabel *l = (UILabel *)[self.view viewWithTag:STORE_FOOTER_LABEL_TAG];
    if (l.alpha >= 1) {
        [self animateFooterViewForAlpha:0.0];
    }
}

-(void)animateFooterViewForAlpha:(float)alpha {
    UILabel *l = (UILabel *)[self.view viewWithTag:STORE_FOOTER_LABEL_TAG];
    [UIView animateWithDuration:0.5 animations:^{
        l.alpha = alpha;
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

@end

/**
 Implementation of PackageStoreTableHeaderView
 */
@implementation PackageStoreTableHeaderView

-(void)awakeFromNib {
    _viewLabel.font = [Utilities RobotoRegularFontWithSize:12];
}
/*
-(void)drawRect:(CGRect)rect {
    
    // Drawing lines around DOWNLOAD text
    UIBezierPath *path = [[UIBezierPath alloc] init];
    path.lineWidth = 1.0;
    [path moveToPoint:CGPointMake(17, 11)];
    [path addLineToPoint:CGPointMake(111, 11)];
    [[UIColor colorWithRed:220./255. green:220./255. blue:220./255. alpha:1.0] setStroke];
    [path stroke];
    
    path = [[UIBezierPath alloc] init];
    path.lineWidth = 1.0;
    [path moveToPoint:CGPointMake(210, 11)];
    [path addLineToPoint:CGPointMake(303, 11)];
    [[UIColor colorWithRed:220./255. green:220./255. blue:220./255. alpha:1.0] setStroke];
    [path stroke];
    
    [[UIColor colorWithRed:220./255. green:220./255. blue:220./255. alpha:0.0] setFill];
}
*/
@end

/**
 Implementation of PackageStoreSearchBar
 */
@implementation PackageStoreSearchBar

-(void)drawRect:(CGRect)rect {
    [[UIColor colorWithRed:255./255. green:255./255. blue:255./255. alpha:1.0] setFill];
    self.layer.cornerRadius = 7;
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = [UIColor colorWithRed:220./255. green:220./255. blue:220./255. alpha:1.0].CGColor;
}


@end


