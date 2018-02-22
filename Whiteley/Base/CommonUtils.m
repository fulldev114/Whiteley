//
//  CommonUtils.m
//  SNCTA
//
//  Created by Michael on 8/11/14.
//
//

#import "CommonUtils.h"
#import "CustomIOS7AlertView.h"

static CustomIOS7AlertView *waitAlert;

@implementation CommonUtils
+ (void) showIndicator
{
    if (waitAlert == nil) {
        waitAlert =  [[CustomIOS7AlertView alloc] init];
        [waitAlert setFrame:CGRectMake(0, 44, 320, waitAlert.frame.size.height - 44)];
        UIView *loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
        loadingView.backgroundColor = [UIColor blackColor];
        loadingView.layer.cornerRadius = 5.0;
        loadingView.layer.borderWidth  = 0;
        
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityView.center = loadingView.center;
        [activityView startAnimating];
        
        [loadingView addSubview:activityView];
        
        // Add some custom content to the alert view
        [waitAlert setContainerView:loadingView];
        
        // Modify the parameters
        [waitAlert setButtonTitles:[NSMutableArray arrayWithObjects:nil]];
        
        // You may use a Block, rather than a delegate.
        [waitAlert setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex) {
            NSLog(@"Block: Button at position %ld is clicked on alertView %ld.", (long)buttonIndex, (long)[alertView tag]);
            [alertView close];
        }];
    }
    
    [waitAlert show];
    [waitAlert setUseMotionEffects:true];
}

+ (void) hideIndicator
{
    [waitAlert close];
}
@end
