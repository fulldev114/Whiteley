//
//  HomeViewController.m
//  Whiteley
//
//  Created by Alex Hong on 3/20/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import <MessageUI/MessageUI.h>
#import "DXPopover.h"
#import "HomeViewController.h"
#import "MenuView.h"
#import "StoreListViewController.h"
#import "MapViewController.h"
#import "MenuViewController.h"
#import "DCNavigationViewController.h"
#import "MonsterFirstViewController.h"
#import "MonsterFoundViewController.h"
#import "OfferListViewController.h"
#import "OfferDetailViewController.h"
#import "EventDetailViewController.h"
#import "CardViewController.h"
#import "OpenWebSiteViewController.h"
#import "FeedbackViewController.h"
#import "HeaderView.h"

typedef NS_ENUM(NSInteger, SECTION_TYPE) {
    SECTION_MAP = 0,
    SECTION_STORE,
    SECTION_OFFER,
    SECTION_FOOD,
    SECTION_CINEMA,
    SECTION_ROCKUP,
    //SECTION_HERE,
    SECTION_FACLITIES,
    //SECTION_MONSTER,
    SECTION_SIGNUP,
};

typedef NS_ENUM(NSInteger, ALERT_TYPE) {
    WELCOME_ALERT = 1,
    MONSTER_ALERT,
    FAVORITE_ALERT,
    FEEDBACK_ALERT,
    LIKE_ALERT,
    RATE_ALERT,
    UPGRADE_ALERT
};

typedef NS_ENUM(NSInteger, SETTING_NOTIFY_TYPE) {
    BLUETOOTH_SETTING = 1,
    LOCATION_SETTING,
    NOTIFICATION_SETTING
};

@interface HomeViewController () <CLLocationManagerDelegate, MFMessageComposeViewControllerDelegate>
{
    NSString *offeventID;
    NSInteger regIntervalTime;
    CLLocationManager *locationManager;
    CLLocation *userGPSLocation;
    NSInteger settingNotifyType;
}

@property (nonatomic, retain) DXPopover         *popover;
@property (nonatomic, retain) UIView            *popContainerView;
@property (nonatomic, strong) NSMutableArray    *menuIcons;
@property (nonatomic, strong) NSMutableArray    *menuTexts;
@property (nonatomic, strong) NSMutableArray    *menuDetails;
@property (nonatomic, strong) CBCentralManager  *centralManager;
@property (nonatomic, strong) NSMutableArray    *aryMonster;
@property (nonatomic, strong) NSMutableArray    *aryCarousel;
@property (nonatomic, assign) BOOL              m_bRerfreshCarousel;
@property (nonatomic, assign) BOOL              m_bWeekBehaviourEnable;
@property (nonatomic, assign) BOOL              m_bWeekBehaviourDone;
@property (nonatomic, assign) BOOL              m_bBlueoothEnabled;
@property (nonatomic, assign) NSInteger         homeCarouselReloadCount;
@property (nonatomic, retain) UIAlertView       *alertNotfication;
@property (nonatomic, retain) UIView            *viewFeedback;
@property (strong, nonatomic) UIAlertView       *alertUpgrade;

@end

@implementation HomeViewController
@synthesize aryMonster, aryCarousel, m_bRerfreshCarousel, m_bWeekBehaviourEnable, m_bWeekBehaviourDone;
@synthesize shoppingThread, alertNotfication;
@synthesize viewFeedback;

- (void)viewDidLoad {
        
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];

    UIImageView* titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"whiteley-logo"]];
    self.navigationItem.titleView = titleView;
    
    self.menuIcons = [NSMutableArray array];
    self.menuTexts = [NSMutableArray array];
    self.menuDetails = [NSMutableArray array];

    alertNotfication = [[UIAlertView alloc] initWithTitle:@"" message:@"" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"View", nil];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
// ------------- App Open Count ----------
    NSNumber *open_num = [userDefaults valueForKey:APP_OPEN_NUM];
    NSInteger m_nOpen = 0;
    if (open_num == nil) {
        m_nOpen = 1;
    }
    else {
        m_nOpen = [open_num integerValue];
        
        if (m_nOpen == 2) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Like our app?" message:@"Spread the love and share it with your friends!" delegate:self cancelButtonTitle:@"Not right now" otherButtonTitles:@"Share", nil];
            alert.tag = LIKE_ALERT;
            [alert show];
        }
        else
        if (m_nOpen == 4) {
            UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle:@"Like us? Rate us!" message:@"Help us improve the Whiteley app by rating us!" delegate:self cancelButtonTitle:@"Not right now" otherButtonTitles:@"OK", nil];
            alert1.tag = RATE_ALERT;
            [alert1 show];
        }
        
        m_nOpen++;
    }
    [userDefaults setObject:[NSNumber numberWithInteger:m_nOpen] forKey:APP_OPEN_NUM];
    [userDefaults synchronize];
// ---------------------------------------
    
// -------- Table Header View Init -------
    NSMutableArray *aryData = [userDefaults valueForKey:WHITELEY_CAROUSEL_LIST];
    HeaderView *headerView = [HeaderView headerViewWithData:aryData Delegate:self];
    [self.tableView setTableHeaderView:headerView];
