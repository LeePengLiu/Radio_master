//
//  ReadListModel.h
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReadListModel : NSObject
//列表model
//图片地址
@property (nonatomic, strong)NSString *coverimg;
//标题
@property (nonatomic, strong)NSString *name;
@property (nonatomic, strong)NSString *enname;
//类型
@property (nonatomic, strong)NSString *type;//是我们做详情界面的参数
@end
