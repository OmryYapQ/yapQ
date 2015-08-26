//
//  MyPackageAbstractCell.m
//  yapq
//
//  Created by yapQ Ltd on 6/27/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import "MyPackageAbstractCell.h"

@implementation MyPackageAbstractCell

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
    
    _titleLabel.font = [Utilities RobotoRegularFontWithSize:17];
    _descriptionLabel.font = [Utilities RobotoRegularFontWithSize:12];
    _progressLabel.font = [Utilities RobotoRegularFontWithSize:10];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)cellReset {
    
}

-(void)setPackage:(Package *)package {
    _package = package;
    _titleLabel.text = _package.packageName;
    NSNumber *poiNumber = [NSNumber numberWithInt:_package.numberOfPlaces];
    NSString *numberInFormat = [NSNumberFormatter localizedStringFromNumber:poiNumber numberStyle:NSNumberFormatterDecimalStyle];
    _descriptionLabel.text = [NSString stringWithFormat:NSLocalizedString(@"places", nil),numberInFormat];
}

@end
