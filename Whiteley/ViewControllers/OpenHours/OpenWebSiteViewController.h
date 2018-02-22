//
//  OpenDrakeSiteViewController.h
//  Whiteley
//
//  Created by Alex Hong on 5/6/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import "DCBaseViewController.h"

@interface OpenWebSiteViewController : DCBaseViewController
@property (retain, nonatomic) UIWebView *webView;
@property (strong, nonatomic) NSString  *strURL;
@end
