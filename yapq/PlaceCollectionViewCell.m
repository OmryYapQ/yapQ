//
//  PlaceCollectionViewCell.m
//  PlaceCollectionViewCell
//
//  Created by 0L 2015-07-28.
//  Copyright (c) 2015 yapQ. All rights reserved.
//

#import "PlaceCollectionViewCell.h"
#import "Place.h"
#import "SettingsPlace.h"
#import "OfflinePlace.h"
#import "DBPlace.h"
#import "SwipePlaceFirstCell.h"
#import "SinglePlaceCell.h"
#import "SettingsCollectionCell.h"
#import "SwipeCollectionFirstCell.h"

@implementation CollectionViewCustomLayout

@end

@implementation AFIndexedCollectionView

#pragma mark - UICollectionViewDataSource Methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //reusing is a bit tricky since there are many types and they are not the same
    id cellData = [self.dataArray objectAtIndex:indexPath.row];
    Class cellDataClass = [cellData class];
    
    if (cellDataClass == [Place class]) {
        //static NSString *placeCellIdentifier = @"PlaceViewCell";
        // the collection cell is used by many types: settings, offline, one cell, swiped cells etc....
        SinglePlaceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SinglePlaceCell"
                    forIndexPath:indexPath];
        
        if (cell == nil) {
            cell = [[SinglePlaceCell alloc] initWithFrame:self.frame];
        }
        
        
        Place *p = (Place *)cellData;
        [cell setPlace:p];
        //0L:TODO: [cell setVCDelegate:self];
        // //NSLog(@"%@, %i",p.title,p.isPlaying);
        return cell;
    }
    else if (cellDataClass == [OfflinePlace class]) {
        int k = 0;
        ++k;
    }
    else if (cellDataClass == [SettingsPlace class]) {
        SettingsCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SettingsCollectionCell"
                                                                          forIndexPath:indexPath];
        
        if (cell == nil) {
            cell = [[SettingsCollectionCell alloc] initWithFrame:self.frame];
        }
        
        SettingsPlace *p = (SettingsPlace *)cellData;
        [cell setPlace:p];
        //0L:TODO: [cell setVCDelegate:self];
        return cell;
    }
    else if (cellDataClass == [SwipePlaceFirstCell class]) {
        SwipeCollectionFirstCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SwipeCollectionFirstCell"
                                                                                     forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[SwipeCollectionFirstCell alloc] initWithFrame:self.frame];
        }
        
        SwipePlaceFirstCell *p = (SwipePlaceFirstCell *)cellData;
        [cell setPlace:p];
        cell.backgroundColor = UIColor.yellowColor;
        //0L:TODO: [cell setVCDelegate:self];
        return cell;

    }
    
    
    SinglePlaceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SinglePlaceCell"
                                                                      forIndexPath:indexPath];
    return cell;
}

@end

@implementation PlaceCollectionViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    //never get called !
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self != nil) {
        
    }

    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    
    UISwipeGestureRecognizer *swipeLGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeRight:)];
    swipeLGR.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:swipeLGR];
    
    UISwipeGestureRecognizer *swipeRGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeLeft:)];
    swipeRGR.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:swipeRGR];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    self.collectionView.frame = self.contentView.bounds;
}

-(void)setData:(NSMutableArray *)dataArray andIndexPath:(NSIndexPath *)indexPath
{
    /*
    // the collection type dictates the height of the collection cell
    CGSize szCollectionCell;
    
    id cellData = [dataArray objectAtIndex:0];
    Class cellDataClass = [cellData class];
    
    if (cellDataClass == [Place class]) {
        szCollectionCell = CGSizeMake(320, 385);
    }
    else if (cellDataClass == [OfflinePlace class]) {
        szCollectionCell = CGSizeMake(320, 385);
    }
    else if (cellDataClass == [SettingsPlace class]) {
        szCollectionCell = CGSizeMake(320, 200);
    }
    else if (cellDataClass == [SwipePlaceFirstCell class]) {
        szCollectionCell = CGSizeMake(320, 385);
    }
    */
    
    self.customCollectionViewLayout.sectionInset = UIEdgeInsetsMake(0 , 0, 0, 0); // t l b r
    self.customCollectionViewLayout.itemSize = self.bounds.size; // szCollectionCell;
    self.customCollectionViewLayout.minimumInteritemSpacing = 0;
    self.customCollectionViewLayout.minimumLineSpacing = 0;
    self.customCollectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    
    numberOfCells = dataArray.count;
    self.collectionView.dataSource = self.collectionView;
    self.collectionView.delegate = self.collectionView;
    self.collectionView.indexPath = indexPath;
    self.collectionView.dataArray = dataArray;
    [self.collectionView reloadData];
}

-(void)onSwipeLeft:(UISwipeGestureRecognizer *)gr {
    if (self.currentCellIndex == 0) {
        return;
    }
    
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentCellIndex - 1
        inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    --self.currentCellIndex;
}
-(void)onSwipeRight:(UISwipeGestureRecognizer *)gr {
    if ((self.currentCellIndex + 1) == numberOfCells) {
        return;
    }
    
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentCellIndex + 1
                                        inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    ++self.currentCellIndex;
}

@end
