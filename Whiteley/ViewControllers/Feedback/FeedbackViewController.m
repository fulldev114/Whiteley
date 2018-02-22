//
//  FeedbackViewController.m
//  Whiteley
//
//  Created by Alex Hong on 1/13/16.
//  Copyright © 2016 Alex Hong. All rights reserved.
//

#import "FeedbackViewController.h"
#import "HomeViewController.h"

#define PICKER_HEIGHT       220
#define NAVBAR_HEIGHT       64
#define TOOL_BAR_HEIGHT     45
#define KEYBOARD_HEIGHT     216
#define PRE_PRICE_TEXT      @"Select price range"
#define PRE_FREQ_TEXT       @"Select frequency"

@interface FeedbackViewController () <UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate, UITextFieldDelegate>
{
    UIPickerView    *picker;
    UIToolbar       *pickerDone;

    NSString        *strPrice;
    NSString        *strWalk;
    NSString        *strKids;
    NSArray         *aryPickerPrice;
    NSArray         *aryPickerFreq;
    
    CGPoint         scrollOffset;
}
@end


@implementation FeedbackViewController
@synthesize scrollView, lblSkip, viewFeedback;
@synthesize btnSuggestion, btnSubmit;
@synthesize btnWalkYES, btnWalkNO, btnKidsYES, btnKidsNO;
@synthesize txtSuggestion, txtViewFeedback;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [scrollView setFrame:CGRectMake(0, 0, 320, self.view.frame.size.height - 44)];
    [scrollView setContentSize:CGSizeMake(320, 700)];
    
    btnKidsYES.layer.borderWidth = 0.5;
    btnKidsYES.layer.borderColor = UIColorWithRGBA(151, 151, 151, 1).CGColor;
    btnKidsNO.layer.borderWidth = 0.5;
    btnKidsNO.layer.borderColor = UIColorWithRGBA(151, 151, 151, 1).CGColor;
    
    btnSuggestion.layer.borderWidth = 0.5;
    btnSuggestion.layer.borderColor = UIColorWithRGBA(151, 151, 151, 1).CGColor;
    btnSuggestion.layer.cornerRadius = 3;
    btnWalkYES.layer.borderWidth = 0.5;
    btnWalkYES.layer.borderColor = UIColorWithRGBA(151, 151, 151, 1).CGColor;
    btnWalkNO.layer.borderWidth = 0.5;
    btnWalkNO.layer.borderColor = UIColorWithRGBA(151, 151, 151, 1).CGColor;
    
    txtViewFeedback.layer.borderWidth = 0.5;
    txtViewFeedback.layer.borderColor = UIColorWithRGBA(151, 151, 151, 1).CGColor;
    txtViewFeedback.layer.cornerRadius = 3;
    
    NSString *strFilter = @"Skip";
    NSMutableAttributedString *attrString1 = [[NSMutableAttributedString alloc] initWithString:strFilter];
    
    [attrString1 addAttributes:@{
                                 NSForegroundColorAttributeName : UIColorWithRGBA(5, 181, 218, 1),
                                 NSFontAttributeName : [UIFont fontWithName:HFONT_ULTRA_LIGHT size:16],
                                 NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)
                                 }
                         range:NSMakeRange(0, strFilter.length)];
    lblSkip.attributedText = attrString1;
    [lblSkip sizeToFit];
    
    aryPickerPrice = [NSArray arrayWithObjects:@"Nothing", @"under £10", @"under £50", @"over £50", nil];
    aryPickerFreq = [NSArray arrayWithObjects:@"Once every few months", @"Once a year", @"Never", @"Everyday", @"Once a week", @"Twice a week", @"Once a month", nil];

    picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - NAVBAR_HEIGHT - PICKER_HEIGHT, 320, PICKER_HEIGHT)];
    [picker setBackgroundColor:UIColorWithRGBA(211, 210, 209, 1)];
    [picker setTintColor:UIColorWithRGBA(41, 41, 41, 1)];
    [picker setHidden:YES];
    [picker setDelegate:self];
    [picker setDataSource:self];
    
    pickerDone = [[UIToolbar alloc] init];
    [pickerDone sizeToFit];
    UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                       target:nil action:nil];
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc]
                                       initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(onClickPickerDoneButton)];
    pickerDone.items = @[flexBarButton, doneBarButton];
    [pickerDone setTintColor:UIColorWithRGBA(0, 122, 255, 1)];
    
    strWalk = @"";
    strKids = @"";
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark TextView
-(BOOL) textViewShouldBeginEditing:(UITextView *)textView {

    [scrollView setScrollEnabled:NO];

    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = CGRectMake(0, 0, scrollView.frame.size.width, scrollView.frame.size.height);
        NSInteger offsetY = KEYBOARD_HEIGHT + TOOL_BAR_HEIGHT + 10;
        [scrollView setFrame:CGRectMake(0, -offsetY, rect.size.width, rect.size.height)];
        scrollOffset = scrollView.contentOffset;
        if ([DCDefines isiPHone4])
            [scrollView setContentOffset:CGPointMake(0, 80)];
        else
            [scrollView setContentOffset:CGPointMake(0, 0)];
    } completion:^(BOOL finished) {
        [pickerDone setFrame:CGRectMake(0, SCREEN_HEIGHT - KEYBOARD_HEIGHT - TOOL_BAR_HEIGHT - NAVBAR_HEIGHT, 320, TOOL_BAR_HEIGHT)];
        [self.view addSubview:pickerDone];
    }];
    return YES;
}

