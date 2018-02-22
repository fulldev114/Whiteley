//
//  OpenDrakeSiteViewController.m
//  Whiteley
//
//  Created by Alex Hong on 5/6/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import "OpenWebSiteViewController.h"

@interface OpenWebSiteViewController ()<UIWebViewDelegate>

@end

@implementation OpenWebSiteViewController
@synthesize webView, strURL;
- (void)viewDidLoad {
    [super viewDidLoad];
   
    webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:strURL]]];
    webView.delegate = self;
    webView.scrollView.bounces = NO;
    [webView setBackgroundColor:[UIColor clearColor]];
    [webView setOpaque:NO];
    webView.scalesPageToFit = YES;
    [self.view addSubview:webView];
    
    [CommonUtils showIndicator];

    [self performSelector:@selector(hideWaitingIndicator) withObject:nil afterDelay:30.0f];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [CommonUtils hideIndicator];
}

- (void) hideWaitingIndicator
{
    [CommonUtils hideIndicator];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
