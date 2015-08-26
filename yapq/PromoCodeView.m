//
//  PromoCodeView.m
//  yapq
//
//  Created by yapQ Ltd on 12/16/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import "PromoCodeView.h"

@implementation PromoCodeView

-(void)awakeFromNib {
    _label.font = [Utilities RobotoLightFontWithSize:12];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(keyPressed:) name: UITextFieldTextDidChangeNotification object: _nOne];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(keyPressed:) name: UITextFieldTextDidChangeNotification object: _nTwo];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(keyPressed:) name: UITextFieldTextDidChangeNotification object: _nThree];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(keyPressed:) name: UITextFieldTextDidChangeNotification object: _nFour];
}

-(void) keyPressed: (NSNotification*) notification
{
    if ([[notification object] tag] < 4) {
        UITextField *tf = (UITextField *)[self viewWithTag:[[notification object] tag]+1];
        [tf becomeFirstResponder];                                                          // Moving to text field with next tag
    }
    else {
        [_nFour resignFirstResponder];
        [_inputDelegate codeEntered:[self getPin]];
    }
}

-(NSString *)getPin {
    return [NSString stringWithFormat:@"%@%@%@%@",_nOne.text,_nTwo.text,_nThree.text,_nFour.text];
}


@end
