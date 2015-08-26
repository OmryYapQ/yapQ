//
//  SearchViewController.m
//  yapq
//
//  Created by Omry Levy on 6/4/15.
//  Copyright (c) 2015 yapQ . All rights reserved.
//

#import "SearchViewController.h"
#import "SQLiteDBManager.h"
#import "LRSlideMenuController.h"
#import "ServerResponse.h"
#import "Utilities.h"

#define SEARCH_BAR_H            44
#define YELLOW_LINE_H           8
#define MAX_SEARCH_NUM_CHARS    26

@interface MyUISearchBar : UISearchBar {
    
}
@end
@implementation MyUISearchBar
-(void)setShowsCancelButton:(BOOL)showsCancelButton {
    // Do nothing...
}

-(void)setShowsCancelButton:(BOOL)showsCancelButton animated:(BOOL)animated {
    // Do nothing....
}
@end

@interface MyUISearchController : UISearchController<UISearchBarDelegate> {
    UISearchBar *_searchBar;
}
@end
@implementation MyUISearchController

-(UISearchBar *)searchBar {
    if (_searchBar == nil) {
        _searchBar = [[MyUISearchBar alloc] initWithFrame:CGRectZero];
        _searchBar.delegate = self;
    }
    return _searchBar;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchBar.text length] > 0) {
        self.active = true;
    } else {
        self.active = false;
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)setShowsCancelButton:(BOOL)showsCancelButton {
    // Do nothing...
}

-(void)setShowsCancelButton:(BOOL)showsCancelButton animated:(BOOL)animated {
    // Do nothing....
}

@end

@interface SearchViewController () {
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *arrFilterd;
@property (strong, nonatomic) IBOutlet UIView *VCView;
@property (strong, nonatomic) NSMutableDictionary *dictFilter;

@end

@implementation SearchViewController


//TODO: hide the cancel button in iOS 7
//TODO: hide the search gray UI in iOS 7

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 8.0) {
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        
        // Above ios 8.0
        self.searchController = [[MyUISearchController alloc] initWithSearchResultsController:nil];
        
        // The searchcontroller's searchResultsUpdater property will contain our tableView.
        self.searchController.searchResultsUpdater = self;
        
        // this will allow the scrolling if the underneath table
        self.searchController.dimsBackgroundDuringPresentation = NO;
        
        self.searchController.searchBar.delegate = self;
        self.searchController.searchBar.backgroundColor = UIColor.whiteColor;
        
        self.searchController.searchBar.frame = CGRectMake(
                                                           0,
                                                           8, // height of yellow line
                                                           320 - 40,
                                                           44.0);
        
        
        [self.view addSubview:self.searchController.searchBar];
    
        // for iOS 6+
        [self.searchController.searchBar setBackgroundColor:[UIColor whiteColor]];
        [self.searchController.searchBar setBackgroundImage:[UIImage new]];
        [self.searchController.searchBar setTranslucent:YES];
        self.searchController.searchBar.placeholder = @"Where do you wanna go?";
        
        UITextField *searchField = [self.searchController.searchBar valueForKey:@"_searchField"];
        searchField.textAlignment = NSTextAlignmentLeft;
        searchField.font = [UIFont fontWithName:@"Roboto-Light" size:17];
        searchField.clearButtonMode = UITextFieldViewModeNever;
        [searchField adjustsFontSizeToFitWidth];
        //searchField.backgroundColor = UIColor.yellowColor;
    }
    else {
        UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(
                                                                              0,
                                                                              8, // height of yellow line
                                                                              320 - 40,
                                                                              44.0)];
        self.__searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
        
        searchBar.delegate = self;
        searchBar.backgroundColor = UIColor.whiteColor;
        searchBar.showsCancelButton = NO;
        [self.view addSubview:searchBar];
        
        // The searchcontroller's searchResultsUpdater property will contain our tableView.
        self.__searchDisplayController.searchResultsDataSource = self;
        self.__searchDisplayController.searchResultsDelegate = self;
        
        
        // for iOS 6+
        [searchBar setBackgroundColor:[UIColor whiteColor]];
        [searchBar setBackgroundImage:[UIImage new]];
        [searchBar setTranslucent:YES];
        searchBar.placeholder = @"Where do you wanna go?";
        
        UITextField *searchField = [searchBar valueForKey:@"_searchField"];
        searchField.textAlignment = NSTextAlignmentLeft;
        searchField.font = [UIFont fontWithName:@"Roboto-Light" size:17];
        searchField.clearButtonMode = UITextFieldViewModeNever;
        [searchField adjustsFontSizeToFitWidth];
        //searchField.backgroundColor = UIColor.yellowColor;
        self.__searchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    //self.tableView.backgroundColor = UIColor.yellowColor;
    
    //self.definesPresentationContext = YES;
    
    self.arrFilterd = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil]
        setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],NSForegroundColorAttributeName,nil]
                                                                                        forState:UIControlStateNormal];
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 8)];
    v.backgroundColor = [UIColor colorWithRed:255/255.0f green:237/255.0f blue:0 alpha:1];
    [self.VCView addSubview:v];
    
    UIImage *image = [UIImage imageNamed:@"close-btn"];
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - image.size.width - 15,
                                                                       22,
                                                                       image.size.width,
                                                                       image.size.height)];
    [closeButton setImage:image forState:UIControlStateNormal];
    [closeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(searchBarCancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.VCView addSubview:closeButton];
}



