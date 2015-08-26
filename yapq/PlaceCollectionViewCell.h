//
//  PlaceCollectionViewCell.h
//  PlaceCollectionViewCell
//
//  Created by 0L 2015-07-28.
//  Copyright (c) 2015 yapQ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionViewCustomLayout : UICollectionViewFlowLayout

@end

@interface AFIndexedCollectionView : UICollectionView<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end


static NSString *CollectionViewCellIdentifier = @"CollectionViewCellIdentifier";

@interface PlaceCollectionViewCell : UITableViewCell {
    NSInteger numberOfCells;
}

@property (strong, nonatomic) IBOutlet AFIndexedCollectionView *collectionView;
@property (strong, nonatomic) IBOutlet CollectionViewCustomLayout *customCollectionViewLayout;
@property NSInteger currentCellIndex;

//- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath;
-(void)setData:(NSMutableArray *)dataArray andIndexPath:(NSIndexPath *)indexPath;

@end
