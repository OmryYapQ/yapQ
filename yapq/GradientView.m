//
//  GradientView.m
//  yapq
//
//  Created by yapQ Ltd on 6/22/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import "GradientView.h"

@implementation GradientView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self awakeFromNib];
    }
    return self;
}

-(void)awakeFromNib {
    CGRect frame = [[UIScreen mainScreen] bounds];
    _backgroundImageView = [[UIImageView alloc] initWithFrame: (CGRect){0, 0, frame.size.width, frame.size.height}];
    //_backgroundImageView.image = [UIImage imageNamed:@"bg_4"];
      _backgroundImageView.backgroundColor = [[UIColor alloc]initWithRed:234.0/255.0 green:237.0/255.0 blue:240.0/255.0 alpha:1.0];
    [self insertSubview:_backgroundImageView atIndex:0];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    /*CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
    gradientLayer.colors = @[(id)[Utilities colorWith255StyleRed:232 green:244 blue:244 alpha:1.0].CGColor,
                             (id)[Utilities colorWith255StyleRed:233 green:239 blue:225 alpha:1.0].CGColor,
                             (id)[Utilities colorWith255StyleRed:211 green:204 blue:188 alpha:1.0].CGColor
                             ];
    gradientLayer.frame = self.bounds;
    [self.layer insertSublayer:gradientLayer atIndex:0];*/
}


@end
