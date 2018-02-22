//
//  FeedbackViewController.h
//  Whiteley
//
//  Created by Alex Hong on 1/13/16.
//  Copyright © 2016 Alex Hong. All rights reserved.
//

#import "DCBaseViewController.h"
#import "FeedbackWelcome.h"

@interface FeedbackViewController : DCBaseViewController
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *lblSkip;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;
@property (weak, nonatomic) IBOutlet UIButton *btnWalkYES;
@property (weak, nonatomic) IBOutlet UIButton *btnWalkNO;
@property (weak, nonatomic) IBOutlet UIButton *btnKidsYES;
@property (weak, nonatomic) IBOutlet UIButton *btnKidsNO;
@property (weak, nonatomic) IBOutlet UIButton *btnSuggestion;
@property (weak, nonatomic) IBOutlet UITextField *txtSuggestion;
@property (strong, nonatomic) FeedbackWelcome *viewFeedback;
@property (weak, nonatomic) IBOutlet UITextView *txtViewFeedback;

- (IBAction)onClickSelectPrice:(id)sender;
- (IBAction)onClickSubmitButton:(id)sender;
- (IBAction)onClickSkipButton:(id)sender;
- (IBAction)onClickWalkYESButton:(id)sender;
- (IBAction)onClickWalkNOButton:(id)sender;
- (IBAction)onClickKidsYESButton:(id)sender;
- (IBAction)onClickKidsNOButton:(id)sender;

@end
