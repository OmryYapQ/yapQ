//
//  DescriptionViewController.h
//  yapq
//
//  Created by yapQ Ltd on 12/5/13.
//  Copyright (c) 2013 yapQ Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Settings.h"
#import "Utilities.h"

@interface DescriptionViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) NSString *text;
@property (weak, nonatomic) IBOutlet UILabel *titleView;
@property (weak, nonatomic) IBOutlet UILabel *sourceLable;
@property (strong, nonatomic) NSString *titleLabelPopUp;
- (IBAction)goToWiki:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *wikipeidaButton;
@end
