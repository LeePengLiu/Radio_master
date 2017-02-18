//
//  TopicListCellTwo.m
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "TopicListCellTwo.h"

@implementation TopicListCellTwo
- (void)setModel:(TopicModel *)model {
    _model = model;
    NSInteger a = [model.like integerValue];
    NSInteger b = [model.comment integerValue];
    CGFloat c = b / 1000.0;
    self.counterLabel.text = [NSString stringWithFormat:@"%ld参与", a + b];
    self.titleLabel.text = model.title;
    [self.iconImageView setImageWithURL:[NSURL URLWithString:model.icon]];
    self.iconImageView.layer.cornerRadius = 20;
    self.iconImageView.layer.masksToBounds = YES;
    self.unameLabel.text = model.uname;
    self.likeLabel.text = [NSString stringWithFormat:@"%@", model.like];
    self.commentLabel.text = [NSString stringWithFormat:@"%.1lfk",c];
    self.contentLabel.text = model.content;
    
}



- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
