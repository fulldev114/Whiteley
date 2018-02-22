//
//  StoreListViewController.m
//  Whiteley
//
//  Created by Alex Hong on 3/21/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import "StoreListViewController.h"
#import "DCDefines.h"
#import "StoreTableViewCell.h"
#import "StoreDetailViewController.h"

@interface StoreListViewController ()
{
    BOOL m_bFirstLoad;
}
@end

@implementation StoreListViewController
@synthesize dcStores, dcCategories, dcFavoriteData;
@synthesize backView, sadImageView, noItemContent;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:NO];
    
    self.searchTextField.font = [UIFont fontWithName:HFONT_THIN size:18];
    self.searchTextField.tintColor = UIColorWithRGBA(74, 74, 74, 1);
    self.searchTextField.textColor = UIColorWithRGBA(74, 74, 74, 1);
    self.searchTextField.delegate = self;
    
    self.button1.layer.borderWidth = 1;
    self.button1.layer.borderColor = UIColorWithRGBA(151, 151, 151, 1).CGColor;
    [self.button1 setTitle:@"STORE NAME" forState:UIControlStateNormal];
    self.button1.titleLabel.font = [UIFont fontWithName:NFONT_DEMI_BOLD size:12];
    
    self.button2.layer.borderWidth = 1;
    self.button2.layer.borderColor = UIColorWithRGBA(151, 151, 151, 1).CGColor;
    [self.button2 setTitle:@"CATEGORY" forState:UIControlStateNormal];
    self.button2.titleLabel.font = [UIFont fontWithName:NFONT_DEMI_BOLD size:12];
    
    dcFavoriteData = [[[NSUserDefaults standardUserDefaults] valueForKey:WHITELEY_FOVORITE_STORE] mutableCopy];
  
    if (dcFavoriteData == nil)
        dcFavoriteData = [[NSMutableDictionary alloc] init];
#pragma mark No Item View
    
    CGFloat contentsWidth = 320;
    CGFloat contentsHeight = 86;
    CGFloat lineSpacing = 3;
    CGRect rect;
    
    if (SCREEN_HEIGHT == 480) {
        contentsHeight = 72;
        lineSpacing = 1;
    }
    self.backView = [[UIView alloc] initWithFrame:CGRectMake(0, contentsHeight, 320, self.view.frame.size.height - contentsHeight)];
    [self.backView setBackgroundColor:[UIColor whiteColor]];
    self.sadImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sadFace"]];
    [self.backView addSubview:self.sadImageView];
    
    contentsHeight = 5;
    rect = self.sadImageView.frame;
    rect.size.width = 64;
    self.sadImageView.frame = rect;
    [self.sadImageView sizeToFit];
    rect = self.sadImageView.frame;
    rect.origin.x = ( contentsWidth - self.sadImageView.frame.size.width ) / 2;
    rect.origin.y = contentsHeight;
    self.sadImageView.frame = rect;
    
    if (SCREEN_HEIGHT != 480)
        contentsHeight += self.sadImageView.frame.size.height + 5;
    else
        contentsHeight += self.sadImageView.frame.size.height - 12;
        
    self.noItemContent = [[UITextView alloc] init];
    [self.backView addSubview:self.noItemContent];
    [self.noItemContent setEditable:NO];
    [self.noItemContent setScrollEnabled:NO];
    [self.noItemContent setSelectable:NO];
    [self.noItemContent setBackgroundColor:[UIColor clearColor]];

    self.noItemContent.text = @"Sorry\nThere are no stores matching your search.\nPlease check your spelling or browse our\nstore directory.";
    
    NSString *text = self.noItemContent.text;
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:text];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:lineSpacing];
    [style setAlignment:NSTextAlignmentCenter];
    
    [attrString addAttributes:@{
                                NSForegroundColorAttributeName : UIColorWithRGBA(74, 74, 74, 1),
                                NSFontAttributeName : [UIFont fontWithName:HFONT_THIN size:17],
                                NSParagraphStyleAttributeName : style
                                } range:NSMakeRange(0, text.length)];
    
    [attrString addAttributes:@{
                                NSForegroundColorAttributeName : UIColorWithRGBA(74, 74, 74, 1),
                                NSFontAttributeName : [UIFont fontWithName:HFONT_MEDIUM size:18],
                                NSParagraphStyleAttributeName : style
                                } range:NSMakeRange(0, 5)];
    
    self.noItemContent.attributedText = attrString;
    
    rect = self.noItemContent.frame;
    rect.size.width = contentsWidth;
    self.noItemContent.frame = rect;
    [self.noItemContent sizeToFit];
    rect = self.noItemContent.frame;
    rect.origin.x = ( contentsWidth - rect.size.width ) /2;
    rect.origin.y = contentsHeight;
    self.noItemContent.frame = rect;
    
    [self.backView setHidden:YES];
    [self.view addSubview:backView];

    [self addHeader];
    //[self addFooter];
    [self.header beginRefreshing];

    [self getInfosFromWebServer];

}

