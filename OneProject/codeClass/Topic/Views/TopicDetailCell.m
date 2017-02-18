//
//  TopicDetailCell.m
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "TopicDetailCell.h"

@implementation TopicDetailCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setModel:(TopicDetailModel *)model {
    _model = model;
    [self.headerImageView setImageWithURL:[NSURL URLWithString:model.icon]];
    self.userNameLabel.text = model.uname;
    CGRect rect = self.contectLabel.frame;
    rect.size.height = [self setLabelText:model.content];
    self.contectLabel.frame = rect;
    self.contectLabel.text = model.content;
    self.contectLabel.backgroundColor = [UIColor colorWithRed:220/ 255.0 green:220/ 255.0 blue:220/ 255.0 alpha:1];
}
//封装计算Label文字大小
- (CGFloat)setLabelText:(NSString *)content {
    NSDictionary *dic = @{NSFontAttributeName:[UIFont systemFontOfSize:18]};
    CGRect rect = [content boundingRectWithSize:CGSizeMake(self.frame.size.width, MAXFLOAT) options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin) attributes:dic context:nil];
    return rect.size.height;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
