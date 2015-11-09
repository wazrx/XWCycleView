//
//  CycleView.m
//  循环滚动WithSDWebImage
//
//  Created by wazrx on 15/11/6.
//  Copyright (c) 2015年 wazrx. All rights reserved.
//

#import "XWCycleView.h"
#import "UIImageView+WebCache.h"

static NSString * const identifier = @"cycleViewCell";


#pragma mark ======================XWPageControl==========================


//自定义UIPageControl
@interface XWPageControl :UIPageControl
@property (nonatomic, assign) CGSize dotSize;
@property (nonatomic, strong) UIColor *SelectedDotBackGroundColor;
@property (nonatomic, strong) UIColor *NormalDotBackGroundColor;
@end

@implementation XWPageControl
/**
 *  重写该方法改变小圆点的大小
 */
- (void)setCurrentPage:(NSInteger)currentPage{
    [super setCurrentPage:currentPage];
    for (NSUInteger subviewIndex = 0; subviewIndex < [self.subviews count]; subviewIndex++) {
        UIImageView* subview = [self.subviews objectAtIndex:subviewIndex];
        subview.layer.cornerRadius = self.dotSize.height / 2.0;
        [subview setFrame:CGRectMake(subview.frame.origin.x, subview.frame.origin.y,
                                     self.dotSize.width,self.dotSize.height)];
        if (subviewIndex == currentPage) {
            subview.backgroundColor = self.SelectedDotBackGroundColor;
        }else{
            subview.backgroundColor = self.NormalDotBackGroundColor;
        }
    }
}
@end


#pragma mark ======================XWCycleViewCell==========================


@interface XWCycleViewCell : UICollectionViewCell
@property (nonatomic, weak) UIImageView *mainView;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, copy) NSString *imgURL;
@property (nonatomic, strong) UIImage *placeHodler;
@property (nonatomic, assign, getter=isCellConfiged) BOOL cellConfiged;
@end

@implementation XWCycleViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *mainView = [UIImageView new];
        self.mainView = mainView;
        mainView.frame = self.bounds;
        [self.contentView addSubview:mainView];
        UILabel *label = [UILabel new];
        label.hidden = YES;
        self.titleLabel = label;
        [self.contentView addSubview:label];
    }
    return self;
}

- (void)setImgURL:(NSString *)imgURL{
    _imgURL = imgURL;
    [_mainView sd_setImageWithURL:[NSURL URLWithString:imgURL] placeholderImage:_placeHodler];
}

@end


#pragma mark ======================XWCycleView==========================

@interface XWCycleView ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSTimer *myTimer;

@property (nonatomic, strong) UICollectionViewFlowLayout *layout;

@property (nonatomic, weak) UIPageControl *pageControl;

@property (nonatomic, assign) NSInteger originalCount;

@property (nonatomic, assign) NSInteger totleCount;

@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, assign, getter=isHasInitialUI) BOOL hasInitialUI;

@end

@implementation XWCycleView


#pragma mark - initialize

+ (instancetype)cycleViewWithFrame:(CGRect)frame imageNames:(NSArray *)imageNames{
    XWCycleView *cycleView = [[XWCycleView alloc] initWithFrame:frame];
    cycleView.imageNames = imageNames;
    return cycleView;
}

+ (instancetype)cycleViewWithFrame:(CGRect)frame images:(NSArray *)images{
    XWCycleView *cycleView = [[XWCycleView alloc] initWithFrame:frame];
    cycleView.images = images;
    return cycleView;
}

+ (instancetype)cycleViewWithFrame:(CGRect)frame imageUrlStrings:(NSArray *)imageUrlStrings{
    XWCycleView *cycleView =[[XWCycleView alloc] initWithFrame:frame];
    cycleView.imageUrlStrings = imageUrlStrings;
    return cycleView;
}