- (void)keyboardWillShow:(NSNotification*)notification {
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 8.0) {
        self.searchController.searchBar.showsCancelButton = NO;
    }
    else {
        self.__searchDisplayController.searchBar.showsCancelButton = NO;
    }
    
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    self.tableView.frame = CGRectMake(0,
                                      44,
                                      [UIScreen mainScreen].bounds.size.width,
                                      [UIScreen mainScreen].bounds.size.height - 44 - kbSize.height);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    return; // doesn't get called
    //make sure model has only results that correspond to the search
    [self updateFilteredContentWithSearchText:[self.searchController.searchBar text]];
    
    //update the table now that the model has been updated
    [self.tableView reloadData];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    //make sure model has only results that correspond to the search
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 8.0) {
        [self updateFilteredContentWithSearchText:[self.searchController.searchBar text]];
    }
    else {
        [self updateFilteredContentWithSearchText:[self.__searchDisplayController.searchBar text]];
    }
    
    _results = YES;
    
    //update the table now that the model has been updated
    [self.tableView reloadData];
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return ([searchBar.text length] + [text length] - range.length <= MAX_SEARCH_NUM_CHARS);
}

- (void)updateFilteredContentWithSearchText:(NSString*)searchText
{
    [self.arrFilterd removeAllObjects];
    self.dictFilter = [[SQLiteDBManager sharedInstance] getDB:nil countriesBySearchString:searchText];
    
    if (self.dictFilter != NULL) {
        for (NSString *s in self.dictFilter.allValues) {
            [self.arrFilterd addObject:s];
        }
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_results) {
        _results = NO;
        
        if (self.arrFilterd.count == 0) {
            return 1;
        }
        else {
            return self.arrFilterd.count;
        }
    }
    else {
        return self.arrFilterd.count;
    }
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.arrFilterd.count == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                           reuseIdentifier:@"SearchCountries"];
        cell.textLabel.font = [UIFont fontWithName:@"Roboto-Light" size:30];
        cell.textLabel.textColor = UIColor.lightGrayColor;
        cell.textLabel.text = @"Nothing found";
        return cell;
    }
    else {
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SearchCountries"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:@"SearchCountries"];
        }
        
        cell.textLabel.font = [UIFont fontWithName:@"Roboto-Light" size:30];
        cell.textLabel.textColor = UIColor.blackColor;
        
        NSString *searchString = NULL;
        float version = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (version >= 8.0) {
            searchString = self.searchController.searchBar.text;
        }
        else {
            searchString = self.__searchDisplayController.searchBar.text;
        }
        
        NSString *txt = [self.arrFilterd objectAtIndex:indexPath.row];

        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:txt];
        NSRange range = [txt rangeOfString:searchString options:NSCaseInsensitiveSearch];
        
        if (range.length != 0) {
            [attributedString addAttribute: NSFontAttributeName value:[UIFont fontWithName:@"Roboto-Bold" size:30] range:range];
            cell.textLabel.text = @"";
            cell.textLabel.attributedText = attributedString;
        }
        else {
            cell.textLabel.attributedText = nil;
            cell.textLabel.text = txt;
        }
        
        return cell;
    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.view.userInteractionEnabled = NO;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (NULL != cell) {
        NSString *valToFind = cell.textLabel.text;
        
        for (NSNumber *key in self.dictFilter) {
            NSString *val = self.dictFilter[key];

            if ([val compare:valToFind] == NSOrderedSame) {
                // set the search Id for the request
                float version = [[[UIDevice currentDevice] systemVersion] floatValue];
                if (version >= 8.0) {
                    [self.searchController.searchBar resignFirstResponder];
                }
                else {
                    [self.__searchDisplayController.searchBar resignFirstResponder];
                }
                
                [ServerResponse sharedResponse].searchId = key;
                [[LRSlideMenuController sharedInstance] closeMenuWithCompletionBlock:nil];
                [self dismissViewControllerAnimated:YES completion:nil];
                break;
            }
        }
    }
}

//-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
-(void)searchBarCancelButtonClicked {
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 8.0) {
        [self.searchController.searchBar resignFirstResponder];
    }
    else {
        [self.__searchDisplayController.searchBar resignFirstResponder];
    }

    [[LRSlideMenuController sharedInstance] closeMenuWithCompletionBlock:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version < 8.0) {
        self.__searchDisplayController.searchBar.showsCancelButton = NO;
    }
}

@end
