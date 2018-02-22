//
//  DCDefines.h
//  Whiteley
//
//  Created by Alex Hong on 3/20/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#ifndef DrakeCircus_DCDefines_h
#define DrakeCircus_DCDefines_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "MLog.h"
#import "CommonUtils.h"

extern NSString *deviceTokenID;
extern BOOL bUpdateUserLocation;

#define SYSTEM_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

#define APP_ID                  @"1081755653"
#define APP_VERSION             [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#define APP_OPEN_NUM            @"app_open_num"

// Screen Size
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

// Map Location
#define MAP_RIGHT_BOTTOM_LAT 50.88418
#define MAP_RIGHT_BOTTOM_LONG -1.243586
#define MAP_LEFT_TOP_LAT 50.886777
#define MAP_LEFT_TOP_LONG -1.249650

// Map Size
#define MAP_WIDTH 320
#define MAP_HEIGHT 568

// Map Scale
#define MAX_SCALE 6.0f
#define MIN_SCALE 1.5f

// Color
#define UIColorWithRGBA(r, g, b, a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]
#define APP_MAIN_COLOR [UIColor colorWithRed:(5)/255.0f green:(181)/255.0f blue:(218)/255.0f alpha:(1)]

// Font
#define HFONT_REGULAR           @"HelveticaNeue"
#define HFONT_ULTRA_LIGHT       @"HelveticaNeue-UltraLight"
#define HFONT_LIGHT             @"HelveticaNeue-Light"
#define HFONT_THIN              @"HelveticaNeue-Thin"
#define HFONT_MEDIUM            @"HelveticaNeue-Medium"

#define NFONT_DEMI_BOLD         @"Novecentowide-DemiBold"
#define NFONT_BOLD              @"NovecentoWide-Bold"
#define NFONT_LIGHT             @"NovecentoWide-Light"

#define NUMBER_OF_HOME_MENU 10

#define DC_SESSION_TIME_OUT 30.0f

#define WHITELEY_FIRST_OPEN             @"first_open"
#define WHITELEY_MENU_SELECT            @"menu_select"
#define WHITELEY_DEVICE_ID              @"device_id"

// Feedback Macro
#define WHITELEY_FEEDBACK               @"feedback"
#define WHITELEY_FEEDBACK_ASK           @"feedback_ask"
#define FEEDBACK_NOTIFY                 @"feedback_notify"
#define FEEDBACK_PAGE                   @"feedback_page"

// Web Server API
//#define WEB_SERVER_ENABLE
//#define DCWEBAPI_BASE                   @"http://10.70.5.4/json_api?request_type="
#define DCWEBAPI_BASE                   @"http://glow.waistaging.com/whiteley/json_api?request_type="
//#define DCWEBAPI_BASE                   @"http://glow.weareignition.com/whiteley/json_api?request_type="

#define DCWEBAPI_GET_STORE_NAME         [DCWEBAPI_BASE stringByAppendingString:@"store_name"]
#define DCWEBAPI_GET_STORE_CATEGORY     [DCWEBAPI_BASE stringByAppendingString:@"store_category"]
#define DCWEBAPI_GET_STORE_CATEDETAIL   [DCWEBAPI_BASE stringByAppendingString:@"store_name&category_id="]
#define DCWEBAPI_GET_STORE_DETAIL       [DCWEBAPI_BASE stringByAppendingString:@"store_detail&store_id="]
#define DCWEBAPI_GET_OFFERS_NAME        [DCWEBAPI_BASE stringByAppendingString:@"offers_name"]
#define DCWEBAPI_GET_OFFERS_DETAIL      [DCWEBAPI_BASE stringByAppendingString:@"offers_detail&device_token="]
#define DCWEBAPI_GET_EVENTS_NAME        [DCWEBAPI_BASE stringByAppendingString:@"events_name"]
#define DCWEBAPI_GET_EVENTS_DETAIL      [DCWEBAPI_BASE stringByAppendingString:@"events_detail&event_id="]
#define DCWEBAPI_GET_FOOD_OUTLETS       [DCWEBAPI_BASE stringByAppendingString:@"food_outlets"]
#define DCWEBAPI_GET_MONSTER_INFO       [DCWEBAPI_BASE stringByAppendingString:@"monster_info"]
#define DCWEBAPI_GET_OFFEVENT_ID        [DCWEBAPI_BASE stringByAppendingString:@"get_offevent&store_id="]
#define DCWEBAPI_GET_HOME_CAROUSEL      [DCWEBAPI_BASE stringByAppendingString:@"home_carousel"]
#define DCWEBAPI_GET_NOTIFY_INFO        [DCWEBAPI_BASE stringByAppendingString:@"get_notification"]
#define DCWEBAPI_SET_USER_DETECT        [DCWEBAPI_BASE stringByAppendingString:@"user_detect&uuid="]
#define DCWEBAPI_SET_SENT_NOTIFY        [DCWEBAPI_BASE stringByAppendingString:@"notification_sent&uuid="]
#define DCWEBAPI_SET_INTER_NOTIFY       [DCWEBAPI_BASE stringByAppendingString:@"notification_receive&uuid="]
// When you visit the shop at first
#define DCWEBAPI_SET_REGISTER_INFO      [DCWEBAPI_BASE stringByAppendingString:@"register_info&device_token="]
#define DCWEBAPI_SET_USER_GPS           [DCWEBAPI_BASE stringByAppendingString:@"set_user_gps&device_token="]
#define DCWEBAPI_SET_USER_BEACON        [DCWEBAPI_BASE stringByAppendingString:@"set_user_beacon&device_token="]
#define DCWEBAPI_NOTIFICATION_VIEWED    [DCWEBAPI_BASE stringByAppendingString:@"notification_viewed&notification_id="]
#define DCWEBAPI_REGISTER_SECTION       [DCWEBAPI_BASE stringByAppendingString:@"register_section&kind="]
#define DCWEBAPI_REGISTER_SHARES        [DCWEBAPI_BASE stringByAppendingString:@"register_shares"]
#define DCWEBAPI_REGISTER_REVIEWS       [DCWEBAPI_BASE stringByAppendingString:@"register_reviews"]
#define DCWEBAPI_SEND_FEEDBACK          [DCWEBAPI_BASE stringByAppendingString:@"send_feedback&device_token="]
#define DCWEBAPI_SEND_USER_VISIT        [DCWEBAPI_BASE stringByAppendingString:@"send_user_visit&device_token="]
#define DCWEBAPI_CHECK_NOTIFICATION     [DCWEBAPI_BASE stringByAppendingString:@"check_notification"]
#define DCWEBAPI_SET_REDEEM             [DCWEBAPI_BASE stringByAppendingString:@"redeem&device_token="]

