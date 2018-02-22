//
//  MonsterHelpViewController.m
//  Whiteley
//
//  Created by Alex Hong on 5/16/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import "MonsterHelpViewController.h"

@interface MonsterHelpViewController ()<UIScrollViewDelegate>

@end

@implementation MonsterHelpViewController
@synthesize imgScrollView;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    imgScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 82, 320, 388)];
    [imgScrollView setShowsHorizontalScrollIndicator:NO];
    [self.view addSubview:imgScrollView];

    for (int i = 0; i < 3; i++) {
        
        NSString *strImage = [NSString stringWithFormat:@"monster_help%ld", (long)i+1];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(320 * i + 30, 0, 260, 388)];
        imageView.clipsToBounds = YES;
        imageView.image = [UIImage imageNamed:strImage];
        [imgScrollView addSubview:imageView];
    }
    
    imgScrollView.contentSize = CGSizeMake(320 * 3, 388);
    imgScrollView.pagingEnabled = YES;
    imgScrollView.delegate = self;
    
    TAPageControl* pageControl = [[TAPageControl alloc] initWithFrame:CGRectMake(0, 82 + 26, 320, 11)];
    pageControl.numberOfPages   = 3;
    // Custom dot view with image
    pageControl.dotSize = CGSizeMake(8, 8);
    pageControl.dotImage        = [UIImage imageNamed:@"monster_dot_small"];
    pageControl.currentDotImage = [UIImage imageNamed:@"monster_dot_big"];
    pageControl.spacingBetweenDots = 9;
    pageControl.userInteractionEnabled = NO;
    
    [self.view addSubview:pageControl];
    
    self.pageControl = pageControl;
    
}


- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onClickNextButton:(id)sender {
    NSInteger pageIndex = self.pageControl.currentPage;
    if (pageIndex == 2) {
        [self onClickCloseButton:nil];
    }
    else
    {
        [imgScrollView setContentOffset:CGPointMake(320 * (pageIndex + 1), 0) animated:YES];
        self.pageControl.currentPage = pageIndex + 1;
    }
}

- (IBAction)onClickCloseButton:(id)sender {
    [self removeSubViews];
    UIViewController *vc = nil;
    vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MonsterListViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger pageIndex = scrollView.contentOffset.x / CGRectGetWidth(scrollView.frame);
    
    self.pageControl.currentPage = pageIndex;
}

- (void) removeSubViews {
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            UIImageView *imgView = (UIImageView*)view;
            imgView.image = nil;
        }
        [view removeFromSuperview];
    }
    
    for (UIView *view in self.imgScrollView.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            UIImageView *imgView = (UIImageView*)view;
            imgView.image = nil;
        }
        [view removeFromSuperview];
    }
}

@end
