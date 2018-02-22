//
//  MonsterHelpViewController.h
//  Whiteley
//
//  Created by Alex Hong on 5/16/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import "DCBaseViewController.h"
#import <TAPageControl.h>

@interface MonsterHelpViewController : DCBaseViewController
- (IBAction)onClickNextButton:(id)sender;
- (IBAction)onClickCloseButton:(id)sender;
@property (retain, nonatomic) UIScrollView *imgScrollView;
@property (nonatomic, strong) TAPageControl* pageControl;

@end
