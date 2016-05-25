//
//  DYCalendarPicker.m
//  DYCalendar
//
//  Created by andy on 16/4/28.
//  Copyright © 2016年 ady. All rights reserved.
//

#define KPickHight 350
#define KPickDistance 10
#define kPickBtnHeight 44
#define KTitleViewHeight 44
#define KDateStrSize 16

#define KTitleBtnWidth 15
#define KTitleBtnHeight 18

#define kWeakSelf __weak typeof(self) weakSelf = self;

#import "DYCalendarPicker.h"

@interface DYCalendarCell : UICollectionViewCell
@property (nonatomic, assign) DYResultColor resultColor;
@property (nonatomic, strong) UIBezierPath *path;
@property (nonatomic, strong) NSString *dateStr;
@property (nonatomic, strong) NSDictionary *strAttrbutes;
@end

@implementation DYCalendarCell

- (NSDictionary *)strAttrbutes{
    if (!_strAttrbutes) {
        _strAttrbutes = @{
                          NSFontAttributeName:[UIFont systemFontOfSize:KDateStrSize],
                          //前景色(字体颜色)
                          NSForegroundColorAttributeName :[UIColor blackColor],
                          };
    }
    return _strAttrbutes;
}
    
- (UIBezierPath *)path{
    if (!_path) {
        _path = [UIBezierPath bezierPath];
        CGRect rect = self.frame;
        [_path addArcWithCenter:CGPointMake(rect.size.width/2.0, rect.size.height/2.0) radius:MIN(rect.size.height, rect.size.width)/2.0- 4 startAngle:0 endAngle:M_PI *2.0 clockwise:YES];
    }
    return _path;
}
-(void)drawRect:(CGRect)rect{

    //dateStr
    CGRect newFrame = [self.dateStr boundingRectWithSize:CGSizeMake(9999, 9999) options:NSStringDrawingUsesLineFragmentOrigin attributes:self.strAttrbutes context:nil];
    //设置背景图
    if (DYResultSelectedColor == _resultColor) {
        [[UIColor redColor]setFill];
        [self.path fill];
        [_dateStr drawAtPoint:CGPointMake((rect.size.width - newFrame.size.width)/2.0, (rect.size.height - newFrame.size.height)/2.0) withAttributes:@{
                                                                                                                                                       NSFontAttributeName:[UIFont systemFontOfSize:KDateStrSize],
                                                                                                                                                       //前景色(字体颜色)
                                                                                                                                                       NSForegroundColorAttributeName :[UIColor whiteColor],
                                                                                                                                                       }];
    }else{
        
        [[UIColor clearColor] setFill];
        [self.path fill];
    if (DYResultGray == _resultColor) {
        _strAttrbutes = @{
                          NSFontAttributeName:[UIFont systemFontOfSize:18],
                          //前景色(字体颜色)
                          NSForegroundColorAttributeName :[UIColor colorWithRed:203.0/255 green:203.0/255 blue:203.0/255 alpha:1]
                          };
    }else{
        _strAttrbutes = @{
                          NSFontAttributeName:[UIFont systemFontOfSize:18],
                          //前景色(字体颜色)
                          NSForegroundColorAttributeName :[UIColor blackColor]
                          };
    }
        [_dateStr drawAtPoint:CGPointMake((rect.size.width - newFrame.size.width)/2.0, (rect.size.height - newFrame.size.height)/2.0) withAttributes:_strAttrbutes];
    }
}

@end

@interface DYCalendarPicker ()<UICollectionViewDelegate,UICollectionViewDataSource>
/** 当前页的date */
@property (nonatomic, strong) NSDate *date;
/** 现在的date（本地） */
@property (nonatomic, strong) NSDate *currentDate;
/** 所选择的date（初始化传入） */
@property (nonatomic, strong) NSDate *selectedDate;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic , strong) UILabel *monthLabel;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) NSCalendar *calendar;
@property (nonatomic , strong) NSArray *weekDayArray;
@property (nonatomic, copy) void(^calendarBlock)(NSInteger day, NSInteger month, NSInteger year);
@property (nonatomic, weak) DYCalendarCell *selectedCell;
@property (nonatomic , strong) UIView *mask;


