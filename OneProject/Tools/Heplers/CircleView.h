//
//  CircleView.h
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import <UIKit/UIKit.h>
/*
 数组参数、frame、时间
 */
@interface CircleView : UIView
//定时器
@property (nonatomic, strong)NSTimer *myTimer;
//image数组
@property (nonatomic, strong)NSMutableArray *imageArray;
@property (nonatomic, assign)NSTimeInterval timeInterval;
//轮播图的初始化方法
- (id)initWithImageURLArray:(NSMutableArray *)imageURLArray changeTime:(NSTimeInterval) timeInterval withFrame:(CGRect)frame;
//释放定时器(关闭)
- (void)removeTimer;
//开启定时器
- (void)initWithTimer;
//轻拍手势 点击事件的回调
@property (nonatomic, copy)void(^tapActionBlock)(NSInteger pageIndex);
//滑动视图属性
@property (nonatomic, strong)UIScrollView *mySrollView;
//页码控件
@property (nonatomic, strong)UIPageControl *myPageControl;


@end
