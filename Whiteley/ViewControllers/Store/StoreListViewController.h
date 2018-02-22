//
//  StoreListViewController.h
//  Whiteley
//
//  Created by Alex Hong on 3/21/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCBaseViewController.h"
#import "MJRefresh.h"

typedef NS_ENUM(NSInteger, DCStoresListType) {
    DCStoresListTypeStore = 1,
    DCStoresListTypeCategory,
    DCStoresListTypeSubCategory,
    DCFoodOutletsTypeCategory
};

@interface StoreListViewController : DCBaseViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, retain) MJRefreshHeaderView   *header;
@property (nonatomic, retain) MJRefreshFooterView   *footer;

@property (nonatomic, strong) NSMutableArray    *dcStores;
@property (nonatomic, strong) NSMutableArray    *dcCategories;
@property (nonatomic, strong) NSMutableArray    *tableData;
@property (nonatomic, assign) NSUInteger        listType;
@property (nonatomic, assign) NSString          *categoryID;
@property (nonatomic, strong) NSMutableDictionary *dcFavoriteData;

@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UIButton *button2;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITextField *txtSearch;
@property (strong, nonatomic) UIView                *backView;
@property (strong, nonatomic) UIImageView           *sadImageView;
@property (strong, nonatomic) UITextView            *noItemContent;

- (IBAction)onButtonClicked:(UIButton *)sender;

@end