- (UICollectionViewFlowLayout *)initializeLayout{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    return layout;
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout{
    
    self = [super initWithFrame:frame collectionViewLayout:[self initializeLayout]];
    if (self) {
        [self initializeUI];
        [self initalizeProperty];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.collectionViewLayout = [self initializeLayout];
        [self initializeUI];
        [self initalizeProperty];
    }
    return self;
}

- (void)initializeUI{
    
    [self registerClass:[XWCycleViewCell class] forCellWithReuseIdentifier:identifier];
    self.backgroundColor = [UIColor whiteColor];
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.pagingEnabled = YES;
    self.delegate = self;
    self.dataSource = self;
}

- (void)initalizeProperty{
    _contentMode = UIViewContentModeScaleAspectFill;
    _timerInterval = 2;
    _pageControlDotSize = CGSizeMake(8, 8);
    _pageControlNormalDotBackGroundColor = [UIColor colorWithRed:255 / 255.0 green:255 / 255.0 blue:255 / 255.0 alpha:0.5];
    _pageControlSlectedDotBackGroundColor = [UIColor whiteColor];
    _pageControlAlignment = XWCycleViewPageControllAlignmentCenter;
    _titleLabelHeight = 30.0f;
    _pageControlSpacingToBottom = 15.0f;
    _titleLabelTextColor = [UIColor whiteColor];
    _titleLabelTextFont = [UIFont systemFontOfSize:12];
    _titleLabelBackgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    _titleLabelAlignment = NSTextAlignmentLeft;
}

- (void)initalizePageControl{
    
    if (!self.PageControlOpened || self.pageControl) {
        return;
    }
    XWPageControl *pageControl = [XWPageControl new];
    pageControl.dotSize = self.pageControlDotSize;
    pageControl.SelectedDotBackGroundColor = self.pageControlSlectedDotBackGroundColor;
    pageControl.NormalDotBackGroundColor = self.pageControlNormalDotBackGroundColor;
    self.pageControl = pageControl;
    pageControl.numberOfPages = self.cycleClosed ? _totleCount : _totleCount - 1;
    pageControl.userInteractionEnabled = NO;
    [self.superview addSubview:pageControl];
    CGFloat width = _pageControlDotSize.width * pageControl.numberOfPages + 10 * (pageControl.numberOfPages - 1);
    CGFloat centerX = 0;
    switch (_pageControlAlignment) {
        case XWCycleViewPageControllAlignmentLeft:
            centerX = self.frame.origin.x + width / 2 + 5;
            break;
            
        case XWCycleViewPageControllAlignmentCenter:
            centerX = self.center.x;
            break;
        case XWCycleViewPageControllAlignmentRight:
            centerX = self.frame.origin.x + self.frame.size.width - width / 2 - 5;
            break;
    }
    pageControl.bounds = CGRectMake(0, 0, width, _pageControlDotSize.height + 5);
    pageControl.center = CGPointMake(centerX, CGRectGetMaxY(self.frame) - _pageControlSpacingToBottom);
}

- (void)setImageNames:(NSArray *)imageNames{
    _imageNames = imageNames;
    NSMutableArray *temp = @[].mutableCopy;
    for (NSString *name in imageNames) {
        [temp addObject: [UIImage imageNamed:name]];
    }
    _images = temp;
    
}

/**
 *  视图销毁是或者移除屏幕时停止timer，防止视图未被释放
 */
- (void)willMoveToWindow:(UIWindow *)newWindow{
    [super willMoveToWindow:newWindow];
    if (newWindow) {
        [self setTimer];
    }else{
        [self stopTimer];
    }
}

#pragma mark - Timer

/**
 *  创建Timer
 */
- (void)setTimer{
    if (!_myTimer && _timerOpened) {
        _myTimer = [NSTimer scheduledTimerWithTimeInterval:_timerInterval target:self selector:@selector(timerEvent) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_myTimer forMode:NSRunLoopCommonModes];
    }
}
/**
 *  停止Timer
 */
- (void)stopTimer{
    if (_myTimer) {
        [_myTimer invalidate];
        _myTimer = nil;
        [self scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
}
#pragma mark - private Methods

- (void)timerEvent{
    if (self.contentOffset.x + self.bounds.size.width == self.contentSize.width) {//处理滚动到滚动到最后一张
        [self scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:self.cycleClosed];
        if (_cycleClosed) {
            return;
        }
    }
    [self scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_currentIndex + 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
}

- (void)updateUI{
    if (_hasInitialUI) {
        return;
    }
    if (!_cycleClosed) {
        if (_images) {
            NSMutableArray *temp= self.images.mutableCopy;
            [temp addObject:temp[0]];
            _images = temp;
            _totleCount = temp.count;
        }
        if (_imageUrlStrings) {
            NSMutableArray *urlTemp = self.imageUrlStrings.mutableCopy;
            [urlTemp addObject:urlTemp[0]];
            _imageUrlStrings = urlTemp;
            _totleCount = urlTemp.count;
        }
        NSMutableArray *titleTemp = self.titles.mutableCopy;
        [titleTemp addObject:titleTemp[0]];
        _titles = titleTemp;
    }else{
        if (_images) {
            _totleCount = _images.count;
        }
        if (_imageUrlStrings) {
            _totleCount = _imageUrlStrings.count;
        }
    }
    if (_timerOpened) {
        [self setTimer];
    }else{
        [self stopTimer];
    }
    [self initalizePageControl];
    _hasInitialUI = YES;
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    [self updateUI];
    return _totleCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    XWCycleViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if (!cell.cellConfiged) {//判断避免多次设置
        cell.mainView.contentMode = _contentMode;
        cell.titleLabel.textAlignment = _titleLabelAlignment;
        cell.titleLabel.textColor = _titleLabelTextColor;
        cell.titleLabel.backgroundColor = _titleLabelBackgroundColor;
        cell.titleLabel.frame = CGRectMake(0, self.bounds.size.height - 30, self.bounds.size.width, 30);
        cell.titleLabel.font = _titleLabelTextFont;
        cell.placeHodler = _placeHoldImage;
        cell.cellConfiged = YES;
        if (_titles && _titles.count) {
            cell.titleLabel.hidden = NO;
        }
    }
    if (_images && _images.count) {
        cell.mainView.image = _images[indexPath.item];
    }
    if (_imageUrlStrings && _imageUrlStrings.count) {
        cell.imgURL = _imageUrlStrings[indexPath.item];
    }
    if (_titleLabelAlignment == NSTextAlignmentLeft) {
        cell.titleLabel.text = [NSString stringWithFormat:@"  %@", _titles[indexPath.item]];
    }else{
        cell.titleLabel.text = _titles[indexPath.item];
    }
    return cell;
}
#pragma mark - <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger index = 0;
    if (_cycleClosed) {
        index = indexPath.item;
    }else{
        index = indexPath.item % (_totleCount - 1);
    }
    if ([_cycleViewDelegate respondsToSelector:@selector(cycleView:didSelectItemAtIndex:)]) {
        [_cycleViewDelegate cycleView:self didSelectItemAtIndex:index];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (_timerOpened) {
        [self stopTimer];
    }
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (_timerOpened) {
        [self setTimer];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (!_cycleClosed) {//开启了轮播才要处理
        if (scrollView.contentOffset.x < 0) {
            [self scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_totleCount - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        }
        if (scrollView.contentOffset.x > scrollView.frame.size.width * (_totleCount - 1)) {
            [self scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        }
    }
    if (_PageControlOpened) {//是否开启了pageControl，开启了才需要设置
        //这里%，保证开启循环多了一张图片仍在能正确显示，因为开启循环后的最后一张图就是第一张图,就不用分开判断了
        NSInteger currentIndex = (NSInteger)(round(scrollView.contentOffset.x / scrollView.frame.size.width)) % (_cycleClosed ? _totleCount : _totleCount - 1);
        _currentIndex = currentIndex;
        _pageControl.currentPage = currentIndex;
        
    }
}

#pragma mark - <UICollectionViewDelegateFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return collectionView.frame.size;
}

@end