// --------------------------------------
    
    self.popover = [DXPopover new];
    self.popover.maskType = DXPopoverMaskTypeNone;
    
    [self addHeader];

    NSMutableAttributedString* attString = nil;
    
    // Centre Map
    [self.menuIcons addObject:@"home-icon-map"];
    
    attString = [[NSMutableAttributedString alloc] initWithString:@"Centre Map"];
    [attString addAttributes:@{NSForegroundColorAttributeName : UIColorWithRGBA(74, 74, 74, 1), NSFontAttributeName : [UIFont fontWithName:HFONT_ULTRA_LIGHT size:24]} range:[@"Centre Map" rangeOfString:@"Centre "]];
    [attString addAttributes:@{NSForegroundColorAttributeName : UIColorWithRGBA(74, 74, 74, 1), NSFontAttributeName : [UIFont fontWithName:HFONT_REGULAR size:24]} range:[@"Centre Map" rangeOfString:@"Map"]];
    [self.menuTexts addObject:attString];
    
    attString = [[NSMutableAttributedString alloc] initWithString:@"FIND YOUR WAY" attributes:@{NSForegroundColorAttributeName : UIColorWithRGBA(74, 74, 74, 1), NSFontAttributeName : [UIFont fontWithName:NFONT_DEMI_BOLD size:12]}];
    [self.menuDetails addObject:attString];
    
    // Our Stores
    [self.menuIcons addObject:@"home-icon-stores"];
    
    attString = [[NSMutableAttributedString alloc] initWithString:@"Our Stores"];
    [attString addAttributes:@{NSForegroundColorAttributeName : UIColorWithRGBA(74, 74, 74, 1), NSFontAttributeName : [UIFont fontWithName:HFONT_ULTRA_LIGHT size:24]} range:[@"Our Stores" rangeOfString:@"Our "]];
    [attString addAttributes:@{NSForegroundColorAttributeName : UIColorWithRGBA(74, 74, 74, 1), NSFontAttributeName : [UIFont fontWithName:HFONT_REGULAR size:24]} range:[@"Our Stores" rangeOfString:@"Stores"]];
    [self.menuTexts addObject:attString];
    	
    attString = [[NSMutableAttributedString alloc] initWithString:@"BROWSE DIRECTORY" attributes:@{NSForegroundColorAttributeName : UIColorWithRGBA(74, 74, 74, 1), NSFontAttributeName : [UIFont fontWithName:NFONT_DEMI_BOLD size:12]}];
    [self.menuDetails addObject:attString];
    
    // Latest Offers
    [self.menuIcons addObject:@"home-icon-offers"];
    
    attString = [[NSMutableAttributedString alloc] initWithString:@"Latest Offers"];
    [attString addAttributes:@{NSForegroundColorAttributeName : UIColorWithRGBA(74, 74, 74, 1), NSFontAttributeName : [UIFont fontWithName:HFONT_ULTRA_LIGHT size:24]} range:[@"Latest Offers" rangeOfString:@"Latest "]];
    [attString addAttributes:@{NSForegroundColorAttributeName : UIColorWithRGBA(74, 74, 74, 1), NSFontAttributeName : [UIFont fontWithName:HFONT_REGULAR size:24]} range:[@"Latest Offers" rangeOfString:@"Offers"]];
    [self.menuTexts addObject:attString];
    
    attString = [[NSMutableAttributedString alloc] initWithString:@"FOR WHITELEY SHOPPERS" attributes:@{NSForegroundColorAttributeName : UIColorWithRGBA(74, 74, 74, 1), NSFontAttributeName : [UIFont fontWithName:NFONT_DEMI_BOLD size:12]}];
    [self.menuDetails addObject:attString];
    
    // Food Outlets
    [self.menuIcons addObject:@"home-icon-food"];
    
    attString = [[NSMutableAttributedString alloc] initWithString:@"Food Outlets"];
    [attString addAttributes:@{NSForegroundColorAttributeName : UIColorWithRGBA(74, 74, 74, 1), NSFontAttributeName : [UIFont fontWithName:HFONT_ULTRA_LIGHT size:24]} range:[@"Food Outlets" rangeOfString:@"Food "]];
    [attString addAttributes:@{NSForegroundColorAttributeName : UIColorWithRGBA(74, 74, 74, 1), NSFontAttributeName : [UIFont fontWithName:HFONT_REGULAR size:24]} range:[@"Food Outlets" rangeOfString:@"Outlets"]];
    [self.menuTexts addObject:attString];
    
    attString = [[NSMutableAttributedString alloc] initWithString:@"GRAB A BITE" attributes:@{NSForegroundColorAttributeName : UIColorWithRGBA(74, 74, 74, 1), NSFontAttributeName : [UIFont fontWithName:NFONT_DEMI_BOLD size:12]}];
    [self.menuDetails addObject:attString];
    
    // Cinea Times
    [self.menuIcons addObject:@"home-icon-cinema"];
    
    attString = [[NSMutableAttributedString alloc] initWithString:@"Cinema Times"];
    [attString addAttributes:@{NSForegroundColorAttributeName : UIColorWithRGBA(74, 74, 74, 1), NSFontAttributeName : [UIFont fontWithName:HFONT_ULTRA_LIGHT size:24]} range:[@"Cinema Times" rangeOfString:@"Cinema "]];
    [attString addAttributes:@{NSForegroundColorAttributeName : UIColorWithRGBA(74, 74, 74, 1), NSFontAttributeName : [UIFont fontWithName:HFONT_REGULAR size:24]} range:[@"Cinema Times" rangeOfString:@"Times"]];
    [self.menuTexts addObject:attString];
    
    attString = [[NSMutableAttributedString alloc] initWithString:@"CINEMA TIMES" attributes:@{NSForegroundColorAttributeName : UIColorWithRGBA(74, 74, 74, 1), NSFontAttributeName : [UIFont fontWithName:NFONT_DEMI_BOLD size:12]}];
    [self.menuDetails addObject:attString];

    // Rock Up
    [self.menuIcons addObject:@"home-icon-rockup"];
    
    attString = [[NSMutableAttributedString alloc] initWithString:@"Rock Up"];
    [attString addAttributes:@{NSForegroundColorAttributeName : UIColorWithRGBA(74, 74, 74, 1), NSFontAttributeName : [UIFont fontWithName:HFONT_ULTRA_LIGHT size:24]} range:[@"Rock Up" rangeOfString:@"Rock "]];
    [attString addAttributes:@{NSForegroundColorAttributeName : UIColorWithRGBA(74, 74, 74, 1), NSFontAttributeName : [UIFont fontWithName:HFONT_REGULAR size:24]} range:[@"Rock Up" rangeOfString:@"Up"]];
    [self.menuTexts addObject:attString];
    
    attString = [[NSMutableAttributedString alloc] initWithString:@"ROCK UP" attributes:@{NSForegroundColorAttributeName : UIColorWithRGBA(74, 74, 74, 1), NSFontAttributeName : [UIFont fontWithName:NFONT_DEMI_BOLD size:12]}];
    [self.menuDetails addObject:attString];
    
    /*
    // Getting Here
    [self.menuIcons addObject:@"home-icon-travel"];
    
    attString = [[NSMutableAttributedString alloc] initWithString:@"Getting Here"];
    [attString addAttributes:@{NSForegroundColorAttributeName : UIColorWithRGBA(74, 74, 74, 1), NSFontAttributeName : [UIFont fontWithName:HFONT_ULTRA_LIGHT size:24]} range:[@"Getting Here" rangeOfString:@"Getting "]];
    [attString addAttributes:@{NSForegroundColorAttributeName : UIColorWithRGBA(74, 74, 74, 1), NSFontAttributeName : [UIFont fontWithName:HFONT_REGULAR size:24]} range:[@"Getting Here" rangeOfString:@"Here"]];
    [self.menuTexts addObject:attString];
    
    attString = [[NSMutableAttributedString alloc] initWithString:@"TO AND FROM THE CENTRE" attributes:@{NSForegroundColorAttributeName : UIColorWithRGBA(74, 74, 74, 1), NSFontAttributeName : [UIFont fontWithName:NFONT_DEMI_BOLD size:12]}];
    [self.menuDetails addObject:attString];
    */
    
    // Our Facilities
    [self.menuIcons addObject:@"home-icon-facilities"];
    
    attString = [[NSMutableAttributedString alloc] initWithString:@"Our Facilities"];
    [attString addAttributes:@{NSForegroundColorAttributeName : UIColorWithRGBA(74, 74, 74, 1), NSFontAttributeName : [UIFont fontWithName:HFONT_ULTRA_LIGHT size:24]} range:[@"Our Facilities" rangeOfString:@"Our "]];
    [attString addAttributes:@{NSForegroundColorAttributeName : UIColorWithRGBA(74, 74, 74, 1), NSFontAttributeName : [UIFont fontWithName:HFONT_REGULAR size:24]} range:[@"Our Facilities" rangeOfString:@"Facilities"]];
    [self.menuTexts addObject:attString];
    
    attString = [[NSMutableAttributedString alloc] initWithString:@"AT THE CENTRE" attributes:@{NSForegroundColorAttributeName : UIColorWithRGBA(74, 74, 74, 1), NSFontAttributeName : [UIFont fontWithName:NFONT_DEMI_BOLD size:12]}];
    [self.menuDetails addObject:attString];
   
    // Our Monster
    /*
    [self.menuIcons addObject:@"home-icon-monster"];
    
    attString = [[NSMutableAttributedString alloc] initWithString:@"Easter Egg Hunt"];
    [attString addAttributes:@{NSForegroundColorAttributeName : UIColorWithRGBA(74, 74, 74, 1), NSFontAttributeName : [UIFont fontWithName:HFONT_ULTRA_LIGHT size:24]} range:[@"Easter Egg Hunt" rangeOfString:@"Easter Egg "]];
    [attString addAttributes:@{NSForegroundColorAttributeName : UIColorWithRGBA(74, 74, 74, 1), NSFontAttributeName : [UIFont fontWithName:HFONT_REGULAR size:24]} range:[@"Easter Egg Hunt" rangeOfString:@"Hunt"]];
    [self.menuTexts addObject:attString];
    
    attString = [[NSMutableAttributedString alloc] initWithString:@"FIND THE HIDDEN EGGS" attributes:@{NSForegroundColorAttributeName : UIColorWithRGBA(74, 74, 74, 1), NSFontAttributeName : [UIFont fontWithName:NFONT_DEMI_BOLD size:12]}];
    [self.menuDetails addObject:attString];
    */
    
    // Sign Up
    [self.menuIcons addObject:@"home-icon-signup"];
    
    attString = [[NSMutableAttributedString alloc] initWithString:@"Sign Up"];
    [attString addAttributes:@{NSForegroundColorAttributeName : UIColorWithRGBA(74, 74, 74, 1), NSFontAttributeName : [UIFont fontWithName:HFONT_ULTRA_LIGHT size:24]} range:[@"Sign Up" rangeOfString:@"Sign "]];
    [attString addAttributes:@{NSForegroundColorAttributeName : UIColorWithRGBA(74, 74, 74, 1), NSFontAttributeName : [UIFont fontWithName:HFONT_REGULAR size:24]} range:[@"Sign Up" rangeOfString:@"Up"]];
    [self.menuTexts addObject:attString];
    
    attString = [[NSMutableAttributedString alloc] initWithString:@"SIGN UP" attributes:@{NSForegroundColorAttributeName : UIColorWithRGBA(74, 74, 74, 1), NSFontAttributeName : [UIFont fontWithName:NFONT_DEMI_BOLD size:12]}];
    [self.menuDetails addObject:attString];
    
#pragma mark iBeacon Monitor Start
    
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:@{CBCentralManagerOptionShowPowerAlertKey : @NO}];
    
    // ----------- Estimote Beacon ----------
    BeaconMonitor* mainMonitor = [BeaconMonitor sharedBeaconMonitor];
    mainMonitor.delegate = self;
    mainMonitor.isEasterEgg = NO;
    [mainMonitor startBeaconMonitoringWith:WHITELEY_PROXIMITY_UUID regionID:WHITELEY_REGION_IDENTIFIER determinedProximity:CLProximityNear];

    // ----------- Jaalee Beacon ----------
//    JLEBeaconMonitor* JLEmainMonitor = [JLEBeaconMonitor sharedBeaconMonitor];
//    JLEmainMonitor.delegate = self;
//    [JLEmainMonitor startBeaconMonitoringWith:WHITELEY_PROXIMITY_UUID regionID:WHITELEY_REGION_IDENTIFIER determinedProximity:CLProximityNear];

    // ---------- phone vibration -----------
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);

    // ----------- init notification steop ----------
    //[userDefaults setObject:@"start" forKey:WHITELEY_NOTIFY_STEP];
    [userDefaults setObject:@"0" forKey:WHITELEY_ENABLE_FIND_MONSTER];
    [userDefaults setObject:@"0" forKey:WHITELEY_SHOW_MONSTER_PAGE];

    // ------------ shopping check time ------------
    NSDate *lastTime, *nowTime = [NSDate date];
    lastTime = [userDefaults valueForKey:WHITELEY_SHOPPING_LAST_TIME];
    if (lastTime != nil) {
        NSCalendar * calendar = [NSCalendar currentCalendar];
        NSDateComponents * components = [calendar components:NSCalendarUnitSecond fromDate:lastTime toDate:nowTime options:0];
        NSInteger seconds = components.second;
        
        if (seconds >= WHITELEY_NO_SHOPPING_TIME) {
            [userDefaults setObject:nil forKey:WHITELEY_SHOPPING_LAST_TIME];
            //[userDefaults setObject:@"start" forKey:WHITELEY_NOTIFY_STEP];
            [userDefaults setObject:nil forKey:WHITELEY_NOTIFY_USER_DETECT];
            [userDefaults synchronize];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *fb = [userDefaults valueForKey:WHITELEY_FEEDBACK];
                
                if ([fb isEqualToString:FEEDBACK_NOTIFY] || [fb isEqualToString:FEEDBACK_PAGE]) {
                    return;
                }
                
                NSString *msg = @"Help us improve your shopping\nexperience by answering 3 short\nquestions about your visit today.";
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"How was your visit to Whiteley?" message:msg delegate:self cancelButtonTitle:@"Not right now" otherButtonTitles:@"OK, let's go!", nil];
                alert.tag = FEEDBACK_ALERT;
                
                [userDefaults setValue:FEEDBACK_NOTIFY forKey:WHITELEY_FEEDBACK];
                [userDefaults synchronize];
                
                [alert show];
                
            });
            //[userDefaults setObject:@"start" forKey:WHITELEY_NOTIFY_STEP];
        }
    }

    [userDefaults setObject:nil forKey:WHITELEY_NOTIFY_USER_DETECT];
    [userDefaults synchronize];
    
    [self registerDeviceTokenToServer:NO];

    regIntervalTime = 0;

    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager requestWhenInUseAuthorization];
    [locationManager startUpdatingLocation];

    
    userGPSLocation = [[CLLocation alloc] initWithLatitude:0 longitude:0];
    
    shoppingThread = [[NSThread alloc] initWithTarget:self selector:@selector(isLeavingShoppingCentre) object:nil];
    [shoppingThread start];
    
    m_bWeekBehaviourDone = NO;
    m_bRerfreshCarousel = YES;

    
    [self setupAppLocalSettings];
    
    NSString *firstOpened = [[NSUserDefaults standardUserDefaults] valueForKey:WHITELEY_FIRST_OPEN];
    
    if([firstOpened isEqualToString:@"1"])
        [self performSelector:@selector(showNotifyBox) withObject:nil afterDelay:1.0f];

    // Feedback View
    
    viewFeedback = [[UIView alloc] initWithFrame:CGRectMake(30, 125, 260, 177)];
    [viewFeedback setBackgroundColor:UIColorWithRGBA(239, 240, 240, 1)];
    
    UILabel *lblFB = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, 260, 18)];
    [lblFB setText:@"Thank you for your feedback!"];
    [lblFB setFont:[UIFont fontWithName:HFONT_MEDIUM size:16]];
    [lblFB setTextColor:UIColorWithRGBA(5, 181, 218, 1)];
    [lblFB setTextAlignment:NSTextAlignmentCenter];
    [viewFeedback addSubview:lblFB];
    
    UIButton *btnFB = [[UIButton alloc] initWithFrame:CGRectMake(12, 90, 236, 55)];
    [btnFB setImage:[UIImage imageNamed:@"feedback_welcome"] forState:UIControlStateNormal];
    [btnFB addTarget:self action:@selector(onClickFeedbackWelcome:) forControlEvents:UIControlEventTouchUpInside];
    [viewFeedback addSubview:btnFB];
    
    NSString *fb_sent = [userDefaults valueForKey:WHITELEY_FEEDBACK_ASK];
    
    if ( [fb_sent isEqualToString:@"1"] ) {
        NSString *msg = @"Help us improve your shopping\nexperience by answering 3 short\nquestions about your visit today.";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"How was your visit to Whiteley?" message:msg delegate:self cancelButtonTitle:@"Not right now" otherButtonTitles:@"OK, let's go!", nil];
        alert.tag = FEEDBACK_ALERT;
        [alert show];
        
        [userDefaults setValue:FEEDBACK_NOTIFY forKey:WHITELEY_FEEDBACK];
        [userDefaults synchronize];
    }
    else {
        [userDefaults setValue:nil forKey:WHITELEY_FEEDBACK];
        [userDefaults synchronize];
    }
    
    // GPS Report Time reset
    [userDefaults setValue:nil forKey:WHITELEY_GPS_LAST_TIME];

    // User Shop Visit Data
    [userDefaults setValue:nil forKey:WHITELEY_VISIT_STATUS];
    [userDefaults synchronize];
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:nil forKey:WHITELEY_MENU_SELECT];
    [userDefaults synchronize];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

