//
//  StoreDetailViewController.h
//  Whiteley
//
//  Created by Alex Hong on 3/23/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCBaseViewController.h"

@interface StoreDetailViewController : DCBaseViewController

@property (nonatomic, strong) NSMutableArray*       dcSimilarStore;
@property (nonatomic, strong) NSDictionary*         dcStoreDetail;
@property (nonatomic, strong) NSMutableDictionary*  dcFavoriteData;
@property (nonatomic, assign) NSString*             strStoreID;
@property (weak, nonatomic) IBOutlet UIScrollView*  scrollView;

@end
