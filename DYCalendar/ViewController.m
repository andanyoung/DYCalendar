//
//  ViewController.m
//  DYCalendar
//
//  Created by andy on 16/4/28.
//  Copyright © 2016年 ady. All rights reserved.
//

#import "ViewController.h"
#import "DYCalendarPicker.h"
#import "DYScrollView.h"
@interface ViewController ()

@property (weak, nonatomic) IBOutlet DYScrollView *scrollView;
@property (strong, nonatomic) IBOutlet DYCalendarPicker *calendarPicker;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    _scrollView.imgViews = @[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"introduce1"]],[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"introduce2"]],[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"introduce3"]],[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"introduce4"]]];
    [_scrollView reloadScrollView];
    _scrollView.tapGestureEnable = YES;
    _scrollView.clickBlock =  ^(NSInteger index){
        NSLog(@"%ld",index);
    };
    
    
}
- (IBAction)showAction:(id)sender {
    
    [DYCalendarPicker showOnView:self.view withSelectDate:nil withComplete:^(NSInteger day, NSInteger month, NSInteger year) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
