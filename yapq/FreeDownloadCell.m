//
//  FreeDownloadCell.m
//  yapq
//
//  Created by yapQ Ltd on 6/27/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import "FreeDownloadCell.h"

@implementation FreeDownloadCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)awakeFromNib {
   // _downloadButton.layer.cornerRadius = 3;
    [super awakeFromNib];
}

-(void)cellReset {
    
    self.progressLabel.text = NSLocalizedString(@"for_offline_use", nil);
    //_state = BBS_PRICE;
    [_circleLoader setProgress:0.0];
    _circleLoader.hidden = YES;
    //loader color
    _circleLoader.indicatorColor = [Utilities colorWith255StyleRed:61 green:61 blue:61 alpha:1.0];
    _downloadButton.hidden = NO;
}

-(void)setupAsLoading:(PackageLoader *)packageLoader {
    [Utilities UITaskInSeparatedBlock:^{
        [_circleLoader setProgress:packageLoader.loadingProgres];
    }];
    _circleLoader.hidden = NO;
    _downloadButton.hidden = YES;
}

-(IBAction)downloadButton:(id)sender {

    _circleLoader.hidden = NO;
    _downloadButton.hidden = YES;
    [self.delegete downloadButtonEvent:self];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:kDownloadProgressObserver]) {
        float progress = [[change valueForKeyPath:NSKeyValueChangeNewKey] floatValue];
        NSLog(@"%f",progress);
        [Utilities UITaskInSeparatedBlock:^{
            [_circleLoader setProgress:progress animated:YES];
        }];
        
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