@end

@implementation DYCalendarPicker

#pragma mark -- show or hide
+ (instancetype)showOnView:(UIView *)view withSelectDate:(NSDate *)selecteDate withComplete:(void(^)(NSInteger day, NSInteger month, NSInteger year))calendarBlock{
    
    UIView *mask = [[UIView alloc] initWithFrame:view.bounds];
    mask.backgroundColor = [UIColor blackColor];
    mask.alpha = 0.3;
    [view addSubview:mask];
    UIView *contentView = [[UIView alloc]init];
    contentView.frame = CGRectMake( KPickDistance,view.bounds.size.height  - KPickDistance - KPickHight, view.bounds.size.width - KPickDistance * 2.0, KPickHight);
    [view addSubview:contentView];
    contentView.backgroundColor = [UIColor clearColor];
    DYCalendarPicker *calendarPicker = [[DYCalendarPicker alloc]initWithFrame:CGRectMake( 0,0, contentView.frame.size.width, KPickHight- KPickDistance - kPickBtnHeight)];
    
    calendarPicker.currentDate = [[NSDate alloc] init];
    if (!selecteDate) {
        selecteDate = calendarPicker.currentDate;
    }
    calendarPicker.date = selecteDate;
    calendarPicker.selectedDate = selecteDate;
    
    calendarPicker.mask = mask;
    calendarPicker.contentView = contentView;
    [contentView addSubview:calendarPicker];
    [calendarPicker show];
    calendarPicker.calendarBlock = calendarBlock;
    UIButton *cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, calendarPicker.frame.origin.y + calendarPicker.frame.size.height   + KPickDistance, calendarPicker.frame.size.width, kPickBtnHeight)];
    [cancelBtn setTitle:@"Cancel" forState:0];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:0];
    cancelBtn.layer.cornerRadius = 10.0;
    cancelBtn.backgroundColor = [UIColor redColor];
    [contentView addSubview:cancelBtn];
    [cancelBtn addTarget:calendarPicker action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    return calendarPicker;
}

- (void)show{
    
    kWeakSelf
    self.contentView.transform = CGAffineTransformTranslate(self.contentView.transform, 0,  self.frame.size.height);
    [UIView animateWithDuration:0.5 animations:^(void) {
        weakSelf.contentView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL isFinished) {
        [weakSelf addGestureRecognizer];
    }];
}

- (void)addGestureRecognizer{
    
    UISwipeGestureRecognizer *swipLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(nextAction:)];
    swipLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:swipLeft];
    
    UISwipeGestureRecognizer *swipRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(previouseAction:)];
    swipRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:swipRight];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    [self.mask addGestureRecognizer:tap];
    self.layer.cornerRadius = 10.0;
    self.clipsToBounds = YES;
}
- (void)hide{
    kWeakSelf
    [UIView animateWithDuration:0.5 animations:^(void) {
        weakSelf.contentView.transform = CGAffineTransformTranslate(self.contentView.transform, 0,  self.contentView.frame.size.height);
        weakSelf.mask.alpha = 0;
    } completion:^(BOOL isFinished) {
        [weakSelf.mask removeFromSuperview];
        [weakSelf removeFromSuperview];
        [weakSelf.contentView  removeFromSuperview];
        weakSelf.contentView = nil;
    }];
}
- (void)previouseAction:(UIButton *)sender
{
    kWeakSelf
    [UIView transitionWithView:self duration:0.5 options:UIViewAnimationOptionTransitionCurlDown animations:^(void) {
        weakSelf.date = [self lastMonth:self.date];
    } completion:^(BOOL finished) {
        [weakSelf reloadData];
    }];
}

- (void)nextAction:(UIButton *)sender
{
    kWeakSelf
    [UIView transitionWithView:self duration:0.5 options:UIViewAnimationOptionTransitionCurlUp animations:^(void) {
        weakSelf.date = [self nextMonth:self.date];
    } completion:nil];
}
- (void)reloadData{
    if(_date == nil) _date = self.currentDate;
    [self.collectionView reloadData];
   // [self layoutIfNeeded];
}

