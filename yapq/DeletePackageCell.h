//
//  DeletePackageCell.h
//  yapq
//
//  Created by yapQ Ltd on 5/23/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import "StoreAbstractCell.h"

@interface DeletePackageCell : StoreAbstractCell

@property (strong, nonatomic) IBOutlet UIButton *deleteButton;

@property id<StoreButtonEvents> delegete;

@end
