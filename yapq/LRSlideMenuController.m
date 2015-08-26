//
//  LRSlideMenuController.m
//  LRSlideMenu
//
//  Created by yapQ Ltd.
//  Copyright (c) 2013 yapQ Ltd. All rights reserved.
//

#import "LRSlideMenuController.h"
#import "YMenuViewController.h"
#import "YWebViewController.h"
#import "SearchViewController.h"

@interface LRSlideMenuController () {
    SearchViewController *svc;
}

@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic, assign) CGPoint draggingPoint;
@property (nonatomic, weak) UIViewController *searchCallerVC;
@property (nonatomic, strong) UINavigationItem *navigationItemRef;
@end

@implementation LRSlideMenuController

static LRSlideMenuController *instance;

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init Methods
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////

-(id)init {
    
    if (self = [super init]) {
        [self setDefaults];
    }
    return self;
}

-(id)initWithRootViewController:(UIViewController *)rootViewController {
    
    if (self = [super initWithRootViewController:rootViewController]) {
        [self setDefaults];
    }
    return self;
}

-(void)awakeFromNib {
    [self setDefaults];
}

-(void)setDefaults {
    
    _slideMenuDuration = LRSlideSpeedMedium;
    _menuOpenOffset = LRSlideMenuOpenOffset;
    _leftImageName = LRSLideMenuImageName;
    _rightImageName = LRSLideMenuImageName;
    
    // Use tap gesture for menu closing
    _isUseTapClose = YES;
    
    instance = self;
    self.delegate = self;
    
    // Shadow of menu top level
    /*self.view.layer.shadowColor = [UIColor darkGrayColor].CGColor;
	self.view.layer.shadowRadius = 10;
	self.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.bounds].CGPath;
	self.view.layer.shadowOpacity = 1;
	self.view.layer.shouldRasterize = YES;
	self.view.layer.rasterizationScale = [UIScreen mainScreen].scale;*/
    
    // Using swipe gesture for opening menu
    [self setEnableSwipeGesture:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/**
 * Check if menu is open
 *
 * @return YES if opened, NO if closed.
 */
-(BOOL)isMenuOpen {
    //0L: HACK
    return (self.view.frame.origin.x == 0) && (svc == NULL) ? NO : YES;
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public Method
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////

/**
 * Method open's choosen view controller from menu.
 *
 * @param viewController choosen view controller to display.
 * @param block call's when view controller was pushed to navigation controller (was displayed).
 */
-(void)openMenuItemViewController:(UIViewController *)viewController withCompletionBlock:(void(^)(void))block {
    
    if ([self.topViewController isKindOfClass:viewController.class]) { // Choosen displayed VC
        [self closeMenuWithCompletionBlock:block];
        
        return;
    }
    
    // Call protocol method
    if ([self.topViewController respondsToSelector:@selector(choosenItemWillShow:)]) {
        [(UIViewController<LRSlideMenuDelegate> *)self.topViewController choosenItemWillShow:viewController];
    }
    
    // Opening choosen VC
    if ([self isMenuOpen]) {
        [super popToRootViewControllerAnimated:NO];
        if (viewController != nil) {
            [super pushViewController:viewController animated:NO];
        }
        [self closeMenuWithCompletionBlock:^{
            if (block) {
                block();
            }
        }];
    }
    else {
        [super popToRootViewControllerAnimated:NO];
        [super pushViewController:viewController animated:NO];
        if (block) {
            block();
        }
    }
    // Call protocol method
    if ([self.topViewController respondsToSelector:@selector(choosenItemDidShow:)]) {
        [(UIViewController<LRSlideMenuDelegate> *)self.topViewController choosenItemDidShow:viewController];
    }
}

/**
 * Instance of current menu controller
 * @return instance of slide menu
 */
+(LRSlideMenuController *)sharedInstance {
    if (!instance) {
        instance = [[LRSlideMenuController alloc] init];
    }
    
    return instance;
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UI initializations
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////

/**
 * Create's menu bar button
 * 
 * @param menu left or right menu
 *
 * @return instance of UIBarButtonItem.
 */
-(UIBarButtonItem *)menuButton:(LRSlideMenu) menu {
    
    SEL selector = menu == LRSlideMenuLeft ? @selector(leftMenuButtonAction:) : @selector(rightMenuButtonAction:);
    UIBarButtonItem *button = menu == LRSlideMenuLeft ? _leftMenuButton : _rightMenuButton;
    
    if (button) {
        button.action = selector;
        button.target = self;
        return button;
    }
    
    button.tag = menu;
    
    UIImage *image = nil;
    
    if (menu == LRSlideMenuLeft && [ServerResponse sharedResponse].searchId != NULL) {
        image = [UIImage imageNamed:@"back-icon"];
    }
    else if (menu == LRSlideMenuLeft && [_leftImageName isEqualToString:LRSLideMenuImageName]) {
        image = [UIImage imageWithContentsOfFile: _leftImageName];
    }
    else if (menu == LRSlideMenuLeft) {
        image = [UIImage imageNamed:_leftImageName];
    }
    else if (menu == LRSlideMenuRight && [_rightImageName isEqualToString:LRSLideMenuImageName]) {
        image = [UIImage imageWithContentsOfFile: _rightImageName];
    }
    else if (menu == LRSlideMenuRight) {
        image = [UIImage imageNamed:_rightImageName];
    }
    
    button = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:selector];
    button.tintColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
    return button;
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Menu Button Actions
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////

-(void)leftMenuButtonAction:(id)sender {
    if ([self isMenuOpen]) {
        [self closeMenuWithCompletionBlock:nil];
    }
    else {
        if ([ServerResponse sharedResponse].searchId != NULL) {
            // in search mode -> back was clicked -> stop search
            if (self.searchCallerVC != NULL && [self.searchCallerVC isKindOfClass:[PlacesTableViewController class]]) {
                [((PlacesTableViewController *)self.searchCallerVC) stopSearch];
            }
            
            // change the icon back to settings
            self.navigationItemRef.leftBarButtonItem.image = [UIImage imageNamed:@"menu_img"];
        }
        else {
            [self openMenu:LRSlideMenuLeft withCompletionBlock:nil];
        }
    }
}

-(void)rightMenuButtonAction:(id)sender {
    if ([self isMenuOpen]) {
        [self closeMenuWithCompletionBlock:nil];
    }
    else {
        [self openMenu:LRSlideMenuRight withCompletionBlock:nil];
    }
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Open Close Animations
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////

-(void)openMenu:(LRSlideMenu)menu withCompletionBlock:(void(^)(void)) block {
    //0L open button should change to close button on search
    
    UIViewController *topVC = [self topViewController];
    if ([topVC respondsToSelector:@selector(menuWillOpen:)]) {
        if ([(UIViewController<LRSlideMenuDelegate> *)topVC menuWillOpen:menu] == NO) {
            return;
        }
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_1" bundle:nil];

    YMenuViewController *mvc = [storyboard instantiateViewControllerWithIdentifier:@"YMenuVC"];
    [mvc setLocalization];

    //topVC.view.userInteractionEnabled = NO;
    if (_isUseTapClose)
        [self.topViewController.view addGestureRecognizer:self.tapRecognizer];
    
    if (menu == LRSlideMenuLeft) { // For left menu move view right
        [self.rightMenu.view removeFromSuperview];
        [self.view.window insertSubview:self.leftMenu.view atIndex:0];
        CGRect frame = CGRectMake(self.view.frame.size.width-_menuOpenOffset,
                                  self.view.frame.origin.y,
                                  self.view.frame.size.width,
                                  self.view.frame.size.height);
        [self animationWithFrame:frame withCompletionBlock:block];
    }
    else if (menu == LRSlideMenuRight) { // For right menu move menu left
        self.searchCallerVC = topVC;
        
        //0L: for now this is the search
        svc = [storyboard instantiateViewControllerWithIdentifier:@"SearchTableVC"];
        
        [self presentViewController:svc animated:YES completion:^(void) {
            float version = [[[UIDevice currentDevice] systemVersion] floatValue];
            if (version >= 8.0) {
                [svc.searchController.searchBar becomeFirstResponder];
            }
            else {
                [svc.__searchDisplayController.searchBar becomeFirstResponder];
            }
        }];
    
        /*
        [self.leftMenu.view removeFromSuperview];
        [self.view.window insertSubview:self.rightMenu.view atIndex:0];
        
        CGRect frame = CGRectMake(-(self.view.frame.size.width-_menuOpenOffset),
                                  self.view.frame.origin.y,
                                  self.view.frame.size.width,
                                  self.view.frame.size.height);
        [self animationWithFrame:frame withCompletionBlock:block];
         */
        
    }
    
    if ([topVC respondsToSelector:@selector(menuDidOpen:)]) {
        [(UIViewController<LRSlideMenuDelegate> *)topVC menuDidOpen:menu];
    }
}

-(void)closeMenuWithCompletionBlock:(void(^)(void))block {
    UIViewController *topVC = [self topViewController];
    if ([topVC respondsToSelector:@selector(menuWillClose:)]) {
        if ([(UIViewController<LRSlideMenuDelegate> *)topVC menuWillClose:(svc!=NULL?LRSlideMenuRight:LRSlideMenuLeft)] == NO) {
            return;
        }
    }
    if (_isUseTapClose)
        [self.topViewController.view removeGestureRecognizer:self.tapRecognizer];
    //topVC.view.userInteractionEnabled = YES;
    
    if (NULL != svc) {
        //0L: HACK - we are showing the search
        if ([ServerResponse sharedResponse].searchId != NULL) {
            // change the settings icon to back icon
            self.navigationItemRef.leftBarButtonItem.image = [UIImage imageNamed:@"back-icon"];
        }
        
        if (self.searchCallerVC != NULL && [self.searchCallerVC isKindOfClass:[PlacesTableViewController class]]) {
            [((PlacesTableViewController *)self.searchCallerVC) callSearch];
        }
        
        svc = NULL;
        
    }
    else {
        CGRect frame = CGRectMake(0,
                                  self.view.frame.origin.y,
                                  self.view.frame.size.width,
                                  self.view.frame.size.height);
        [self animationWithFrame:frame withCompletionBlock:block];
    }
    
    if ([topVC respondsToSelector:@selector(menuDidClose)]) {
        [(UIViewController<LRSlideMenuDelegate> *)topVC menuDidClose];
    }
}

/**
 * Animation method of open/close operation.
 *
 * @param frame new rect of top view
 * @param block animation completion block.
 */
-(void)animationWithFrame:(CGRect)frame withCompletionBlock:(void(^)(void))block {
    
    [UIView animateWithDuration:_slideMenuDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                        self.view.frame = frame;
                    } completion:^(BOOL finished) {
                        if (finished) {
                            if (block) {
                                block();
                            }
                        }
     }];
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UINavigationController Delegate Method
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([viewController respondsToSelector:@selector(LRSlideMenuHasLeftMenu)] &&
        [(UIViewController<LRSlideMenuDelegate> *)viewController LRSlideMenuHasLeftMenu]) {
        viewController.navigationItem.leftBarButtonItem = [self menuButton:LRSlideMenuLeft];
        self.navigationItemRef = viewController.navigationItem;
    }
    
    //0L: was LRSlideMenuHasLeftMenu  maybe intentional ???
    if ([viewController respondsToSelector:@selector(LRSlideMenuHasRightMenu)] &&
        [(UIViewController<LRSlideMenuDelegate> *)viewController LRSlideMenuHasRightMenu]) {
        viewController.navigationItem.rightBarButtonItem = [self menuButton:LRSlideMenuRight];
    }
}

-(NSArray *)popToRootViewControllerAnimated:(BOOL)animated {
    if ([self isMenuOpen]) {
        [self closeMenuWithCompletionBlock:^{
            [super popToRootViewControllerAnimated:animated];
        }];
    }
    else {
        return [super popToRootViewControllerAnimated:animated];
    }
    return nil;
}

-(NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([self isMenuOpen]) {
        [self closeMenuWithCompletionBlock:^{
            [self popToViewController:viewController animated:animated];
        }];
    }
    else {
        return [super popToViewController:viewController animated:animated];
    }
    
    return nil;
}

-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([self isMenuOpen]) {
        [self closeMenuWithCompletionBlock:^{
            [super pushViewController:viewController animated:animated];
        }];
    }
    else {
        [super pushViewController:viewController animated:animated];
    }
}

//////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Gesture
#pragma mark -
//////////////////////////////////////////////////////////////////////////////////////
/**
 * Create tap gesture recognizer
 *
 * @return UITapGestureRecognizer instance
 */
- (UITapGestureRecognizer *)tapRecognizer
{
	if (!_tapRecognizer)
	{
		_tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected:)];
	}
	
	return _tapRecognizer;
}

/**
 * Create pan gesture recognizer
 *
 * @return UIPanGestureRecognizer instance
 */
- (UIPanGestureRecognizer *)panRecognizer
{
	if (!_panRecognizer)
	{
		_panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panDetected:)];
	}
	
	return _panRecognizer;
}

