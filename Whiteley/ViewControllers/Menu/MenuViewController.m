//
//  MenuViewController.m
//  DrakeCircus
//
//  Created by Alex Hong on 3/24/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import "MenuViewController.h"
#import "DCDefines.h"
#import "MenuTableViewCell.h"
#import "StoreListViewController.h"
#import "EventListViewController.h"
#import "MapViewController.h"
#import "OfferListViewController.h"
#import "HereViewController.h"
#import "CardViewController.h"
#import "OpeningHoursViewController.h"
#import "MonsterFirstViewController.h"
#import "OpenWebSiteViewController.h"

@interface MenuViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray* menuIcons;
@property (nonatomic, strong) NSArray* menuTexts;
@property (nonatomic, weak) UINavigationController *rootController;
@property (nonatomic, assign) NSInteger m_nMenuSelect;
@end

@implementation MenuViewController
@synthesize m_nMenuSelect;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.blurView.underlyingView = self.presentingViewController.view;
    self.blurView.blurRadius = 10.0f;
    self.blurView.tintColor = UIColorWithRGBA(108, 130, 140, 1);
    self.blurView.dynamic = YES;
    self.rootController = (UINavigationController*)self.presentingViewController;
    
    self.menuIcons = [NSArray arrayWithObjects: @"icon-map", @"icon-stores", @"icon-offers-menu", @"icon-food", @"icon-cinema", @"icon-rockup", @"icon-car", @"icon-parking", @"icon-events", @"icon-open-hours", @"icon-signup", @"icon-feedback", nil];
    self.menuTexts = [NSArray arrayWithObjects: @"Centre Map", @"Our Stores", @"Latest Offers", @"Food Outlets", @"Cinema Times", @"Rock Up", @"Getting Here", @"Centre Facilities", @"Latest Events", @"Opening Hours", @"Sign Up", @"Feedback", nil];
    
    NSNumber *number = [[NSUserDefaults standardUserDefaults] valueForKey:WHITELEY_MENU_SELECT];
    
    if (number == nil)
        m_nMenuSelect = -1;
    else
        m_nMenuSelect = [number integerValue];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"drake-logo"]];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = UIColorWithRGBA(108, 130, 140, 0.9);
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