#pragma mark -- layz init

- (UILabel *)monthLabel{
    if (!_monthLabel) {
        
        UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, KTitleViewHeight)];
        [self addSubview:titleView];
        titleView.backgroundColor = [UIColor redColor];
        _monthLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.bounds.size.width/4.0, 0, self.bounds.size.width/2.0, KTitleViewHeight)];
        _monthLabel.textAlignment = NSTextAlignmentCenter;
        [titleView addSubview:_monthLabel];
        
        UIButton *nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(_monthLabel.frame.origin.x + _monthLabel.frame.size.width + 8, titleView.center.y - KTitleBtnHeight/2.0, KTitleBtnWidth, KTitleBtnHeight)];
        [nextBtn setBackgroundImage:[UIImage imageNamed:@"dateNext_default"] forState:0];
        [nextBtn setBackgroundImage:[UIImage imageNamed:@"datepNext_pressed"] forState:UIControlStateHighlighted];
        [nextBtn addTarget:self action:@selector(nextAction:) forControlEvents:UIControlEventTouchUpInside];
        [titleView addSubview:nextBtn];
        UIButton *pretBtn = [[UIButton alloc] initWithFrame:CGRectMake(_monthLabel.frame.origin.x - KTitleBtnWidth - 8, titleView.center.y - KTitleBtnHeight/2.0, KTitleBtnWidth, KTitleBtnHeight)];
        [pretBtn setBackgroundImage:[UIImage imageNamed:@"datePrevious_default"] forState:0];
        [pretBtn setBackgroundImage:[UIImage imageNamed:@"datePrevious_pressed"] forState:UIControlStateHighlighted];
        [pretBtn addTarget:self action:@selector(previouseAction:) forControlEvents:UIControlEventTouchUpInside];
        [titleView addSubview:pretBtn];
    }
    return _monthLabel;
}

- (UICollectionView *)collectionView{
    
    if (!_collectionView) {
        CGFloat itemWidth = self.bounds.size.width / 7;
        CGFloat itemHeight = (self.bounds.size.height - KTitleViewHeight)/ 7;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        layout.itemSize = CGSizeMake(itemWidth, itemHeight);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, KTitleViewHeight, self.bounds.size.width, self.bounds.size.height - KTitleViewHeight) collectionViewLayout:layout];
        [self addSubview:_collectionView];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.scrollEnabled = NO;
        [_collectionView registerClass:[DYCalendarCell class] forCellWithReuseIdentifier:@"Cell"];
        _collectionView.backgroundColor = [UIColor whiteColor];
    }
    return _collectionView;
}

- (void)setDate:(NSDate *)date{
    _date = date;
    
    [self.monthLabel setText:[NSString stringWithFormat:@"%ld年 %.2ld月",(long)[self year:date],(long)[self month:date]]];
    [self.collectionView reloadData];
    
}

- (NSCalendar *)calendar{
    if (!_calendar) {
        _calendar = [NSCalendar currentCalendar];
    }
    return _calendar;
}

- (NSArray *)weekDayArray{
    
    if (!_weekDayArray) {
        _weekDayArray = @[@"日",@"一",@"二",@"三",@"四",@"五",@"六"];
    }
    return _weekDayArray;
}


#pragma mark -- Calendar
/**
 *  计算所给的月总共有几天
 *
 *  @param date date
 *
 *  @return 该月的总天数
 */
