//
//  MenuView.h
//  Whiteley
//
//  Created by Alex Hong on 3/20/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuView : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *dcTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *dcDetailTextLabel;

@end
