//
//  MonsterFirstViewController.h
//  Whiteley
//
//  Created by Alex Hong on 4/21/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCBaseViewController.h"

typedef NS_ENUM(NSInteger, MONSTER_FIRST_PAGE_TYPE) {
    PLAY_TYPE = 0,
    HELP_TYPE = 1
};

@interface MonsterFirstViewController : DCBaseViewController
@property (strong, nonatomic) IBOutlet UIView *viewFirst;
@property (weak, nonatomic) IBOutlet UIImageView *imgMonster;
@property (weak, nonatomic) IBOutlet UIButton *btnStart;
@property (weak, nonatomic) IBOutlet UIImageView *imgLogo;
@property (weak, nonatomic) IBOutlet UITextView *lblEggs;
@property (weak, nonatomic) IBOutlet UILabel *lblTry;

@property (assign, nonatomic) NSInteger m_nType;

- (IBAction)onClickPlayButton:(id)sender;
- (IBAction)onClickHomeButton:(id)sender;

@end