-(void) viewWillAppear:(BOOL)animated
{
    if ( self.listType != DCStoresListTypeSubCategory )
    {
        dcFavoriteData = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] valueForKey:WHITELEY_FOVORITE_STORE]];
        for (int i = 0; i < dcStores.count; i++) {
            NSMutableDictionary *dic = [dcStores objectAtIndex:i];
            NSString *strFlag = [dcFavoriteData valueForKey:dic[@"id"]];
            [dic setValue:strFlag forKey:@"favorite"];
        }
        
        [self.tableView reloadData];
    }
}

-(void) getInfosFromWebServer
{
    self.dcStores = [[NSMutableArray alloc] init];
    self.dcCategories = [[NSMutableArray alloc] init];
    
    if (self.listType == DCStoresListTypeSubCategory) {
        CGRect tableFrame = self.tableView.frame;
        tableFrame.origin.y = self.txtSearch.frame.origin.y + self.txtSearch.frame.size.height + 10;
        tableFrame.size.height = self.view.frame.size.height - tableFrame.origin.y;
        self.tableView.frame = tableFrame;
        
        if (self.categoryID.length != 0)
            [self getCategoryStoreFromWebServer];
    }
    else if ( self.listType == DCFoodOutletsTypeCategory )
    {
        CGRect tableFrame = self.tableView.frame;
        tableFrame.origin.y -= 85;
        tableFrame.size.height += 85;
        self.tableView.frame = tableFrame;
        
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setValue:[NSNumber numberWithInteger:MENU_FOOD] forKey:WHITELEY_MENU_SELECT];
        [userDefault synchronize];
        
        [self getFoodOutletsFromWebServer];
    }
    else {

        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setValue:[NSNumber numberWithInteger:MENU_STORE] forKey:WHITELEY_MENU_SELECT];
        [userDefault synchronize];
        
        if (self.listType == DCStoresListTypeStore) {
            // button1
            self.button1.backgroundColor = UIColorWithRGBA(215, 163, 2, 1);
            [self.button1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            // button2
            self.button2.backgroundColor = [UIColor whiteColor];
            [self.button2 setTitleColor:UIColorWithRGBA(74, 74, 74, 1) forState:UIControlStateNormal];
        }
        else {
            // button1
            self.button1.backgroundColor = [UIColor whiteColor];
            [self.button1 setTitleColor:UIColorWithRGBA(74, 74, 74, 1) forState:UIControlStateNormal];
            
            // button2
            self.button2.backgroundColor = UIColorWithRGBA(215, 163, 2, 1);
            [self.button2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *aryStore = [userDefaults valueForKey:WHITELEY_STORE_LIST];
        NSMutableArray *aryCategory = [userDefaults valueForKey:WHITELEY_CATEGORY_LIST];
       
        for (int i = 0; i < aryStore.count; i++) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[aryStore objectAtIndex:i]];
            [dcStores addObject:dic];
        }

        for (int i = 0; i < aryCategory.count; i++) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[aryCategory objectAtIndex:i]];
            [dcCategories addObject:dic];
        }
        
        if (dcStores.count == 0) {
            self.dcStores = [[NSMutableArray alloc] init];
            self.dcCategories = [[NSMutableArray alloc] init];
            [self getStoreFromWebServer];
        }
        else
        {
            [self setStoreTableData];
            [self.tableView reloadData];
            [self.header endRefreshing];
        }
    }
    m_bFirstLoad = YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSInteger table_y = self.txtSearch.frame.origin.y + self.txtSearch.frame.size.height + 10;
    [self.tableView setFrame:CGRectMake(0, table_y, 320, self.view.frame.size.height - table_y - 216)];
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.listType == DCStoresListTypeSubCategory || self.listType == DCFoodOutletsTypeCategory)
    {
        NSInteger table_y = self.txtSearch.frame.origin.y + self.txtSearch.frame.size.height + 10;
        [self.tableView setFrame:CGRectMake(0, table_y, 320, self.view.frame.size.height - table_y)];
    }
    else
        [self.tableView setFrame:CGRectMake(0, 176, 320, self.view.frame.size.height - 176)];
    
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self.tableData removeAllObjects];
    NSString *search_name = [NSString stringWithFormat:@"%@%@", textField.text, string];
    
    if (string.length == 0 && search_name.length > 0) {
        search_name = [search_name substringToIndex:search_name.length - 1];
    }
    
    if (search_name.length == 0) {
        if ( self.listType == DCStoresListTypeCategory )
        {
            for (int i = 0; i < self.dcCategories.count; i++) {
                NSMutableDictionary *dic = [self.dcCategories objectAtIndex:i];
                [self.tableData addObject:dic];
            }
        }
        else
        {
            [self setStoreTableData];
        }
    }
    else
    {
        if ( self.listType == DCStoresListTypeCategory )
        {
            for (int i = 0; i < self.dcCategories.count; i++) {
                NSMutableDictionary *dic = [self.dcCategories objectAtIndex:i];
                NSString *name = [dic valueForKey:@"name"];
                NSRange range = [name rangeOfString:search_name options:NSCaseInsensitiveSearch];
                if ( range.location == 0) {
                    [self.tableData addObject:dic];
                }
            }

        }
        else
        {
            for (int i = 0; i < self.dcStores.count; i++) {
                NSMutableDictionary *dic = [self.dcStores objectAtIndex:i];
                NSString *name = [dic valueForKey:@"name"];
                
                if ([name isEqualToString:NEW_RETAILER_SHOP])
                    continue;
                
                NSRange range = [name rangeOfString:search_name options:NSCaseInsensitiveSearch];
                if ( range.location == 0) {
                    [self.tableData addObject:dic];
                }
            }
        }
    }
    if (self.tableData.count == 0)
        self.backView.hidden = NO;
    else
        self.backView.hidden = YES;

    
    [self.tableView reloadData];
    
    return YES;
}

