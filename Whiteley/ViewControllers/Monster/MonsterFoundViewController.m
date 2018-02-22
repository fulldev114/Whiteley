//
//  MonsterFoundViewController.m
//  Whiteley
//
//  Created by Alex Hong on 4/21/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import "MonsterFoundViewController.h"
#import "DCDefines.h"
#import "MonsterListViewController.h"

@interface MonsterFoundViewController()

@end

@implementation MonsterFoundViewController

- (void) viewDidLoad
{
    if (self.bFoundAll) {
        self.lblWellDone.text = @"EGGS-CELLENT JOB!";
        self.lblMonsterName.text = @"YOU'VE FOUND ALL THE\nVIRTUAL EASTER EGGS!";
        [self.imgMonster setImage:[UIImage imageNamed:@"dc_monster_flay"]];
        [self.imgMonster setFrame:CGRectMake(37, 150, 246, 118)];
        
        NSString *first = @"IF YOU COMPLETE THIS BETWEEN\n";
        NSString *date = @"THURSDAY 24TH - SATURDAY 26TH MARCH 2016";
        NSString *second = @", YOU CAN COLLECT YOUR 'REAL EGGS' FROM THE STAFF IN THE TOWN SQUARE. ENJOY!";
        NSString *enjoy = [NSString stringWithFormat:@"%@%@%@", first, date, second];
        
        NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString:enjoy];
        
        CGFloat lineSpacing = 3;
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setLineSpacing:lineSpacing];
        [attrString addAttributes:@{
                                    NSForegroundColorAttributeName : UIColorWithRGBA(255,255, 255, 1),
                                    NSFontAttributeName : [UIFont fontWithName:HFONT_THIN size:17.0f]
                                    } range:NSMakeRange(0, enjoy.length)];
        
        [attrString addAttributes:@{
                                    NSForegroundColorAttributeName : UIColorWithRGBA(255, 255, 255, 1),
                                    NSFontAttributeName : [UIFont fontWithName:NFONT_BOLD size:17.0f],
                                    NSParagraphStyleAttributeName : style
                                    } range:NSMakeRange(first.length, date.length)];

        
        UILabel *lblEnjoy = [[UILabel alloc] initWithFrame:CGRectMake(47, 288, 226, 150)];
        lblEnjoy.attributedText = attrString;
        lblEnjoy.numberOfLines = 0;
        lblEnjoy.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview: lblEnjoy];
        
        if ([DCDefines isiPHone4]) {
            [self.lblWellDone setCenter:CGPointMake(self.lblWellDone.center.x, self.lblWellDone.center.y - 18)];
            [self.lblMonsterName setCenter:CGPointMake(self.lblMonsterName.center.x, self.lblMonsterName.center.y - 22)];
            [self.imgMonster setCenter:CGPointMake(self.imgMonster.center.x, self.imgMonster.center.y - 34)];
            [lblEnjoy setCenter:CGPointMake(lblEnjoy.center.x, lblEnjoy.center.y - 44)];
            [self.btnMonsterView setCenter:CGPointMake(self.btnMonsterView.center.x, self.btnMonsterView.center.y - 40)];
        }
        
    } else {
        [self.imgMonster setImage:self.imageMonster];
        self.lblMonsterName.text = [NSString stringWithFormat:@"%@ %@!", @"YOU'VE JUST FOUND", self.monsterName];
        
        if ([DCDefines isiPHone4]) {
            [self.lblWellDone setCenter:CGPointMake(self.lblWellDone.center.x, self.lblWellDone.center.y - 18)];
            [self.lblMonsterName setCenter:CGPointMake(self.lblMonsterName.center.x, self.lblMonsterName.center.y - 22)];
            [self.imgMonster setCenter:CGPointMake(self.imgMonster.center.x, self.imgMonster.center.y - 24)];
            [self.btnMonsterView setCenter:CGPointMake(self.btnMonsterView.center.x, self.btnMonsterView.center.y - 40)];
        }
    }
    
    self.btnMonsterView.layer.cornerRadius = 5.0f;
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
}

- (IBAction)onClickViewMonsterButton:(id)sender {
    self.imgMonster.image = nil;
    [self.imgMonster removeFromSuperview];
    
    self.btnMonsterView.imageView.image = nil;
    [self.btnMonsterView removeFromSuperview];
    
    NSArray *subViewControllers = self.navigationController.viewControllers;
    UIViewController *prevController = [subViewControllers objectAtIndex:subViewControllers.count-2];
    
    if ([prevController isKindOfClass:[MonsterListViewController class]]) {
        [self.navigationController popViewControllerAnimated:YES];
        [self.navigationController setNavigationBarHidden:NO];
    }
    else {
        MonsterListViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MonsterListViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)onClickCloseButton:(id)sender {
    [self.imgMonster removeFromSuperview];
    self.imgMonster = nil;
    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController setNavigationBarHidden:NO];
}
@end
