//
//  HereViewController.h
//  Whiteley
//
//  Created by Alex Hong on 3/31/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCBaseViewController.h"

@interface HereViewController : DCBaseViewController

@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UIButton *button2;
@property (weak, nonatomic) IBOutlet UIButton *button3;
@property (weak, nonatomic) IBOutlet UITextView *dcTextView;

- (IBAction)onButtonClicked:(UIButton *)sender;

@end
