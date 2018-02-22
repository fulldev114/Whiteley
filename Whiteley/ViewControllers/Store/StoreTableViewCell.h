//
//  StoreTableViewCell.h
//  Whiteley
//
//  Created by Alex Hong on 3/21/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, StoreTableViewCellType) {
    StoreTableViewCellTypeStore = 1,
    StoreTableViewCellTypeCategory
};

typedef NS_ENUM(NSInteger, ParentType) {
    STORE_TYPE = 1,
    MAP_TYPE
};

@interface StoreTableViewCell : UITableViewCell

@property (nonatomic, retain) UIViewController *parent;
@property (nonatomic, assign) NSUInteger storeCellType;
@property (nonatomic, assign) BOOL hasOffer;
@property (nonatomic, assign) BOOL isFavorite;
@property (nonatomic, assign) NSInteger m_nCellType;

@property (strong, nonatomic) IBOutlet UIButton *favoriteButton;
@property (strong, nonatomic) IBOutlet UILabel *dcTextLabel;
@property (strong, nonatomic) IBOutlet UIImageView *rightArrowView;
@property (strong, nonatomic) IBOutlet UIImageView *toolTipView;

- (IBAction)onFavoriteButtonClicked:(UIButton *)sender;

@end
