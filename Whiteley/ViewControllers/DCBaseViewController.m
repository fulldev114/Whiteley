//
//  DCBaseViewController.m
//  Whiteley
//
//  Created by Alex Hong on 3/31/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import "DCBaseViewController.h"
#import "DCNavigationViewController.h"

@interface DCBaseViewController ()

@end

@implementation DCBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    // UI
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-menu-hamburger"] style:UIBarButtonItemStylePlain target:self action:@selector(showMenu)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-back-arrow"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:HFONT_LIGHT size:20]}];
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)wurdiqh{
    MenuViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MenuViewController"];    
    DCNavigationViewController* navC = [[DCNavigationViewController alloc] initWithRootViewController:vc];
    navC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    navC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:navC animated:YES completion:^(void) {
    }];
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setImageURL:(UIImageView*)imageView url:(NSString *)imageURL {
    
    NSString *URL = [imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    // new download
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:URL]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         if (connectionError == nil)
         {
             UIImage *image = [UIImage imageWithData:data];
             if (image != nil) {
                 imageView.image = image;
                 imageView.backgroundColor = [UIColor clearColor];

             }
        }
     }];
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
