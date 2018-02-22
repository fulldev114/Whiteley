//
//  MenuTableViewCell.h
//  Whiteley
//
//  Created by Alex Hong on 3/24/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *dcImageView;
@property (weak, nonatomic) IBOutlet UILabel *dcTextLabel;
@property (weak, nonatomic) IBOutlet UIImageView *dcMenuDividerImageView;

@end
