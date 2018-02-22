//
//  MonsterFoundViewController.h
//  Whiteley
//
//  Created by Alex Hong on 4/21/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MonsterFoundViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *imgMonster;
@property (strong, nonatomic) IBOutlet UILabel *lblMonsterName;
@property (weak, nonatomic) IBOutlet UIButton *btnMonsterView;
@property (weak, nonatomic) IBOutlet UILabel *lblWellDone;
@property (strong, nonatomic) NSString* majorNumber;
@property (strong, nonatomic) NSString* minorNumber;
@property (strong, nonatomic) UIImage*  imageMonster;
@property (nonatomic, assign) BOOL bFoundAll;
@property (strong, nonatomic) NSString* monsterName;
- (IBAction)onClickViewMonsterButton:(id)sender;
- (IBAction)onClickCloseButton:(id)sender;

@end
