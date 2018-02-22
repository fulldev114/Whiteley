//
//  MapViewController.m
//  Whiteley
//
//  Created by Alex Hong on 4/10/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import "MapViewController.h"
#import "DXPopover.h"
#import "DCDefines.h"
#import "StoreTableViewCell.h"
#import "CentreMapView.h"
#import "AppDelegate.h"

BOOL bUpdateUserLocation;

CGFloat a11 = 0.00890434949266055;
CGFloat a12 = 0.00987327055587534;
CGFloat a13 = -0.440765957499249;
CGFloat a21 = 0.0175081941027169;
CGFloat a22 = -0.00520653163009943;
CGFloat a23 = -0.897337705040420;
CGFloat a31 = 1.77422923713616e-07;
CGFloat a32 = 9.30692883361414e-08;
CGFloat a33 = -8.87764112131846e-06;

typedef NS_ENUM(NSInteger, DCStoresListType) {
    DCStoresListTypeStore = 1,
    DCStoresListTypeCategory,
    DCStoresListTypeSubCategory
};

@implementation Coordinate

+ (Coordinate*) coordinateWithX:(double)sx Y:(double)sy
{
    Coordinate* coord = [[Coordinate alloc] init];
    coord.x = sx;
    coord.y = sy;
    return coord;
}

@end

@interface MapViewController ()
{
    NSMutableArray *aryLocation;
    NSInteger locIndex;
}
@property (nonatomic, retain) DXPopover         *popover;
@property (nonatomic, retain) UIView            *popContainerView;
@property (strong, nonatomic) CentreMapView     *scrollMapView;
@property (nonatomic, assign) NSUInteger        listType;
@property (nonatomic, retain) NSMutableArray    *tableData;
@property (nonatomic, retain) UIButton          *txtSearchButton;
@property (nonatomic, retain) CLLocation        *shopGPSLocation;
@property (nonatomic, retain) CLLocation        *userGPSLocation;
@property (nonatomic, retain) NSMutableArray    *aryMapLatLongLocation;
@end

