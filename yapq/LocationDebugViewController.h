//
//  LocationDebugViewController.h
//  yapq
//
//  Created by yapQ Ltd on 12/7/13.
//  Copyright (c) 2013 yapQ Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationSevice.h"

@interface LocationDebugViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UILabel *signalLabel;

@end