- (void)addFooter
{
    MJRefreshFooterView *footer = [MJRefreshFooterView footer];
    footer.scrollView = self.tableView;
    footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        [self performSelector:@selector(doneWithView:) withObject:refreshView afterDelay:DC_SESSION_TIME_OUT];
        
    };
    self.footer = footer;
}

- (void)addHeader
{
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    header.scrollView = self.tableView;
    header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        [self performSelector:@selector(doneWithView:) withObject:refreshView afterDelay:DC_SESSION_TIME_OUT];
    };
    header.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
        
    };
    header.refreshStateChangeBlock = ^(MJRefreshBaseView *refreshView, MJRefreshState state) {
        switch (state) {
            case MJRefreshStateNormal:
                //                NSLog(@"%@----Change State：Normal普通状态", refreshView.class);
                break;
                
            case MJRefreshStatePulling:
                //                NSLog(@"%@----Change State：Can Refresh if release松开即可刷新的状态", refreshView.class);
                break;
                
            case MJRefreshStateRefreshing:
                //                NSLog(@"%@----Change State：Now Refreshing正在刷新状态", refreshView.class);
                self.dcStores = [[NSMutableArray alloc] init];

                if (self.listType == DCStoresListTypeSubCategory) {
                    if (self.categoryID.length != 0)
                        [self getCategoryStoreFromWebServer];
                }
                else if ( self.listType == DCFoodOutletsTypeCategory )
                {
                    [self getFoodOutletsFromWebServer];
                }
                else {
                    self.dcCategories = [[NSMutableArray alloc] init];
                    [self getStoreFromWebServer];
                }
                break;
            default:
                break;
        }
    };
    self.header = header;
}

