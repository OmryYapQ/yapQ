//
//  StoreAbstractCell.h
//  yapq
//
//  Created by yapQ Ltd
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Package.h"
#import "PackageLoader.h"

@protocol StoreButtonEvents <NSObject>

-(void)buyEvent:(id)cell;
-(void)deleteButtonEvent:(id)cell;

@end

@interface StoreAbstractCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *packageImageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *progressLabel;
@property (strong, nonatomic) Package *package;
@property (nonatomic) NSInteger index;

@property id<StoreButtonEvents> delegete;
-(void)cellReset;


@end
