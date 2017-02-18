//
//  DownLoadManager.m
//  LessonDownLoad_17
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "DownLoadManager.h"

@implementation DownLoadManager
- (NSMutableArray *)dataArray {
    if (_dataArray == nil) {
        self.dataArray = [NSMutableArray array];
    }return _dataArray;
}

//实现单例方法
+ (DownLoadManager *)sharedDownLoadManager {
    static DownLoadManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DownLoadManager alloc]init];
    });
    
    
    return manager;
}
//GET请求
- (void)getdataFromServerWithURLStr:(NSString *)urlStr success:(void (^)(NSData *))successBlock fail:(void (^)(NSError *))failBlock {
    //创建NSURL链接对象
    NSURL *url = [NSURL URLWithString:urlStr];
    //创建请求类
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //创建全局会话对象
    NSURLSession *session = [NSURLSession sharedSession];
    //创建请求任务
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //这里是子线程来执行的
        if (error == nil) {
            //说明请求成功
            //安全判断block是否存在
            if (successBlock) {
                //调用block来传值
                successBlock(data);
            }
        }else {
            if (failBlock) {
                failBlock(error);
            }
        }
    }];
    [task resume];
    
}
//下载

- (void)downLoadWithModel:(RadioDetailModel *)model {
//    self.dataArray 用来存储下载任务的 model
    for (RadioDetailModel *tempModel in self.dataArray) {
        //遍历，查看传进来的model是否已经在下载的任务中
        if ([tempModel.tingid isEqualToString:model.tingid]) {
            return;//直接结束代码
        }
    }
    //将model添加到数组
    [self.dataArray addObject:model];
    //配置下载请求
    //1.创建NSURL
    NSURL *url = [NSURL URLWithString:model.musicUrl];
    //2.创建请求对象
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //3.创建会话配置信息
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    //4.将配置信息和会话对象关联起来
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    //5.创建下载任务
    NSURLSessionDownloadTask *downLoadTask = [session downloadTaskWithRequest:request];
    //6.记录下模型的tingid，为了避免重复创建下载任务,为了准备查找任务和model
    downLoadTask.taskDescription =  model.tingid;
    model.downloadTask = downLoadTask;
    //7.执行任务
    [downLoadTask resume];
    
}

#pragma mark -- NSURLSessionDownLoadDelegate -- 
//byteWritten 每秒钟下载的字节数
//totalByteWritten 已经下载的字节数
//totalByteExpectedToWritten 文件的总大小
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    //计算进度条应该显示比例
    float progress = (float)totalBytesWritten / totalBytesExpectedToWrite;
    float bytes = (float)bytesWritten;
    //查找对应的模型
    //封装查找model的方法
    RadioDetailModel *model = [self searchModelWithDesicirption:downloadTask.taskDescription];
    //调用block
    if (model.progressBlock) {
        model.progressBlock(progress,bytes);
    }
    
}

//封装查找model的方法
- (RadioDetailModel *)searchModelWithDesicirption: (NSString *)str{
    
    //遍历，查找model
    for (RadioDetailModel *tempModel in self.dataArray) {
        if ([str isEqualToString:tempModel.tingid]) {
            return tempModel;//找到了
        }
    }
    return nil;
}

//下载完成
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    //将数据，存入沙盒
    //1.获取cache文件件路径
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)firstObject];
    //创建新文件路径
    NSString *musicPath = [cachePath stringByAppendingPathComponent:@"MyMusic"];
    //创建文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //创建文件
    [fileManager createDirectoryAtPath:musicPath withIntermediateDirectories:YES attributes:nil error:nil];
    //根据标识查找model
    RadioDetailModel *model = [self searchModelWithDesicirption:downloadTask.taskDescription];
    //创建文件要存储的路径
    NSString *str =  model.tingid;
//    str = [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];

    //NSString *pinyin = [ChineseToPinyin pinyinFromChiniseString:model.title];
    NSString *filePath = [musicPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3", str]];
    
    //先文件创建在沙盒
    [fileManager createFileAtPath:filePath contents:nil attributes:nil];
    //将路径转化为URL(创建文件需要)
    NSURL *url = [NSURL fileURLWithPath:filePath];
    //把下载的资源移动到目的地
    [fileManager moveItemAtURL:location toURL:url error:nil];
}


@end
