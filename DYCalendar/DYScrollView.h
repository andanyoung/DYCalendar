//
//  DYScrollView.h
//  KDLLock
//
//  Created by andy on 16/5/5.
//  Copyright © 2016年 Hangzhou LUXCON Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DYScrollView : UIView
/**
 *  点击事件回调Block
 */
@property (nonatomic, copy) void (^clickBlock)(NSInteger index);
@property (nonatomic, strong) NSArray<UIImageView *> *imgViews;
@property (nonatomic, strong) UIScrollView *scrollView;
/**
 *  是否支持点击手势
 */
@property (nonatomic, assign) BOOL tapGestureEnable;

/**
 *  刷新
 */
- (void) reloadScrollView;


/**
 *  使用工厂化方法一步创建DYScrollView，默认不支持点击手势
 *
 *  @param frame    frame
 *  @param imgViews 图片数组
 *
 *  @return 一个DYScrollView实例对象
 */
+ (instancetype)initWithFrame:(CGRect)frame andImgViews:(NSArray<UIImageView *> *)imgViews;
/**
 *  使用工厂化方法一步创建DYScrollView，默认支持点击手势
 *
 *  @param frame      frame
 *  @param imgViews   图片数组
 *  @param clickBlock 点击图片时的回调函数
 *
 *  @return 一个DYScrollView实例对象
 */
+ (instancetype)initWithFrame:(CGRect)frame andImgViews:(NSArray<UIImageView *> *)imgViews andClickBlock:(void(^)(NSInteger index)) clickBlock;
@end
