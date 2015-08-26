//
//  MenuViewController.m
//  yapq
//
//  Created by yapQ Ltd
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import "MenuViewController.h"

@interface MenuViewController () 

@end

@implementation MenuViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.tableView.contentInset = UIEdgeInsetsMake(64.0f, 0.0f, 0.0f, 60.0f);
    
    //self.edgesForExtendedLayout = UIRectEdgeNone;
    //self.extendedLayoutIncludesOpaqueBars = NO;
    //self.automaticallyAdjustsScrollViewInsets = NO;
    
    //self.tableView.frame = CGRectMake(self.tableView.frame.origin.x,
    //                                  self.tableView.frame.origin.y,
    //                                  self.tableView.frame.size.width,
    //                                  self.tableView.frame.size.height);
    
    _navigationBar.frame = CGRectMake(0, 0, 320, 64);
    CALayer *border = [CALayer layer];
    border.borderColor = [Utilities colorWith255StyleRed:245 green:245 blue:245 alpha:1.0].CGColor;
    border.borderWidth = 1;
    CALayer *layer = _navigationBar.layer;
    border.frame =  (CGRect){0, layer.bounds.size.height, layer.bounds.size.width, 0.5};
    [layer addSublayer:border];
    
    _menuStructure = @{NSLocalizedString(@"Speech Languages",nil): AVALIABLE_LANGS_IOS7,
                       NSLocalizedString(@"Other",nil): @[NSLocalizedString(@"Term & Conditions", nil),NSLocalizedString(@"About", nil), @"Store",@"Languages"]};
}

-(void)viewDidAppear:(BOOL)animated {
    /*if ([[Settings sharedSettings].speechLanguage isEqualToString:tSpeechEnglish]) {
        [self checkRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    }
    else {
        [self checkRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
    }*/
}

-(void)viewWillDisappear:(BOOL)animated {
    self.navigationItem.title = @"";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [[_menuStructure allKeys] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) { // Section with inner table
        return 1;       // Languages
    }
    return [[_menuStructure objectForKey:[[_menuStructure allKeys] objectAtIndex:section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    // Languages
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CellCheck" forIndexPath:indexPath];
        ((MenuTableViewCell*)cell).innerTableData = [_menuStructure objectForKey:[[_menuStructure allKeys] objectAtIndex:indexPath.section]];
        
        return cell;
    }
    // Other
    else if (indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CellItem" forIndexPath:indexPath];
    }
    @autoreleasepool {
        cell.textLabel.text = [[_menuStructure objectForKey:[[_menuStructure allKeys] objectAtIndex:indexPath.section]]objectAtIndex: indexPath.row];
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(15, cell.frame.size.height-1, 245, 1)];
        v.backgroundColor = [UIColor colorWithRed:228./255. green:228./255. blue:228./255. alpha:1.0];
        [cell addSubview:v];
    }
    
    // Configure the cell...
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Languages
    if (indexPath.section == 0) {
        return (35*[[_menuStructure objectForKey:[[_menuStructure allKeys] objectAtIndex:0]] count])+20;
    }
    // Other
    return 44;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == [_menuStructure allKeys].count - 1) {
        return @"";
    }
    return [[_menuStructure allKeys] objectAtIndex:section];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Choose language
    UIViewController *vc = nil;
    /*if (indexPath.section == 0) {
        if (![[Settings sharedSettings].speechLanguage isEqualToString:[[Settings sharedSettings] languageWithIndex:(int)indexPath.row]]) {
            [((PlacesTableViewController *)[LRSlideMenuController sharedInstance].topViewController) prepareToChangeLanguage];
            [self checkRowAtIndexPath:indexPath];
            [((PlacesTableViewController *)[LRSlideMenuController sharedInstance].topViewController) reloadLanguage];
        }
        [[LRSlideMenuController sharedInstance] openMenuItemViewController:vc withCompletionBlock:nil];
    }
    else*/
    if (indexPath.section == 1) {
        
        /*if (indexPath.row == 0) {
            //vc = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeVC"];
            vc = nil;
            [[LRSlideMenuController sharedInstance] openMenuItemViewController:vc withCompletionBlock:^{
                [((PlacesTableViewController *)[LRSlideMenuController sharedInstance].topViewController) enterBackground:nil];
                [((PlacesTableViewController *)[LRSlideMenuController sharedInstance].topViewController) enterForeground:nil];
            }];
        }
        else */if (indexPath.row == 0){
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AboutVC"];
            ((WebViewController *)vc).urlToView = TermCondition_API;
            [[LRSlideMenuController sharedInstance] closeMenuWithCompletionBlock:^{
                [((PlacesTableViewController *)[LRSlideMenuController sharedInstance].topViewController) presentViewController:vc animated:YES completion:nil];
            }];
            
            //[[LRSlideMenuController sharedInstance] openMenuItemViewController:vc withCompletionBlock:nil];
        }
        else if (indexPath.row == 1) {
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AboutVC"];
            ((WebViewController *)vc).urlToView = ABOUT_API;
            [[LRSlideMenuController sharedInstance] closeMenuWithCompletionBlock:^{
                [((PlacesTableViewController *)[LRSlideMenuController sharedInstance].topViewController) presentViewController:vc animated:YES completion:nil];
            }];
        }
        else if (indexPath.row == 2) {
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PackageStoreVC"];
            [[LRSlideMenuController sharedInstance] closeMenuWithCompletionBlock:^{
                [[LRSlideMenuController sharedInstance] pushViewController:vc animated:YES];
                //[((PlacesTableViewController *)[LRSlideMenuController sharedInstance].topViewController) presentViewController:vc animated:YES completion:nil];
                
            }];
        }
        else if (indexPath.row == 3) {
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LangVC"];
            [[LRSlideMenuController sharedInstance] closeMenuWithCompletionBlock:^{
                [[LRSlideMenuController sharedInstance] pushViewController:vc animated:YES];
                //[((PlacesTableViewController *)[LRSlideMenuController sharedInstance].topViewController) presentViewController:vc animated:YES completion:nil];
                
            }];
        }
        
    }
    
}

-(void)checkRowAtIndexPath:(NSIndexPath *)indexPath {
    
    for (int i=0;i<[self.tableView numberOfRowsInSection:0]; i++) {
        [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]].accessoryType = UITableViewCellAccessoryNone;
    }
    [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:indexPath.row inSection:0]].accessoryType = UITableViewCellAccessoryCheckmark;
    Settings *settings = [Settings sharedSettings];
    [settings saveParameterForKey:kSpeechLanguage andValue:[settings languageWithIndex:(int)indexPath.row]];
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
