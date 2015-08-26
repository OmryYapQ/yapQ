//
//  MyPackageAbstractCell.h
//  yapq
//
//  Created by yapQ Ltd on 6/27/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Package.h"
#import "PackageLoader.h"

@protocol MyPackageCellEvents <NSObject>

-(void)downloadButtonEvent:(id)sender;
-(void)deleteButtonEvent:(id)sender;

@end

@interface MyPackageAbstractCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *progressLabel;
@property (strong, nonatomic) Package *package;
@property (nonatomic) NSInteger index;

@property id<MyPackageCellEvents> delegete;
-(void)cellReset;

@end
