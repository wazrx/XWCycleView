//
//  ViewController.m
//  XWCycleViewDemo
//
//  Created by YouLoft_MacMini on 15/11/6.
//  Copyright © 2015年 YouLoft_MacMini. All rights reserved.
//

#import "ViewController.h"
#import "XWCycleView.h"
#import "Masonry.h"

@interface ViewController ()<XWCycleViewDelegete>

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self cycleViewOne];
    [self cycleViewTwo];
}


- (void)cycleViewOne{
    XWCycleView *cycleViewOne = [XWCycleView cycleViewWithFrame:CGRectMake(0, 50, self.view.frame.size.width, 200) imageNames:@[@"zrx1.jpg", @"zrx2.jpg", @"zrx3.jpg", @"zrx4.jpg", ]];
    //设置标题
    cycleViewOne.titles = @[@"我是title1", @"我是title2", @"我是title3", @"我是title4"];
    //开启PageControl
    cycleViewOne.PageControlOpened = YES;
    //配置pageControl的一些属性
    cycleViewOne.pageControlSlectedDotBackGroundColor = [UIColor yellowColor];
    cycleViewOne.pageControlDotSize = CGSizeMake(10, 10);
    cycleViewOne.pageControlAlignment = XWCycleViewPageControllAlignmentRight;
    //开启自动滚动
    cycleViewOne.timerOpened = YES;
    //设置滚动间隔
    cycleViewOne.timerInterval = 0.8;
    //设置代理
    cycleViewOne.cycleViewDelegate = self;

    [self.view addSubview:cycleViewOne];
    
}

- (void)cycleViewTwo{
    NSArray *urlStrs = @[@"http://img.pconline.com.cn/images/upload/upc/tx/wallpaper/1508/18/c0/11378035_1439907092499_800x600.jpg", @"http://img.pconline.com.cn/images/upload/upc/tx/wallpaper/1508/18/c0/11378052_1439907094063_800x600.jpg", @"http://img.pconline.com.cn/images/upload/upc/tx/wallpaper/1508/18/c0/11378037_1439907099584_800x600.jpg", @"http://img.pconline.com.cn/images/upload/upc/tx/wallpaper/1508/18/c0/11378039_1439907105713_800x600.jpg"];
    XWCycleView *cycleViewTwo = [XWCycleView new];
    cycleViewTwo.imageUrlStrings = urlStrs;
    //设置占位图片
    cycleViewTwo.placeHoldImage = [UIImage imageNamed:@"placeHolderImage"];
    //开启PageControl
    cycleViewTwo.PageControlOpened = YES;
    //配置pageControl的一些属性
    cycleViewTwo.pageControlAlignment = XWCycleViewPageControllAlignmentCenter;
    //开启自动滚动
    cycleViewTwo.timerOpened = YES;
    //设置滚动间隔
    cycleViewTwo.timerInterval = 1;
    //关闭循环
    cycleViewTwo.cycleClosed = YES;
    //设置代理
    cycleViewTwo.cycleViewDelegate = self;
    [self.view addSubview:cycleViewTwo];
    [cycleViewTwo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left. width.equalTo(self.view);
        make.top.equalTo(self.view.mas_top).offset(300);
        make.height.mas_equalTo(200);
    }];
}

#pragma mark - <XWCycleViewDelegete>

- (void)cycleView:(XWCycleView *)cycleView didSelectItemAtIndex:(NSUInteger)index{
    NSLog(@"点击了第%zd张图片", index);
}

@end