//    if ([self isViewLoaded] && self.view.window == nil)
//        self.view = nil;
}

- (void) registerDeviceTokenToServer:(BOOL) bVisit {
    
    
    if (deviceTokenID == nil || deviceTokenID.length == 0) {
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *deviceID = [userDefaults valueForKey:WHITELEY_DEVICE_ID];
        deviceTokenID = @"";
        
        if (deviceID != nil && deviceID.length > 0)
            deviceTokenID = deviceID;
        else
            return;
    }

    NSString *uuid = [DCDefines deviceUUID];
    
    NSLog(@"UUID = %@", uuid);
    
    if (bVisit) {
        NSString *url = [NSString stringWithFormat:@"%@%@&device_id=%@&device_kind=ios&shop_visit=1", DCWEBAPI_SET_REGISTER_INFO, deviceTokenID, uuid];
        
        [DCDefines getHttpAsyncResponse:url withHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        }];
    }
    else {

        NSString *url = [NSString stringWithFormat:@"%@%@&device_id=%@&device_kind=ios&shop_visit=0", DCWEBAPI_SET_REGISTER_INFO, deviceTokenID, uuid];
        
        [DCDefines getHttpAsyncResponse:url withHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        }];
    }
}

- (void) registerGPSInfoToServer {
    while (YES) {
        
    }
}

- (void) setupAppLocalSettings
{
    NSInteger flag_count = 0;
    if (![DCDefines isNotifiyEnableBluetooth])
        flag_count++;
    else {
        if (settingNotifyType == BLUETOOTH_SETTING) {
            [self.popover dismiss];
        }
    }
    
    if (![DCDefines isNotifyEnableLocation])
        flag_count++;
    else {
        if (settingNotifyType == LOCATION_SETTING) {
            [self.popover dismiss];
        }
    }
    
    if (![DCDefines isNotifyEnableNotification])
        flag_count++;
    else {
        if (settingNotifyType == NOTIFICATION_SETTING) {
            [self.popover dismiss];
        }
    }
    
    UIImage *image = nil;
    switch (flag_count) {
        case 0:
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@""] style:UIBarButtonItemStylePlain target:self action:nil];
            break;
        case 1:
            image = [[UIImage imageNamed:@"notify_group1"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(showNotifyBox)];
            break;
        case 2:
            image = [[UIImage imageNamed:@"notify_group2"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(showNotifyBox)];
            break;
        case 3:
            image = [[UIImage imageNamed:@"notify_group3"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(showNotifyBox)];
            break;
        default:
            break;
    }
    
    [self checkUpgradeApp];
}

- (void)checkUpgradeApp {
    NSString *url = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@", APP_ID];
    
    [DCDefines getHttpAsyncResponse:url withHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSData *responseData = data;
        NSString *store_version = @"";
        NSError* errorInfo;
        
        if (responseData == nil) {
            return;
        }
        
        NSDictionary *dic  = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&errorInfo];
        if (dic == nil) {
            return;
        }
        NSDictionary *configData = [dic valueForKey:@"results"];
        
        for (id config in configData) {
            store_version = (NSString*)[config valueForKey:@"version"];
        }
        
        float fltStoreVersion = [store_version floatValue];
        float fltAppVersion = [APP_VERSION floatValue];
        
        if (store_version.length > 0 && fltStoreVersion > fltAppVersion ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.alertUpgrade == nil) {
                    self.alertUpgrade = [[UIAlertView alloc] initWithTitle:@"App Update" message:@"Hey there! We've made some updates to the Whiteley Shopping app and you'll need to download the latest version." delegate:self cancelButtonTitle:@"Update" otherButtonTitles:nil, nil];
                    self.alertUpgrade.tag = UPGRADE_ALERT;
                    [self.alertUpgrade show];
                }
            });
        }
        
    }];
}

- (void) showNotifyBox
{

    CGRect rect = self.popover.frame;
    
    if( rect.size.width >= 200 )
    {
        return;
    }
    
    CGPoint startPoint = CGPointMake(30, 0);

    NSInteger contentHeight = 0;
    NSInteger flag_count = 0;
    UIView *notifyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 90)];
    
    if (![DCDefines isNotifiyEnableBluetooth]) {
        UIView *bleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 86)];
        UIImageView *bleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 25, 36, 36)];
        bleImageView.image = [UIImage imageNamed:@"notify_ble"];
        [bleView addSubview:bleImageView];
        
        UITextView *bleTxtView = [[UITextView alloc] initWithFrame:CGRectMake(70, 10, 220, 70)];
        NSString* text = @"When at the centre please turn on\nyour phone's Bluetooth to make\nuse of this app's iBeacon features.";
        NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString:text];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setLineSpacing:3];
        [attrString addAttributes:@{
                                    NSForegroundColorAttributeName : UIColorWithRGBA(74, 74, 74, 1),
                                    NSFontAttributeName : [UIFont fontWithName:HFONT_THIN size:13],
                                    NSParagraphStyleAttributeName : style
                                    } range:NSMakeRange(0, text.length)];
        bleTxtView.attributedText = attrString;
        bleTxtView.scrollEnabled = NO;
        bleTxtView.selectable = NO;
        [bleView addSubview:bleTxtView];
        [bleView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickBluetoothSettings)]];
        [bleView setUserInteractionEnabled:YES];
        [notifyView addSubview:bleView];
        
        contentHeight += 86;
        [notifyView setFrame:CGRectMake(0, 0, 300, contentHeight+4)];
        flag_count++;
        notifyView.tag = BLUETOOTH_SETTING;
    }
    
    if (![DCDefines isNotifyEnableLocation]) {
        UIView *locationView = [[UIView alloc] initWithFrame:CGRectMake(0, contentHeight, 300, 86)];
        
        if (contentHeight != 0) {
            UIImageView *locLine = [[UIImageView alloc] initWithFrame:CGRectMake(20, 0, 300, 1)];
            locLine.image = [UIImage imageNamed:@"notify_line"];
            [locationView addSubview:locLine];
        }
        
        UIImageView *locImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 25, 36, 36)];
        locImageView.image = [UIImage imageNamed:@"notify_location"];
        [locationView addSubview:locImageView];
        
        UITextView *locTxtView = [[UITextView alloc] initWithFrame:CGRectMake(70, 10, 220, 70)];
        NSString* text = @"For a better experience, please\nenable location sharing within\nthe app's settings";
        NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString:text];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setLineSpacing:3];
        [attrString addAttributes:@{
                                    NSForegroundColorAttributeName : UIColorWithRGBA(74, 74, 74, 1),
                                    NSFontAttributeName : [UIFont fontWithName:HFONT_THIN size:13],
                                    NSParagraphStyleAttributeName : style
                                    } range:NSMakeRange(0, text.length)];
        locTxtView.attributedText = attrString;
        locTxtView.scrollEnabled = NO;
        locTxtView.selectable = NO;
        [locationView addSubview:locTxtView];
        
        UIImageView *linkImageView = [[UIImageView alloc] initWithFrame:CGRectMake(264, 30, 15, 28)];
        linkImageView.image = [UIImage imageNamed:@"notify_link"];
        [locationView addSubview:linkImageView];
        [locationView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickAppSettings)]];
        [locationView setUserInteractionEnabled:YES];
        [notifyView addSubview:locationView];
        
        contentHeight += 86;
        [notifyView setFrame:CGRectMake(0, 0, 300, contentHeight+4)];
        flag_count++;
        notifyView.tag = LOCATION_SETTING;
    }
    
    if (![DCDefines isNotifyEnableNotification]) {
        UIView *notView = [[UIView alloc] initWithFrame:CGRectMake(0, contentHeight, 300, 86)];
        
        if (contentHeight != 0) {
            UIImageView *locLine = [[UIImageView alloc] initWithFrame:CGRectMake(20, 0, 300, 1)];
            locLine.image = [UIImage imageNamed:@"notify_line"];
            [notView addSubview:locLine];
        }
        
        UIImageView *locImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 25, 36, 36)];
        locImageView.image = [UIImage imageNamed:@"notify_notification"];
        [notView addSubview:locImageView];
        
        UITextView *notTxtView = [[UITextView alloc] initWithFrame:CGRectMake(70, 10, 220, 70)];
        NSString* text = @"For a better experience, please\nenable notifications within the\napp's settings";
        NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString:text];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setLineSpacing:3];
        [attrString addAttributes:@{
                                    NSForegroundColorAttributeName : UIColorWithRGBA(74, 74, 74, 1),
                                    NSFontAttributeName : [UIFont fontWithName:HFONT_THIN size:13],
                                    NSParagraphStyleAttributeName : style
                                    } range:NSMakeRange(0, text.length)];
        notTxtView.attributedText = attrString;
        notTxtView.scrollEnabled = NO;
        notTxtView.selectable = NO;
        [notView addSubview:notTxtView];
        
        UIImageView *linkImageView = [[UIImageView alloc] initWithFrame:CGRectMake(264, 30, 15, 28)];
        linkImageView.image = [UIImage imageNamed:@"notify_link"];
        [notView addSubview:linkImageView];
        [notView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickAppSettings)]];
        [notView setUserInteractionEnabled:YES];
        [notifyView addSubview:notView];
        
        contentHeight += 86;
        [notifyView setFrame:CGRectMake(0, 0, 300, contentHeight+4)];
        flag_count++;
        notifyView.tag = NOTIFICATION_SETTING;
    }
    
    notifyView.userInteractionEnabled = YES;

    if (flag_count > 0)
    {
        self.popContainerView = notifyView;
        settingNotifyType = notifyView.tag;
        startPoint.y = startPoint.y + self.tableView.contentOffset.y;
        [self.popover showAtPoint:startPoint popoverPostion:DXPopoverPositionDown withContentView:self.popContainerView inView:self.view];
    }
    else
        settingNotifyType = 0;
}

