//
//  EventTableViewCell.h
//  Whiteley
//
//  Created by Alex Hong on 3/30/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *dcDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *dcEventTitle;
@property (strong, nonatomic) IBOutlet UILabel *dcEventDetailLabel;
@property (strong, nonatomic) IBOutlet UIImageView *dcEventImageView;
@property (strong, nonatomic) IBOutlet UIImageView *dcRightArrowImage;
@property (strong, nonatomic) NSString* imageURL;

@end
