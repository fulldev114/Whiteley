//
//  MenuView.m
//  Whiteley
//
//  Created by Alex Hong on 3/20/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import "MenuView.h"

@implementation MenuView

- (void)awakeFromNib {
    // Initialization code
    
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.iconView.frame = CGRectMake(21, 15, 65, 65);
    
    [self.dcTextLabel sizeToFit];
    CGRect rect = CGRectMake(107, 25, self.dcTextLabel.frame.size.width, self.dcTextLabel.frame.size.height);
    self.dcTextLabel.frame = rect;
    
    [self.dcDetailTextLabel sizeToFit];
    rect = CGRectMake(107, 55, self.dcDetailTextLabel.frame.size.width, self.dcDetailTextLabel.frame.size.height);
    self.dcDetailTextLabel.frame = rect;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
