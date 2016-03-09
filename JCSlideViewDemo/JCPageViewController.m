//
//  JCPageViewController.m
//  JCSlideViewDemo
//
//  Created by Jam on 16/3/4.
//  Copyright © 2016年 Jam. All rights reserved.
//

#import "JCPageViewController.h"

@implementation JCPageViewController

- (void)dealloc{
    NSLog(@"dealloc %@", self.tagInfo);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSLog(@"page viewDidLoad %@", self.tagInfo);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    NSLog(@"page willAppear %@", self.tagInfo);
}

- (void)viewDidAppear:(BOOL)animated{
    NSLog(@"page Appear %@", self.tagInfo);
}

- (void)viewWillDisappear:(BOOL)animated{
    NSLog(@"page willDisappear %@", self.tagInfo);
}

- (void)viewDidDisappear:(BOOL)animated{
    NSLog(@"page Disappear %@", self.tagInfo);
}

- (IBAction)onClickButton:(id)sender {
    
    NSLog(@"click button tag %@", self.tagInfo);
}

@end
