//
//  RadioViewController.h
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "BaseViewController.h"

@interface RadioViewController : BaseViewController
- (void)setupHttp;
@property (nonatomic, strong)CircleView *cricleView;
@property (nonatomic, assign)NSInteger isFirst;
@end
