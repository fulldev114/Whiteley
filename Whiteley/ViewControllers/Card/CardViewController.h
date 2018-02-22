//
//  CardViewController.h
//  Whiteley
//
//  Created by Alex Hong on 3/31/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import "DCBaseViewController.h"

@interface CardViewController : DCBaseViewController

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextView *dcTextView;
@property (weak, nonatomic) IBOutlet UIButton *btnOrder;
@property (weak, nonatomic) IBOutlet UIButton *btnCheck;
@property (weak, nonatomic) IBOutlet UIButton *btnTerm;
- (IBAction)onClickOrderButton:(id)sender;
- (IBAction)onClickTermButton:(id)sender;
- (IBAction)onClickCheckButton:(id)sender;

@end
