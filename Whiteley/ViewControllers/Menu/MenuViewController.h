//
//  MenuViewController.h
//  Whiteley
//
//  Created by Alex Hong on 3/24/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FXBlurView.h>

typedef NS_ENUM(NSInteger, MENU_TYPE) {
    MENU_MAP = 0,//1
    MENU_STORE,
    MENU_OFFER,//2
    MENU_FOOD,//3
    MENU_CINEMA,//4
    MENU_ROCKUP,//5
    MENU_HERE,//6
    MENU_FACLITIES,//7
    MENU_EVENTS,//8
    MENU_HOURS,//9
    MENU_SIGNUP,//11
    MENU_FEEDBACK//11
};

@interface MenuViewController : UIViewController

@property (weak, nonatomic) IBOutlet FXBlurView *blurView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)onHomeButtonClicked:(UIBarButtonItem *)sender;
- (IBAction)onCloseButtonClicked:(UIBarButtonItem *)sender;

@end
