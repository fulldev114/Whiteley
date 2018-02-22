//
//  OpeningHoursViewController.h
//  Whiteley
//
//  Created by Alex Hong on 5/6/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import "DCBaseViewController.h"

@interface OpeningHoursViewController : DCBaseViewController
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) UILabel    *lblOpenHours;
@property (nonatomic, retain) UILabel    *lblDescription;
@property (nonatomic, retain) UIButton   *btnWebLink;
@end