- (void) onClickFeedbackWelcome:(id)sender {
    //[viewFeedback removeFromSuperview];
}

- (void) onClickAppSettings
{
    [self.popover dismiss];
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

- (void) onClickBluetoothSettings
{
    [self.popover dismiss];
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
                [self getCarouselFromWebServer];
                break;
            default:
                break;
        }
    };
    self.header = header;
}

- (void) getCarouselFromWebServer
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    self.homeCarouselReloadCount = 0;
    [self.tableView setScrollEnabled:NO];

    [DCDefines getHttpAsyncResponse:DCWEBAPI_GET_HOME_CAROUSEL withHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        NSData *responseData = data;
        
        if (responseData == nil) {
            return;
        }
        
        NSError* errorInfo;
        NSDictionary *dic  = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&errorInfo];
        aryCarousel = [dic valueForKey:@"result"];
        
        for (int i = 0; i < aryCarousel.count; i++) {
            [self performSelectorInBackground:@selector(downloadCarouselImageFromWebServer:) withObject:[NSNumber numberWithInteger:i]];
        }
        
        [userDefaults setObject:aryCarousel forKey:WHITELEY_CAROUSEL_LIST];
        [userDefaults synchronize];
    }];
}

- (void)downloadCarouselImageFromWebServer:(NSNumber*)index
{
    NSInteger c_index = [index integerValue];
    NSDictionary *dic = [aryCarousel objectAtIndex:c_index];
    NSString *imgURL = dic[@"image"];
    
    self.homeCarouselReloadCount++;
    
    if (imgURL.length ==0 || imgURL == nil)
        return;

    NSString *URL = [imgURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    // new download
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:URL]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         if (connectionError == nil)
         {
             UIImage *img = [UIImage imageWithData:data];
             
             NSString *strImage = [NSString stringWithFormat:@"carousel_%@.png", dic[@"id"]];
             if ( img != nil )
             {
                 NSString *documentFolderPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
                 NSString* file_name = [documentFolderPath stringByAppendingPathComponent:strImage];
                 
                 NSData *imgData = UIImagePNGRepresentation(img);
                 [imgData writeToFile:file_name atomically:YES];
                 
             }
            

         }
         
         if (self.homeCarouselReloadCount >= aryCarousel.count) {
             m_bRerfreshCarousel = YES;
             [self.tableView reloadData];
             [self.tableView setScrollEnabled:YES];
             
             HeaderView *headerView = (HeaderView*)self.tableView.tableHeaderView;
             NSInteger page_index = headerView.pageControl.currentPage;
             NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
             NSMutableArray *aryData = [userDefaults valueForKey:WHITELEY_CAROUSEL_LIST];
             headerView.aryHomeCarousel = aryData;
             
             if (page_index >= headerView.aryHomeCarousel.count)
                 page_index = headerView.aryHomeCarousel.count - 1;
            
             headerView.pageControl.currentPage = page_index;
             CGRect rect = headerView.bluredImageView.frame;
             rect.origin.x = page_index * 320;
             [headerView.bluredImageView setFrame:rect];

             [self.header endRefreshing];
             [self performSelector:@selector(refreshBlurView:) withObject:headerView afterDelay:0.5f];

         }
     }];
    
}
- (void)refreshBlurView:(HeaderView*)header
{
    //[header refreshBlurViewForNewImage];
}
- (void)doneWithView:(MJRefreshBaseView *)refreshView
{
    [self.tableView reloadData];
    [refreshView endRefreshing];
}

#pragma mark Shopping FeedBack

- (void) isLeavingShoppingCentre
{
    while (true) {
        if (regIntervalTime >= WHITELEY_GPS_NOFITY_TIME) {
            
            if (SYSTEM_VERSION >= 8)
                [locationManager requestAlwaysAuthorization];
            
            if (SYSTEM_VERSION >= 9)
                [locationManager setAllowsBackgroundLocationUpdates:YES];

            [locationManager startUpdatingLocation];
            regIntervalTime = 0;
        }
        
        // Check notification
        [DCDefines getHttpAsyncResponse:DCWEBAPI_CHECK_NOTIFICATION withHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
        }];
        
        NSLog(@"--------thread_call----------\n");
        
        sleep(WHITELEY_CHECK_SHOPPING_TIME);
        
        regIntervalTime += WHITELEY_CHECK_SHOPPING_TIME;
     
        // ------- If bluetooh is off, near beacon will be set 0.0 -------
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:@{CBCentralManagerOptionShowPowerAlertKey : @NO}];
        
        NSDate *nowTime = [NSDate date];
        NSDate *lastTime;
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        lastTime = [userDefaults valueForKey:WHITELEY_SHOPPING_LAST_TIME];
        
#if 0
        // calculate seconds from last check time
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"e"];
        NSInteger week = [[dateFormatter stringFromDate:nowTime]integerValue];
        if ( week == 5 ) // Thursday
        {
            [dateFormatter setDateFormat:@"HH"];
            NSInteger hour = [[dateFormatter stringFromDate:nowTime]integerValue];
            if (hour == 13 && !m_bWeekBehaviourDone) {
                m_bWeekBehaviourEnable = YES;
                m_bWeekBehaviourDone = YES;
            }
            else if ( hour == 14 )
                m_bWeekBehaviourDone = NO;
            else
                m_bWeekBehaviourEnable = NO;
            
        }
        else
            m_bWeekBehaviourEnable = NO;
#endif
        
        if (lastTime != nil) {
            NSCalendar * calendar = [NSCalendar currentCalendar];
            NSDateComponents * components = [calendar components:NSCalendarUnitSecond fromDate:lastTime toDate:nowTime options:0];
            NSInteger seconds = components.second;
            
            if (seconds < WHITELEY_NO_SHOPPING_TIME)
                continue;
            
            [userDefaults setObject:nil forKey:WHITELEY_SHOPPING_LAST_TIME];
            //[userDefaults setObject:@"start" forKey:WHITELEY_NOTIFY_STEP];
            [userDefaults setObject:nil forKey:WHITELEY_NOTIFY_USER_DETECT];
            [userDefaults synchronize];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *fb = [userDefaults valueForKey:WHITELEY_FEEDBACK];

                if ([fb isEqualToString:FEEDBACK_NOTIFY] || [fb isEqualToString:FEEDBACK_PAGE]) {
                    return;
                }
                
                NSString *msg = @"Help us improve your shopping\nexperience by answering 3 short\nquestions about your visit today.";
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"How was your visit to Whiteley?" message:msg delegate:self cancelButtonTitle:@"Not right now" otherButtonTitles:@"OK, let's go!", nil];
                alert.tag = FEEDBACK_ALERT;
          
                [userDefaults setValue:FEEDBACK_NOTIFY forKey:WHITELEY_FEEDBACK];
                [userDefaults synchronize];
                
                if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive)
                {
                    msg = @"How was your visit to Whiteley?";
                    [DCDefines pushNotification:msg SectionType:FEEDBACK_NOTIFICATION Major:0 Minor:0 Delay:0];
                }
                else
                {
                    [alert show];
                }
            });
        }
        else
            continue;
        
        
