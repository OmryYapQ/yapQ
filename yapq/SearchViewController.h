//
//  SearchViewController.h
//  yapq
//
//  Created by Omry Levy on 6/4/15.
//  Copyright (c) 2015 yapQ . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YViewController.h"

@interface SearchViewController : YViewController<UITableViewDelegate, UITableViewDataSource,
UISearchResultsUpdating, UISearchBarDelegate> {
    BOOL _results;
}

@property (strong, nonatomic) UISearchController *searchController; // iOS 8
@property (strong, nonatomic) UISearchDisplayController *__searchDisplayController; // iOS 7

@end
