//
//  HomeViewController.h
//  Whiteley
//
//  Created by Alex Hong on 3/20/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BeaconMonitor.h"
#import "MJRefresh.h"

@interface HomeViewController : UITableViewController<BeaconMonitorDelegate, CBCentralManagerDelegate>
@property (nonatomic, retain) MJRefreshHeaderView   *header;
@property (nonatomic, retain) MJRefreshFooterView   *footer;
@property (nonatomic, retain) NSThread              *shoppingThread;
@property (nonatomic, retain) NSThread              *bgShoppingThread;

- (IBAction)showMenu:(UIBarButtonItem *)sender;
- (void)showViewController:(NSString*)identifier;
- (void)isLeavingShoppingCentre;
- (void) setupAppLocalSettings;
- (void)checkUpgradeApp;
@end
