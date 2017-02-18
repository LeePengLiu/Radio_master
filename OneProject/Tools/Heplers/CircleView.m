//
//  CircleView.m
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "CircleView.h"
#import "UIImageView+AFNetworking.h"
@interface CircleView ()<UIScrollViewDelegate>


@end
int i = 1;
@implementation CircleView

//初始化方法
- (id)initWithImageURLArray:(NSMutableArray *)imageUrlArray changeTime:(NSTimeInterval)timeInterval withFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //给属性赋值 只是为了方便全局访问
        self.imageArray = imageUrlArray;
        //时间赋值
        self.timeInterval = timeInterval;
        //创建新数组 开辟空间 并且再另外插入第一个对象和最后一个对象
        NSMutableArray *tempArray = [NSMutableArray array];
        [tempArray addObject:[imageUrlArray lastObject]];
        [tempArray addObjectsFromArray:imageUrlArray];
        [tempArray addObject:[imageUrlArray firstObject]];
        //展示图片(封装方法)
        [self scrollviewwillImageURLArray:tempArray];
        //封装定时器方法
        [self initWithTimer];
    }
    return self;
}
#pragma mark -- 定时器初始化
- (void)initWithTimer {
    self.myTimer = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
}

#pragma mark -- 定时器方法的实现
- (void)timerAction:(NSTimer *)timer {
    
    
    [self.mySrollView setContentOffset:CGPointMake(self.mySrollView.contentOffset.x + kDeviceWidth, 0) animated:YES];
//    [self.mySrollView setContentOffset:CGPointMake(kDeviceWidth * i, 0) animated:YES];
    //self.myPageControl.currentPage = self.timeInterval - 1;
}
//关闭定时器
- (void)removeTimer {
    [self.myTimer invalidate];//定时器会失效
    self.myTimer = nil;
}


#pragma mark -- 展示图片
- (void)scrollviewwillImageURLArray:(NSMutableArray *)imageArray {
    self.mySrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
    //设置内容区域大小
    self.mySrollView.contentSize = CGSizeMake(imageArray.count * kDeviceWidth, self.bounds.size.height);
    //设置默认显示的图片
    self.mySrollView.contentOffset = CGPointMake(kDeviceWidth, 0);
    //设置代理
    self.mySrollView.delegate = self;
    //设置整屏滚动
    self.mySrollView.pagingEnabled = YES;
    //设置显示滚动条
    self.mySrollView.showsHorizontalScrollIndicator = NO;
    //添加到视图上
    [self addSubview:self.mySrollView];
    //开始循环遍历，添加图片
    for (int i = 0; i < imageArray.count; i++) {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(kDeviceWidth * i, 0, kDeviceWidth, self.bounds.size.height)];
        
        //请求图片， 并且放在imageView上
        NSURL *url = [NSURL URLWithString:imageArray[i]];
        imageView.userInteractionEnabled = YES;
        [imageView setImageWithURL:url];
        //给imageVIew 添加手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        imageView.userInteractionEnabled = YES;
        [imageView addGestureRecognizer:tap];
        //将imageView添加到滑动视图上
        [self.mySrollView  addSubview:imageView];
    }
    //小图点
    self.myPageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(kDeviceWidth - 100, self.bounds.size.height - 30, 100, 30)];
    self.myPageControl.numberOfPages = self.imageArray.count;
    //小圆点默认的位置
    self.myPageControl.currentPage = 0;
    //添加到视图上
    [self addSubview:self.myPageControl];
}
#pragma mark -- 实现轻拍手势
- (void)tapAction:(UITapGestureRecognizer *)sender {
    //调用block，为了把当前被点击的图片的下标传递到控制器上
    if (self.tapActionBlock) {
        self.tapActionBlock(self.myPageControl.currentPage);
    }
}

#pragma mark -- UIScrollViewDelegate
//只要发生滑动就会触发
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    NSInteger tempNumber = scrollView.contentOffset.x / kDeviceWidth;
    
        self.myPageControl.currentPage = tempNumber - 1;
    
    //跳转到第一张上
    if (self.mySrollView.contentOffset.x >= kDeviceWidth * (self.imageArray.count + 1)) {
        [self.mySrollView setContentOffset:CGPointMake(kDeviceWidth, 0)];//不要动画
    }
}
//将要拖拽的时候，需要将计时器暂停(周一见)
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    //定时器暂停
    [self.myTimer setFireDate:[NSDate distantFuture]];
}
//减速结束
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    //更改动画，对第一次或者最后一张做处理
   // [self headerAndFooterChangeImage];
    //重新开启计时器（周一）
    [self.myTimer setFireDate:[[NSDate alloc] initWithTimeIntervalSinceNow:self.timeInterval]];
    //给pageControll赋值
    NSInteger tempNumber = self.mySrollView.contentOffset.x / kDeviceWidth;
    self.myPageControl.currentPage = tempNumber - 1;
}

//滑动结束(针对定时器 自动滑动结束处理第一张和最后一张)
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self headerAndFooterChangeImage];

}


#pragma mark -- 封装第一张和最后一张的处理方法
- (void)headerAndFooterChangeImage {
    //如果是第一张，跳转到最后一张
    if (self.mySrollView.contentOffset.x == 0) {
        [self.mySrollView setContentOffset:CGPointMake(kDeviceWidth * self.imageArray.count, 0)] ;
    }
    //跳转到第一张上  大于等于号是为了防止计时器最后一张，进行切换时，突然push界面，所造成的轮播图contentOffSet.x越界问题
    if (self.mySrollView.contentOffset.x >= kDeviceWidth * (self.imageArray.count + 1)) {
        [self.mySrollView setContentOffset:CGPointMake(kDeviceWidth, 0)];//不要动画
    }
}



@end
