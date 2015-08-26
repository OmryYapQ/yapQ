//
//  LanguagesViewController.h
//  yapq
//
//  Created by yapQ Ltd on 6/21/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "LRSlideMenuController.h"
#import "Settings.h"
#import "ViewInsetsSetupProtocol.h"
#import "Utilities.h"
#import "YViewController.h"

#define LANGUAGE_CHANGE_NOTIFICATION_KEY @"LanguageChange"
#define LANGUAGE_CHANGE_STATE_KEY @"StateKey"

typedef NS_ENUM(NSInteger, LanguageChangeState) {
    LanguageChangeStatePrepare = 0,
    LanguageChangeStateReload = 1
};

@interface LanguagesViewController : YViewController <LRSlideMenuDelegate,UITableViewDataSource,UITableViewDelegate,ViewInsetsSetupProtocol>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *listOfLanguages;
@end
