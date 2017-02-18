//
//  ReadListCell.m
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "ReadListCell.h"

@implementation ReadListCell

- (void)awakeFromNib {
    //self.nameLabel.font = [UIFont systemFontOfSize:14];
    self.nameLabel.layer.cornerRadius = 2;
    self.nameLabel.layer.masksToBounds = YES;
    self.coverImage.layer.cornerRadius = 2;
    self.coverImage.layer.masksToBounds = YES;
}

@end
