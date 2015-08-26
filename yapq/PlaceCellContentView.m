//
//  PlaceCellContentView.m
//  yapq
//
//  Created by yapQ Ltd on
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import "PlaceCellContentView.h"

@implementation PlaceCellContentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)awakeFromNib {
    
    self.layer.cornerRadius = 7.0;
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = [UIColor colorWithRed:233./255. green:233./255. blue:233./255. alpha:1.0].CGColor;
    
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    UIBezierPath *path = [[UIBezierPath alloc] init];
    path.lineWidth = 38.0;
    [path moveToPoint:CGPointMake(0, 355)];
    [path addLineToPoint:CGPointMake(rect.size.width, 355)];
    [[UIColor colorWithRed:248./255. green:248./255. blue:248./255. alpha:1.0] setStroke];
    [path stroke];

}


@end
