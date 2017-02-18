//
//  CommentViewController.h
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "BaseViewController.h"
#import "ReadDetailModel.h"
@interface CommentViewController : BaseViewController
//将要评论的数据带进来，需要让服务器知道，我评论了哪条文章
@property (nonatomic, strong)ReadDetailModel *tempDetailModel;
@end
