//
//  DownLoadManager.h
//  LessonDownLoad_17
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RadioDetailModel.h"
@interface DownLoadManager : NSObject<NSURLSessionDownloadDelegate>
//数据源数组
@property (nonatomic, strong)NSMutableArray *dataArray;

//单例
+ (DownLoadManager *)sharedDownLoadManager;
//get请求
- (void)getdataFromServerWithURLStr: (NSString *)urlStr success:(void (^)(NSData *data))successBlock fail:(void(^)(NSError *error)) failBlock;
//下载
- (void)downLoadWithModel:(RadioDetailModel *)model;


@end
