//
//  MonsterFirstViewController.m
//  Whiteley
//
//  Created by Alex Hong on 4/21/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import "MonsterFirstViewController.h"
#import "DCNavigationViewController.h"
#include "MenuViewController.h"


@interface MonsterFirstViewController()

@end

@implementation MonsterFirstViewController
@synthesize viewFirst;

- (void) viewDidLoad
{
    if ([DCDefines isiPHone4]) {
        self.imgMonster.center = CGPointMake(self.imgMonster.center.x, self.imgMonster.center.y - 50);
        self.imgLogo.center = CGPointMake(self.imgLogo.center.x, self.imgLogo.center.y - 50);
        self.btnStart.center = CGPointMake(self.btnStart.center.x, self.btnStart.center.y - 50);
        self.lblEggs.center = CGPointMake(self.lblEggs.center.x, self.lblEggs.center.y - 50);
        self.lblTry.center = CGPointMake(self.lblTry.center.x, self.lblTry.center.y - 50);
    }
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    //[userDefault setValue:[NSNumber numberWithInteger:MENU_MONSTER] forKey:WHITELEY_MENU_SELECT];
    [userDefault synchronize];
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onClickPlayButton:(id)sender {
    [self removeSubViews];
    UIViewController *vc = nil;
    vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MonsterHelpViewController"];
    [self.navigationController pushViewController:vc animated:YES];

}

- (IBAction)onClickHomeButton:(id)sender {
    [self removeSubViews];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) removeSubViews {
    self.imgLogo.image = nil;
    self.imgMonster.image = nil;
    self.btnStart.imageView.image = nil;
    [self.imgLogo removeFromSuperview];
    [self.imgMonster removeFromSuperview];
    [self.btnStart removeFromSuperview];
}

@end