/**
 * Tap event handler.
 *
 * @param tapRecognizer event sender
 */
- (void)tapDetected:(UITapGestureRecognizer *)tapRecognizer
{
	[self closeMenuWithCompletionBlock:^{
        
    }];
}

/**
 * Tap event handler.
 *
 * @param aPanRecognizer event sender
 */
- (void)panDetected:(UIPanGestureRecognizer *)aPanRecognizer
{
	CGPoint translation = [aPanRecognizer translationInView:aPanRecognizer.view];
    CGPoint velocity = [aPanRecognizer velocityInView:aPanRecognizer.view];
    if (aPanRecognizer.state == UIGestureRecognizerStateBegan)
	{
		self.draggingPoint = translation;
    }
	else if (aPanRecognizer.state == UIGestureRecognizerStateChanged)
	{
		NSInteger movement = translation.x - self.draggingPoint.x;
		CGRect rect = self.view.frame;
		rect.origin.x += movement;
		
		if (rect.origin.x >= self.minXForDragging && rect.origin.x <= self.maxXForDragging)
			self.view.frame = rect;
		
		self.draggingPoint = translation;
		
		if (rect.origin.x > 0)
		{
			[self.rightMenu.view removeFromSuperview];
			[self.view.window insertSubview:self.leftMenu.view atIndex:0];
		}
		else
		{
			[self.leftMenu.view removeFromSuperview];
			[self.view.window insertSubview:self.rightMenu.view atIndex:0];
		}
	}
	else if (aPanRecognizer.state == UIGestureRecognizerStateEnded)
	{
        if (self.view.frame.origin.x < 0 && velocity.x >= 0) {
            [self closeMenuWithCompletionBlock:^{
                
            }];
        }
        else if (self.view.frame.origin.x < -0 && self.view.frame.origin.x > (-(self.view.frame.size.width-_menuOpenOffset)) && velocity.x < 0) {
            [self openMenu:LRSlideMenuRight withCompletionBlock:^{
                
            }];
        }
        else if (self.view.frame.origin.x > 0 && self.view.frame.origin.x < self.view.frame.size.width-_menuOpenOffset && velocity.x > 0) {
            [self openMenu:LRSlideMenuLeft withCompletionBlock:^{
                
            }];
        }
        else if (self.view.frame.origin.x < self.view.frame.size.width-_menuOpenOffset && self.view.frame.origin.x > 0 && velocity.x <= 0) {
            [self closeMenuWithCompletionBlock:^{
                
            }];
        }
    }
}

- (NSInteger)minXForDragging
{
	if ([(UIViewController<LRSlideMenuDelegate> *)self.topViewController LRSlideMenuHasRightMenu])
	{
		return (self.view.frame.size.width - _menuOpenOffset)  * -1;
	}
	
	return 0;
}

- (NSInteger)maxXForDragging
{
	if ([(UIViewController<LRSlideMenuDelegate> *)self.topViewController LRSlideMenuHasLeftMenu])
	{
		return self.view.frame.size.width - _menuOpenOffset;
	}
	
	return 0;
}

/**
 * Enable swipe gesture use.
 * @param markEnableSwipeGesture if YES use swipe gesture, else NO.
 */
- (void)setEnableSwipeGesture:(BOOL)markEnableSwipeGesture
{
	_enableSwipeGesture = markEnableSwipeGesture;
	
	if (_enableSwipeGesture)
	{
		[self.view addGestureRecognizer:self.panRecognizer];
	}
	else
	{
		[self.view removeGestureRecognizer:self.panRecognizer];
	}
}

@end
