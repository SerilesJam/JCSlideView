//
//  JCSlidView.h
//  JCSlideViewDemo
//
//  Created by Jam on 16/3/4.
//  Copyright © 2016年 Jam. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JCSlideView;

@protocol JCSlideViewDataSource <NSObject>

@required
- (UIViewController *)JCSlideView:(JCSlideView *)slideView viewControllerAtIndex:(NSInteger)index;
- (NSInteger)numberOfViewConrollersInJCSlideView:(JCSlideView *)slideView;

@end

@interface JCSlideView : UIView

@property (nonatomic, weak) UIViewController *baseViewController;
@property (nonatomic, weak) id<JCSlideViewDataSource> dataSource;

- (void)showViewControllerAtIndex:(NSInteger)index;

@end