- (NSInteger)totaldaysInThisMonth:(NSDate *)date{
    
    NSRange totaldaysInMonth = [self.calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    return totaldaysInMonth.length;
}

/**
 *  计算第一天是周几
 *
 */
- (NSInteger)firstWeekdayInThisMonth:(NSDate *)date{
    
    [self.calendar setFirstWeekday:1];//1.Sun. 2.Mon. 3.Thes. 4.Wed. 5.Thur. 6.Fri. 7.Sat.
    NSDateComponents *comp = [self.calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    [comp setDay:1];
    NSDate *firstDayOfMonthDate = [self.calendar dateFromComponents:comp];
    
    NSUInteger firstWeekday = [self.calendar ordinalityOfUnit:NSCalendarUnitWeekday inUnit:NSCalendarUnitWeekOfMonth forDate:firstDayOfMonthDate];
    return firstWeekday - 1;
}


- (NSInteger)totaldaysInMonth:(NSDate *)date{
    NSRange daysInLastMonth = [self.calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    return daysInLastMonth.length;
}

- (NSDate *)lastMonth:(NSDate *)date{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = -1;
    NSDate *newDate = [self.calendar dateByAddingComponents:dateComponents toDate:date options:0];
    return newDate;
}

- (NSDate*)nextMonth:(NSDate *)date{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = +1;
    NSDate *newDate = [self.calendar dateByAddingComponents:dateComponents toDate:date options:0];
    return newDate;
}


- (NSInteger)day:(NSDate *)date{
    
    NSDateComponents *components = [self.calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    return [components day];
}


- (NSInteger)month:(NSDate *)date{
    NSDateComponents *components = [self.calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    return [components month];
}

- (NSInteger)year:(NSDate *)date{
    NSDateComponents *components = [self.calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    return [components year];
}

- (DYResultColor)isEqualToDateWithSelectDay:(NSInteger) day{

    NSDateComponents *dateComponents = [self.calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:_date];//当前页时间
    NSDateComponents *selectedComponents = [self.calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:_selectedDate];//选择的时间
    NSDateComponents *currentComponents = [self.calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:_currentDate];//现在的时间
    
    if (day == [selectedComponents day] &&  ([dateComponents year] == [selectedComponents year] && [dateComponents month] == [selectedComponents month])){
        return DYResultSelectedColor;
    }
    
    if ([dateComponents year] < [currentComponents year] || ([dateComponents year] == [currentComponents year] && [dateComponents month] < [currentComponents month])) {
        
        return DYResultBlack;
    }else if ([dateComponents year] == [currentComponents year] && [dateComponents month] == [currentComponents month]){
       
       if (day <=  [currentComponents day]){
            return DYResultBlack;
        }else{
            return DYResultGray;
        }
    }
    else {
        return DYResultGray;
    }
}

#pragma mark -- UICollectionViewDelegate,UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (section) {
        return 42;//_weekDayArray.count
    }else{
        return 7;
    }
    
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    DYCalendarCell *cell = (DYCalendarCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    if (indexPath.section == 0) {
        cell.dateStr = self.weekDayArray[indexPath.row];
        cell.resultColor = DYResultBlack;
    }else{
        
        NSInteger daysInThisMonth = [self totaldaysInMonth:_date];
        NSInteger firstWeekday = [self firstWeekdayInThisMonth:_date];
        NSInteger day = 0;
        NSInteger i = indexPath.row;
        if (i < firstWeekday) {
             cell.dateStr = @"";
             cell.resultColor = DYResultGray;
            
        }else if (i > firstWeekday + daysInThisMonth - 1){
            cell.dateStr = @"";
             cell.resultColor = DYResultGray;
        }else{
            day = i - firstWeekday + 1;
            cell.dateStr = [NSString stringWithFormat:@"%ld",day];
            DYResultColor resultColor =[self isEqualToDateWithSelectDay:day];
            cell.resultColor = resultColor;
             if (resultColor == DYResultSelectedColor) {
                self.selectedCell = cell;
            }
        }
    }
    
    cell.backgroundColor = [UIColor whiteColor];
    [cell setNeedsDisplay];
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 2;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    DYCalendarCell *cell = (DYCalendarCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (cell.resultColor == DYResultGray || indexPath.section == 0) {
        return;
    }
    if (cell != _selectedCell) {
        
        _selectedCell.resultColor = DYResultBlack;
        cell.resultColor = DYResultSelectedColor;
        [_selectedCell setNeedsDisplay];
        [cell setNeedsDisplay];
    }
    
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:self.date];
    NSInteger firstWeekday = [self firstWeekdayInThisMonth:_date];
    
    NSInteger day = 0;
    NSInteger i = indexPath.row;
    day = i - firstWeekday + 1;
    if (self.calendarBlock) {
        self.calendarBlock(day, [comp month], [comp year]);
    }
    [self hide];
}
@end
