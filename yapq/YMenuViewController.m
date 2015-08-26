//
//  YMenuViewController.m
//  yapq
//
//  Created by yapQ Ltd on 6/21/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import "YMenuViewController.h"
#import "tToken.h"

@interface YMenuViewController ()

@end

@implementation YMenuViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    /*_navigationBar.frame = CGRectMake(0, 0, 320, 64);
    CALayer *border = [CALayer layer];
    border.borderColor = [Utilities colorWith255StyleRed:238 green:243 blue:236 alpha:1.0].CGColor;
    border.borderWidth = 1;
    CALayer *layer = _navigationBar.layer;
    border.frame =  (CGRect){0, layer.bounds.size.height, layer.bounds.size.width, 0.5};
    [layer addSublayer:border];*/
    
    //_menuTableView.hidden = YES;
    //[_menuTableView bringSubviewToFront:self.view];
//    [[NSBundle mainBundle] localizedStringForKey:@"" value:@"" table:nil];
//    _imageNames = @[@"lang-icon",@"account-icon",@"gps-icon",@"settings-icon",@"sendToFriend",@"help-icon"];
//    _menuStructure = @[NSLocalizedString(@"change_language_menu", @""),NSLocalizedString(@"account_menu",nil),NSLocalizedString(@"offline_menu",nil),NSLocalizedString(@"settings_menu",nil),NSLocalizedString(@"send_to_friend", nil),NSLocalizedString(@"help_menu",nil)];
    [self setLocalization];
}

-(void)setLocalization{

    _imageNames = @[@"lang-icon",@"account-icon",@"gps-icon",@"settings-icon",@"sendToFriend",@"help-icon"];
    _menuStructure = @[NSLocalizedString(@"change_language_menu", @""),NSLocalizedString(@"account_menu",nil),NSLocalizedString(@"offline_menu",nil),NSLocalizedString(@"settings_menu",nil),NSLocalizedString(@"send_to_friend", nil),NSLocalizedString(@"help_menu",nil)];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _menuStructure.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"CellItem";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    cell.textLabel.text = _menuStructure[indexPath.row];
    cell.textLabel.font = [Utilities RobotoLightFontWithSize:18];
    cell.imageView.image = [UIImage imageNamed:_imageNames[indexPath.row]];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 50;
}
/*
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == [_menuStructure allKeys].count - 1) {
        return @"";
    }
    return [[_menuStructure allKeys] objectAtIndex:section];
    return @"";
}
*/
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Choose language
    UIViewController *vc = nil;
    if (indexPath.row == 0) { // Languages
        vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LangVC"];
        [[LRSlideMenuController sharedInstance] closeMenuWithCompletionBlock:^{
            [[LRSlideMenuController sharedInstance] pushViewController:vc animated:YES];
        }];
    }
    else if (indexPath.row == 1) { // Account
        vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AccountVC"];
        [[LRSlideMenuController sharedInstance] closeMenuWithCompletionBlock:^{
            [[LRSlideMenuController sharedInstance] pushViewController:vc animated:YES];
        }];
    }
    else if (indexPath.row == 2) { // Package Store
        vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PackageStoreVC"];
        [[LRSlideMenuController sharedInstance] closeMenuWithCompletionBlock:^{
            [[LRSlideMenuController sharedInstance] pushViewController:vc animated:YES];
        }];
    }
    else if (indexPath.row == 3) { // Settings
        vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsVC"];
        [[LRSlideMenuController sharedInstance] closeMenuWithCompletionBlock:^{
            [[LRSlideMenuController sharedInstance] pushViewController:vc animated:YES];
        }];
    }
    else if (indexPath.row == 4) { // Settings
        //vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsVC"];
        [[LRSlideMenuController sharedInstance] closeMenuWithCompletionBlock:^{
            if(![MFMessageComposeViewController canSendText]) {
                UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [warningAlert show];
                return;
            }
            
            NSString *message = @"Just because I love you, Here's a free offline package coupon to use in yapQ app: 8156. Get the app on http://get.yapq.com";
            
            MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
            messageController.messageComposeDelegate = self;
            [messageController setBody:message];
            
            // Present message view controller on screen
            [[LRSlideMenuController sharedInstance] presentViewController:messageController animated:YES completion:nil];
            saveEvent(@"sendToAFriend");
        }];
    }
    else if (indexPath.row == 5) { // About
        vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AboutVC"];
        ((WebViewController *)vc).urlToView = ABOUT_API;
        [[LRSlideMenuController sharedInstance] closeMenuWithCompletionBlock:^{
            [[LRSlideMenuController sharedInstance] pushViewController:vc animated:YES];
        }];
    }
        
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [controller dismissViewControllerAnimated:YES completion:nil];
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

@implementation YMenuView

-(void)drawRect:(CGRect)rect {
    
    CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
    gradientLayer.colors = @[(id)[Utilities colorWith255StyleRed:234 green:233 blue:231 alpha:1.0].CGColor,
                             (id)[Utilities colorWith255StyleRed:228 green:226 blue:214 alpha:1.0].CGColor,
                             (id)[Utilities colorWith255StyleRed:235 green:221 blue:212 alpha:1.0].CGColor
                             ];
    gradientLayer.frame = self.bounds;
    [self.layer insertSublayer:gradientLayer atIndex:0];
    /*CGFloat colors [] = {
        241.0/255., 241./255., 239./255., 1.0,
        226.0/255., 221./255., 215./255., 1.0
    };
    CGFloat locations[] = {
      0.4,0.6
    };
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, locations, 2);
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //CGContextSaveGState(context);
    //CGContextAddEllipseInRect(context, rect);
    //CGContextClip(context);
    
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient), gradient = NULL;
    
    //CGContextRestoreGState(context);
    
    //CGContextAddEllipseInRect(context, rect);
    //CGContextDrawPath(context, kCGPathStroke);*/
    
}

@end