- (void)doneWithView:(MJRefreshBaseView *)refreshView
{
    [self.tableView reloadData];
    [refreshView endRefreshing];
}

-(void) getFoodOutletsFromWebServer
{
    [DCDefines getHttpAsyncResponse:DCWEBAPI_GET_FOOD_OUTLETS withHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        NSData *responseData = data;
        
        if (responseData == nil) {
            [self.header endRefreshing];
            return;
        }
        
        NSError* errorInfo;
        NSDictionary *dic  = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&errorInfo];
        NSMutableArray *aryStoreName = [dic valueForKey:@"result"];
        for (int i = 0; i < aryStoreName.count; i++) {
            NSMutableDictionary *dicStore = [aryStoreName objectAtIndex:i];
            NSString *favoriteFlag = [dcFavoriteData valueForKey:dicStore[@"id"]];
            BOOL m_bFlag = NO;
            if (favoriteFlag == nil || favoriteFlag.length == 0)
                [dcFavoriteData setValue:@"0" forKey:dicStore[@"id"]];
            else if([favoriteFlag isEqualToString:@"1"])
                m_bFlag = YES;
            
            NSMutableDictionary *store = [NSMutableDictionary dictionaryWithObjectsAndKeys:[dicStore valueForKey:@"id"], @"id",
                                   [dicStore valueForKey:@"name"], @"name",
                                   [dicStore valueForKey:@"has_offer"],  @"hasoffer",
                                   [NSNumber numberWithBool:m_bFlag], @"favorite", nil];
            [self.dcStores addObject:store];
        }
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:dcFavoriteData forKey:WHITELEY_FOVORITE_STORE];
        [userDefaults synchronize];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setStoreTableData];
            [self.header endRefreshing];
            [self.tableView reloadData];
        });
        
    }];
    
}

-(void) getCategoryStoreFromWebServer
{
    NSString *url = [DCWEBAPI_GET_STORE_CATEDETAIL stringByAppendingString:self.categoryID];
    
    [DCDefines getHttpAsyncResponse:url withHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSData *responseData = data;
        
        if (responseData == nil) {
            [self.header endRefreshing];
            return;
        }
        
        NSError* errorInfo;
        NSDictionary *dic  = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&errorInfo];
        NSMutableArray *aryStoreName = [dic valueForKey:@"result"];
        for (int i = 0; i < aryStoreName.count; i++) {
            
            NSMutableDictionary *dicStore = [aryStoreName objectAtIndex:i];
            NSString *favoriteFlag = [dcFavoriteData valueForKey:dicStore[@"id"]];
            BOOL m_bFlag = NO;
            if (favoriteFlag == nil || favoriteFlag.length == 0)
                [dcFavoriteData setValue:@"0" forKey:dicStore[@"id"]];
            else if([favoriteFlag isEqualToString:@"1"])
                m_bFlag = YES;
            
            NSMutableDictionary *store = [NSMutableDictionary dictionaryWithObjectsAndKeys:[dicStore valueForKey:@"id"], @"id",
                                   [dicStore valueForKey:@"name"], @"name",
                                   [dicStore valueForKey:@"has_offer"],  @"hasoffer",
                                   [NSNumber numberWithBool:m_bFlag], @"favorite", nil];
            [self.dcStores addObject:store];
        }
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:dcFavoriteData forKey:WHITELEY_FOVORITE_STORE];
        [userDefaults synchronize];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setStoreTableData];
            [self.tableView reloadData];
            [self.header endRefreshing];
        });
    }];
}

