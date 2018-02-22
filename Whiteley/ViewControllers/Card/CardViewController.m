//
//  CardViewController.m
//  Whiteley
//
//  Created by Alex Hong on 3/31/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import "CardViewController.h"
#import "DCDefines.h"
#import "OpenWebSiteViewController.h"

@interface CardViewController ()

@end

@implementation CardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController setNavigationBarHidden:NO];
    
    self.view.backgroundColor = UIColorWithRGBA(239, 240, 240, 1);
	
    self.scrollView.contentSize = CGSizeMake(320, 638);

    CGFloat lineSpacing = 2;
    CGFloat fontSize = 14;
    
    NSString* text = @"Whiteley Gift Card\n\nBuying a present? The Whiteley Gift Card really is the perfect gift of choice.\n\nGift card amounts range from £5 up to £500 and you will be able to use the Gift Cards in all shops at Drakes Circus with the exception of: EE, Fuel Juice, Spudulike, Regus Express and Jack Wills Pop up store.";
    
    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString:text];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:lineSpacing];
    [attrString addAttributes:@{
                                NSForegroundColorAttributeName : UIColorWithRGBA(38, 38, 38, 1),
                                NSFontAttributeName : [UIFont fontWithName:HFONT_THIN size:fontSize],
                                NSParagraphStyleAttributeName : style
                                } range:NSMakeRange(0, text.length)];
    
    [attrString addAttributes:@{
                                NSForegroundColorAttributeName : UIColorWithRGBA(74, 74, 74, 1),
                                NSFontAttributeName : [UIFont fontWithName:HFONT_THIN size:20],
                                NSParagraphStyleAttributeName : style
                                } range:NSMakeRange(0, 22)];
    

    self.dcTextView.attributedText = attrString;
    
    UIButton* button = nil;
    
    CGFloat edgeControl = 50;
    CGFloat fontHeight = 17;
    
    button = self.btnOrder;
    UIImage* btnImage = [UIImage imageNamed:@"iconGift"];
    [button setBackgroundImage:[UIImage imageNamed:@"purple-button"] forState:UIControlStateNormal];
    [button setImage:btnImage forState:UIControlStateNormal];
    [button setTitle:@"Order a Gift Card" forState:UIControlStateNormal];
    button.titleLabel.textColor = [UIColor whiteColor];
    button.titleLabel.font = [UIFont fontWithName:HFONT_THIN size:fontHeight];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.imageEdgeInsets = UIEdgeInsetsMake(0, (edgeControl - btnImage.size.width) / 2.0f, 0, 0);
    button.titleEdgeInsets = UIEdgeInsetsMake(0, edgeControl - btnImage.size.width, 0, 0);
    
    button = self.btnCheck;
    btnImage = [UIImage imageNamed:@"iconCheck"];
    [button setBackgroundImage:[UIImage imageNamed:@"purple-button"] forState:UIControlStateNormal];
    [button setImage:btnImage forState:UIControlStateNormal];
    [button setTitle:@"Check your balance" forState:UIControlStateNormal];
    button.titleLabel.textColor = [UIColor whiteColor];
    button.titleLabel.font = [UIFont fontWithName:HFONT_THIN size:fontHeight];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.imageEdgeInsets = UIEdgeInsetsMake(0, (edgeControl - btnImage.size.width) / 2.0f, 0, 0);
    button.titleEdgeInsets = UIEdgeInsetsMake(0, edgeControl - btnImage.size.width, 0, 0);
    
    button = self.btnTerm;
    btnImage = [UIImage imageNamed:@"iconTerm"];
    [button setBackgroundImage:[UIImage imageNamed:@"purple-button"] forState:UIControlStateNormal];
    [button setImage:btnImage forState:UIControlStateNormal];
    [button setTitle:@"Terms and conditions" forState:UIControlStateNormal];
    button.titleLabel.textColor = [UIColor whiteColor];
    button.titleLabel.font = [UIFont fontWithName:HFONT_THIN size:fontHeight];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.imageEdgeInsets = UIEdgeInsetsMake(0, (edgeControl - btnImage.size.width) / 2.0f, 0, 0);
    button.titleEdgeInsets = UIEdgeInsetsMake(0, edgeControl - btnImage.size.width, 0, 0);
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    //[userDefault setValue:[NSNumber numberWithInteger:MENU_GIFT] forKey:WHITELEY_MENU_SELECT];
    [userDefault synchronize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onClickOrderButton:(id)sender {

}

- (IBAction)onClickTermButton:(id)sender {

}

- (IBAction)onClickCheckButton:(id)sender {

}
@end
