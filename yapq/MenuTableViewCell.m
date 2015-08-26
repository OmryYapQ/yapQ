//
//  MenuTableViewCell.m
//  yapq
//
//  Created by yapQ Ltd
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import "MenuTableViewCell.h"

@implementation MenuTableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(void)awakeFromNib {
    _innerTable.backgroundColor = [UIColor clearColor];
    self.separatorInset = UIEdgeInsetsMake(0, 260, 0, 200);
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _innerTableData.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [_innerTable dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = [_innerTableData objectAtIndex:indexPath.row];
    //cell.contentView.frame = CGRectMake(5, cell.frame.origin.y, cell.frame.size.width-10, cell.frame.size.height);
    if ([[Settings sharedSettings].speechLanguage isEqualToString:[[Settings sharedSettings] languageWithIndex:(int)indexPath.row]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.backgroundColor = [UIColor colorWithRed:241./255. green:243./255. blue:94./255. alpha:1.0];
    }
    else {
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = [UIColor colorWithRed:228./255. green:228./255. blue:228./255. alpha:1.0];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //[self checkRowAtIndexPath:indexPath];
    if (![[Settings sharedSettings].speechLanguage isEqualToString:[[Settings sharedSettings] languageWithIndex:(int)indexPath.row]]) {
        [((PlacesTableViewController *)[LRSlideMenuController sharedInstance].topViewController) prepareToChangeLanguage];
        [self checkRowAtIndexPath:indexPath];
        [((PlacesTableViewController *)[LRSlideMenuController sharedInstance].topViewController) reloadLanguage];
    }
    [[LRSlideMenuController sharedInstance] openMenuItemViewController:nil withCompletionBlock:nil];
}

-(void)checkRowAtIndexPath:(NSIndexPath *)indexPath {
    
    for (int i=0;i<[self.innerTable numberOfRowsInSection:0]; i++) {
        [self.innerTable cellForRowAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]].accessoryType = UITableViewCellAccessoryNone;
        [self.innerTable cellForRowAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]].backgroundColor = [UIColor colorWithRed:228./255. green:228./255. blue:228./255. alpha:1.0];
    }
    [self.innerTable cellForRowAtIndexPath:[NSIndexPath indexPathForItem:indexPath.row inSection:0]].accessoryType = UITableViewCellAccessoryCheckmark;
    [self.innerTable cellForRowAtIndexPath:[NSIndexPath indexPathForItem:indexPath.row inSection:0]].backgroundColor = [UIColor colorWithRed:241./255. green:243./255. blue:94./255. alpha:1.0];
    Settings *settings = [Settings sharedSettings];
    [settings saveParameterForKey:kSpeechLanguage andValue:[settings languageWithIndex:(int)indexPath.row]];
}

@end
