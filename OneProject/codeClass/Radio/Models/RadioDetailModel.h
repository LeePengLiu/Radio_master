//
//  RadioDetailModel.h
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RadioDetailModel : NSObject<NSCoding>
@property (nonatomic, strong)NSString *coverimg, *title, *musicUrl, *tingid;
@property (nonatomic, strong)NSNumber *musicVisit;
//包含歌曲与分享信息
@property (nonatomic, strong)NSDictionary *playInfo;

//用来记录当前model的下载量
@property (nonatomic, copy)void (^progressBlock)(float,float);

//用来暂停下载
@property (nonatomic, strong)NSURLSessionDownloadTask *downloadTask;
@end
