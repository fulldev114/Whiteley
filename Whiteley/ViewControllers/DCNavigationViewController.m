//
//  DCNavigationViewController.m
//  Whiteley
//
//  Created by Alex Hong on 3/20/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import "DCNavigationViewController.h"

@implementation DCNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationBar.translucent = NO;
    self.navigationBar.barTintColor = APP_MAIN_COLOR;
    self.navigationBar.tintColor = [UIColor whiteColor];
    
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
