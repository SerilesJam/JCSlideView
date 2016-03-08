//
//  JCPageViewController.m
//  JCSlideViewDemo
//
//  Created by Jam on 16/3/4.
//  Copyright © 2016年 Jam. All rights reserved.
//

#import "JCPageViewController.h"

@implementation JCPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSLog(@"page viewDidLoad");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    NSLog(@"page willAppear");
}

- (void)viewDidAppear:(BOOL)animated{
    NSLog(@"page Appear");
}

- (void)viewWillDisappear:(BOOL)animated{
    NSLog(@"page willDisappear");
}

- (void)viewDidDisappear:(BOOL)animated{
    NSLog(@"page Disappear");
}

@end