#if 0
        if (!m_bWeekBehaviourEnable) {
            
            if (lastTime == nil)
                continue;
            
            [userDefaults setObject:nil forKey:WHITELEY_SHOPPING_LAST_TIME];
            [userDefaults setObject:@"start" forKey:WHITELEY_NOTIFY_STEP];
            [userDefaults setObject:nil forKey:WHITELEY_NOTIFY_USER_DETECT];
            [userDefaults synchronize];
            continue;
        }

        NSMutableArray *aryStore = [userDefaults valueForKey:WHITELEY_STORE_LIST];
        NSMutableDictionary *dcFavoriteData = [userDefaults valueForKey:WHITELEY_FOVORITE_STORE];
        NSString *strStoreID = nil;
        NSMutableArray *aryStoreID = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < aryStore.count; i++) {
            NSDictionary *dic = [aryStore objectAtIndex:i];
            NSString *storeID = [dic valueForKey:@"id"];
            NSString *favID = [dcFavoriteData valueForKey:storeID];
            if ([favID isEqual:@"1"] && [dic[@"hasoffer"] isEqualToString:@"1"]) {
                [aryStoreID addObject:storeID];
            }
        }
        
        if (aryStoreID.count > 0) {
            NSInteger rand = random();
            rand = rand % aryStoreID.count;
            strStoreID = [aryStoreID objectAtIndex:rand];
            
            NSString *url = [NSString stringWithFormat:@"%@%@", DCWEBAPI_GET_OFFEVENT_ID, strStoreID];
            
            [DCDefines getHttpAsyncResponse:url withHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

                NSData *responseData = data;
                
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                NSDictionary *dic = [userDefaults valueForKey:WHITELEY_NOTIFICATION_INFO];
                NSString *msg = [dic valueForKey:@"visit"];
                
                if (msg == nil || msg.length == 0)
                    msg = @"We love our shoppers. Please could you tell us how to make your experience even better?";
                
                
                if (responseData == nil) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive)
                        {
                            [DCDefines pushNotification:msg SectionType:0 Major:0 Minor:0 Delay:0];
                        }
                    });
                    return;
                }
                
                NSError* errorInfo;
                NSDictionary *resultDic  = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&errorInfo];
                NSDictionary *dcOffEvent = [resultDic valueForKey:@"result"];
                
                if ([dcOffEvent isKindOfClass:[NSString class]])
                    return;
                
                
                if ( dcOffEvent.count == 0 )
                    return;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSString *msg = @"Offer/Evnet - specific";
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Offer/Event Page" message:msg delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"View", nil];
                    offeventID = [dcOffEvent valueForKey:@"id"];
                    
                    NSString *type = [dcOffEvent valueForKey:@"type"];
                    
                    if ([type isEqual:@"offer"]) {
                        if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive)
                        {
                            [DCDefines pushNotification:msg SectionType:OFFERDETAIL_NOTIFICATION Major:0 Minor:0 Delay:0];
                        }
                        else
                        {
                            alert.tag = OFFERDETAIL_NOTIFICATION;
                            [alert show];
                        }
                    }
                    else if ([type isEqual:@"event"])
                    {
                        if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive)
                        {
                            [DCDefines pushNotification:msg SectionType:EVENTDETAIL_NOTIFICATION Major:0 Minor:0 Delay:0];
                        }
                        else
                        {
                            alert.tag = EVENTDETAIL_NOTIFICATION;
                            [alert show];
                        }
                        
                    }
                });
                
            }];

        }
#endif
    }
}

- (void) showCoachScreen
{
     UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CoachViewController"];
    [self.navigationController pushViewController:vc animated:YES];

}

# pragma mark Table View

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == self.tableView) {
        if (self.popover.frame.size.width >= 200 )
            [self.popover dismiss];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.tableView)
    {
        [(HeaderView *)self.tableView.tableHeaderView layoutHeaderViewForScrollViewOffset:scrollView.contentOffset];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuDetails.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 95;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   // static NSString* headerCellIdentifier = @"HeaderView";
    static NSString* menuCellIdentifier = @"MenuView";
    
    UITableViewCell* cell = nil;
    {
        cell = [tableView dequeueReusableCellWithIdentifier:menuCellIdentifier];
        cell.autoresizesSubviews = NO;
        
        if ((indexPath.row % 2) == 0) {
            cell.backgroundColor = UIColorWithRGBA(239, 240, 240, 1);
        }
        else {
            cell.backgroundColor = UIColorWithRGBA(230, 232, 232, 1);
        }
        
        MenuView* menu = (MenuView*)cell;
        menu.iconView.image = [UIImage imageNamed:self.menuIcons[indexPath.row]];
        menu.dcTextLabel.attributedText = self.menuTexts[indexPath.row];
        menu.dcDetailTextLabel.attributedText = self.menuDetails[indexPath.row];

    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIViewController* vc = nil;
    NSString *strKind = @"";

    switch (indexPath.row ) {
        case SECTION_STORE:
        {
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"StoreListViewController"];
            StoreListViewController* storeVC = (StoreListViewController*)vc;
            storeVC.listType = DCStoresListTypeStore;
            strKind = @"stores";
            break;
        }
        case SECTION_MAP:
        {
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
            MapViewController *controller = (MapViewController*)vc;
            controller.m_bSectionFacilites = NO;
            controller.m_nCentureFloor = LOWER_MALL;
            controller.m_sSelectedShopID = @"";
            strKind = @"map";
            break;
        }
        case SECTION_OFFER:
        {
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OfferListViewController"];
            strKind = @"offers";
            break;
        }
        case SECTION_FOOD:
        {
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"StoreListViewController"];
            StoreListViewController* storeVC = (StoreListViewController*)vc;
            storeVC.listType = DCFoodOutletsTypeCategory;
            strKind = @"food";
            break;
        }
        case SECTION_CINEMA:
        {
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OpenWebSiteViewController"];
            OpenWebSiteViewController *controller = (OpenWebSiteViewController*) vc;
            controller.title = @"Cinema Times";
            controller.strURL = @"http://www1.cineworld.co.uk/cinemas/whiteley";
            strKind = @"cinema";
            break;
        }
        case SECTION_ROCKUP:
        {
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OpenWebSiteViewController"];
            OpenWebSiteViewController *controller = (OpenWebSiteViewController*) vc;
            controller.title = @"Rock Up";
            controller.strURL = @"http://www.rock-up.co.uk/book-online/";
            strKind = @"rockup";
            break;
        }
//        case SECTION_HERE:
//        {
//            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"HereViewController"];
//            strKind = @"here";
//            break;
//        }
        case SECTION_FACLITIES:
        {
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
            MapViewController *controller = (MapViewController*)vc;
            controller.m_bSectionFacilites = YES;
            controller.m_nCentureFloor = LOWER_MALL;
            controller.m_sSelectedShopID = @"";
            strKind = @"facilities";
            break;
        }
        /*case SECTION_MONSTER:
        {
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MonsterFirstViewController"];
            strKind = @"monster";
            break;
        }*/
        case SECTION_SIGNUP:
        {
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OpenWebSiteViewController"];
            OpenWebSiteViewController *controller = (OpenWebSiteViewController*) vc;
            controller.title = @"Sign Up";
            controller.strURL = @"http://eepurl.com/JEbsb";
            break;
        }

        default:
            return;
            break;
    }
    
    if (strKind.length > 0) {
        NSString *url = [DCWEBAPI_REGISTER_SECTION stringByAppendingString:strKind];
        
        [DCDefines getHttpAsyncResponse:url withHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        }];
    }

    vc.title = [self.menuTexts[indexPath.row] string];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)showMenu:(UIBarButtonItem *)sender {
    MenuViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MenuViewController"];
    DCNavigationViewController* navC = [[DCNavigationViewController alloc] initWithRootViewController:vc];
    navC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    navC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:navC animated:YES completion:^(void) {
    }];
}

- (void) getOfferEventFromWebServer:(NSString*)strStoreID
{
    NSString *url = [NSString stringWithFormat:@"%@%@", DCWEBAPI_GET_OFFEVENT_ID, strStoreID];
    [DCDefines getHttpAsyncResponse:url withHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSData *responseData = data;
        
        if (responseData == nil) {
            return;
        }
        
        NSError* errorInfo;
        NSDictionary *dic  = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&errorInfo];
        NSDictionary *dcOffEvent = [dic valueForKey:@"result"];
        
        if ( [dcOffEvent isKindOfClass:[NSString class]] || dcOffEvent.count == 0 )
        {            
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSString *msg = dcOffEvent[@"notification"];
            NSString *title = nil;
            
            NSMutableArray *aryStore = [userDefaults valueForKey:WHITELEY_STORE_LIST];

            for (int i = 0; i < aryStore.count; i++) {
                NSDictionary *dic = [aryStore objectAtIndex:i];
                if ([strStoreID isEqualToString:dic[@"id"]]) {
                    title = dic[@"name"];
                    break;
                }
            }

            msg = dcOffEvent[@"notification"];
            if (msg.length == 0 || msg == nil) {
                msg = @"Offer/Event Detail List";
            }
          
            NSDictionary *dicBeacon = [userDefaults valueForKey:WHITELEY_NOTIFY_USER_DETECT];
            NSInteger major = [dicBeacon[@"major"] integerValue];
            NSInteger minor = [dicBeacon[@"minor"] integerValue];
            
            offeventID = [dcOffEvent valueForKey:@"id"];
            NSString *type = [dcOffEvent valueForKey:@"type"];
            
            if ([type isEqual:@"offer"])
            {
                if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive)
                {
                    [DCDefines pushNotification:msg SectionType:OFFERDETAIL_NOTIFICATION Major:major Minor:minor Delay:0];
                }
                else
                {
                    if ([alertNotfication isVisible])
                    {
                        [userDefaults setObject:@"monster" forKey:WHITELEY_NOTIFY_STEP];
                        [userDefaults synchronize];
                        return;
                    }
                    alertNotfication.title = @"Offer/Event Page";
                    
                    if (title != nil) {
                        NSString *alert_title = @"Offer from ";
                        alert_title = [alert_title stringByAppendingString:title];
                        alertNotfication.title = alert_title;
                    }
                    
                    alertNotfication.message = msg;
                    alertNotfication.tag = OFFERDETAIL_NOTIFICATION;
                    [alertNotfication show];
                }
            }
            else if ([type isEqual:@"event"])
            {
                if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive)
                {
                    [DCDefines pushNotification:msg SectionType:EVENTDETAIL_NOTIFICATION Major:major Minor:minor Delay:0];
                }
                else
                {
                    if ([alertNotfication isVisible])
                    {
                        [userDefaults setObject:@"monster" forKey:WHITELEY_NOTIFY_STEP];
                        [userDefaults synchronize];
                        return;
                    }
                    alertNotfication.title = @"Offer/Event Page";
                    
                    if (title != nil) {
                        NSString *alert_title = @"Event from ";
                        alert_title = [alert_title stringByAppendingString:title];
                        alertNotfication.title = alert_title;
                    }
                    alertNotfication.message = msg;
                    alertNotfication.tag = EVENTDETAIL_NOTIFICATION;
                    [alertNotfication show];

                }
            }
            
        });
        
    }];
    
    return;

}

