//
//  JCSlidView.m
//  JCSlideViewDemo
//
//  Created by Jam on 16/3/4.
//  Copyright © 2016年 Jam. All rights reserved.
//

#import "JCSlideView.h"

#define WeakObj(o) try{} @finally{} __weak typeof(o) o##Weak = o;
#define kPanOffsetXHold 120.0f

@interface JCSlideView ()

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) UIViewController *currentViewController;
@property (nonatomic, strong) UIViewController *willViewController;

@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) NSInteger lastPanIndex;
@property (nonatomic, assign) CGPoint panStartPoint;

@property (nonatomic, strong) NSLayoutConstraint *currentConstraintLeft;
@property (nonatomic, strong) NSLayoutConstraint *willConstraintLeft;

@property (nonatomic, strong) NSNumber *countOfViewControllers;

@end

@implementation JCSlideView

- (NSNumber *)countOfViewControllers {
    if (_countOfViewControllers == nil) {
        _countOfViewControllers = [NSNumber numberWithInteger:[_dataSource numberOfViewConrollersInJCSlideView:self]];
    }
    return _countOfViewControllers;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self setup];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setup];
    }
    
    return self;
}

- (void)setup {
    self.currentIndex = -1;
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self addGestureRecognizer:self.panGestureRecognizer];
}

- (void)showViewControllerAtIndex:(NSInteger)index {
    
    if (self.currentIndex == index) {
        return ;
    }
    
    UIViewController *viewController = [self.dataSource JCSlideView:self viewControllerAtIndex:index];
    [self.baseViewController addChildViewController:viewController];
    [viewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:viewController.view];
    
    NSDictionary *layoutViews = @{@"view":viewController.view};
    self.currentConstraintLeft = [NSLayoutConstraint constraintWithItem:viewController.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
    NSLayoutConstraint *layoutConstraintWith = [NSLayoutConstraint constraintWithItem:viewController.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
    NSArray *constraints_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:layoutViews];
    
    [self addConstraint:self.currentConstraintLeft];
    [self addConstraint:layoutConstraintWith];
    [self addConstraints:constraints_V];
    
    [viewController didMoveToParentViewController:self.baseViewController];
    
    self.currentIndex = index;
    self.currentViewController = viewController;
}


#pragma mark Hanle PanGestureRecognizer

- (void)handlePanGesture:(UIPanGestureRecognizer *)pan {
    
    CGPoint point = [pan translationInView:self];
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        self.panStartPoint = point;
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        
        //每次滑动重新布局
        [self layoutIfNeeded];
        
        NSInteger panIndex = -1;
        CGFloat panOffsetX = point.x - self.panStartPoint.x;
        if (panOffsetX > 0) {
            panIndex = self.currentIndex - 1;
        }
        if (panOffsetX < 0) {
            panIndex = self.currentIndex + 1;
        }
        
        if (panIndex < 0 || panIndex >= [self.countOfViewControllers integerValue]) {
            self.lastPanIndex = panIndex;
            [self handlerAnimationForOffsetx:panOffsetX];
        } else {
            if (panIndex != self.lastPanIndex) {
                self.lastPanIndex = panIndex;
                
                self.willViewController = [self.dataSource JCSlideView:self viewControllerAtIndex:panIndex];
                [self.baseViewController addChildViewController:self.willViewController];
                [self.willViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
                [self addSubview:self.willViewController.view];
                
                NSDictionary *layoutViews = @{@"view":self.willViewController.view};
                self.willConstraintLeft = [NSLayoutConstraint constraintWithItem:self.willViewController.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:self.bounds.size.width];
                NSLayoutConstraint *layoutConstraintWith = [NSLayoutConstraint constraintWithItem:self.willViewController.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
                NSArray *constraints_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:layoutViews];
                
                [self addConstraint:self.willConstraintLeft];
                [self addConstraint:layoutConstraintWith];
                [self addConstraints:constraints_V];
                
                [self.willViewController didMoveToParentViewController:self.baseViewController];
            }
            [self handlerAnimationForOffsetx:panOffsetX];
        }
    } else if (pan.state == UIGestureRecognizerStateEnded) {
        @WeakObj(self)
        CGFloat offsetX = point.x - self.panStartPoint.x;
        
        if (self.lastPanIndex >= 0 && self.lastPanIndex < [self.countOfViewControllers integerValue]) {
            if (fabs(offsetX) > kPanOffsetXHold) {
                NSTimeInterval animationTime = (self.bounds.size.width - fabs(offsetX)) / self.bounds.size.width*0.6;
                [self handlerAnimationForOffsetx:(offsetX > 0 ? self.bounds.size.width : -self.bounds.size.width)];
                [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                [UIView animateWithDuration:animationTime animations:^{
                    [self layoutIfNeeded];
                } completion:^(BOOL completion){
                    selfWeak.currentIndex = self.lastPanIndex;
                    [selfWeak removeCurrentViewController];
                    selfWeak.currentViewController = self.willViewController;
                    selfWeak.willViewController = nil;
                    selfWeak.currentConstraintLeft = selfWeak.willConstraintLeft;
                }];
            } else {
                [self handlerAnimationForOffsetx:0];
                self.lastPanIndex = self.currentIndex;
                NSTimeInterval animationTime = fabs(offsetX) / self.bounds.size.width*0.6;
                [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                [UIView animateWithDuration:animationTime animations:^{
                    [self layoutIfNeeded];
                } completion:^(BOOL completion){
                    [selfWeak backToCurrentViewController];
                }];
            }
        } else {
            [self handlerAnimationForOffsetx:0];
            NSTimeInterval animationTime = fabs(offsetX) / self.bounds.size.width*0.6;
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            [UIView animateWithDuration:animationTime animations:^{
                [self layoutIfNeeded];
            } completion:^(BOOL completion){
                [selfWeak backToCurrentViewController];
            }];
        }
    }
}

#pragma privateMethod

- (void)removeCurrentViewController {
    [self.currentViewController willMoveToParentViewController:nil];
    [self.currentViewController.view removeFromSuperview];
    [self.currentViewController removeFromParentViewController];
}

- (void)backToCurrentViewController {
    if (!self.willViewController) {
        return;
    }
    [self.willViewController willMoveToParentViewController:nil];
    [self.willViewController.view removeFromSuperview];
    [self.willViewController removeFromParentViewController];
    self.willViewController = nil;
}

- (void)handlerAnimationForOffsetx:(CGFloat)offsetx {
    
    CGFloat actualOffsetX = 0;
    
    if (self.lastPanIndex > self.currentIndex) {
        actualOffsetX = self.bounds.origin.x + self.bounds.size.width + offsetx;
    }
    
    if (self.lastPanIndex < self.currentIndex) {
        actualOffsetX = self.bounds.origin.x - self.bounds.size.width + offsetx;
    }
    
    self.currentConstraintLeft.constant = offsetx;
    if (self.lastPanIndex >= 0 && self.lastPanIndex < [self.countOfViewControllers integerValue]) {
        self.willConstraintLeft.constant = actualOffsetX;
    }
    
}

@end