-(void) setStoreTableData {
    self.tableData = [[NSMutableArray alloc] initWithArray:self.dcStores];

    for ( int i = 0; i < self.tableData.count; i++ ){
        NSMutableDictionary *dic = [self.tableData objectAtIndex:i];
        if ([dic[@"name"] isEqualToString:NEW_RETAILER_SHOP]) {
            [self.tableData removeObjectAtIndex:i];
        }
    }
}

-(void) getStoreFromWebServer
{
    [DCDefines getHttpAsyncResponse:DCWEBAPI_GET_STORE_NAME withHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        NSData *responseData = data;
        
        if (responseData == nil) {
            return;
        }
        
        NSError* errorInfo;
        NSDictionary *dic  = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&errorInfo];
        NSMutableArray *aryStoreName = [dic valueForKey:@"result"];
        for (int i = 0; i < aryStoreName.count; i++) {
            NSMutableDictionary *dicStore = [aryStoreName objectAtIndex:i];
            NSString *favoriteFlag = [dcFavoriteData valueForKey:dicStore[@"id"]];
            if (favoriteFlag == nil || favoriteFlag.length == 0)
                favoriteFlag = @"0";
           
            NSMutableDictionary *store = [[NSMutableDictionary alloc] init];
            
            //if ([dicStore[@"name"] isEqualToString:@"New Retailer Coming Soon"]) {
            //    continue;
            //}
            [store setValue:[dicStore valueForKey:@"id"] forKey:@"id"];
            [store setValue:[dicStore valueForKey:@"name"] forKey:@"name"];
            [store setValue:[dicStore valueForKey:@"label"] forKey:@"label"];
            [store setValue:[dicStore valueForKey:@"location"] forKey:@"location"];
            [store setValue:[dicStore valueForKey:@"unit_num"] forKey:@"unit_num"];
            [store setValue:[dicStore valueForKey:@"has_offer"] forKey:@"hasoffer"];
            [store setValue:[dicStore valueForKey:@"cat_id"] forKey:@"cat_id"];
            [store setValue:favoriteFlag forKey:@"favorite"];
            
            [self.dcStores addObject:store];
        }
        
        [self performSelectorInBackground:@selector(downloadLogoImageFromWebServer) withObject:nil];

        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:self.dcStores forKey:WHITELEY_STORE_LIST];
        [userDefaults setObject:dcFavoriteData forKey:WHITELEY_FOVORITE_STORE];
        [userDefaults synchronize];
       
        [DCDefines getHttpAsyncResponse:DCWEBAPI_GET_STORE_CATEGORY withHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           
            NSData *responseData = data;

            if (responseData == nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    [self.header endRefreshing];

                });
                return;
            }
            
            NSError* errorInfo;
            NSDictionary *dic  = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&errorInfo];
            NSMutableArray *aryCategoryName = [dic valueForKey:@"result"];
            for (int i = 0; i < aryCategoryName.count; i++) {
                NSMutableDictionary *dicCategory = [aryCategoryName objectAtIndex:i];
                NSMutableDictionary *category = [NSMutableDictionary dictionaryWithObjectsAndKeys:[dicCategory valueForKey:@"id"], @"id",
                                       [dicCategory valueForKey:@"name"], @"name", nil];
                [self.dcCategories addObject:category];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:self.dcCategories forKey:WHITELEY_CATEGORY_LIST];
                [userDefaults synchronize];
                
                if ( self.listType == DCStoresListTypeStore ) {
                    [self setStoreTableData];
                }
                else
                    self.tableData = [[NSMutableArray alloc] initWithArray:self.dcCategories];
                
                [self.header endRefreshing];

                [self.tableView reloadData];
            });
        }];
   
    }];

}

