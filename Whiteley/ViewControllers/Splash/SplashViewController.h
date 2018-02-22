//
//  SplashViewController.h
//  Whiteley
//
//  Created by Alex Hong on 4/14/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCGIFImageView.h"

@interface SplashViewController : UIViewController
@property (strong, nonatomic) IBOutlet SCGIFImageView *animateImgView;
@property (strong, nonatomic) IBOutlet UIImageView *imgDrake;
@property (strong, nonatomic) IBOutlet UIImageView *imgPlay;
@property (strong, nonatomic) IBOutlet UIImageView *imgTM;

@end
