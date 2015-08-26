//
//  LanguagesViewController.m
//  yapq
//
//  Created by yapQ Ltd on 6/21/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import "LanguagesViewController.h"


@interface LanguagesViewController ()

@end

@implementation LanguagesViewController

-(BOOL)LRSlideMenuHasLeftMenu {
    return NO;
}

-(BOOL)LRSlideMenuHasRightMenu {
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _listOfLanguages = [Settings avaliableLanguagesNative];

}

-(void)viewWillAppear:(BOOL)animated {
    [self isNeedSetupInsets];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _listOfLanguages.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"LangCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    cell.textLabel.text = _listOfLanguages[indexPath.row];
    cell.textLabel.font = [Utilities RobotoLightFontWithSize:18];
    if ([[Settings sharedSettings].speechLanguage isEqualToString:[[Settings sharedSettings] languageWithIndex:(int)indexPath.row]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //[self checkRowAtIndexPath:indexPath];
    if (![[Settings sharedSettings].speechLanguage isEqualToString:[[Settings sharedSettings] languageWithIndex:(int)indexPath.row]]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:LANGUAGE_CHANGE_NOTIFICATION_KEY
                                                            object:self
                                                          userInfo:@{LANGUAGE_CHANGE_STATE_KEY: [NSNumber numberWithInteger:LanguageChangeStatePrepare]}];
        [self checkRowAtIndexPath:indexPath];
        [[NSNotificationCenter defaultCenter] postNotificationName:LANGUAGE_CHANGE_NOTIFICATION_KEY
                                                            object:self
                                                          userInfo:@{LANGUAGE_CHANGE_STATE_KEY: [NSNumber numberWithInteger:LanguageChangeStateReload]}];
    }

    
    //[[LRSlideMenuController sharedInstance] openMenuItemViewController:nil withCompletionBlock:nil];
    [self.navigationController popViewControllerAnimated:YES];

}

-(void)checkRowAtIndexPath:(NSIndexPath *)indexPath {
    
    for (int i=0;i<[self.tableView numberOfRowsInSection:0]; i++) {
        [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]].accessoryType = UITableViewCellAccessoryNone;
    }
    [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:indexPath.row inSection:0]].accessoryType = UITableViewCellAccessoryCheckmark;
    Settings *settings = [Settings sharedSettings];
    [settings saveParameterForKey:kSpeechLanguage andValue:[settings languageWithIndex:(int)indexPath.row]];
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


@end
