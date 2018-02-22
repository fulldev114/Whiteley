//
//  EventListViewController.h
//  Whiteley
//
//  Created by Alex Hong on 3/30/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCBaseViewController.h"
#import "MJRefresh.h"

@interface EventListViewController : DCBaseViewController
@property (nonatomic, retain) MJRefreshHeaderView* header;
@property (nonatomic, retain) MJRefreshFooterView* footer;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIImageView *sadImageView;
@property (weak, nonatomic) IBOutlet UITextView *noItemContent;
@property (nonatomic, strong) NSMutableArray*      aryEventsData;

@end
