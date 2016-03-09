//
//  JCSlidView.m
//  JCSlideViewDemo
//
//  Created by Jam on 16/3/4.
//  Copyright © 2016年 Jam. All rights reserved.
//

#import "JCSlideView.h"

#define kPanOffsetXHold 64.0f

@interface JCSlideView ()

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) UIViewController *currentViewController;
@property (nonatomic, strong) UIViewController *willViewController;

@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) NSInteger lastPanIndex;
@property (nonatomic, assign) CGPoint panStartPoint;

@property (nonatomic, strong) NSLayoutConstraint *currentConstraintLeft;
@property (nonatomic, strong) NSLayoutConstraint *willConstraintLeft;

@end

@implementation JCSlideView

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
        [self.currentViewController beginAppearanceTransition:NO animated:YES];
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
            
            [self handlerAnimationForOffsetx:panOffsetX];
        } else {
            [self handlerAnimationForOffsetx:panOffsetX];
        }
    } else if (pan.state == UIGestureRecognizerStateEnded) {
        
        CGFloat offsetX = point.x - self.panStartPoint.x;
        
        if (fabs(offsetX) > kPanOffsetXHold) {
            NSTimeInterval animationTime = (self.bounds.size.width - fabs(offsetX)) / self.bounds.size.width*0.6;
            [self handlerAnimationForOffsetx:(offsetX > 0 ? self.bounds.size.width : -self.bounds.size.width)];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            [UIView animateWithDuration:animationTime animations:^{
                [self layoutIfNeeded];
            } completion:^(BOOL completion){
                self.currentIndex = self.lastPanIndex;
                [self removeCurrentViewController];
                self.currentViewController = nil;
                self.currentViewController = self.willViewController;
                self.willViewController = nil;
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

- (void)handlerAnimationForOffsetx:(CGFloat)offsetx {
    
    CGFloat actualOffsetX = 0;
    
    if (self.lastPanIndex > self.currentIndex) {
        actualOffsetX = self.bounds.origin.x + self.bounds.size.width + offsetx;
    }
    
    if (self.lastPanIndex < self.currentIndex) {
        actualOffsetX = self.bounds.origin.x - self.bounds.size.width + offsetx;
    }
    
    self.currentConstraintLeft.constant = offsetx;
    self.willConstraintLeft.constant = actualOffsetX;
}

@end