#pragma mark TextField
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {

    CGRect rect = txtSuggestion.frame;
    [pickerDone removeFromSuperview];
    [scrollView setScrollEnabled:NO];

    NSInteger posY = rect.origin.y + rect.size.height + 64;
    if (SCREEN_HEIGHT - posY < KEYBOARD_HEIGHT) {
        [UIView animateWithDuration:0.3f animations:^{
            NSInteger offsetY;
            if ([DCDefines isiPHone4])
                offsetY = 163;
            else
                offsetY = 75;

            [scrollView setFrame:CGRectMake(0, -offsetY, scrollView.frame.size.width, scrollView.frame.size.height)];
        }];
    }
#if 0
    if (SCREEN_HEIGHT - posY < KEYBOARD_HEIGHT) {
        [UIView animateWithDuration:0.3f animations:^{
            CGRect viewRect = self.view.frame;
            viewRect.origin.y -= KEYBOARD_HEIGHT - (SCREEN_HEIGHT - posY) + 10;
            [self.view setFrame:viewRect];
        }];
    }
#endif
    
    
    return YES;
};

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [txtSuggestion resignFirstResponder];
    
    [scrollView setScrollEnabled:YES];

    CGRect rect = scrollView.frame;
    if (rect.origin.y < 0) {
        [UIView animateWithDuration:0.3 animations:^{
            [scrollView setFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
        }];
    }

    return YES;
}


#pragma mark Picker DataSource/Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return aryPickerPrice.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *optionForRow = @"";
    
    optionForRow =[aryPickerPrice objectAtIndex:row];
    
    return optionForRow;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    strPrice =[aryPickerPrice objectAtIndex:row];

}

// Buttons Action
- (void) onClickPickerDoneButton {
    [self showPickerView:NO];
    
    //[btnSelectPrice setTitleColor:UIColorWithRGBA(5, 181, 218, 1) forState:UIControlStateNormal];
    //[btnSelectPrice setTitle:strPrice forState:UIControlStateNormal];
    
    //[self validateFeedbackData];
    
}

- (IBAction)onClickSelectPrice:(id)sender {
    
//    if ( [btnSelectPrice.titleLabel.text isEqualToString:PRE_PRICE_TEXT] ) {
//        [picker selectRow:0 inComponent:0 animated:NO];
//    }
//    else {
//        NSInteger index = [aryPickerPrice indexOfObject:strPrice];
//        [picker selectRow:index inComponent:0 animated:NO];
//    }
//    
//    [self showPickerView:YES];
}

