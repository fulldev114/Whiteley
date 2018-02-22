//
//  AppDelegate.m
//  Whiteley
//
//  Created by Alex Hong on 5/23/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import "AppDelegate.h"
#import "DCDefines.h"
#import "HomeViewController.h"
#import "DCNavigationViewController.h"
#import "MapViewController.h"
#import "StoreListViewController.h"
#import "OfferListViewController.h"
#import "HereViewController.h"
#import "EventListViewController.h"
#import "OpeningHoursViewController.h"
#import "MonsterFirstViewController.h"
#import "StoreDetailViewController.h"
#import "EventDetailViewController.h"
#import "OfferDetailViewController.h"

NSString *deviceTokenID;

@interface AppDelegate () <UIAlertViewDelegate>
{
    NSString *aps_type;
    NSString *aps_value;
    NSString *aps_vid;

}
@property (assign) UIBackgroundTaskIdentifier masterTaskId;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
    
    [application setStatusBarHidden:NO];
    [application setStatusBarStyle:UIStatusBarStyleLightContent];

    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *deviceID = [userDefaults valueForKey:WHITELEY_DEVICE_ID];
    deviceTokenID = @"";
    
    if (deviceID == nil) {
        NSString *device = [deviceToken description];
        device = [device stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
        device = [device stringByReplacingOccurrencesOfString:@" " withString:@""];
        deviceTokenID = device;
        [userDefaults setObject:deviceID forKey:WHITELEY_DEVICE_ID];
        [userDefaults synchronize];
    }
    else
        deviceTokenID = deviceID;
    
    NSLog(@"Device Token 1 = %@\n", deviceTokenID);
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    NSDictionary *dic = [userDefaults valueForKey:WHITELEY_NOTIFY_USER_DETECT];
    [userDefaults synchronize];
    NSString *uuid = dic[@"uuid"];
    NSInteger major = [dic[@"major"] integerValue];
    NSInteger minor = [dic[@"minor"] integerValue];
    
    NSString *url = [NSString stringWithFormat:@"%@%@&major=%ld&minor=%ld", DCWEBAPI_SET_INTER_NOTIFY, uuid, (long)major, (long)minor];
    
    [DCDefines getHttpAsyncResponse:url withHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    }];
    
    NSString *sectionType = notification.alertAction;
    
    if ([sectionType isEqual:@"0"])
        return;
    
    HomeViewController *homeVC = nil;
    UIViewController *vc = nil;
    DCNavigationViewController *navVC = nil;

    vc = self.window.rootViewController.presentedViewController;
    
    if ([vc isKindOfClass:[DCNavigationViewController class]]) {
        navVC = (DCNavigationViewController*)vc;
        homeVC = (HomeViewController*)[navVC.viewControllers objectAtIndex:0];
    }
    else if ([vc.presentedViewController isKindOfClass:[DCNavigationViewController class]])
    {
        navVC = (DCNavigationViewController*)vc.presentedViewController;
        homeVC = (HomeViewController*)[navVC.viewControllers objectAtIndex:0];
    }
    
    if (homeVC != nil)
        [homeVC showViewController:sectionType];
    
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"Remote Notification: %@", [userInfo description]);
    NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Whiteley Message" message:apsInfo[@"alert"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alert.tag = 100;
    [alert show];
    
    NSString *url = [NSString stringWithFormat:@"%@%@", DCWEBAPI_NOTIFICATION_VIEWED, apsInfo[@"nid"]];
    [DCDefines getHttpAsyncResponse:url withHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    }];
    
    aps_type = [apsInfo objectForKey:@"type"];
    aps_value = [apsInfo objectForKey:@"value"];
    aps_vid = [apsInfo objectForKey:@"vid"];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    UIBackgroundTaskIdentifier bgTaskId = UIBackgroundTaskInvalid;
    if([application respondsToSelector:@selector(beginBackgroundTaskWithExpirationHandler:)]){
        bgTaskId = [application beginBackgroundTaskWithExpirationHandler:^{
            //            NSLog(@"background task %lu expired", (unsigned long)bgTaskId);
        }];
        if ( self.masterTaskId == UIBackgroundTaskInvalid )
        {
            self.masterTaskId = bgTaskId;
        }
        else
        {
            //add this id to our list
            [self endBackgroundTasks];
        }
    }
    
    HomeViewController *homeVC = nil;
    UIViewController *vc = nil;
    DCNavigationViewController *navVC = nil;
    
    vc = self.window.rootViewController.presentedViewController;
    
    if ([vc isKindOfClass:[DCNavigationViewController class]]) {
        navVC = (DCNavigationViewController*)vc;
        homeVC = (HomeViewController*)[navVC.viewControllers objectAtIndex:0];
        //[homeVC restartShoppingThread];
    }

}