- (void)downloadLogoImageFromWebServer
{
    for (int i = 0; i < dcStores.count; i++)
    {
        NSDictionary *dic = [dcStores objectAtIndex:i];
        NSString *imgURL = dic[@"label"];

        if (imgURL.length ==0 || imgURL == nil)
            continue;
        
        NSString *URL = [dic[@"label"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        // new download
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:URL]];

        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
        {
             if (connectionError == nil)
             {
                 UIImage *img = [UIImage imageWithData:data];
                 
                 NSString *strImage = [NSString stringWithFormat:@"logo_%@.png", dic[@"id"]];
                 if ( img != nil )
                 {
                     NSString *documentFolderPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
                     NSString* file_name = [documentFolderPath stringByAppendingPathComponent:strImage];
                     
                     NSData *imgData = UIImagePNGRepresentation(img);
                     [imgData writeToFile:file_name atomically:YES];
                     
                 }
                 
             }
         }];
    }
}

- (void)updateButtons {
    
    if (self.listType == DCStoresListTypeStore) {
        // button1
        self.button1.backgroundColor = UIColorWithRGBA(215, 163, 2, 1);
        [self.button1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.button1.layer.borderColor = [UIColor clearColor].CGColor;

        // button2
        self.button2.backgroundColor = [UIColor whiteColor];
        [self.button2 setTitleColor:UIColorWithRGBA(74, 74, 74, 1) forState:UIControlStateNormal];
        self.button2.layer.borderColor = UIColorWithRGBA(151, 151, 151, 1).CGColor;
        
        [self setStoreTableData];
    }
    else {
        // button1
        self.button1.backgroundColor = [UIColor whiteColor];
        [self.button1 setTitleColor:UIColorWithRGBA(74, 74, 74, 1) forState:UIControlStateNormal];
        self.button1.layer.borderColor = UIColorWithRGBA(151, 151, 151, 1).CGColor;

        // button2
        self.button2.backgroundColor = UIColorWithRGBA(215, 163, 2, 1);
        [self.button2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.button2.layer.borderColor = [UIColor clearColor].CGColor;

        self.tableData = [[NSMutableArray alloc] initWithArray:self.dcCategories];
    }

    [self.tableView reloadData];
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

#pragma mark <UITableViewDataSource&Delegate>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 69;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StoreTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"StoreTableViewCell"];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row % 2 == 0) {
        cell.backgroundColor = UIColorWithRGBA(237, 236, 236, 1);
    }
    else {
        cell.backgroundColor = UIColorWithRGBA(249, 249, 249, 1);
    }
    
    if (self.listType == DCStoresListTypeStore || self.listType == DCStoresListTypeSubCategory || self.listType == DCFoodOutletsTypeCategory) {
        cell.storeCellType = StoreTableViewCellTypeStore;
        
        NSMutableDictionary* store = self.tableData[indexPath.row];
        cell.hasOffer = [store[@"hasoffer"] boolValue];
        cell.isFavorite = [store[@"favorite"] boolValue];
        cell.dcTextLabel.text = store[@"name"];
        cell.favoriteButton.tag = [store[@"id"] integerValue];
        cell.parent = self;
        cell.m_nCellType = STORE_TYPE;
    }
    else {
        cell.storeCellType = StoreTableViewCellTypeCategory;
        NSMutableDictionary *category = self.tableData[indexPath.row];
        cell.dcTextLabel.text = category[@"name"];
    }
    
//    [cell layoutIfNeeded];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.listType == DCStoresListTypeCategory) {
        StoreListViewController* storeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"StoreListViewController"];
        storeVC.listType = DCStoresListTypeSubCategory;
        NSMutableDictionary *dic = self.tableData[indexPath.row];
        storeVC.categoryID = dic[@"id"];
        storeVC.title = dic[@"name"];
        [self.navigationController pushViewController:storeVC animated:YES];
    }
    else {
        StoreDetailViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"StoreDetailViewController"];
        NSMutableDictionary *store = self.tableData[indexPath.row];
        vc.strStoreID = store[@"id"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSInteger total_row = ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row;
//    if (total_row > 5) {
//        total_row = 5;
//    }
//    if (indexPath.row == total_row) {
//        [self.header endRefreshing];
//    }
}
#pragma mark <UIAction>
- (IBAction)onButtonClicked:(UIButton *)sender {
    if (self.listType != sender.tag) {
        self.listType = sender.tag;
        [self updateButtons];
    }
}

@end
