//
//  PromoCodeView.h
//  yapq
//
//  Created by yapQ Ltd on 12/16/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CodeTextField.h"
#import "Utilities.h"

@protocol CodeInputEvent <NSObject>

-(void)codeEntered:(NSString *)code;

@end

@interface PromoCodeView : UIView <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet CodeTextField *nOne;
@property (strong, nonatomic) IBOutlet CodeTextField *nTwo;
@property (strong, nonatomic) IBOutlet CodeTextField *nThree;
@property (strong, nonatomic) IBOutlet CodeTextField *nFour;

@property (strong, nonatomic) IBOutlet UILabel *label;

@property id<CodeInputEvent> inputDelegate;

-(NSString *)getPin;

@end