#pragma mark Beacon monitor

- (void)didExitRegion:(NSString *)strUUID {
 
    NSLog(@"new beacon discovered: %d.%d", 0, 0);

    NSString *url = [NSString stringWithFormat:@"%@%@&uuid=%@&major=0&minor=0", DCWEBAPI_SET_USER_BEACON, deviceTokenID, strUUID];
    [DCDefines getHttpAsyncResponse:url withHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    }];
}

- (void)beaconMonitor:(BeaconMonitor *)beaconMonitor didDiscoverNearestBeacon:(ESTBeacon *)nearestBeacon {
    
    NSLog(@"new beacon discovered: %d.%d", nearestBeacon.major.intValue, nearestBeacon.minor.intValue);
   
    NSDate *curDate = [NSDate date];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *strUUID = [[nearestBeacon.proximityUUID UUIDString] lowercaseString];
    
    if (nearestBeacon == nil)
    {
        NSString *url = [NSString stringWithFormat:@"%@%@&uuid=%@&major=0&minor=0", DCWEBAPI_SET_USER_BEACON, deviceTokenID, strUUID];
        [DCDefines getHttpAsyncResponse:url withHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        }];
        
        return;
    }
    
    if (nearestBeacon.major.intValue == 0 && nearestBeacon.minor.intValue == 0) {
        NSString *url = [NSString stringWithFormat:@"%@%@&uuid=%@&major=0&minor=0", DCWEBAPI_SET_USER_BEACON, deviceTokenID, strUUID];
        [DCDefines getHttpAsyncResponse:url withHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        }];
        
        return;
    }
    
    NSDate *lastTime;
    lastTime = [userDefaults valueForKey:WHITELEY_LAST_VISIT_TIME];
    
    if (lastTime == nil) {
        [userDefaults setObject:curDate forKey:WHITELEY_LAST_VISIT_TIME];
        [userDefaults synchronize];
        [self registerDeviceTokenToServer:YES];
    }
    else {
        NSCalendar * calendar = [NSCalendar currentCalendar];
        NSDateComponents * components = [calendar components:NSCalendarUnitSecond fromDate:lastTime toDate:curDate options:0];
        NSInteger seconds = components.second;
        
        if (seconds > 24 * 3600/* 24 hours*/)
        {
            [self registerDeviceTokenToServer:YES];
            [userDefaults setObject:curDate forKey:WHITELEY_LAST_VISIT_TIME];
            [userDefaults synchronize];
        }
    }
    
// ---- Register user near beacon to Server ----
    NSString *url = [NSString stringWithFormat:@"%@%@&uuid=%@&major=%ld&minor=%ld", DCWEBAPI_SET_USER_BEACON, deviceTokenID , strUUID, (long)nearestBeacon.major.intValue, (long)nearestBeacon.minor.intValue];
    [DCDefines getHttpAsyncResponse:url withHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    }];
// ---------------------------------------------
    

#pragma mark <User Detect>
    NSDictionary *dic = [userDefaults valueForKey:WHITELEY_NOTIFY_USER_DETECT];
    
    if (dic == nil) {
        dic = [NSDictionary dictionaryWithObjectsAndKeys:strUUID, @"uuid", nearestBeacon.major, @"major", nearestBeacon.minor, @"minor", nil];
        [userDefaults setValue:dic forKey:WHITELEY_NOTIFY_USER_DETECT];
        [userDefaults synchronize];
    }
    else
    {
        NSString *p_uuid = dic[@"uuid"];
        NSNumber *major = dic[@"major"];
        NSNumber *minor = dic[@"minor"];
        
        if (![p_uuid isEqualToString:strUUID] && major.integerValue != nearestBeacon.major.integerValue && minor.integerValue != nearestBeacon.minor.integerValue ) {
            NSDictionary *newDic = [NSDictionary dictionaryWithObjectsAndKeys:strUUID, @"uuid", nearestBeacon.major, @"major", nearestBeacon.minor, @"minor", nil];
            [userDefaults setValue:newDic forKey:WHITELEY_NOTIFY_USER_DETECT];
            [userDefaults synchronize];
        }
    }
    
    NSMutableArray *aryDetectedDevice = [[NSMutableArray alloc] initWithArray:[userDefaults valueForKey:WHITELEY_NOTIFY_DETECTED_BEACON]];
    BOOL m_bDetected = NO;
    
    if (aryDetectedDevice != nil || aryDetectedDevice.count > 0) {
        for (int i = 0; i < aryDetectedDevice.count; i++) {
            NSDictionary *dicDevice = [aryDetectedDevice objectAtIndex:i];
            NSString *p_uuid = [dicDevice valueForKey:@"uuid"];
            NSInteger major = [[dicDevice valueForKey:@"major"] integerValue];
            NSInteger minor = [[dicDevice valueForKey:@"minor"] integerValue];
            if ([p_uuid isEqualToString:strUUID] && major == nearestBeacon.major.integerValue && minor == nearestBeacon.minor.integerValue) {
                NSDate *detectedDate = dicDevice[@"date"];
                if ([curDate timeIntervalSinceDate:detectedDate] < 10) {
                    m_bDetected = YES;
                }
                else {
                    [aryDetectedDevice removeObjectAtIndex:i];
                }
                break;
            }
        }
    }
    
    if (!m_bDetected) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:strUUID, @"uuid", nearestBeacon.major, @"major", nearestBeacon.minor, @"minor", curDate, @"date", nil];
        [aryDetectedDevice addObject:dic];
        [userDefaults setObject:aryDetectedDevice forKey:WHITELEY_NOTIFY_DETECTED_BEACON];
        
        NSString *url = [NSString stringWithFormat:@"%@%@&major=%ld&minor=%ld", DCWEBAPI_SET_USER_DETECT, strUUID, nearestBeacon.major.longValue, nearestBeacon.minor.longValue];

        [DCDefines getHttpAsyncResponse:url withHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        }];
    }
    
#pragma mark <last ibeacon discovering time>
    
#if 0
    NSString *notifyStep = [userDefaults valueForKey:WHITELEY_NOTIFY_STEP];
   
    NSString *showMonsterPage = [[NSUserDefaults standardUserDefaults] valueForKey:WHITELEY_SHOW_MONSTER_PAGE];
    
    if (showMonsterPage == nil || [showMonsterPage isEqual:@"0"])
    {
#pragma mark WELCOME NOTIFICATION
        //-------------------------------------------------------------------------------
        if ([notifyStep isEqual:@"start"]) {
            
            NSDate *lastTime;
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            lastTime = [userDefaults valueForKey:WHITELEY_LAST_VISIT_TIME];
            /*
            if (lastTime == nil) {
                [userDefaults setObject:curDate forKey:WHITELEY_LAST_VISIT_TIME];
                [userDefaults synchronize];
                [self registerDeviceTokenToServer:YES];
            }
            else {
                NSCalendar * calendar = [NSCalendar currentCalendar];
                NSDateComponents * components = [calendar components:NSCalendarUnitSecond fromDate:lastTime toDate:curDate options:0];
                NSInteger seconds = components.second;
                
                if (seconds > 24 * 3600/* 24 hours*/)
/*                {
                    [self registerDeviceTokenToServer:YES];
                    [userDefaults setObject:curDate forKey:WHITELEY_LAST_VISIT_TIME];
                    [userDefaults synchronize];
                }

            }
*/
            [userDefaults setObject:@"welcome" forKey:WHITELEY_NOTIFY_STEP];
            
            NSMutableDictionary *lastBeacon = [[NSMutableDictionary alloc] init];
            [lastBeacon setObject:nearestBeacon.major forKey:@"major"];
            [lastBeacon setObject:nearestBeacon.minor forKey:@"minor"];
            [lastBeacon setObject:curDate forKey:@"date"];
            [userDefaults setObject:lastBeacon forKey:WHITELEY_NOTIFY_LAST_BEACON];
            [userDefaults synchronize];
            
            [DCDefines getHttpAsyncResponse:DCWEBAPI_GET_NOTIFY_INFO withHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

                NSData *responseData = data;
                
                if (responseData != nil) {
                    NSError* errorInfo;
                    NSDictionary *dic  = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&errorInfo];
                    NSDictionary *dcNotification = [dic valueForKey:@"result"];
                    [userDefaults setObject:dcNotification forKey:WHITELEY_NOTIFICATION_INFO];
                    [userDefaults synchronize];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary *dic = [userDefaults valueForKey:WHITELEY_NOTIFICATION_INFO];
                    NSString *msg = [dic valueForKey:@"welcome"];
                    
                    if (msg == nil || msg.length == 0)
                        msg = @"Welcome to Whiteley, Please check out our offers.";

                    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive)
                    {
                        [DCDefines pushNotification:msg SectionType:OFFERLIST_NOTIFICATION Major:nearestBeacon.major.integerValue Minor:nearestBeacon.minor.integerValue Delay:0];
                    }
                    else
                    {
                        if ([alertNotfication isVisible])
                        {
                            [userDefaults setObject:@"start" forKey:WHITELEY_NOTIFY_STEP];
                            [userDefaults synchronize];
                            return;
                        }
                        alertNotfication.title = @"Welcome to Whiteley";
                        alertNotfication.message = msg;
                        alertNotfication.tag = OFFERLIST_NOTIFICATION;
                        [alertNotfication show];
                    }
                    
                });

                
            }];
            
            return;
        }

