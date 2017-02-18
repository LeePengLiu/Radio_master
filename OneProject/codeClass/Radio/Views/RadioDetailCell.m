//
//  RadioDetailCell.m
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "RadioDetailCell.h"

@implementation RadioDetailCell

- (void)setModel:(RadioDetailModel *)model {
    _model = model;
    [self.coverimageView setImageWithURL:[NSURL URLWithString:model.coverimg]];
    NSInteger a = arc4random() % 500;
    CGFloat b = [model.musicVisit floatValue];
    if (b > 999) {
        CGFloat c = b / 1000;
        self.musicVisitLabel.text = [NSString stringWithFormat:@"%.2lfk", c];
    }else {
        self.musicVisitLabel.text = [NSString stringWithFormat:@"%@", model.musicVisit];
    }
    self.titleLabel.text = model.title;
    self.likeLabel.text = [NSString stringWithFormat:@"%ld", a];;
}


- (void)awakeFromNib {
    self.coverimageView.layer.cornerRadius = 1;
    self.coverimageView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
