//
//  OfferTableViewCell.h
//  Whiteley
//
//  Created by Alex Hong on 3/26/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OfferTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *dcShopNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *dcOfferTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *dcOfferDetailLabel;
@property (strong, nonatomic) IBOutlet UIImageView *dcOfferImageView;
@property (strong, nonatomic) IBOutlet UIImageView *dcRightArrowImageView;
@property (strong, nonatomic) NSString* imageURL;

@end
