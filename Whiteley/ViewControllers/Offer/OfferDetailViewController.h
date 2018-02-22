//
//  OfferDetailViewController.h
//  Whiteley
//
//  Created by Alex Hong on 3/26/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCBaseViewController.h"

@interface OfferDetailViewController : DCBaseViewController

@property (weak, nonatomic) IBOutlet    UIScrollView *scrollView;
@property (nonatomic, strong) NSString* strOfferID;
@end
