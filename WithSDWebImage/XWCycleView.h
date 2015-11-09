//
//  CycleView.h
//  循环滚动WithSDWebImage
//
//  Created by wazrx on 15/11/6.
//  Copyright (c) 2015年 wazrx. All rights reserved.
//  利用UICollectionViews实现的循环滚动视图，可自定义标题、pageControll、是否开启循环，自动滚动等一系列属性，欢迎使用，如有问题请发送邮件至xiaowennengxing@163.com，或者到我的博客：http://wazrx.com 反馈， 谢谢！


#import <UIKit/UIKit.h>
@class XWCycleView;

@protocol XWCycleViewDelegete <NSObject>

@optional
/**
 *  点击了某一个cell的事件，请使用XWCycleViewDelegete监听， 不要设置CollectionView自身的delegate
 */
- (void)cycleView:(XWCycleView *)cycleView didSelectItemAtIndex:(NSUInteger )index;

@end
//PageControl的对齐方式
typedef NS_ENUM(NSUInteger, XWCycleViewPageControllAlignment) {
    
    XWCycleViewPageControllAlignmentLeft = 0,
    XWCycleViewPageControllAlignmentCenter,
    XWCycleViewPageControllAlignmentRight
};

@interface XWCycleView : UICollectionView

#pragma mark - dataSourceSetting

/**图片名数组*/
@property (nonatomic, copy) NSArray *imageNames;
/**图片数组*/
@property (nonatomic, copy) NSArray *images;
/**图片url字符串数组*/
@property (nonatomic, copy) NSArray *imageUrlStrings;
/**标题数组*/
@property (nonatomic, copy) NSArray *titles;

#pragma mark - CycleSetting

/**是否关闭无限循环, 默认NO*/
@property (nonatomic, assign) BOOL cycleClosed;

#pragma mark - TimerSetting

/**是否开启轮播定时器,默认NO*/
@property (nonatomic, assign) BOOL timerOpened;
/**轮播定时器时间间隔, 默认5秒*/
@property (nonatomic, assign) NSTimeInterval timerInterval;

#pragma mark - imageViewSetting

/**图片的填充模式*/
@property (nonatomic, assign) UIViewContentMode contentMode;
/**网络加载时的占位图片*/
@property (nonatomic, strong) UIImage *placeHoldImage;

#pragma mark - PageControlSetting

/**是否开启UIPageControl, 默认NO*/
@property (nonatomic, assign) BOOL PageControlOpened;
/**pageControl小圆点的大小, 默认{8， 8}*/
@property (nonatomic, assign) CGSize pageControlDotSize;
/**pageControl选中小圆点的颜色， 默认白色*/
@property (nonatomic, strong) UIColor *pageControlSlectedDotBackGroundColor;
/**pageControl普通小圆点的颜色，默认白色 + 0.5 透明度*/
@property (nonatomic, strong) UIColor *pageControlNormalDotBackGroundColor;
/**pageControl的水平位置，默认居中*/
@property (nonatomic, assign) XWCycleViewPageControllAlignment pageControlAlignment;

#pragma mark - TitleLabelSetting

/**titleLabel颜色, 默认白色*/
@property (nonatomic, strong) UIColor *titleLabelTextColor;
/**titleLabel字体, 默认14*/
@property (nonatomic, strong) UIFont  *titleLabelTextFont;
/**titleLabel背景色, 默认黑色，0.5 透明度*/
@property (nonatomic, strong) UIColor *titleLabelBackgroundColor;
/**titleLabel高度, 默认30*/
@property (nonatomic, assign) CGFloat titleLabelHeight;
/**titleLabel对齐方式, 默认左对齐*/
@property (nonatomic, assign) NSTextAlignment titleLabelAlignment;
/**pageControl距离底部的距离，默认15.0f*/
@property (nonatomic, assign) CGFloat pageControlSpacingToBottom;

#pragma mark - delegate
/**监听点击事件请使用此代理监听，不要使用CollectionView自带的delegate*/
@property (nonatomic, assign) id<XWCycleViewDelegete> cycleViewDelegate;
/**
 *  通过图片名数组初始化
 */
+ (instancetype)cycleViewWithFrame:(CGRect)frame imageNames:(NSArray *)imageNames;
/**
 *  通过图片数组初始化
 */
+ (instancetype)cycleViewWithFrame:(CGRect)frame images:(NSArray *)images;
/**
 *  通过图片urlString数组初始化
 */
+ (instancetype)cycleViewWithFrame:(CGRect)frame imageUrlStrings:(NSArray *)imageUrlStrings;
@end
