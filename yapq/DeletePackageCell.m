//
//  DeletePackageCell.m
//  yapq
//
//  Created by yapQ Ltd on 5/23/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import "DeletePackageCell.h"

@implementation DeletePackageCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)cellReset {
    
}

-(void)awakeFromNib {
    [super awakeFromNib];
    _deleteButton.layer.cornerRadius = 3;
}

-(IBAction)deleteAction:(id)sender {
    [self.delegete deleteButtonEvent:self];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
