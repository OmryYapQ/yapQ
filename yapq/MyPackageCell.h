//
//  MyPackageCell.h
//  yapq
//
//  Created by yapQ Ltd on 6/21/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Package.h"
#import "MyPackageAbstractCell.h"

@interface MyPackageCell : MyPackageAbstractCell

@property (strong, nonatomic) IBOutlet UIButton *deleteButton;

@end