- (void)endBackgroundTasks {
    UIApplication* application = [UIApplication sharedApplication];
    if([application respondsToSelector:@selector(endBackgroundTask:)]){
        [application endBackgroundTask:self.masterTaskId];
        self.masterTaskId = UIBackgroundTaskInvalid;
    }

}
- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self endBackgroundTasks];
    
    HomeViewController *homeVC = nil;
    UIViewController *vc = nil;
    DCNavigationViewController *navVC = nil;
    
    vc = self.window.rootViewController.presentedViewController;
    
    if ([vc isKindOfClass:[DCNavigationViewController class]]) {
        navVC = (DCNavigationViewController*)vc;
        homeVC = (HomeViewController*)[navVC.viewControllers objectAtIndex:0];
        //[homeVC restartShoppingThread];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    HomeViewController *homeVC = nil;
    UIViewController *vc = nil;
    DCNavigationViewController *navVC = nil;
    
    vc = self.window.rootViewController.presentedViewController;
    
    if ([vc isKindOfClass:[DCNavigationViewController class]]) {
        navVC = (DCNavigationViewController*)vc;
        homeVC = (HomeViewController*)[navVC.viewControllers objectAtIndex:0];
    }
    else if ([vc.presentedViewController isKindOfClass:[DCNavigationViewController class]])
    {
        navVC = (DCNavigationViewController*)vc.presentedViewController;
        homeVC = (HomeViewController*)[navVC.viewControllers objectAtIndex:0];
    }
    
    if (homeVC != nil)
    {
        [homeVC performSelector:@selector(setupAppLocalSettings) withObject:nil afterDelay:1.0f];
    }    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        if (alertView.tag == 100) {
            
            
            if ([aps_type isEqualToString:@"section"]) {
                UIViewController *rootVC = (DCNavigationViewController*)self.window.rootViewController.presentedViewController;
                DCNavigationViewController *navVC = nil;
                UIViewController *vc = nil;
                
                if ([rootVC isKindOfClass:[DCNavigationViewController class]])
                    navVC = (DCNavigationViewController*)rootVC;
                else if ([rootVC.presentedViewController isKindOfClass:[DCNavigationViewController class]])
                    navVC = (DCNavigationViewController*)rootVC.presentedViewController;
                
                DCNavigationViewController *curVC = [navVC.viewControllers lastObject];
                
               // UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                
                if ([aps_value isEqualToString:@"map"]) {
                    if ( [curVC isKindOfClass:[MapViewController class]] ) {
                        return;
                    }
                    vc = [curVC.storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
                    MapViewController *controller = (MapViewController*)vc;
                    controller.m_bSectionFacilites = NO;
                    controller.m_nCentureFloor = LOWER_MALL;
                    controller.m_sSelectedShopID = @"";
                    controller.title = @"Centre Map";

                }
                else if ([aps_value isEqualToString:@"stores"]) {
                    if (aps_vid.length == 0) {
                        if ( [curVC isKindOfClass:[StoreListViewController class]] ) {
                            StoreListViewController *storeVC = (StoreListViewController*)vc;
                            if ( storeVC.listType == DCStoresListTypeStore)
                                return;
                        }
                        vc = [curVC.storyboard instantiateViewControllerWithIdentifier:@"StoreListViewController"];
                        StoreListViewController* storeVC = (StoreListViewController*)vc;
                        storeVC.listType = DCStoresListTypeStore;
                        vc.title = @"Our Stores";
                    }
                    else {
                        vc = [curVC.storyboard instantiateViewControllerWithIdentifier:@"StoreDetailViewController"];
                        StoreDetailViewController *storeVC = (StoreDetailViewController*)vc;
                        storeVC.strStoreID = aps_vid;
                        vc.title = @"Our Stores";
                    }
                }
                else if ([aps_value isEqualToString:@"offers"]) {
                    if (aps_vid.length == 0) {
                        if ( [curVC isKindOfClass:[OfferListViewController class]] )
                            return;
                    
                        vc = [curVC.storyboard instantiateViewControllerWithIdentifier:@"OfferListViewController"];
                        vc.title = @"Latest Offers";
                    }
                    else {
                        vc = [curVC.storyboard instantiateViewControllerWithIdentifier:@"OfferDetailViewController"];
                        OfferDetailViewController* offerVC = (OfferDetailViewController*)vc;
                        offerVC.strOfferID = aps_vid;
                        vc.title = @"Latest Offers";
                    }
                }
                else if ([aps_value isEqualToString:@"food"]) {
                    if ( [curVC isKindOfClass:[OfferListViewController class]] ) {
                        StoreListViewController *storeVC = (StoreListViewController*)vc;
                        if ( storeVC.listType == DCFoodOutletsTypeCategory)
                            return;
                    }
                    
                    vc = [curVC.storyboard instantiateViewControllerWithIdentifier:@"StoreListViewController"];
                    StoreListViewController *storeVC = (StoreListViewController*)vc;
                    storeVC.listType = DCFoodOutletsTypeCategory;
                    storeVC.title = @"Food Outlets";

                }
                else if ([aps_value isEqualToString:@"here"]) {
                    if ( [curVC isKindOfClass:[HereViewController class]] )
                        return;
                    
                    vc = [curVC.storyboard instantiateViewControllerWithIdentifier:@"HereViewController"];
                    vc.title = @"Getting Here";

                }
                else if ([aps_value isEqualToString:@"facilities"]) {
                    if ( [curVC isKindOfClass:[MapViewController class]] )
                        return;
                    
                    vc = [curVC.storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
                    MapViewController *controller = (MapViewController*)vc;
                    controller.m_bSectionFacilites = YES;
                    controller.m_nCentureFloor = LOWER_MALL;
                    controller.m_sSelectedShopID = @"";
                    controller.title = @"Our Facilities";

                }
                else if ([aps_value isEqualToString:@"events"]) {
                    if (aps_vid.length == 0) {
                        if ( [curVC isKindOfClass:[EventListViewController class]] )
                            return;
                        
                        vc = [curVC.storyboard instantiateViewControllerWithIdentifier:@"EventListViewController"];
                        vc.title = @"Latest Events";

                    }
                    else {
                        vc = [curVC.storyboard instantiateViewControllerWithIdentifier:@"EventDetailViewController"];
                        EventDetailViewController* eventVC = (EventDetailViewController*)vc;
                        eventVC.strEventID = aps_vid;
                        vc.title = @"Latest Events";
                    }
                }
                else if ([aps_value isEqualToString:@"open_hrs"]) {
                    if ( [curVC isKindOfClass:[OpeningHoursViewController class]] )
                        return;
                    
                    vc = [curVC.storyboard instantiateViewControllerWithIdentifier:@"OpeningHoursViewController"];
                    vc.title = @"Opening Hours";
                }
                else if ([aps_value isEqualToString:@"monster"]) {
                    if ( [curVC isKindOfClass:[MonsterFirstViewController class]] )
                        return;
                    
                    vc = [curVC.storyboard instantiateViewControllerWithIdentifier:@"MonsterFirstViewController"];
                    vc.title = @"Easter Egg Hunt";
                }
                [curVC.navigationController pushViewController:vc animated:YES];
                
            }
            else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:aps_value]];
            }
        }
    }
}

@end

