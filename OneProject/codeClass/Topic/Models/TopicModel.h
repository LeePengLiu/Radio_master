//
//  TopicModel.h
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TopicModel : NSObject

@property (nonatomic,strong)NSString *title, *uname, * icon, *addtime_f, *content, *coverimg,  *isrecommend, *ishot;
@property (nonatomic, strong)NSNumber *contentid, * uid, *addtime, *comment, *like, *view;


@end