@implementation MapViewController
@synthesize scrollMapView, mapSearchView, mapFacilitesView, shopGPSLocation, userGPSLocation, userMapArrow, m_bOutsideAlert, aryMapLatLongLocation, userMapLocation;
@synthesize btnArrow, btnFacilites, btnFloor, txtSearchButton, txtSearch;
@synthesize dcStores, dcAllStores, m_nCentureFloor, dcCategoryStores;
@synthesize viewLocationTooltip, viewOutsideTooltip;
@synthesize backView, sadImageView, noItemContent;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setStoreInfo:m_nCentureFloor];
    [self setStoreCategoryInfo];
    
    NSString *map_name = [NSString stringWithFormat:@"floor_%ld", (long)m_nCentureFloor];
    scrollMapView = [[CentreMapView alloc] initWithFrame:CGRectMake(0, 0, 320, SCREEN_HEIGHT) parentController:self andImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:map_name ofType:@"png"]]];//imageNamed:map_name]]; //
    scrollMapView.imageView.frame = CGRectMake(0, 0, MAP_WIDTH, MAP_HEIGHT);
    [self.view addSubview:scrollMapView];
    scrollMapView.contentSize = CGSizeMake(MAP_WIDTH, MAP_HEIGHT);
    scrollMapView.contentMode = UIViewContentModeScaleToFill;
    [scrollMapView setZoomScale:MIN_SCALE];
    //self.scrollMapView.rootViewController = self;
    
    [self.scrollMapView setFacilitesInfo:m_nCentureFloor];
    self.popover = [DXPopover new];
    UIImageView *imgSearchBackView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-search-rectangle"]];
    [imgSearchBackView setFrame:CGRectMake(12, 12, 296, 51)];
    UIImageView *imgSearchButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-search"]];
    [imgSearchButton setFrame:CGRectMake(274, 28, 22, 22)];
    txtSearchButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 12, 288, 51)];
    [txtSearchButton setTitle:@"Search for store" forState:UIControlStateNormal];
    [txtSearchButton setTitleColor:UIColorWithRGBA(74, 74, 74, 1) forState:UIControlStateNormal];
    txtSearchButton.titleLabel.font = [UIFont fontWithName:HFONT_THIN size:17];
    txtSearchButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [txtSearchButton addTarget:self action:@selector(onClickSearchButton:) forControlEvents:UIControlEventTouchUpInside];
    
    self.button1.layer.borderWidth = 1;
    self.button1.layer.borderColor = UIColorWithRGBA(151, 151, 151, 1).CGColor;
    [self.button1 setTitle:@"STORE NAME" forState:UIControlStateNormal];
    self.button1.titleLabel.font = [UIFont fontWithName:NFONT_DEMI_BOLD size:12];
    
    self.button2.layer.borderWidth = 1;
    self.button2.layer.borderColor = UIColorWithRGBA(151, 151, 151, 1).CGColor;
    [self.button2 setTitle:@"CATEGORY" forState:UIControlStateNormal];
    self.button2.titleLabel.font = [UIFont fontWithName:NFONT_DEMI_BOLD size:12];
    
    self.listType = DCStoresListTypeStore;

    [self updateButtons];

    btnArrow = [[UIButton alloc] initWithFrame:CGRectMake(6/*6*/, SCREEN_HEIGHT - 114, 41, 42)];
    [btnArrow setBackgroundImage:[UIImage imageNamed:@"dc_map_arrow"] forState:UIControlStateNormal];
    [btnArrow addTarget:self action:@selector(onClickArrowButton:) forControlEvents:UIControlEventTouchUpInside];

    btnFloor = [[UIButton alloc] initWithFrame:CGRectMake(55, SCREEN_HEIGHT - 114, 134, 40)];
    [btnFloor setTitle:@"Lower Mall" forState:UIControlStateNormal];
    [btnFloor.titleLabel setFont:[UIFont fontWithName:HFONT_REGULAR size:14.0f]];
    [btnFloor setTitleColor:UIColorWithRGBA(74, 74, 74, 1) forState:UIControlStateNormal];
    UIImage* btnImage = [UIImage imageNamed:@"dc_map_floor_image"];
    [btnFloor setImage:btnImage forState:UIControlStateNormal];
    [btnFloor setBackgroundImage:[UIImage imageNamed:@"dc_map_floor"] forState:UIControlStateNormal];
    btnFloor.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    btnFloor.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    btnFloor.hidden = YES;
   // [btnFloor addTarget:self action:@selector(onClickFloorButton:) forControlEvents:UIControlEventTouchUpInside];

    btnFacilites = [[UIButton alloc] initWithFrame:CGRectMake(273/*198*/, SCREEN_HEIGHT - 114, 41, 42)];
    //[btnFacilites setTitle:@"Facilities" forState:UIControlStateNormal];
    //[btnFacilites.titleLabel setFont:[UIFont fontWithName:HFONT_REGULAR size:14.0f]];
    [btnFacilites setTitleColor:UIColorWithRGBA(74, 74, 74, 1) forState:UIControlStateNormal];
    [btnFacilites setBackgroundImage:[UIImage imageNamed:@"dc_map_fac"] forState:UIControlStateNormal];
    UIImage* btnFacImage = [UIImage imageNamed:@"dc_map_fac_btn"];
    [btnFacilites setImage:btnFacImage forState:UIControlStateNormal];
    //btnFacilites.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    //btnFacilites.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    
    [btnFacilites addTarget:self action:@selector(onClickFacilitiesButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btnArrow];
    [self.view addSubview:btnFloor];
    [self.view addSubview:btnFacilites];
    [self.view addSubview:imgSearchBackView];
    [self.view addSubview:txtSearchButton];
    [self.view addSubview:imgSearchButton];
    [mapSearchView removeFromSuperview];
    [self.view addSubview:mapSearchView];
    mapSearchView.hidden = YES;
    
#pragma mark No Item View
    
    CGFloat contentsWidth = 320;
    CGFloat contentsHeight = 106;
    CGFloat lineSpacing = 2;
    CGRect rect;
    
    self.backView = [[UIView alloc] initWithFrame:CGRectMake(0, contentsHeight, 320, self.view.frame.size.height - contentsHeight)];
    [self.backView setBackgroundColor:[UIColor whiteColor]];
    self.sadImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sadFace"]];
    [self.backView addSubview:self.sadImageView];
    
    contentsHeight = 0;
    rect = self.sadImageView.frame;
    rect.size.width = 64;
    self.sadImageView.frame = rect;
    [self.sadImageView sizeToFit];
    rect = self.sadImageView.frame;
    rect.origin.x = ( contentsWidth - self.sadImageView.frame.size.width ) / 2;
    rect.origin.y = contentsHeight;
    self.sadImageView.frame = rect;
    
    if (![DCDefines isiPHone4])
        contentsHeight += self.sadImageView.frame.size.height;
    
    self.noItemContent = [[UITextView alloc] init];
    [self.backView addSubview:self.noItemContent];
    [self.noItemContent setEditable:NO];
    [self.noItemContent setScrollEnabled:NO];
    [self.noItemContent setSelectable:NO];
    
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
    [self.mapSearchView addSubview:backView];
        
    // --------------- User Map Arrow ------------------
    userMapArrow = [[UIImageView alloc] initWithFrame:CGRectMake(100, 100, 29, 29)];
    [userMapArrow setImage:[UIImage imageNamed:@"dc_map_location"]];
    [scrollMapView addSubview:userMapArrow];
    userMapArrow.hidden = YES;
    
    // ------------- CLLocationManager Enable --------------
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager requestWhenInUseAuthorization];
    [locationManager requestAlwaysAuthorization];
    
    shopGPSLocation = [[CLLocation alloc] initWithLatitude:100 longitude:100 ];

    viewLocationTooltip = [[UIButton alloc] initWithFrame:CGRectMake(btnArrow.frame.origin.x, btnArrow.frame.origin.y - 56 , 308, 55)];
    [viewLocationTooltip setBackgroundImage:[UIImage imageNamed:@"dc_map_enable_location"] forState:UIControlStateNormal];
    [viewLocationTooltip addTarget:self action:@selector(onClickAppSettingPage) forControlEvents:UIControlEventTouchUpInside];
    viewLocationTooltip.alpha = 0;
    viewLocationTooltip.hidden = YES;
    [self.view addSubview:viewLocationTooltip];
    
    viewOutsideTooltip = [[UIButton alloc] initWithFrame:CGRectMake(btnArrow.frame.origin.x, btnArrow.frame.origin.y - 56 , 308, 55)];
    [viewOutsideTooltip setBackgroundImage:[UIImage imageNamed:@"dc_map_outside"] forState:UIControlStateNormal];
    viewOutsideTooltip.alpha = 0;
    [self.view addSubview:viewOutsideTooltip];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setValue:[NSNumber numberWithInteger:MENU_MAP] forKey:WHITELEY_MENU_SELECT];

    m_bOutsideAlert = YES;
    if (self.m_bSectionFacilites) {
        [self onClickFacilitiesButton:nil];
        [userDefault setValue:[NSNumber numberWithInteger:MENU_FACLITIES] forKey:WHITELEY_MENU_SELECT];
    }
    [userDefault synchronize];

    aryMapLatLongLocation = [[NSMutableArray alloc] init];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.884157 Y:1.245199]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.884671 Y:1.246962]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.885040 Y:1.247179]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.885930 Y:1.247635]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.886052 Y:1.248697]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.886363 Y:1.248617]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.886207 Y:1.247404]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.886702 Y:1.245548]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.886394 Y:1.245232]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.886062 Y:1.245553]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.885947 Y:1.245891]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.884417 Y:1.244502]];

    /*
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.884157 Y:1.245199]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.884228 Y:1.245366]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.884390 Y:1.245945]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.884644 Y:1.246739]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.884671 Y:1.246962]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.884999 Y:1.246948]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.885040 Y:1.247179]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.885192 Y:1.247157]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.885930 Y:1.247635]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.886052 Y:1.248697]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.886363 Y:1.248617]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.886370 Y:1.246514]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.886455 Y:1.246347]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.886576 Y:1.246026]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.886702 Y:1.245548]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.886394 Y:1.245232]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.886062 Y:1.245553]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.885947 Y:1.245891]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.885808 Y:1.245843]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.885321 Y:1.245435]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.884777 Y:1.244871]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.884725 Y:1.244754]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.884417 Y:1.244502]];
    */
    self.userMapLocation = [Coordinate coordinateWithX:0 Y:0];
    
    // ------ Show Floor Name --------
    NSString *floorName;
    if (m_nCentureFloor == LOWER_MALL)
        floorName = @"Lower Mall";
    
    [btnFloor setTitle:floorName forState:UIControlStateNormal];
    
    // ------- Show Selected Store ------
    if (self.m_sSelectedShopID.length > 0)
    {
        NSString *selectedShopID = self.m_sSelectedShopID;
        NSInteger index = -1;
        for (int i = 0 ; i < dcStores.count; i++) {
            NSDictionary *dic = [dcStores objectAtIndex:i];
            if ([selectedShopID isEqualToString:dic[@"id"]]) {
                index = i;
                break;
            }
        }
        
        if (index != -1) {
            [scrollMapView setZoomScale:MAX_SCALE];
            [scrollMapView showShopUnitTooltip:index searchFlag:NO];

        }
    }
    
    aryLocation = [[NSMutableArray alloc] init];
    [aryLocation addObject:[Coordinate coordinateWithX:50.884777 Y:-1.244871]];
    [aryLocation addObject:[Coordinate coordinateWithX:50.884901 Y:-1.244963]];
    [aryLocation addObject:[Coordinate coordinateWithX:50.884979 Y:-1.245028]];
    [aryLocation addObject:[Coordinate coordinateWithX:50.885321 Y:-1.245435]];
    [aryLocation addObject:[Coordinate coordinateWithX:50.885514 Y:-1.245618]];
    [aryLocation addObject:[Coordinate coordinateWithX:50.885808 Y:-1.245843]];
    [aryLocation addObject:[Coordinate coordinateWithX:50.885947 Y:-1.245891]];
    [aryLocation addObject:[Coordinate coordinateWithX:50.886062 Y:-1.245553]];
    [aryLocation addObject:[Coordinate coordinateWithX:50.886394 Y:-1.245232]];
    [aryLocation addObject:[Coordinate coordinateWithX:50.886702 Y:-1.245548]];
    [aryLocation addObject:[Coordinate coordinateWithX:50.886576 Y:-1.246026]];
    [aryLocation addObject:[Coordinate coordinateWithX:50.886455 Y:-1.246347]];
    [aryLocation addObject:[Coordinate coordinateWithX:50.886370 Y:-1.246514]];
    [aryLocation addObject:[Coordinate coordinateWithX:50.886235 Y:-1.246911]];
    [aryLocation addObject:[Coordinate coordinateWithX:50.886141 Y:-1.247164]];
    [aryLocation addObject:[Coordinate coordinateWithX:50.886363 Y:-1.248617]];
    [aryLocation addObject:[Coordinate coordinateWithX:50.886052 Y:-1.248697]];
    [aryLocation addObject:[Coordinate coordinateWithX:50.885930 Y:-1.247635]];
    [aryLocation addObject:[Coordinate coordinateWithX:50.886011 Y:-1.247558]];
    [aryLocation addObject:[Coordinate coordinateWithX:50.885192 Y:-1.247157]];
    [aryLocation addObject:[Coordinate coordinateWithX:50.885040 Y:-1.247179]];
    [aryLocation addObject:[Coordinate coordinateWithX:50.884999 Y:-1.246948]];
    [aryLocation addObject:[Coordinate coordinateWithX:50.885183 Y:-1.246354]];
    [aryLocation addObject:[Coordinate coordinateWithX:50.884644 Y:-1.246921]];
    [aryLocation addObject:[Coordinate coordinateWithX:50.884963 Y:-1.246748]];
    [aryLocation addObject:[Coordinate coordinateWithX:50.884671 Y:-1.246962]];
    [aryLocation addObject:[Coordinate coordinateWithX:50.884644 Y:-1.246739]];
    [aryLocation addObject:[Coordinate coordinateWithX:50.884390 Y:-1.245945]];
    [aryLocation addObject:[Coordinate coordinateWithX:50.884393 Y:-1.245725]];
    [aryLocation addObject:[Coordinate coordinateWithX:50.884556 Y:-1.245543]];
    [aryLocation addObject:[Coordinate coordinateWithX:50.884228 Y:-1.245366]];
    [aryLocation addObject:[Coordinate coordinateWithX:50.884157 Y:-1.245199]];
}

