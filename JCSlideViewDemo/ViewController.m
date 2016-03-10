//
//  ViewController.m
//  JCSlideViewDemo
//
//  Created by Jam on 16/3/4.
//  Copyright © 2016年 Jam. All rights reserved.
//

#import "ViewController.h"
#import "JCPageViewController.h"
#import "JCSlideView.h"

@interface ViewController () <JCSlideViewDataSource>

@property (weak, nonatomic) IBOutlet JCSlideView *slideView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.slideView.baseViewController = self;
    self.slideView.dataSource = self;
    
    [self.slideView showViewControllerAtIndex:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark JCSlideViewDataSource

- (UIViewController *)JCSlideView:(JCSlideView *)slideView viewControllerAtIndex:(NSInteger)index {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    JCPageViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:@"PageViewController"];
    viewController.tagInfo = [NSString stringWithFormat:@"%ld", index];
    int32_t rgbValue = rand();
    viewController.view.backgroundColor = [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
    
    return viewController;
}

- (NSInteger)numberOfViewConrollersInJCSlideView:(JCSlideView *)slideView {
    return 5;
}

@end
