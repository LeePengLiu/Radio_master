//
//  ArchiveManager.h
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RadioDetailModel.h"
@interface ArchiveManager : NSObject
@property (nonatomic, strong)NSMutableArray *array;
@property (nonatomic, strong)RadioDetailModel *model;
@property (nonatomic, assign)NSInteger index;
@property (nonatomic ,strong)NSMutableArray *itemArray;
@property (nonatomic, strong)NSMutableDictionary *itemDic;
+ (ArchiveManager *)sharedArchiveManager;

//解档
- (void)unarchiver;
@end
