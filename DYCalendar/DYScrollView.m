//
//  DYScrollView.m
//  KDLLock
//
//  Created by andy on 16/5/5.
//  Copyright © 2016年 Hangzhou LUXCON Technology Co.,Ltd. All rights reserved.
//

#import "DYScrollView.h"
#define KPageControlBootom 50
@interface DYScrollView()<UIScrollViewDelegate>
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@end
@implementation DYScrollView
- (void)setTapGestureEnable:(BOOL)tapGestureEnable{
    _tapGestureEnable = tapGestureEnable;
    
    if (tapGestureEnable) {
        [self.scrollView addGestureRecognizer:self.tapGesture];
    }else{
        [self.scrollView removeGestureRecognizer:_tapGesture];
    }
}
- (UITapGestureRecognizer *)tapGesture{
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
       // [self.scrollView addGestureRecognizer:_tapGesture];
    }
    return _tapGesture;
}
- (UIPageControl *)pageControl{
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        [self addSubview:_pageControl];
        _pageControl.center = self.center;
        CGRect frame = _pageControl.frame;
        frame.origin.y = self.frame.size.height - KPageControlBootom;
        _pageControl.frame = frame;
    }
    return _pageControl;
}

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.frame];
        [self addSubview:_scrollView];
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.alwaysBounceHorizontal = NO;
        _scrollView.bounces = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
    }
    return _scrollView;
}

- (void) reloadScrollView{
    
    CGRect frame = self.frame;
    self.scrollView.contentSize = CGSizeMake(frame.size.width * self.imgViews.count, 0);
    for (NSInteger i = 0; i < self.imgViews.count; i++) {
        
        UIImageView *imageView = self.imgViews[i];
       // imageView.tag = i;
        imageView.frame = CGRectMake(frame.size.width * i, 0, frame.size.width, frame.size.height);
        [self.scrollView addSubview:imageView];
       // imageView.userInteractionEnabled = YES;
    }
    
    self.pageControl.numberOfPages = self.imgViews.count;
    self.pageControl.currentPage = 0;
}

- (void) tapGesture:(UITapGestureRecognizer *)tap{
    CGPoint point = [tap locationInView:self.scrollView];
    //NSLog(@"point : %@",NSStringFromCGPoint(point));
    if (self.clickBlock) {
        self.clickBlock(point.x / self.bounds.size.width);
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGPoint offset = scrollView.contentOffset;
    //NSLog(@"point : %@",NSStringFromCGPoint(offset));
    self.pageControl.currentPage = offset.x / self.bounds.size.width;
}
+ (instancetype)initWithFrame:(CGRect)frame andImgViews:(NSArray<UIImageView *> *)imgViews{
    DYScrollView *scrollView = [[DYScrollView alloc] init];
    scrollView.frame = frame;
    scrollView.imgViews = imgViews;
    [scrollView reloadScrollView];
    //scrollView.tapGestureEnable = YES;
    return scrollView;
}
+ (instancetype)initWithFrame:(CGRect)frame andImgViews:(NSArray<UIImageView *> *)imgViews andClickBlock:(void(^)(NSInteger index)) clickBlock{
    
    DYScrollView *scrollView = [[DYScrollView alloc] init];
    scrollView.frame = frame;
    scrollView.imgViews = imgViews;
    scrollView.clickBlock = clickBlock;
    [scrollView reloadScrollView];
    scrollView.tapGestureEnable = YES;
    return scrollView;
}
@end
