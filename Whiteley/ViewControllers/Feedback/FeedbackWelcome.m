//
//  FeedbackWelcome.m
//  Whiteley
//
//  Created by Alex Hong on 2/25/16.
//  Copyright © 2016 Alex Hong. All rights reserved.
//

#import "FeedbackWelcome.h"
#import "DCDefines.h"
#import "HomeViewController.h"

@interface FeedbackWelcome()
@property(strong, nonatomic) UIViewController *rootController;
@end

@implementation FeedbackWelcome
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
    
        [self setBackgroundColor:[UIColor clearColor]];
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(30, 125, 260, 177)];
        [backView setBackgroundColor:UIColorWithRGBA(239, 240, 240, 1)];
        
        UILabel *lblFB = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, 260, 18)];
        [lblFB setText:@"Thank you for your feedback!"];
        [lblFB setFont:[UIFont fontWithName:HFONT_MEDIUM size:16]];
        [lblFB setTextColor:UIColorWithRGBA(5, 181, 218, 1)];
        [lblFB setTextAlignment:NSTextAlignmentCenter];
        [backView addSubview:lblFB];
        
        UIButton *btnFB = [[UIButton alloc] initWithFrame:CGRectMake(12, 90, 236, 55)];
        [btnFB setImage:[UIImage imageNamed:@"feedback_welcome"] forState:UIControlStateNormal];
        [btnFB addTarget:self action:@selector(onClickFeedbackWelcome) forControlEvents:UIControlEventTouchUpInside];
        [backView addSubview:btnFB];
        
        [self addSubview:backView];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame ViewController:(UIViewController*)vc {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.rootController = vc;
        [self setBackgroundColor:[UIColor clearColor]];
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(30, 125, 260, 177)];
        [backView setBackgroundColor:UIColorWithRGBA(239, 240, 240, 1)];
        
        UILabel *lblFB = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, 260, 18)];
        [lblFB setText:@"Thank you for your feedback!"];
        [lblFB setFont:[UIFont fontWithName:HFONT_MEDIUM size:16]];
        [lblFB setTextColor:UIColorWithRGBA(5, 181, 218, 1)];
        [lblFB setTextAlignment:NSTextAlignmentCenter];
        [backView addSubview:lblFB];
        
        UIButton *btnFB = [[UIButton alloc] initWithFrame:CGRectMake(12, 90, 236, 55)];
        [btnFB setImage:[UIImage imageNamed:@"feedback_welcome"] forState:UIControlStateNormal];
        [btnFB addTarget:self action:@selector(onClickFeedbackWelcome) forControlEvents:UIControlEventTouchUpInside];
        [backView addSubview:btnFB];
        
        [self addSubview:backView];
    }
    
    return self;
}


- (void) onClickFeedbackWelcome {
    [self removeFromSuperview];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:nil forKey:WHITELEY_FEEDBACK];
    [userDefaults synchronize];
    
    if (self.rootController && [self.rootController isKindOfClass:[HomeViewController class]]) {
        HomeViewController *vc = (HomeViewController*)self.rootController;
        [vc.tableView setScrollEnabled:YES];
    }
}
@end
