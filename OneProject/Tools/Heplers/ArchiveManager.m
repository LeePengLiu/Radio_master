//
//  ArchiveManager.m
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "ArchiveManager.h"

@implementation ArchiveManager
+ (ArchiveManager *)sharedArchiveManager {
    static ArchiveManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ArchiveManager alloc]init];
    });
    return manager;
}
//- (NSMutableDictionary *)itemDic {
//    if (_itemDic == nil) {
//        self.itemDic = [NSMutableDictionary dictionary];
//    }
//    return _itemDic;
//}
//- (NSMutableArray *)itemArray {
//    if (_itemArray == nil) {
//        self.itemArray = [NSMutableArray array];
//    }
//    return _itemArray;
//}
- (void)unarchiver {
    NSString *string = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)firstObject];
    NSString *MusicArrayPath = [string stringByAppendingPathComponent:@"musicArray.plist"];
    //NSString *indexPath = [string stringByAppendingPathComponent:@"index"];
    NSLog(@"%@", MusicArrayPath);
    NSInteger index = [[[NSUserDefaults standardUserDefaults] valueForKey:@"index"] integerValue];
    if (![[NSFileManager defaultManager] fileExistsAtPath:MusicArrayPath]) {
        return;
    }
    //1.创建并行队列
//    dispatch_queue_t queue = dispatch_queue_create("afda", DISPATCH_QUEUE_CONCURRENT);
//    //2.创建分组
//    dispatch_group_t group = dispatch_group_create();
    NSArray *tempArray = [NSKeyedUnarchiver unarchiveObjectWithFile:MusicArrayPath];
    self.array = [NSMutableArray arrayWithArray:tempArray];
    self.itemDic = [NSMutableDictionary dictionary];
    self.itemArray = [NSMutableArray array];
     //3.往分组中添加异步任务
    for (int i = 0; i < tempArray.count; i++) {
        NSString *urlStr = [tempArray[i] musicUrl ];
        AVPlayerItem *item = [[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:urlStr]];
        [self.itemArray addObject:item];
    }
    

      self.index = index;
}
@end
