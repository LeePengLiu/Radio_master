//
//  RadioPlayerController.h
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RadioDetailModel.h"
@interface RadioPlayerController : UIViewController
@property (nonatomic, strong)RadioDetailModel *tempModel;
@property (nonatomic, strong)NSMutableArray *musicArray;
@property (nonatomic, assign)NSInteger index;
@property (nonatomic, strong)NSMutableArray *itemArray;
@property (nonatomic, assign)BOOL playNew;
+ (RadioPlayerController *)sharedPlayerVC;
@end
