//
//  StoreAbstractCell.m
//  yapq
//
//  Created by yapQ Ltd
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import "StoreAbstractCell.h"

@implementation StoreAbstractCell

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
    CALayer *border = [CALayer layer];
    border.borderColor = [Utilities colorWith255StyleRed:228 green:228 blue:228 alpha:1.0].CGColor;
    border.borderWidth = 1;
    CALayer *layer = self.layer;
    border.frame =  (CGRect){0, layer.bounds.size.height-1, layer.bounds.size.width, 1};
    [layer addSublayer:border];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(void)cellReset{}

@end
