//
//  OpeningHoursViewController.m
//  Whiteley
//
//  Created by Alex Hong on 5/6/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import "OpeningHoursViewController.h"
#import "OpenWebSiteViewController.h"

@interface OpeningHoursViewController ()

@end

@implementation OpeningHoursViewController
@synthesize scrollView, lblDescription, lblOpenHours, btnWebLink;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [scrollView setFrame:CGRectMake(0, 0, 320, self.view.frame.size.height - 44)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 218, 280, 10)];
    [label setNumberOfLines:0];
    label.font = [UIFont fontWithName:HFONT_THIN size:16];
    label.textColor = UIColorWithRGBA(38, 38, 38, 1);

    NSString* text = @"Monday               09:00      -      20:00\nTuesday               09:00      -      20:00\nWednesday         09:00      -      20:00\nThursday             09:00      -      20:00\nFriday                  09:00      -      20:00\nSaturday             09:00      -      19:00\nSunday               10:30      -      16:30";
    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString:text];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:8];
    [attrString addAttributes:@{
                                NSForegroundColorAttributeName : UIColorWithRGBA(38, 38, 38, 1),
                                NSFontAttributeName : [UIFont fontWithName:HFONT_THIN size:16],
                                NSParagraphStyleAttributeName : style
                                } range:NSMakeRange(0, text.length)];
    label.attributedText = attrString;
    [label sizeToFit];
    lblOpenHours = label;
    [scrollView addSubview:lblOpenHours];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(15, lblOpenHours.frame.origin.y + lblOpenHours.frame.size.height + 20 , 290, 10)];
    [label setNumberOfLines:0];
    label.font = [UIFont fontWithName:HFONT_THIN size:16];
    label.textColor = UIColorWithRGBA(38, 38, 38, 1);
    NSString* text1 = @"Please note that some retailers may vary from\nthese times. Please refer to the Whiteley\nwebsite for opening hours during public holidays.";
    NSMutableAttributedString* attrString1 = [[NSMutableAttributedString alloc] initWithString:text1];
    NSMutableParagraphStyle *style1 = [[NSMutableParagraphStyle alloc] init];
    [style1 setLineSpacing:4];
    [attrString1 addAttributes:@{
                                NSForegroundColorAttributeName : UIColorWithRGBA(38, 38, 38, 1),
                                NSFontAttributeName : [UIFont fontWithName:HFONT_THIN size:14],
                                NSParagraphStyleAttributeName : style1
                                } range:NSMakeRange(0, text1.length)];
    label.attributedText = attrString1;
    [label sizeToFit];
    lblDescription = label;
    [scrollView addSubview:lblDescription];
    
    CGFloat edgeControl = 50;
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(10, lblDescription.frame.origin.y + lblDescription.frame.size.height + 20, 300, 56)];
    UIImage *btnImage = [UIImage imageNamed:@"btn-icon-laptop"];
    [button setBackgroundImage:[UIImage imageNamed:@"purple-button"] forState:UIControlStateNormal];
    [button setImage:btnImage forState:UIControlStateNormal];
    [button setTitle:@"Launch Whiteley website" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onClickWebButton:) forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.textColor = [UIColor whiteColor];
    button.titleLabel.font = [UIFont fontWithName:HFONT_THIN size:16];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.imageEdgeInsets = UIEdgeInsetsMake(0, (edgeControl - btnImage.size.width) / 2.0f, 0, 0);
    button.titleEdgeInsets = UIEdgeInsetsMake(0, edgeControl - btnImage.size.width, 0, 0);
    btnWebLink = button;
    [scrollView addSubview:btnWebLink];
    
    self.scrollView.contentSize = CGSizeMake(320, btnWebLink.frame.origin.y + btnWebLink.frame.size.height + 40);
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setValue:[NSNumber numberWithInteger:MENU_HOURS] forKey:WHITELEY_MENU_SELECT];
    [userDefault synchronize];
}

- (void) onClickWebButton:(id)sender
{
    OpenWebSiteViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OpenWebSiteViewController"];
    vc.title = @"Opening Hours";
    vc.strURL = @"http://www.whiteleyshopping.co.uk";
    [self.navigationController pushViewController:vc animated:YES];
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

@end
