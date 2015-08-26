//
//  LRSlideMenuController.h
//  LRSlideMenu
//
//  Created by yapQ Ltd.
//  Copyright (c) 2013 yapQ Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * Enum of two-side menu, left or right menu.
 */
typedef NS_ENUM(NSInteger, LRSlideMenu) {
    LRSlideMenuLeft = 1,
    LRSlideMenuRight
};

/**
 * Default types of menu open or close animation
 *
 * \code
 * LRSlideSpeedFast
 *
 * LRSlideSpeedMedium
 *
 * LRSlideSpeedLow
 * \endcode
 */
#define LRSlideSpeedFast 0.1
#define LRSlideSpeedMedium 0.5
#define LRSlideSpeedLow 0.9
/**
 * Default types of menu open offset
 *
 * \code
 * LRSlideMenuOpenOffset
 * \endcode
 */
#define LRSlideMenuOpenOffset 60.0
/**
 * Default image name of menu button
 *
 * \code
 * LRSLideMenuImageName
 * \endcode
 */
#define LRSLideMenuImageName [[NSBundle bundleForClass:[LRSlideMenuController class]] pathForResource:@"menu_img" ofType:@"png"]//@"menu_img"

/**
 * Menu usage protocol, it's contain's methods of all events of menu
 *
 * - open/close event
 *
 * - choosing item event
 *
 * - option of show hide menu
 */
@protocol LRSlideMenuDelegate <NSObject>

@required
/**
 * Required method of protocol that enabling left menu showing
 *
 * @return YES if menu need to show, NO - don't show
 */
-(BOOL)LRSlideMenuHasLeftMenu;
/**
 * Required method of protocol that enabling right menu showing
 *
 * @return YES if menu need to show, NO - don't show
 */
-(BOOL)LRSlideMenuHasRightMenu;

@optional

/**
 * Method call's before menu opening
 *
 * @param menu left or right menu
 */
-(BOOL)menuWillOpen:(LRSlideMenu)menu;

/**
 * Method call's after menu was opened
 *
 * @param menu left or right menu
 */
-(void)menuDidOpen:(LRSlideMenu)menu;

/**
 * Method call's before menu will close
 *
 */

-(BOOL)menuWillClose:(LRSlideMenu)menu;
/**
 * Method call's after menu was closed
 *
 */
-(void)menuDidClose;

/**
 * Method call's before choose item (ViewController) from menu will be display.
 *
 * @param viewController view controller that will be display,you may use it for sending parameters to it.
 */
-(void)choosenItemWillShow:(UIViewController *)viewController;

/**
 * Method call's after choose item (ViewController) from menu was displayed.
 *
 * @param viewController view controller that was displayed.
 */
-(void)choosenItemDidShow:(UIViewController *)viewController;

@end

/**
 * Class implement special Singlton of UINavigationController for using Left/Right slide menu.
 *
 * @usage You need to impelement it in AppDelegate class in method
 * \code - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions \endcode
 * Example of setup:
 *
 *\code
 * UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
 *
 * MenuViewController *l_mvc = [storyboard instantiateViewControllerWithIdentifier:@"LeftMenu"];
 *
 * MenuViewController *r_mvc = [storyboard instantiateViewControllerWithIdentifier:@"RightMenu"];
 *
 * [LRSlideMenuController sharedInstance].leftMenu = l_mvc;
 *
 * [LRSlideMenuController sharedInstance].rightMenu = r_mvc;
 *\endcode
 * @usage You may also use some optional parameters:
 * \code
 // Speed of open close animation, value from 0.0 to 1.0.
 * [LRSlideMenuController sharedInstance].slideMenuDuration = 0.3;
 *
 // Number of pixels of top view controller will displayed when menu opened.
 * [LRSlideMenuController sharedInstance].menuOpenOffset = 100;
 *
 // Custom menu button image.
 * [LRSlideMenuController sharedInstance].leftImageName = @"left_image"
 *
 // Custom menu button image.
 * [LRSlideMenuController sharedInstance].rightImageName = @"right_image"
 *
 // Using tap gesture for close menu.
 * [LRSlideMenuController sharedInstance].isUseTapClose = YES;
 *
 // Using pan gesture from open/close menu with slide left/right.
 * [[LRSlideMenuController sharedInstance] setEnableSwipeGesture: YES];
 * \endcode
 *
 * Example of using with UITableView:
 * \code
 * -(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 *      UIViewController *vc = nil;
 *      if (indexPath.row == 0) {
 *          vc = [self.storyboard instantiateViewControllerWithIdentifier:@"Item 1"];
 *      }
 *      else if (indexPath.row == 1) {
 *          vc = [self.storyboard instantiateViewControllerWithIdentifier:@"Item 2"];
 *      }
 *
 *      [[LRSlideMenuController sharedInstance] openMenuItemViewController:vc withCompletionBlock:nil];
 *  }
 *\endcode
 */
@interface LRSlideMenuController : UINavigationController <UINavigationControllerDelegate> {
}

@property (assign, nonatomic) float slideMenuDuration;
@property (assign, nonatomic) float menuOpenOffset;
@property (strong, nonatomic) NSString *leftImageName;
@property (strong, nonatomic) NSString *rightImageName;
@property (assign, nonatomic) BOOL isUseTapClose;
@property (nonatomic, assign) BOOL enableSwipeGesture;

@property (strong, nonatomic) UIViewController *leftMenu;
@property (strong, nonatomic) UIViewController *rightMenu;
@property (strong, nonatomic) UIBarButtonItem *leftMenuButton;
@property (strong, nonatomic) UIBarButtonItem *rightMenuButton;

/**
 * Instance of current menu controller
 * @return instance of slide menu
 */
+(LRSlideMenuController *)sharedInstance;

/**
 * Method open's choosen view controller from menu.
 *
 * @param viewController choosen view controller to display.
 * @param block call's when view controller was pushed to navigation controller (was displayed).
 */
-(void)openMenuItemViewController:(UIViewController *)viewController withCompletionBlock:(void(^)(void))block;

-(void)closeMenuWithCompletionBlock:(void(^)(void))block;

-(void)openMenu:(LRSlideMenu)menu withCompletionBlock:(void(^)(void)) block;

@end
