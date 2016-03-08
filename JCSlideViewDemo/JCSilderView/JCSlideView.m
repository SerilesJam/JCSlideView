//
//  JCSlidView.m
//  JCSlideViewDemo
//
//  Created by Jam on 16/3/4.
//  Copyright © 2016年 Jam. All rights reserved.
//

#import "JCSlideView.h"

@interface JCSlideView ()

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

@end

@implementation JCSlideView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self setup];
    }
    
    return self;
}

- (void)setup {
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self addGestureRecognizer:self.panGestureRecognizer];
}

- (void)showViewControllerAtIndex:(NSInteger)index {
    UIViewController *viewController = [self.dataSource JCSlideView:self viewControllerAtIndex:index];
    [self.baseViewController addChildViewController:viewController];
    [viewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:viewController.view];
    
    
    [viewController didMoveToParentViewController:self.baseViewController];
}

#pragma mark Hanle PanGestureRecognizer

- (void)handlePanGesture:(UIPanGestureRecognizer *)pan {
    
}

@end
