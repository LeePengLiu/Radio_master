//
//  ReadDetailCell.m
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "ReadDetailCell.h"

@implementation ReadDetailCell

//实现赋值方法
- (void)dataForCellWithModel:(ReadDetailModel *)tempModel {
    self.titleLabel.text = tempModel.title;
    self.nameLabel.text = tempModel.name;
    self.contentLabel.text = tempModel.content;
    NSURL *url = [NSURL URLWithString:tempModel.coverimg];
    [self.coverimageView setImageWithURL:url];//AFN中加载图片的方法
    
}
//实现赋值方法
- (void)dataForCellWithLikeModel:(UserLikeModel *)tempModel {
    self.titleLabel.text = tempModel.title;
    self.nameLabel.text = tempModel.uname;
    self.contentLabel.text = tempModel.content;
    NSURL *url = [NSURL URLWithString:tempModel.coverimg];
    [self.coverimageView setImageWithURL:url];//AFN中加载图片的方法
    
}


- (void)awakeFromNib {
    self.coverimageView.clipsToBounds = YES;
    self.coverimageView.layer.cornerRadius = 3;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
