//
//  RadioListCell.m
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "RadioListCell.h"

@implementation RadioListCell

- (void)awakeFromNib {
    self.coverimg.layer.cornerRadius = 3;
    self.coverimg.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