#pragma mark Submit
- (IBAction)onClickSubmitButton:(id)sender {
    
    if (!btnSubmit.selected) {
        return;
    }
        
    if ([strPrice isEqualToString:@"under £10"])
        strPrice = @"under 10 GBP";
    else if ([strPrice isEqualToString:@"under £50"])
        strPrice = @"under 50 GBP";
    else if ([strPrice isEqualToString:@"over £50"])
        strPrice = @"over 50 GBP";
    
    NSString *url = [NSString stringWithFormat:@"%@%@&kids=%@&walk=%@&suggest=%@&feedback=%@", DCWEBAPI_SEND_FEEDBACK, deviceTokenID, strKids, strWalk, txtSuggestion.text, txtViewFeedback.text ];
    
    [DCDefines getHttpAsyncResponse:url withHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    }];
    
    
    NSArray *subViewControllers = self.navigationController.viewControllers;
    UIViewController *prevController = [subViewControllers objectAtIndex:subViewControllers.count-2];

    if ([prevController isKindOfClass:[HomeViewController class]]) {
        HomeViewController *vc = (HomeViewController*)prevController;
        viewFeedback = [[FeedbackWelcome alloc] initWithFrame:CGRectMake(0, vc.tableView.contentOffset.y, 320, 568) ViewController:vc];
        [vc.tableView setScrollEnabled:NO];
    } else
        viewFeedback = [[FeedbackWelcome alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];

    [prevController.view addSubview:viewFeedback];
    
    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController.presentedViewController.view addSubview:viewFeedback];
}

- (void) onClickFeedbackWelcome {
    [viewFeedback removeFromSuperview];
}

- (IBAction)onClickSkipButton:(id)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:nil forKey:WHITELEY_FEEDBACK];
    [userDefaults synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onClickWalkYESButton:(id)sender {
    btnWalkYES.backgroundColor = UIColorWithRGBA(215, 163, 2, 1);
    [btnWalkYES setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    btnWalkNO.backgroundColor = UIColorWithRGBA(255, 255, 255, 1);
    [btnWalkNO setTitleColor:UIColorWithRGBA(74, 74, 74, 1) forState:UIControlStateNormal];
    
    strWalk = @"Yes";
    
    [self validateFeedbackData];
}

- (IBAction)onClickWalkNOButton:(id)sender {
    btnWalkNO.backgroundColor = UIColorWithRGBA(215, 163, 2, 1);
    [btnWalkNO setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    btnWalkYES.backgroundColor = UIColorWithRGBA(255, 255, 255, 1);
    [btnWalkYES setTitleColor:UIColorWithRGBA(74, 74, 74, 1) forState:UIControlStateNormal];
    
    strWalk = @"No";

    [self validateFeedbackData];
}

- (IBAction)onClickKidsYESButton:(id)sender {
    btnKidsYES.backgroundColor = UIColorWithRGBA(215, 163, 2, 1);
    [btnKidsYES setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    btnKidsNO.backgroundColor = UIColorWithRGBA(255, 255, 255, 1);
    [btnKidsNO setTitleColor:UIColorWithRGBA(74, 74, 74, 1) forState:UIControlStateNormal];
    
    strKids = @"Yes";

    [self validateFeedbackData];
}

- (IBAction)onClickKidsNOButton:(id)sender {
    btnKidsNO.backgroundColor = UIColorWithRGBA(215, 163, 2, 1);
    [btnKidsNO setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    btnKidsYES.backgroundColor = UIColorWithRGBA(255, 255, 255, 1);
    [btnKidsYES setTitleColor:UIColorWithRGBA(74, 74, 74, 1) forState:UIControlStateNormal];
    
    strKids = @"No";

    [self validateFeedbackData];
}

- (void)showPickerView:(BOOL)isShown {
    if (isShown) {
        [picker setHidden:NO];
        [picker reloadAllComponents];
        [self.view addSubview:picker];
        
        [pickerDone setFrame:CGRectMake(0, picker.frame.origin.y - TOOL_BAR_HEIGHT, 320, TOOL_BAR_HEIGHT)];
        [self.view addSubview:pickerDone];
        
        [scrollView setScrollEnabled:NO];
    }
    else {
        
        CGRect rect = scrollView.frame;
        if (rect.origin.y < 0) {
            [UIView animateWithDuration:0.3 animations:^{
                [scrollView setFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
            }];
        }
        
        //[picker setHidden:YES];
        //[picker removeFromSuperview];
        
        [pickerDone removeFromSuperview];
        [txtViewFeedback resignFirstResponder];
        [scrollView setScrollEnabled:YES];
        
        if ([DCDefines isiPHone4])
            [scrollView setContentOffset:CGPointMake(0, 80)];
        else
            [scrollView setContentOffset:CGPointMake(0, 15)];
    }
}

- (void)validateFeedbackData {
    if (strWalk.length > 0 && strKids.length > 0)
        [btnSubmit setSelected:YES];
    else
        [btnSubmit setSelected:NO];
}
@end


