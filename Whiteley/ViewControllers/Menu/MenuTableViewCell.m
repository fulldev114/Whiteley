//
//  MenuTableViewCell.m
//  Whiteley
//
//  Created by Alex Hong on 3/24/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import "MenuTableViewCell.h"
#import "DCDefines.h"

@implementation MenuTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.dcTextLabel.font = [UIFont fontWithName:HFONT_THIN size:18];
    self.dcTextLabel.textColor = [UIColor whiteColor];
}

@end
