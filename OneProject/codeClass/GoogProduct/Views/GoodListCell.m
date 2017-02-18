//
//  GoodListCell.m
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "GoodListCell.h"

@implementation GoodListCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setModel:(GoodListModel *)model {
    _model = model;
    [self.coverimgVIew setImageWithURL:[NSURL URLWithString:model.coverimg]];
    self.titleLabel.text = model.title;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
