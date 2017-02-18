//
//  CommentModel.h
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommentModel : NSObject
//发表评论的时间
@property (nonatomic, strong)NSString *addtime_f;
//评论内容
@property (nonatomic, strong)NSString *content;
//用户信息（字典）
@property (nonatomic, strong)NSDictionary *userinfo;
//评论id
@property (nonatomic, strong)NSString *contentid;
@end
