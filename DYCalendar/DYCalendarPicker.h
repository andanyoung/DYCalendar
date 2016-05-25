//
//  DYCalendarPicker.h
//  DYCalendar
//
//  Created by andy on 16/4/28.
//  Copyright © 2016年 ady. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, DYResultColor) {
    DYResultNone = -1,
    DYResultGray = 1,
    DYResultBlack,
    DYResultSelectedColor
};
@interface DYCalendarPicker : UIView

+ (instancetype)showOnView:(UIView *)view withSelectDate:(NSDate *)selecteDate withComplete:(void(^)(NSInteger day, NSInteger month, NSInteger year))calendarBlock;
@end