#pragma mark MONSTER NOTIFICATION
        //-------------------------------------------------------------------------------
        if ([notifyStep isEqual:@"welcome"]) {
            NSDictionary *dic = [userDefaults valueForKey:WHITELEY_NOTIFY_LAST_BEACON];

            NSDate *lastTime = dic[@"date"];
            if (lastTime == nil) {
                return;
            }
            
            // calculate seconds from last check time
            NSCalendar * calendar = [NSCalendar currentCalendar];
            NSDateComponents * components = [calendar components:NSCalendarUnitSecond fromDate:lastTime toDate:[NSDate date] options:0];
            NSInteger seconds = components.second;
            
            [userDefaults setObject:@"monster" forKey:WHITELEY_NOTIFY_STEP];
            NSDate *curDate = [NSDate date];
            
            NSMutableDictionary *lastBeacon = [[NSMutableDictionary alloc] init];
            [lastBeacon setObject:nearestBeacon.major forKey:@"major"];
            [lastBeacon setObject:nearestBeacon.minor forKey:@"minor"];

            NSInteger delayTime = 0;
            if (seconds < WHITELEY_NOTIFY_DELAY_TIME) {
                delayTime = WHITELEY_NOTIFY_DELAY_TIME - seconds;
                curDate = [curDate dateByAddingTimeInterval:delayTime];
            }
            
            [lastBeacon setObject:curDate forKey:@"date"];
            [userDefaults setObject:lastBeacon forKey:WHITELEY_NOTIFY_LAST_BEACON];
            [userDefaults synchronize];
            
            [self sendMonsterNotification:nearestBeacon Delay:delayTime];
            
            return;

        }
        
#pragma mark OFFER/EVENT NOTIFICATION
        //-------------------------------------------------------------------------------
        else if ([notifyStep isEqual:@"monster"]) {
            NSDictionary *dic = [userDefaults valueForKey:WHITELEY_NOTIFY_LAST_BEACON];
            
            NSDate *lastTime = dic[@"date"];
            if (lastTime == nil) {
                return;
            }
            // calculate seconds from last check time
            NSCalendar * calendar = [NSCalendar currentCalendar];
            NSDateComponents * components = [calendar components:NSCalendarUnitSecond fromDate:lastTime toDate:[NSDate date] options:0];
            NSInteger seconds = components.second;
            
            [userDefaults setObject:@"end" forKey:WHITELEY_NOTIFY_STEP];
            [userDefaults synchronize];
            
            NSInteger delayTime = 0;

            if ([lastTime compare:curDate] == NSOrderedDescending) {
                delayTime = WHITELEY_NOTIFY_DELAY_TIME + ABS(seconds);
            }
            else {
                if (seconds < WHITELEY_NOTIFY_DELAY_TIME) {
                    delayTime = WHITELEY_NOTIFY_DELAY_TIME - seconds;
                }
            }
            
            [self sendOffEventNotification:nearestBeacon Delay:delayTime];
            
            return;
        }
    }
#endif
    
    NSString *enableFindMonsterFlag = [userDefaults valueForKey:WHITELEY_ENABLE_FIND_MONSTER];
    
    if ([enableFindMonsterFlag isEqual:@"0"] || enableFindMonsterFlag == nil)
        return;
    
    aryMonster = [userDefaults valueForKey:WHITELEY_GOT_MONSTER];
    NSString *strMajor = [NSString stringWithFormat:@"%ld", (long)nearestBeacon.major.intValue];
    NSString *strMinor = [NSString stringWithFormat:@"%ld", (long)nearestBeacon.minor.intValue];
    url = [NSString stringWithFormat:@"%@&uuid=%@&major=%@&minor=%@", DCWEBAPI_GET_MONSTER_INFO, strUUID, strMajor, strMinor];
    
    [DCDefines getHttpAsyncResponse:url withHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSData *responseData = data;
        
        if (responseData == nil) {
            return;
        }
        
        NSError* errorInfo;
        NSDictionary *dic  = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&errorInfo];
        NSDictionary *dcMonster = [dic valueForKey:@"result"];
        NSString *strImage = [[dcMonster[@"image"] componentsSeparatedByString:@"/"] lastObject];

        if ([dcMonster isKindOfClass:[NSString class]])
            return;
        
        if ([dcMonster allKeys].count == 0)
            return;
        
        for (int i = 0; i < aryMonster.count; i++) {
            NSDictionary *dic = [aryMonster objectAtIndex:i];
            NSString *mID = dic[@"id"];
            NSString *mName = dic[@"name"];
            NSString *mImage = dic[@"image"];
            
            if ([mID isEqualToString:dcMonster[@"id"]] && [mName isEqualToString:dcMonster[@"name"]] ) {
                
                if ([strImage isEqualToString:mImage])
                    return;
            }
        }
        
        NSMutableDictionary *newMonster = [[NSMutableDictionary alloc] init];
        [newMonster setValue:dcMonster[@"name"] forKey:@"name"];
        [newMonster setValue:dcMonster[@"id"] forKey:@"id"];
        [newMonster setValue:dcMonster[@"notification"] forKey:@"notification"];
        [newMonster setValue:strImage forKey:@"image"];
        
        NSString *documentFolderPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString* file_name = [documentFolderPath stringByAppendingPathComponent:strImage];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:file_name]) {
            
            UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfFile:file_name]];
            [self showEggsHuntImage:(NSDictionary*)newMonster Image:img Beacon:nearestBeacon];
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSString *URL = [[dcMonster valueForKey:@"image"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            // new download
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:URL]];
            
            [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
             {
                 if (connectionError == nil)
                 {
                     UIImage *img = [UIImage imageWithData:data];
   
                     if ( img != nil )
                     {
                         NSString *documentFolderPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
                         NSString* file_name = [documentFolderPath stringByAppendingPathComponent:strImage];

                         if ([[NSFileManager defaultManager] fileExistsAtPath:file_name])
                             return;
                         
                         NSData *imgData = UIImagePNGRepresentation(img);
                         [imgData writeToFile:file_name atomically:YES];
                     }
                     
                     [self showEggsHuntImage:(NSDictionary*)newMonster Image:img Beacon:nearestBeacon];
                    
                     
                 }
             }];
            
        });

        
    }];

    return;
    
}

- (void) showEggsHuntImage:(NSDictionary*)newMonster Image:(UIImage*) img Beacon:(ESTBeacon *)nearestBeacon{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    aryMonster = [NSMutableArray arrayWithArray:[userDefaults valueForKey:WHITELEY_GOT_MONSTER]];
    
    if (aryMonster == nil)
        aryMonster = [[NSMutableArray alloc] init];
    
    [aryMonster addObject:newMonster];
    [userDefaults setValue:aryMonster forKey:WHITELEY_GOT_MONSTER];
    
    if ( aryMonster.count > 6 )
        [aryMonster removeObjectAtIndex:0];
    
    [userDefaults synchronize];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive)
            [DCDefines pushNotification:newMonster[@"notification"] SectionType:0 Major:nearestBeacon.major.integerValue Minor:nearestBeacon.minor.integerValue Delay:0];
        
        MonsterFoundViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"MonsterFoundViewController"];
        controller.imageMonster = img;
        NSString *name = newMonster[@"name"];
        name = [name uppercaseString];
        controller.monsterName = name;
        
        if (aryMonster.count == 6)
            controller.bFoundAll = YES;
        else
            controller.bFoundAll = NO;
        
        [self.navigationController pushViewController:controller animated:YES];
    });
}

- (void) sendMonsterNotification:(ESTBeacon *)nearestBeacon Delay:(NSInteger)delayTime{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
   
    NSDictionary *dic = [userDefaults valueForKey:WHITELEY_NOTIFICATION_INFO];
    NSString *msg = [dic valueForKey:@"hunt"];
    
    if (msg == nil || msg.length == 0)
        msg = @"We have some monsters hidden in Whiteley. Entertain your kids and find them!";
    
    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive)
    {
        [DCDefines pushNotification:msg SectionType:MONSTERFIRST_NOTIFICATION Major:nearestBeacon.major.integerValue Minor:nearestBeacon.minor.integerValue Delay:delayTime];
    }
    else
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

            sleep(delayTime);
             dispatch_async(dispatch_get_main_queue(), ^{

                    alertNotfication.title = @"Find Some Monsters";
                    alertNotfication.message = msg;
                    alertNotfication.tag = MONSTERFIRST_NOTIFICATION;
                    [alertNotfication show];
            });
        });
    }
    
    [userDefaults synchronize];
    
    return;
}

- (void)sendOffEventNotification:(ESTBeacon *)nearestBeacon Delay:(NSInteger)delayTime{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *aryStore = [userDefaults valueForKey:WHITELEY_STORE_LIST];
    NSMutableDictionary *dcFavoriteData = [userDefaults valueForKey:WHITELEY_FOVORITE_STORE];
    NSString *strStoreID = nil;
    NSMutableArray *aryStoreID = [[NSMutableArray alloc] init];
    BOOL isExistFavourite = NO;
    
    for (int i = 0; i < aryStore.count; i++) {
        NSDictionary *dic = [aryStore objectAtIndex:i];
        NSString *storeID = [dic valueForKey:@"id"];
        NSString *favID = [dcFavoriteData valueForKey:storeID];
        if ([favID isEqual:@"1"])
        {
            isExistFavourite = YES;
            
            if([dic[@"hasoffer"] isEqualToString:@"1"])
                [aryStoreID addObject:storeID];
        }
    }
    
    if (aryStoreID.count > 0) {
        NSInteger rand = random();
        rand = rand % aryStoreID.count;
        strStoreID = [aryStoreID objectAtIndex:rand];
        
        if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive)
            [self getOfferEventFromWebServer:strStoreID];
        else
            [self performSelectorInBackground:@selector(getOfferEventFromWebServer:) withObject:strStoreID];
    }
    else
    {
        
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSDictionary *dic = [userDefaults valueForKey:WHITELEY_NOTIFICATION_INFO];
            NSString *msg = [dic valueForKey:@"favorite"];
            
            if (msg == nil || msg.length == 0)
                msg = @"Favourite stores on our app and you'll receive offers tailored just for you";
            
            if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive)
            {
                [DCDefines pushNotification:msg SectionType:STORELIST_NOTIFICATION Major:nearestBeacon.major.integerValue Minor:nearestBeacon.minor.integerValue Delay:delayTime];
            }
            else
            {
//                if ([alertNotfication isVisible])
//                {
//                    [userDefaults setObject:@"monster" forKey:WHITELEY_NOTIFY_STEP];
//                    [userDefaults synchronize];
//                    return;
//                }
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    sleep(delayTime);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        alertNotfication.title = @"Top Tip";
                        alertNotfication.message = @"Favourite stores on our app and you'll receive offers tailored just for you.";
                        alertNotfication.tag = STORELIST_NOTIFICATION;
                        [alertNotfication show];
                    });
                });
            }
        
        //}
    }
}

