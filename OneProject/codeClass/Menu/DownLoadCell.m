//
//  DownLoadCell.m
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "DownLoadCell.h"

@implementation DownLoadCell

- (IBAction)downAction:(UIButton *)sender {
    if ([sender.currentTitle isEqualToString:@"暂停"]) {
        [self.downloadTask suspend];
        [sender setTitle:@"开始" forState:UIControlStateNormal];
    }else {
        [self.downloadTask resume];
        [sender setTitle:@"暂停" forState:UIControlStateNormal];
    }
}

- (void)awakeFromNib {
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