#pragma mark - <UITableViewDelegate&DataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuTexts.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellId = @"MenuTableViewCell";
    MenuTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    cell.dcImageView.image = [UIImage imageNamed:self.menuIcons[indexPath.row]];
    cell.dcTextLabel.text = self.menuTexts[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (m_nMenuSelect !=-1 && indexPath.row == m_nMenuSelect)
        [cell setBackgroundColor: UIColorWithRGBA(108, 130, 140, 1)];
    else
        [cell setBackgroundColor:[UIColor clearColor]];
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    m_nMenuSelect = -1;
    [self.tableView reloadData];
    
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController* vc = nil;
    NSInteger index = indexPath.row;
    UIViewController *lastController = [self.rootController.viewControllers lastObject];
    NSInteger viewNum = -1;
    if ([lastController isKindOfClass:[MapViewController class]])
        viewNum = MENU_MAP;
    else if ([lastController isKindOfClass:[StoreListViewController class]])
    {
        viewNum = MENU_STORE;
        StoreListViewController *storeContorller = (StoreListViewController*)lastController;
        if (storeContorller.listType == DCFoodOutletsTypeCategory) {
            viewNum = MENU_FOOD;
        }
    }
    else if ([lastController isKindOfClass:[OfferListViewController class]])
        viewNum = MENU_OFFER;
    else if ([lastController isKindOfClass:[HereViewController class]])
        viewNum = MENU_HERE;
    else if ([lastController isKindOfClass:[EventListViewController class]])
        viewNum = MENU_EVENTS;
    else if ([lastController isKindOfClass:[OpeningHoursViewController class]])
        viewNum = MENU_HOURS;
   // else if ([lastController isKindOfClass:[MonsterFirstViewController class]])
   //     viewNum = MENU_MONSTER;
    
    if (viewNum == index)
    {
        [self dismissViewControllerAnimated:NO completion:nil];
        return;
    }
    
    NSString *strKind = @"";
    
    switch (index) {
        case MENU_MAP:
        {
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
            MapViewController *controller = (MapViewController*)vc;
            controller.m_bSectionFacilites = NO;
            controller.m_nCentureFloor = LOWER_MALL;
            controller.m_sSelectedShopID = @"";
            strKind = @"map";
            break;
        }
        case MENU_STORE:
        {
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"StoreListViewController"];
            StoreListViewController* storeVC = (StoreListViewController*)vc;
            storeVC.listType = DCStoresListTypeStore;
            strKind = @"stores";
            break;
        }
        case MENU_OFFER:
        {
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OfferListViewController"];
            strKind = @"offers";
            break;
        }
        case MENU_FOOD:
        {
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"StoreListViewController"];
            StoreListViewController *storeVC = (StoreListViewController*)vc;
            storeVC.listType = DCFoodOutletsTypeCategory;
            strKind = @"food";
            break;
        }
        case MENU_CINEMA:
        {
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OpenWebSiteViewController"];
            OpenWebSiteViewController *controller = (OpenWebSiteViewController*) vc;
            controller.title = @"Cinema Times";
            controller.strURL = @"http://www1.cineworld.co.uk/cinemas/whiteley";
            strKind = @"cinema";
            break;
        }
        case MENU_ROCKUP:
        {
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OpenWebSiteViewController"];
            OpenWebSiteViewController *controller = (OpenWebSiteViewController*) vc;
            controller.title = @"Rock Up";
            controller.strURL = @"http://www.rock-up.co.uk/book-online/";
            strKind = @"rockup";
            break;
        }
        case MENU_HERE:
        {
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"HereViewController"];
            strKind = @"here";
            break;
        }
        case MENU_FACLITIES:
        {
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
            MapViewController *controller = (MapViewController*)vc;
            controller.m_bSectionFacilites = YES;
            controller.m_nCentureFloor = LOWER_MALL;
            controller.m_sSelectedShopID = @"";
            strKind = @"facilities";
            break;
        }
        case MENU_EVENTS:
        {
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"EventListViewController"];
            strKind = @"events";
            break;
        }
        case MENU_HOURS:
        {
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OpeningHoursViewController"];
            strKind = @"open_hrs";
            break;
        }
        /*case MENU_MONSTER:
        {
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MonsterFirstViewController"];
            strKind = @"monster";
            break;
        }*/
        case MENU_SIGNUP:
        {
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OpenWebSiteViewController"];
            OpenWebSiteViewController *controller = (OpenWebSiteViewController*) vc;
            controller.title = @"Sign Up";
            controller.strURL = @"http://eepurl.com/JEbsb";
            break;
        }
        case MENU_FEEDBACK:
        {
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"FeedbackViewController"];
            break;
        }
        default:
            return;
    }
    
    m_nMenuSelect = index;
    [self.tableView reloadData];
    
    vc.title = self.menuTexts[index];
    
    for (int i = 0; i < self.rootController.viewControllers.count; i++) {
        UIViewController *ctrlr = [self.rootController.viewControllers objectAtIndex:i];
        if ([ctrlr isKindOfClass:[MapViewController class]]) {
            MapViewController *controller = (MapViewController*)ctrlr;
            [controller removeMapView];
        }
    }

    
    [self.rootController popToRootViewControllerAnimated:NO];
    [self.rootController setNavigationBarHidden:NO];
    
    [self dismissViewControllerAnimated:NO completion:^(void){
        
        if (strKind.length > 0) {
            NSString *url = [DCWEBAPI_REGISTER_SECTION stringByAppendingString:strKind];
            
            [DCDefines getHttpAsyncResponse:url withHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            }];
        }
        [self.rootController pushViewController:vc animated:NO];
    }];
    
}

- (IBAction)onHomeButtonClicked:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    for (int i = 0; i < self.rootController.viewControllers.count; i++) {
        UIViewController *ctrlr = [self.rootController.viewControllers objectAtIndex:i];
        if ([ctrlr isKindOfClass:[MapViewController class]]) {
            MapViewController *controller = (MapViewController*)ctrlr;
            [controller removeMapView];
        }
    }

    [self.rootController popToRootViewControllerAnimated:NO];
}

- (IBAction)onCloseButtonClicked:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