- (void)beaconNotChanged {
    
}

#pragma mark <CBCentralManagerDelegate>
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if (central.state == CBCentralManagerStatePoweredOn)
        [userDefault setObject:@"1" forKey:WHITELEY_BLE_ENABLE];
    else {
        [userDefault setObject:@"0" forKey:WHITELEY_BLE_ENABLE];
        NSString *url = [NSString stringWithFormat:@"%@%@&uuid=%@&major=0&minor=0", DCWEBAPI_SET_USER_BEACON, deviceTokenID, WHITELEY_PROXIMITY_UUID];
        [DCDefines getHttpAsyncResponse:url withHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        }];
    }
    [userDefault synchronize];
}

#pragma mark AuthorizationStatus 

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        if (alertView.tag == 100) {
            //return;
            [[UIApplication sharedApplication] openURL: [NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
        else if (alertView.tag == FEEDBACK_ALERT ) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSString *fb_sent = [userDefaults valueForKey:WHITELEY_FEEDBACK_ASK];
            [userDefaults setValue:nil forKey:WHITELEY_FEEDBACK];

            if ([fb_sent isEqualToString:@"1"])
                [userDefaults setValue:nil forKey:WHITELEY_FEEDBACK_ASK];
            else
                [userDefaults setValue:@"1" forKey:WHITELEY_FEEDBACK_ASK];
            
            [userDefaults synchronize];
        }
        else if ( alertView.tag == UPGRADE_ALERT ){
            //NSString *link = [@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=" stringByAppendingString:APP_VERSION];
            NSString *link = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", APP_ID];
            [[UIApplication sharedApplication] openURL: [NSURL URLWithString:link]];
        }

        return;
    }
    else
    {
        NSInteger viewIndex = alertView.tag;

        if (viewIndex == 100)
            return;
        
        else if (viewIndex == LIKE_ALERT) {
            [DCDefines getHttpAsyncResponse:DCWEBAPI_REGISTER_SHARES withHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            }];
            
            MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
            if ([MFMessageComposeViewController canSendText]) {
                controller.body = [NSString stringWithFormat:@"http://itunes.apple.com/us/app/whiteley/id%@?mt=8", APP_ID];
                controller.messageComposeDelegate = self;
                [self.navigationController presentViewController:controller animated:YES completion:nil];
            }
        }
        else if (viewIndex == RATE_ALERT) {
            [DCDefines getHttpAsyncResponse:DCWEBAPI_REGISTER_REVIEWS withHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            }];
            
            NSString *url = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", APP_ID];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
        else if (viewIndex == FEEDBACK_ALERT ) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setValue:FEEDBACK_PAGE forKey:WHITELEY_FEEDBACK];
            [userDefaults setValue:nil forKey:WHITELEY_FEEDBACK_ASK];
            [userDefaults synchronize];
            
            FeedbackViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"FeedbackViewController"];
            vc.title = @"Feedback";
            
            [self.navigationController pushViewController:vc animated:YES];
        }
        else
            // Notification
            [self showViewController:[NSString stringWithFormat:@"%ld", (long)viewIndex]];
    }
}

 -(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];

      if (result == MessageComposeResultCancelled)
          NSLog(@"Message cancelled");
      else if (result == MessageComposeResultSent)
          NSLog(@"Message sent");
      else 
          NSLog(@"Message failed");
}

- (void)showViewController:(NSString*)identifier
{
    NSInteger m_nIdentifirer = [identifier integerValue];
    UIViewController *showVC = nil;
    switch (m_nIdentifirer) {
        case STORELIST_NOTIFICATION:
        {
            StoreListViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"StoreListViewController"];
            vc.listType = DCStoresListTypeStore;
            vc.title = @"Our Stores";
            showVC = vc;
            break;
        }
        case OFFERLIST_NOTIFICATION:
        {
            OfferListViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OfferListViewController"];
            vc.title = @"Latest Offers";
            showVC = vc;
            break;
        }
        case OFFERDETAIL_NOTIFICATION:
        {
            OfferDetailViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OfferDetailViewController"];
            vc.strOfferID = offeventID;
            vc.title = @"Latest Offers";
            showVC = vc;
            break;
        }
        case EVENTDETAIL_NOTIFICATION:
        {
            EventDetailViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"EventDetailViewController"];
            vc.strEventID = offeventID;
            vc.title = @"Latest Events";
            showVC = vc;
            break;
        }
        case MONSTERFIRST_NOTIFICATION:
        {
            MonsterFirstViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MonsterFirstViewController"];
            showVC = vc;
            break;
        }
        case FEEDBACK_NOTIFICATION:
        {
            NSString *msg = @"Help us improve your shopping\nexperience by answering 3 short\nquestions about your visit today.";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"How was your visit to Whiteley?" message:msg delegate:self cancelButtonTitle:@"Not right now" otherButtonTitles:@"OK, let's go!", nil];
            alert.tag = FEEDBACK_ALERT;
            [alert show];
            break;
        }
        default:
            return;
            break;
    }
    
    [self.navigationController pushViewController:showVC animated:YES];
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = [locations lastObject];
    NSLog(@"%f", userGPSLocation.coordinate.longitude);
    NSLog(@"%f", userGPSLocation.coordinate.latitude);
    
    NSDate *curDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:curDate];
    NSInteger hour = [components hour];
    
    //if (( hour >= 0 && hour < 8) || ( hour > 20 && hour < 24)) {
    //    return;
    //}
    
    CLLocationDistance distance = [userGPSLocation distanceFromLocation:newLocation];
    
    if (distance >= 0) {
        userGPSLocation = newLocation;
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
#if 1
        NSString *url = [NSString stringWithFormat:@"%@%@&longitude=%f&latitude=%f", DCWEBAPI_SET_USER_GPS, deviceTokenID , userGPSLocation.coordinate.longitude, userGPSLocation.coordinate.latitude];
#else
        NSString *url = [NSString stringWithFormat:@"%@%@&longitude=-1.246171&latitude=50.885332", DCWEBAPI_SET_USER_GPS, deviceTokenID];
#endif

        if ( userGPSLocation.coordinate.longitude != 0 && userGPSLocation.coordinate.latitude != 0) {

            NSDate *lastGPSTime = [userDefaults valueForKey:WHITELEY_GPS_LAST_TIME];
            NSTimeInterval pGPSTime = [curDate timeIntervalSinceDate:lastGPSTime];

            if ( lastGPSTime == nil || pGPSTime > WHITELEY_GPS_NOFITY_TIME - 10) {
                [userDefaults setValue:curDate forKey:WHITELEY_GPS_LAST_TIME];
                [userDefaults synchronize];
                [DCDefines getHttpAsyncResponse:url withHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                }];
            }
        }
        
        NSString *isVisited =  [userDefaults valueForKey:WHITELEY_VISIT_STATUS];
#if 1
        Coordinate *userCoordinate = [Coordinate coordinateWithX:userGPSLocation.coordinate.latitude Y:userGPSLocation.coordinate.longitude];
#else
        Coordinate *userCoordinate = [Coordinate coordinateWithX:50.886 Y:-1.246];
#endif
        
#if 1
        if ( userCoordinate.x >= MAP_RIGHT_BOTTOM_LAT &&
            userCoordinate.x <= MAP_LEFT_TOP_LAT &&
            userCoordinate.y >= MAP_LEFT_TOP_LONG &&
            userCoordinate.y <= MAP_RIGHT_BOTTOM_LONG )
#else
        if ( userCoordinate.y >= 124.3018 && userCoordinate.y <= 124.30185 && userCoordinate.x >= 40.14 && userCoordinate.x <= 40.15 )
#endif
        {
            if (isVisited == nil){
                [userDefaults setValue:@"1" forKey:WHITELEY_VISIT_STATUS];
                [userDefaults setObject:curDate forKey:WHITELEY_VISIT_START_TIME];
                [userDefaults setObject:nil forKey:WHITELEY_SHOPPING_LAST_TIME];
                [userDefaults synchronize];
            }
        }
        else {
            
            if ([isVisited isEqualToString:@"1"]) {

                [userDefaults setValue:nil forKey:WHITELEY_VISIT_STATUS];
                [userDefaults setObject:curDate forKey:WHITELEY_SHOPPING_LAST_TIME];
                [userDefaults synchronize];
                
                NSDate *startDate = [userDefaults valueForKey:WHITELEY_VISIT_START_TIME];
                
                if (startDate != nil) {
                    NSTimeInterval dwell = [curDate timeIntervalSinceDate:startDate];
                    NSInteger dwellHour = dwell / 3600;
                    NSInteger dwellMin = dwell / 60 - dwellHour * 60;
                    
                    NSString *strDwell;
                    
                    if (dwellHour == 0 ) {
                        if (dwellMin == 0)
                            return;
                        else
                            strDwell = [NSString stringWithFormat:@"%ldm", (long)dwellMin];
                    }
                    else
                        strDwell = [NSString stringWithFormat:@"%ldh %ldm", (long)dwellHour, (long)dwellMin];
                    
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"dd-MM-yyyy HH:mm"];
                    NSString *strStartDate = [dateFormatter stringFromDate:startDate];
                    
                    NSString *urlSendVisit = [NSString stringWithFormat:@"%@%@&start=%@&dwell=%@", DCWEBAPI_SEND_USER_VISIT, deviceTokenID , strStartDate, strDwell];
                    
                    [DCDefines getHttpAsyncResponse:urlSendVisit withHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                        
                    }];

                }

            }
        }
    }
    
}

@end
