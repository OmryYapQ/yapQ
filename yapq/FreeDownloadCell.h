//
//  FreeDownloadCell.h
//  yapq
//
//  Created by yapQ Ltd on 6/27/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICircleFilledLoader.h"
#import "MyPackageAbstractCell.h"

@interface FreeDownloadCell : MyPackageAbstractCell

@property (strong, nonatomic) IBOutlet UIButton *downloadButton;
@property (strong, nonatomic) IBOutlet UICircleFilledLoader  *circleLoader;

-(void)setupAsLoading:(PackageLoader *)packageLoader;

@end