- (void) goBack
{
    if (!self.mapSearchView.hidden) {
        if (self.listType == DCStoresListTypeStore || self.listType == DCStoresListTypeCategory) {
            mapSearchView.hidden = YES;
        }
        else if (self.listType == DCStoresListTypeSubCategory) {
            self.listType = DCStoresListTypeCategory;
            [self.tableView setFrame:CGRectMake(0, 214, 320, self.view.frame.size.height - 214)];
            txtSearch.text = @"";
            [self updateButtons];
        }
        [self.txtSearch resignFirstResponder];
    }
    else
    {
        //[self.navigationController popToRootViewControllerAnimated:YES];
        [self removeMapView];
        bUpdateUserLocation = NO;
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)removeMapView
{
    [self.scrollMapView.imageView removeFromSuperview];
    self.scrollMapView.imageView  = nil;
    [self.scrollMapView removeFromSuperview];
    self.scrollMapView = nil;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    NSMutableDictionary *fav_dic =[[NSUserDefaults standardUserDefaults] valueForKey:WHITELEY_FOVORITE_STORE];

    for (int i = 0; i < dcAllStores.count; i++) {
        NSMutableDictionary *dic = [dcAllStores objectAtIndex:i];
        NSString *flag = [fav_dic valueForKey:dic[@"id"]];
        [dic setValue:flag forKey:@"favorite"];
    }
    
    for (int i = 0; i < dcStores.count; i++) {
        NSMutableDictionary *dic = [dcStores objectAtIndex:i];
        NSString *flag = [fav_dic valueForKey:dic[@"id"]];
        [dic setValue:flag forKey:@"favorite"];
    }
    
}

- (void) onClickAppSettingPage
{
    self.viewLocationTooltip.hidden = YES;
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

- (void) onClickSearchButton:(id)sender
{
    self.listType = DCStoresListTypeStore;
    mapSearchView.hidden = NO;
    [self.tableView setFrame:CGRectMake(0, 214, 320, self.view.frame.size.height - 214)];
    txtSearch.text = @"";
    [self updateButtons];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSInteger table_y = txtSearch.frame.origin.y + txtSearch.frame.size.height + 10;
    [self.tableView setFrame:CGRectMake(0, table_y, 320, self.view.frame.size.height - table_y - 216)];
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
        if (self.listType == DCStoresListTypeStore)
            [self setStoreTableData];
        else if (self.listType == DCStoresListTypeSubCategory)
            self.tableData = [[NSMutableArray alloc] initWithArray:dcCategoryStores];
        else
            self.tableData = [[NSMutableArray alloc] initWithArray:self.dcCategories];
    }
    else
    {
        NSMutableArray *searchStores = nil;
        if (self.listType == DCStoresListTypeStore)
            searchStores = dcAllStores;
        else if (self.listType == DCStoresListTypeSubCategory)
            searchStores = dcCategoryStores;
        else
            searchStores = [[NSMutableArray alloc] initWithArray:self.dcCategories];
        
        for (int i = 0; i < searchStores.count; i++) {
            NSDictionary *dic = [searchStores objectAtIndex:i];
            NSString *name = [dic valueForKey:@"name"];
            
            if ([name isEqualToString:NEW_RETAILER_SHOP])
                continue;
            
            NSRange range = [name rangeOfString:search_name options:NSCaseInsensitiveSearch];
            if ( range.location == 0) {
                [self.tableData addObject:dic];
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length == 0)
        [self.tableView setFrame:CGRectMake(0, 214, 320, self.view.frame.size.height - 214)];
    
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    if ([self isViewLoaded] && self.view.window == nil)
        self.view = nil;
}

- (void)onClickArrowButton:(id)sender {
    
    BOOL m_bLocationEnabled = [DCDefines isNotifyEnableLocation];
    if (!m_bLocationEnabled) {
        
        if (!viewLocationTooltip.hidden) {
            [UIView animateWithDuration:0.5 animations:^{
                viewLocationTooltip.alpha = 0;
            } completion:^(BOOL finished) {
                viewLocationTooltip.hidden = YES;
            }];
        }
        else
        {
            viewLocationTooltip.alpha = 0;
            [UIView animateWithDuration:0.5 animations:^{
                viewLocationTooltip.alpha = 1;
                viewLocationTooltip.hidden = NO;
            }];
        }
        return;
    }
    else
    {
        if (!userMapArrow.hidden)
            return;
        
        locIndex = 0;
        bUpdateUserLocation = YES;
        [self performSelectorOnMainThread:@selector(updateLocationOnMap) withObject:nil waitUntilDone:NO];
    }
}

- (void) updateLocationOnMap {
    
    NSLog(@"Updating Location");
    
    [locationManager startUpdatingLocation];

}

- (void)onClickFloorButton:(id)sender {
    
    [scrollMapView setHiddenHighlitedView];
    UIView *viewFloor = [[UIView alloc] initWithFrame:CGRectMake(55, SCREEN_HEIGHT - 150, 134, 72)];
    viewFloor.tag = 100;
    UIImageView *back = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 134, 72)];
    [back setImage:[UIImage imageNamed:@"dc_map_floor_box"]];
    [viewFloor addSubview:back];

    UIButton *floor0 = [[UIButton alloc] initWithFrame:CGRectMake(3, 0, 128, 36)];
    floor0.tag = 0;
    [floor0 setTitle:@"G Lower Mall" forState:UIControlStateNormal];
    [floor0 setTitleColor:UIColorWithRGBA(74, 74, 74, 1) forState:UIControlStateNormal];
    [floor0.titleLabel setFont:[UIFont fontWithName:HFONT_REGULAR size:14.0f]];
    [floor0 addTarget:self action:@selector(onClickSelectFloorButton:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *floor = [[UIButton alloc] initWithFrame:CGRectMake(0, 113, 134, 40)];
    floor.tag = 10;
    [floor setTitleColor:UIColorWithRGBA(74, 74, 74, 1) forState:UIControlStateNormal];
    [floor.titleLabel setFont:[UIFont fontWithName:HFONT_REGULAR size:14.0f]];
    [floor setImage:[UIImage imageNamed:@"dc_map_floor_image"] forState:UIControlStateNormal];
    [floor addTarget:self action:@selector(onClickSelectFloorButton:) forControlEvents:UIControlEventTouchUpInside];
    floor.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);


    NSString *floorName = nil;
    if (m_nCentureFloor == 0)
    {
        floorName = @"Lower Mall";
        [floor0 setBackgroundImage:[UIImage imageNamed:@"dc_flr_sel_button"] forState:UIControlStateNormal];
        [floor0 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
   
    
    [floor setTitle:floorName forState:UIControlStateNormal];
    [viewFloor addSubview:floor0];
    [viewFloor addSubview:floor];
    [self.view addSubview:viewFloor];
    
    viewFloor.alpha = 0;
    [UIView animateWithDuration:0.5f animations:^{
        viewFloor.alpha = 1;
    }];
}

#pragma mark Select Floor Button
- (void)onClickSelectFloorButton:(id)sender
{
    UIView *view = [self.view viewWithTag:100];
    if (view!= nil && !view.hidden) {
        [UIView animateWithDuration:0.1 animations:^{
            view.alpha = 0;
        } completion:^(BOOL finished) {
            [view removeFromSuperview];
        }];
    }
    
    UIButton *button = (UIButton*)sender;
    NSString *floorName = nil;
    NSString *mapName;
    
    if (button.tag == m_nCentureFloor) {
        return;
    }
    
    if (button.tag == 0)
    {
        m_nCentureFloor = LOWER_MALL;
        floorName = @"Lower Mall";
        mapName = @"floor_0";
    }
    else
        return;
    
    [btnFloor setTitle:floorName forState:UIControlStateNormal];
    [self setStoreInfo:m_nCentureFloor];
    [scrollMapView.imageView setImage:[UIImage imageNamed:mapName]];
    [scrollMapView setFacilitesInfo:m_nCentureFloor];
    [scrollMapView setShopPosition];
    [scrollMapView setShopCentreAngle];
    
    [scrollMapView setZoomScale:MIN_SCALE];

    if (m_nCentureFloor == LOWER_MALL)
    {
        [scrollMapView setContentOffset:CGPointMake(0, 0)];
    }
}

- (void)onClickFacilitiesButton:(id)sender {
    
    CGRect frame = btnFacilites.frame;
    CGPoint startPoint = CGPointMake(frame.origin.x + (frame.size.width / 2), frame.origin.y - 5);
    
//    if (SCREEN_HEIGHT == 480)
//        mapFacilitesView = [[[NSBundle mainBundle] loadNibNamed:@"MapFacilitiesView_4s" owner:self options:nil] objectAtIndex:0];
//    else
    mapFacilitesView = [[[NSBundle mainBundle] loadNibNamed:@"MapFacilitiesView" owner:self options:nil] objectAtIndex:0];
    
    for (int i = 0; i < mapFacilitesView.subviews.count; i++) {
        UIButton *button = (UIButton*)[mapFacilitesView.subviews objectAtIndex:i];
        if ([button isKindOfClass:[UIButton class]]) {
            [button addTarget:self action:@selector(onClickFacilitiesItemButton:) forControlEvents:UIControlEventTouchUpInside];

        }
    }

    if ([DCDefines isiPHone4])
        [mapFacilitesView setFrame:CGRectMake(0, 0, 320, SCREEN_HEIGHT - 192)];
    else
        [mapFacilitesView setFrame:CGRectMake(0, 0, 320, SCREEN_HEIGHT - 280)];
    
     self.popContainerView = mapFacilitesView;
    [self.popover showAtPoint:startPoint popoverPostion:DXPopoverPositionUp withContentView:self.popContainerView  inView:self.view];
    
}

- (void)onClickFacilitiesItemButton:(id)sender
{
    UIButton *button = (UIButton*)sender;
    NSInteger tag = button.tag;
    
    if (tag != 13) {
        if (tag == 120) {
            NSDictionary *dic = [[NSUserDefaults standardUserDefaults] valueForKey:WHITELEY_NOTIFY_USER_DETECT];
            if (dic == nil)
            {
                [self.popover dismiss];
                return;
            }
        }

        [scrollMapView onClickFacItemButton:sender];
    }
    [self.popover dismiss];
}

- (IBAction)onClickCloseSearchViewButton:(id)sender {
    mapSearchView.hidden = YES;
    [txtSearch resignFirstResponder];
}

- (IBAction)onClickListButton:(id)sender {
    UIButton *button = (UIButton*)sender;
    if (self.listType != button.tag) {
        self.listType = button.tag;
        [self updateButtons];
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

#pragma mark - CLLocationManagerDelegate

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if (!bUpdateUserLocation) {
        return;
    }
    
    userGPSLocation = [locations lastObject];
    NSLog(@"%f", userGPSLocation.coordinate.longitude);
    NSLog(@"%f", userGPSLocation.coordinate.latitude);

    if (userGPSLocation.coordinate.latitude == 0 || userGPSLocation.coordinate.longitude == 0) {
        self.userMapLocation = [Coordinate coordinateWithX:0 Y:0];
    }
    else {
#if 0
        Coordinate *userCoordinate = aryLocation[locIndex];
        if (locIndex == aryLocation.count - 1) {
            locIndex = 0;
        }
        else
            locIndex++;
#else
        Coordinate *userCoordinate = [Coordinate coordinateWithX:userGPSLocation.coordinate.latitude Y:userGPSLocation.coordinate.longitude];
#endif
        if ( userCoordinate.x >= MAP_RIGHT_BOTTOM_LAT &&
            userCoordinate.x <= MAP_LEFT_TOP_LAT &&
            userCoordinate.y >= MAP_LEFT_TOP_LONG &&
            userCoordinate.y <= MAP_RIGHT_BOTTOM_LONG )
        {
            CGFloat x1 = a11 * userCoordinate.x + a12 * userCoordinate.y + a13;
            CGFloat y1 = a21 * userCoordinate.x + a22 * userCoordinate.y + a23;
            CGFloat w = a31 * userCoordinate.x + a32 * userCoordinate.y + a33;
            CGFloat x = x1 / w;
            CGFloat y = y1 / w;
            self.userMapLocation = [Coordinate coordinateWithX:x/6 Y:(3408-y)/6];
        }
        else
            self.userMapLocation = [Coordinate coordinateWithX:0 Y:0];
    }
    
    if ( userMapLocation.x == 0 || userMapLocation.y == 0 ) {
        self.userMapLocation = [Coordinate coordinateWithX:0 Y:0];
        viewOutsideTooltip.hidden = NO;
        userMapArrow.hidden = YES;
        [UIView animateWithDuration:0.5 animations:^{
            viewOutsideTooltip.alpha = 1;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:2.5 delay:2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                viewOutsideTooltip.alpha = 0;
            } completion:^(BOOL finished) {
                viewOutsideTooltip.hidden = YES;
            }];
        }];
        return;
    }
   
#if 0
    if ( userCoordinate.y <= -1.24487 && userCoordinate.y >= -1.2444 && userCoordinate.x >= 50.8841553 && userCoordinate.x <= 50.886702 )
    {
        CGPoint userDeviation = CGPointMake(userCoordinate.y - 1.24450195, userCoordinate.x - 50.8841553);
        CGPoint baseDeviation = CGPointMake(1.248697-1.24450195, 50.886702-50.8841553);
        //double cos_23 = cos(23*M_PI/180);
        double cos_27 = cos(27*M_PI/180);
        double gps_x = cos_27 * 230 * (userDeviation.x/baseDeviation.x)-40;
        double gps_y = 240 * (userDeviation.y/baseDeviation.y);
        double gps_r = sqrt(pow(gps_x, 2) + pow(gps_y, 2));
        double angle = atan(gps_y/gps_x) * 180 / M_PI;
        double r_angle = angle + 23;
        double r_x = gps_r * cos(r_angle * M_PI / 180);
        double r_y = gps_r * sin(r_angle * M_PI / 180);
        r_x = gps_x > 0? r_x: -r_x;
        r_y = r_y > 0? r_y: -r_y;
        CGFloat userX = 145 - r_x;
        CGFloat userY = 393 - r_y;
        self.userMapLocation = [Coordinate coordinateWithX:userX Y:userY];
    }
    else
        self.userMapLocation = [Coordinate coordinateWithX:0 Y:0];
#endif
   
    userMapArrow.hidden = NO;
    
    userMapArrow.center = CGPointMake(userMapLocation.x * scrollMapView.zoomScale, userMapLocation.y * scrollMapView.zoomScale);
    
    CGPoint offset = CGPointMake(userMapLocation.x * scrollMapView.zoomScale - 320 / 2, userMapLocation.y * scrollMapView.zoomScale - SCREEN_HEIGHT / 2);
    
    [UIView animateWithDuration:0.5 animations:^{
        [scrollMapView setContentOffset:offset];
    }];
    
    [self performSelector:@selector(updateLocationOnMap) withObject:nil afterDelay:5.0f];
}

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
    
    if (self.listType == DCStoresListTypeStore || self.listType == DCStoresListTypeSubCategory) {
        cell.storeCellType = StoreTableViewCellTypeStore;
        
        NSDictionary* store = self.tableData[indexPath.row];
        cell.hasOffer = [store[@"hasoffer"] boolValue];
        cell.isFavorite = [store[@"favorite"] boolValue];
        cell.dcTextLabel.text = store[@"name"];
        cell.favoriteButton.tag = [store[@"id"] integerValue];
        cell.parent = self;
        cell.m_nCellType = MAP_TYPE;
    }
    else {
        cell.storeCellType = StoreTableViewCellTypeCategory;
        NSDictionary *dic = self.tableData[indexPath.row];
        cell.dcTextLabel.text = dic[@"name"];
    }
    
    //    [cell layoutIfNeeded];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [self.txtSearch resignFirstResponder];
    [self.txtSearch setText:@""];
    
    if (self.listType == DCStoresListTypeStore || self.listType == DCStoresListTypeSubCategory) {
        self.mapSearchView.hidden = YES;

        NSDictionary *dic = [self.tableData objectAtIndex:indexPath.row];
        NSString *name = [dic valueForKey:@"name"];
        
        NSInteger index = -1;
        for (int i = 0; i < self.dcAllStores.count; i++) {
            dic = [dcAllStores objectAtIndex:i];
            if ( [[dic valueForKey:@"name"] isEqualToString:name] )
            {
                index = i;
                break;
            }
        }
        if (index != -1)
        {
            NSString *floor = dic[@"location"];
            NSString *floorName;
            NSString *mapName;
            NSInteger floorNumber;
            if ([floor isEqualToString:@"G Lower Mall"])
            {
                floorNumber = LOWER_MALL;
                floorName = @"Lower Mall";
                mapName = @"floor_0";
            }else if ([floor isEqualToString:@"1 Upper Mall"])
            {
                floorNumber = UPPER_MALL;
                floorName = @"Upper Mall";
                mapName = @"floor_1";
            }
            else if ([floor isEqualToString:@"2 Food Court"]) {
                floorNumber = FOOD_COURT;
                floorName = @"Food Court";
                mapName = @"floor_2";
            }
            else
                return;
            
            self.m_sSelectedShopID = dic[@"id"];
            NSString *selectedShopID = self.m_sSelectedShopID;

            if (floorNumber == m_nCentureFloor) {
                index = -1;
                for (int i = 0 ; i < dcStores.count; i++) {
                    NSDictionary *dic = [dcStores objectAtIndex:i];
                    if ([selectedShopID isEqualToString:dic[@"id"]]) {
                        index = i;
                        break;
                    }
                }
                
                if (index != -1)
                    [scrollMapView showShopUnitTooltip:index searchFlag:NO];
                
                return;
            }
            
            m_nCentureFloor = floorNumber;
            [btnFloor setTitle:floorName forState:UIControlStateNormal];
            [self setStoreInfo:m_nCentureFloor];
            [scrollMapView.imageView setImage:[UIImage imageNamed:mapName]];
            [scrollMapView setFacilitesInfo:m_nCentureFloor];
            [scrollMapView setShopPosition];
            [scrollMapView setShopCentreAngle];
            
            index = -1;
            for (int i = 0 ; i < dcStores.count; i++) {
                NSDictionary *dic = [dcStores objectAtIndex:i];
                if ([selectedShopID isEqualToString:dic[@"id"]]) {
                    index = i;
                    break;
                }
            }
            
            if (index != -1) {
                [scrollMapView setZoomScale:MAX_SCALE];
                [scrollMapView showSelectedShop:index];
            }
            
            self.listType = DCStoresListTypeStore;
        }
    }
    else
    {
        NSString *cat_id = [[self.dcCategories objectAtIndex:indexPath.row] objectForKey:@"id"];
        dcCategoryStores = [[NSMutableArray alloc] init];
        for (int i = 0; i < dcAllStores.count; i++) {
            NSDictionary *dic = [dcAllStores objectAtIndex:i];
            NSArray *aryCID = dic[@"cat_id"];
            for (int i = 0; i < aryCID.count; i++) {
                NSString *cID = [aryCID objectAtIndex:i];
                if ([cID isEqualToString:cat_id]) {
                    [dcCategoryStores addObject:dic];
                    break;
                }
            }
        }
        self.tableData = [[NSMutableArray alloc] initWithArray:dcCategoryStores];
        self.listType = DCStoresListTypeSubCategory;
        NSInteger table_y = txtSearch.frame.origin.y + txtSearch.frame.size.height + 15;
        [self.tableView setFrame:CGRectMake(0, table_y, 320, self.view.frame.size.height - table_y)];
        [self.tableView reloadData];
    }
}

-(void) setStoreTableData {
    self.tableData = [[NSMutableArray alloc] initWithArray:self.dcAllStores];
    
    for ( int i = 0; i < self.tableData.count; i++ ){
        NSMutableDictionary *dic = [self.tableData objectAtIndex:i];
        if ([dic[@"name"] isEqualToString:NEW_RETAILER_SHOP]) {
            [self.tableData removeObjectAtIndex:i];
            break;
        }
    }
}

- (void) setStoreInfo:(NSInteger) floor
{
    NSMutableArray* tempList = [NSMutableArray array];
    NSString *floorName;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *localDB = [userDefaults valueForKey:WHITELEY_STORE_LIST];
    dcAllStores = [[NSMutableArray alloc] init];
    for (int i = 0; i < localDB.count; i++) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[localDB objectAtIndex:i]];
        [dcAllStores addObject:dic];
    }
    
    NSArray *aryShopName = nil;
    if (self.m_nCentureFloor == LOWER_MALL) {
        aryShopName = [NSArray arrayWithObjects:@"C",//1
                        @"A1",//2
                        @"A2",//3
                        @"A3",//4
                        @"A4",//5
                        @"A5",//6
                        @"A6",//7
                        @"G4",//8
                        @"G3",//9
                        @"G2",//10
                        @"G1",//11
                        @"H3",//12
                        @"H2",//13
                        @"H1",//14
                        @"M1",//15
                        @"B1",//16
                        @"B2",//17
                        @"B3",//18
                        @"B4",//19
                        @"B5",//20
                        @"B6",//21
                        @"B7",//22
                        @"B8",//23
                        @"B9",//24
                        @"F1",//25
                        @"F2",//26
                        @"F3",//27
                        @"F4",//28
                        @"F5",//29
                        @"F8",//30
                        @"F6",//31
                        @"TO",//32
                        @"T",//33
                        @"E17",//34
                        @"E16",//35
                        @"E15",//36
                        @"E14",//37
                        @"E13",//38
                        @"E12",//39
                        @"K2",//40
                        @"E11",//41
                        @"E10",//42
                        @"E9B",//43
                        @"E9A",//44
                        @"E8B",//45
                        @"E8A",//46
                        @"E7B",//47
                        @"E7A",//48
                        @"E6",//49
                        @"E5",//50
                        @"E4",//51
                        @"E3",//52
                        @"E1/2",//53
                        @"K1",//54
                        @"D13",//55
                        @"D12",//56
                        @"D10/11",//57
                        @"D9",//58
                        @"D8B",//59
                        @"D8A",//60
                        @"D7",//61
                        @"D6",//62
                        @"D5",//63
                        @"D4",//64
                        @"D3B",//65
                        @"D3A",//66
                        //@"D2B",//67
                        @"D2A",//68
                        @"D1",//69
                    nil];
        floorName = @"G Lower Mall";
    }
    
    for (int i = 0; i < aryShopName.count; i++) {
        NSString *unitName = [aryShopName objectAtIndex:i];
        BOOL emptyShopFlag = YES;
        for (int j = 0; j < dcAllStores.count; j++) {
            NSMutableDictionary *dic = [dcAllStores objectAtIndex:j];
            
            NSString *unitNum = dic[@"unit_num"];
            NSString *location = dic[@"location"];
            if ([floorName isEqualToString:location] &&
                [unitNum isEqualToString:unitName]) {
                NSMutableDictionary *store = [ NSMutableDictionary dictionaryWithObjectsAndKeys:
                                              dic[@"id"], @"id",
                                              dic[@"name"], @"name",
                                              dic[@"hasoffer"], @"hasoffer",
                                              dic[@"favorite"], @"favorite", nil];
                [tempList addObject:store];
                emptyShopFlag = NO;
                break;
            }
        }
        if (emptyShopFlag) {
            NSMutableDictionary *store = [ NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          @"", @"id",
                                          @"Empty Shop", @"name",
                                          @"0", @"hasoffer",
                                          @"0", @"favorite", nil];
            [tempList addObject:store];
        }
    }
    
    dcStores = tempList;
    
}

- (void) setStoreCategoryInfo
{
    self.dcCategories = [[NSUserDefaults standardUserDefaults] valueForKey:WHITELEY_CATEGORY_LIST];
}

- (UIImage *)imageByScalingProportionallyToSize :(UIImage*)image size:(CGSize)targetSize {
    
    UIImage *sourceImage = image;
    UIImage *newImage = nil;
    
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (!CGSizeEqualToSize(imageSize, targetSize)) {
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor < heightFactor)
            scaleFactor = widthFactor;
        else
            scaleFactor = heightFactor;
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        
        if (widthFactor < heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        } else if (widthFactor > heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    
    // this is actually the interesting part:
    
    UIGraphicsBeginImageContext(targetSize);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(newImage == nil) NSLog(@"could not scale image");
    
    
    return newImage ;
}
@end
