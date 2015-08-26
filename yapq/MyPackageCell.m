//
//  MyPackageCell.m
//  yapq
//
//  Created by yapQ Ltd on 6/21/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import "MyPackageCell.h"

@implementation MyPackageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(IBAction)deleteAction:(id)sender {
    [self.delegete deleteButtonEvent:self];
}


@end