// Store
#define WHITELEY_STORE_LIST              @"store_list"
#define NEW_RETAILER_SHOP                @"New Retailer Coming Soon"
#define WHITELEY_FOVORITE_STORE          @"favorite_store"
#define WHITELEY_CATEGORY_LIST           @"category_list"
#define WHITELEY_CAROUSEL_LIST           @"carousel_list"
#define WHITELEY_GPS_LATITUDE            -1.246438
#define WHITELEY_GPS_LONGITUDE           50.886117

// Store Visit
#define WHITELEY_VISIT_START_TIME        @"visit_start_time"
#define WHITELEY_VISIT_STATUS            @"visit_status"

// Notificatoin
#define WHITELEY_NOTIFICATION_INFO       @"notifiation_info"
#define WHITELEY_LAST_VISIT_TIME         @"last_visit_time"
#define WHITELEY_SHOPPING_LAST_TIME      @"last_shopping_time"
#define WHITELEY_NOTIFY_USER_DETECT      @"user_detect"
#define WHITELEY_NOTIFY_DETECTED_BEACON  @"detected_beacon"

#define WHITELEY_NOTIFY_SENT             @"notify_sent"
#define WHITELEY_NOTIFY_INTERACTION      @"notify_interaction"
#define WHITELEY_NOTIFY_STEP             @"notify_step"
#define WHITELEY_NOTIFY_LAST_BEACON      @"notify_last_beacon"
#define WHITELEY_NO_SHOPPING_TIME        2 * 3600//30 hours
#define WHITELEY_CHECK_SHOPPING_TIME     600//600 seconds
#define WHITELEY_NOTIFY_DELAY_TIME       600//600 seconds
#define WHITELEY_GPS_NOFITY_TIME         600//600 seconds
#define WHITELEY_GPS_LAST_TIME           @"gps_last"

// Beacon
#define WHITELEY_BLE_ENABLE              @"ble_enable"
#define WHITELEY_LOCATION_ENABLE         @"loc_enable"
#define WHITELEY_NOTIFICATION_ENABLE     @"not_enable"

#define WHITELEY_PROXIMITY_UUID [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"]
#define WHITELEY_REGION_IDENTIFIER       @"Whiteley"
#define CPBEACON_RANGING_INTERVAL        2 // seconds
#define WHITELEY_GOT_MONSTER             @"got_monster"
#define WHITELEY_ENABLE_FIND_MONSTER     @"enable_find_monster"
#define WHITELEY_SHOW_MONSTER_PAGE       @"show_monster_page"

typedef NS_ENUM(NSInteger, NOTIFICATION) {
    STORELIST_NOTIFICATION = 1,
    STOREDETAIL_NOTIFICATION,
    OFFERLIST_NOTIFICATION,
    OFFERDETAIL_NOTIFICATION,
    EVENTDETAIL_NOTIFICATION,
    GIFTCARD_NOTIFICATION,
    MONSTERFIRST_NOTIFICATION,
    FEEDBACK_NOTIFICATION
};

@interface DCDefines : NSObject

+ (NSString *)deviceUUID;
+ (void) getHttpAsyncResponse:(NSString*) request_url withHandler:(void(^)(NSData *data, NSURLResponse *response, NSError *error))ourBlock;
+ (void) downloadImageFromServer:(NSString*) request_url :(void(^)(NSData *data, NSError *connectionError))handler;
+ (NSData *)removeUnescapedCharacter:(NSData *)inputData;
+ (BOOL) validateEmail: (NSString *) candidate;
+ (BOOL) validateNumeric: (NSString *) candidate;
+ (void) pushNotification:(NSString *)msg SectionType:(NSInteger)sectionType Major:(NSInteger)major Minor:(NSInteger)minor Delay:(NSInteger) delayTime;
+ (BOOL) isNotifiyEnableBluetooth;
+ (BOOL) isNotifyEnableLocation;
+ (BOOL) isNotifyEnableNotification;
+ (BOOL) isiPHone4;
@end

#endif
