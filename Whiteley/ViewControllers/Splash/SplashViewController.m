//
//  SplashViewController.m
//  Whiteley
//
//  Created by Alex Hong on 4/14/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import "SplashViewController.h"
#import "DCNavigationViewController.h"

@implementation SplashViewController
{
    NSTimer *timerHomeController;
}
@synthesize animateImgView, imgDrake, imgPlay, imgTM;

- (void) viewDidLoad
{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    if ([DCDefines isiPHone4]) {
        imgDrake.center = CGPointMake(imgDrake.center.x, imgDrake.center.y - 50);
        imgPlay.center = CGPointMake(imgPlay.center.x, imgPlay.center.y - 50);
        imgTM.center = CGPointMake(imgTM.center.x, imgTM.center.y - 50);
    }
    
    imgDrake.center = CGPointMake(imgDrake.center.x, imgDrake.center.y - 10);
    imgDrake.alpha = 0;
    [UIView animateWithDuration:0.7 animations:^{
        imgDrake.alpha = 1;
        imgDrake.center = CGPointMake(imgDrake.center.x, imgDrake.center.y + 10);
    }];

    /*
    imgPlay.center = CGPointMake(imgPlay.center.x + 5, imgPlay.center.y);
    imgPlay.alpha = 0;
    [UIView animateWithDuration:0.7 animations:^{
        imgPlay.alpha = 1;
        imgPlay.center = CGPointMake(imgPlay.center.x - 5, imgPlay.center.y );
    }];
    
    //imgPlay.center = CGPointMake(imgPlay.center.x, imgPlay.center.y + 10);
    imgTM.alpha = 0;
    [UIView animateWithDuration:0.7 delay:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        imgTM.alpha = 1;
    } completion:nil];
    */
    [NSTimer scheduledTimerWithTimeInterval:0.7f target:self selector:@selector(onStartSplashScreen) userInfo:nil repeats:NO];
    
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void) onStartSplashScreen
{
    NSString *filePath = [[NSBundle mainBundle]
                          pathForResource:@"wl_loading" ofType:@"gif"];
    NSData *myGif = [NSData dataWithContentsOfFile:filePath];
    
    // Make a WebView in order to store a GIF
    NSInteger height = SCREEN_HEIGHT == 568 ? 340: 280;
    animateImgView = [[SCGIFImageView alloc] initWithFrame:CGRectMake(138, height, 45, 45)];
    [animateImgView setData:myGif];
    [self.view addSubview:animateImgView];
    
    animateImgView.frame = CGRectMake(150, 372, 10, 10);
    animateImgView.alpha = 0;
    [UIView animateWithDuration:0.7 animations:^{
        animateImgView.frame = CGRectMake(138, 360, 45, 45);
        animateImgView.alpha = 1;
    }];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *coachFlag = [defaults stringForKey:@"coach_read"];
    
    if (!coachFlag.length)
        [NSTimer scheduledTimerWithTimeInterval:2.1f target:self selector:@selector(onStartCoachScreen) userInfo:nil repeats:NO];
    else
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *aryStore = [userDefaults valueForKey:WHITELEY_STORE_LIST];
        NSMutableArray *aryCategory = [userDefaults valueForKey:WHITELEY_CATEGORY_LIST];
        
        
        if (aryStore.count == 0 || aryCategory.count == 0) {
            [self getStoreFromWebServer];
            timerHomeController = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(onStartHomeScreen) userInfo:nil repeats:NO];
        }
        else
            [NSTimer scheduledTimerWithTimeInterval:2.1f target:self selector:@selector(onStartHomeScreen) userInfo:nil repeats:NO];

    }

}

-(void) onStartCoachScreen
{
    UIViewController *coachController = [self.storyboard instantiateViewControllerWithIdentifier:@"CoachViewController"];

    [self presentViewController:coachController animated:NO completion:nil];
}

-(void) onStartHomeScreen
{
    UIViewController *homeController = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
    
    DCNavigationViewController *dc = [[DCNavigationViewController alloc] initWithRootViewController:homeController];
    dc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:dc animated:YES completion:nil];
}

-(void) getStoreFromWebServer
{
    NSMutableArray *dcStores = [[NSMutableArray alloc] init];
    NSMutableArray *dcCategories = [[NSMutableArray alloc] init];

    NSMutableDictionary *dcFavoriteData = [[[NSUserDefaults standardUserDefaults] valueForKey:WHITELEY_FOVORITE_STORE] mutableCopy];
    
    if (dcFavoriteData == nil)
        dcFavoriteData = [[NSMutableDictionary alloc] init];
    
    [DCDefines getHttpAsyncResponse:DCWEBAPI_GET_STORE_NAME withHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        NSData *responseData = data;
        
        if (responseData == nil) {
            [self onStartHomeScreen];
            return;
        }
        
        NSError* errorInfo;
        NSDictionary *dic  = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&errorInfo];
        NSMutableArray *aryStoreName = [dic valueForKey:@"result"];
        for (int i = 0; i < aryStoreName.count; i++) {
            NSMutableDictionary *dicStore = [aryStoreName objectAtIndex:i];
            NSString *favoriteFlag = [dcFavoriteData valueForKey:dicStore[@"id"]];
            if (favoriteFlag == nil || favoriteFlag.length == 0)
            {
                [dcFavoriteData setValue:@"0" forKey:dicStore[@"id"]];
                favoriteFlag = @"0";
            }
            NSMutableDictionary *store = [[NSMutableDictionary alloc] init];
            [store setValue:[dicStore valueForKey:@"id"] forKey:@"id"];
            [store setValue:[dicStore valueForKey:@"name"] forKey:@"name"];
            [store setValue:[dicStore valueForKey:@"label"] forKey:@"label"];
            [store setValue:[dicStore valueForKey:@"location"] forKey:@"location"];
            [store setValue:[dicStore valueForKey:@"unit_num"] forKey:@"unit_num"];
            [store setValue:[dicStore valueForKey:@"has_offer"] forKey:@"hasoffer"];
            [store setValue:[dicStore valueForKey:@"cat_id"] forKey:@"cat_id"];
            [store setValue:favoriteFlag forKey:@"favorite"];
            
            [dcStores addObject:store];
        }
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:dcStores forKey:WHITELEY_STORE_LIST];
        [userDefaults setObject:dcFavoriteData forKey:WHITELEY_FOVORITE_STORE];
        [userDefaults synchronize];
        
        [DCDefines getHttpAsyncResponse:DCWEBAPI_GET_STORE_CATEGORY withHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

            NSData *responseData = data;
            
            if (responseData == nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self onStartHomeScreen];
                    timerHomeController = nil;
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
                [dcCategories addObject:category];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:dcCategories forKey:WHITELEY_CATEGORY_LIST];
                [userDefaults synchronize];
                
                [self onStartHomeScreen];
                timerHomeController = nil;
            });
        }];
        
    }];
    
}
@end
