//
//  CodeTextField.m
//  yapq
//
//  Created by yapQ Ltd on 12/16/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import "CodeTextField.h"

@implementation CodeTextField


-(void)awakeFromNib {
    
    self.borderStyle = UITextBorderStyleNone;
    self.frame = (CGRect){self.frame.origin.x, self.frame.origin.y, 50, 50};
    self.secureTextEntry = true;
    self.backgroundColor = [UIColor clearColor];
    self.font = [UIFont systemFontOfSize:27];
    self.textAlignment = NSTextAlignmentCenter;
    self.textColor = [UIColor whiteColor];
    self.clearsOnBeginEditing = YES;
    
    CAShapeLayer *passLayer = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect: (CGRect){2, 2, self.bounds.size.width-4, self.bounds.size.height-4}
                                                    cornerRadius:self.bounds.size.height/2];
    passLayer.frame = self.bounds;
    passLayer.path = path.CGPath;
    passLayer.strokeColor = [UIColor whiteColor].CGColor;
    passLayer.fillColor = [UIColor clearColor].CGColor;
    
    [self.layer addSublayer:passLayer];
    
}

-(CGRect)caretRectForPosition:(UITextPosition *)position {
    return CGRectZero;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
