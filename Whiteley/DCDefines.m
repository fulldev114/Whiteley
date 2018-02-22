//
//  DCDefines.m
//  Whiteley
//
//  Created by Alex Hong on 4/20/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import "DCDefines.h"
#import <AdSupport/ASIdentifierManager.h>

@implementation DCDefines

+(void) getHttpAsyncResponse:(NSString*) request_url withHandler:(void(^)(NSData *data, NSURLResponse *response, NSError *error))ourBlock
{
    NSString *header = [request_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    header = [header stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:header]];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:ourBlock] resume];
    
    [[NSURLSession sharedSession] finishTasksAndInvalidate];
    
}

+(void) downloadImageFromServer:(NSString*) request_url :(void(^)(NSData *data, NSError *connectionError))handler
{
    NSString *header = request_url;
    
    header = [header stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSString *escapedHeader = [header stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:escapedHeader]];
    // Make synchronous request
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError == nil) {
            handler(data, connectionError);
        }
    }];
}

+(NSData *)removeUnescapedCharacter:(NSData *)inputData
{
    NSString *inputStr = [[NSString alloc] initWithData:inputData encoding:NSUTF8StringEncoding];
    NSCharacterSet *controlChars = [NSCharacterSet controlCharacterSet];
    
    NSRange range = [inputStr rangeOfCharacterFromSet:controlChars];
    
    if (range.location != NSNotFound)
    {
        
        NSMutableString *mutable = [NSMutableString stringWithString:inputStr];
        
        while (range.location != NSNotFound)
        {
            
            [mutable deleteCharactersInRange:range];
            
            range = [mutable rangeOfCharacterFromSet:controlChars];
            
        }
        
        return [mutable dataUsingEncoding:NSUTF8StringEncoding];
        
    }
    
    return [inputStr dataUsingEncoding:NSUTF8StringEncoding];
}

+ (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}

+ (BOOL) validateNumeric: (NSString *) candidate {
    BOOL valid;
    NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:candidate];
    valid = [alphaNums isSupersetOfSet:inStringSet];
    return valid;
}

+ (void) pushNotification:(NSString *)msg SectionType:(NSInteger)sectionType Major:(NSInteger)major Minor:(NSInteger)minor Delay:(NSInteger) delayTime
{
    UILocalNotification* ln = [[UILocalNotification alloc] init];
    if ( msg == nil || msg.length == 0)
        ln.alertBody = @"New Easter Egg was Found.";
    else
        ln.alertBody = msg;
    ln.alertAction = [NSString stringWithFormat:@"%ld", (long)sectionType];
    ln.soundName = UILocalNotificationDefaultSoundName;
    
    if (delayTime > 0) {
        NSDate* reminderDate = [NSDate date];
        reminderDate = [reminderDate dateByAddingTimeInterval:delayTime];
        ln.fireDate = reminderDate;
        ln.timeZone = [NSTimeZone defaultTimeZone];
        [[UIApplication sharedApplication] scheduleLocalNotification:ln];
    }
    else
        [[UIApplication sharedApplication] presentLocalNotificationNow:ln];
    
    if ( sectionType != FEEDBACK_NOTIFICATION ) {
        NSString *url = [NSString stringWithFormat:@"%@%@&major=%ld&minor=%ld", DCWEBAPI_SET_SENT_NOTIFY, [WHITELEY_PROXIMITY_UUID UUIDString], (long)major, (long)minor];
        
        [DCDefines getHttpAsyncResponse:url withHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        }];
    }
}

+ (BOOL) isNotifiyEnableBluetooth
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *ble_status = [userDefault valueForKey:WHITELEY_BLE_ENABLE];
    
    if (ble_status == nil || [ble_status isEqual:@"0"])
        return NO;
    
    return YES;
}

+ (BOOL) isNotifyEnableLocation
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *loc_status = [userDefault valueForKey:WHITELEY_LOCATION_ENABLE];
    
    if (loc_status == nil || [loc_status isEqual:@"0"])
        return NO;
    
    return YES;
}

+ (BOOL) isNotifyEnableNotification
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];

    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings *settings = [[UIApplication sharedApplication] currentUserNotificationSettings];
        UIUserNotificationType types = settings.types;
        if (types == UIUserNotificationTypeNone) {
            [userDefault setObject:@"0" forKey:WHITELEY_NOTIFICATION_ENABLE];
            [userDefault synchronize];
            return NO;
        }
        else
        {
            [userDefault setObject:@"1" forKey:WHITELEY_NOTIFICATION_ENABLE];
            [userDefault synchronize];
            return YES;
            
        }
    }
    else // iOS7 and below
    {
        UIRemoteNotificationType type = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        
        if (type == UIRemoteNotificationTypeNone) {
            [userDefault setObject:@"0" forKey:WHITELEY_NOTIFICATION_ENABLE];
            [userDefault synchronize];
            return NO;
        }
        else
        {
            [userDefault setObject:@"1" forKey:WHITELEY_NOTIFICATION_ENABLE];
            [userDefault synchronize];
            return YES;
            
        }
    }

    return NO;
}

+ (NSString *)deviceUUID
{
    NSString *adid = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];

    return adid;
}

+ (BOOL)isiPHone4 {
    return SCREEN_HEIGHT == 480?YES:NO;
}

@end