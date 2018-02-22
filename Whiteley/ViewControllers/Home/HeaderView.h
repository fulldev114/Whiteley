//
//  HeaderView.h
//  Whiteley
//
//  Created by Alex Hong on 3/20/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TAPageControl.h>
#import "HomeViewController.h"

@interface HeaderView : UIView

@property (retain, nonatomic) IBOutlet UIScrollView *imageScroller;
@property (nonatomic) UIImageView *bluredImageView;
@property (strong, nonatomic) UIViewController *homeController;
@property (nonatomic, strong) NSMutableArray *aryHomeCarousel;
@property (nonatomic, strong) TAPageControl* pageControl;

+ (id)headerViewWithData:(NSMutableArray*)aryData Delegate:(UIViewController*)delegate;
- (void)layoutHeaderViewForScrollViewOffset:(CGPoint)offset;
- (void)refreshBlurViewForNewImage;

@end
