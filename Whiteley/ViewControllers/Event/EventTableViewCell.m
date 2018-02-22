//
//  EventTableViewCell.m
//  Whiteley
//
//  Created by Alex Hong on 3/30/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import "EventTableViewCell.h"
#import "DCDefines.h"

@implementation EventTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.dcDateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.dcDateLabel];
        self.dcEventTitle = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.dcEventTitle];
        self.dcEventDetailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.dcEventDetailLabel];
        
        self.dcEventImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.dcEventImageView];
        
        self.dcRightArrowImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.dcRightArrowImage];
        
        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
    self.dcDateLabel.font = [UIFont fontWithName:HFONT_THIN size:20];
    self.dcDateLabel.textColor = UIColorWithRGBA(74, 74, 74, 1);
    
    self.dcEventTitle.font = [UIFont fontWithName:HFONT_MEDIUM size:14];
    self.dcEventTitle.textColor = UIColorWithRGBA(38, 38, 38, 1);
    self.dcEventTitle.numberOfLines = 0;
    
    self.dcEventDetailLabel.font = [UIFont fontWithName:HFONT_THIN size:14];
    self.dcEventDetailLabel.textColor = UIColorWithRGBA(38, 38, 38, 1);
    self.dcEventDetailLabel.numberOfLines = 0;
    
    UIImage* image = [UIImage imageNamed:@"icon-disclosure-arrow"];
    self.dcRightArrowImage.image = image;
    self.dcRightArrowImage.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    
    self.dcEventImageView.frame = CGRectMake(0, 0, 100, 100);
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setImageURL:(NSString *)imageURL {
    
    imageURL = [imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if ([_imageURL isEqualToString:imageURL]) {
        return;
    }
    
    self.dcEventImageView.image = [UIImage imageNamed:@"default_thumb"];

    _imageURL = [imageURL copy];
    
    // new download
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_imageURL]] ;
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         if (connectionError!=nil)
         {
         }
         else
         {
             self.dcEventImageView.image = [UIImage imageWithData:data];
             self.dcEventImageView.backgroundColor = [UIColor clearColor];
         }
     }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat contentsWidth = 320;
    CGFloat contentsHeight = 190;
    CGFloat vMargin = 25;
    CGFloat hMargin = 12;
    CGFloat lineSpacing = 3;
    
    CGRect rect;
    
    self.dcDateLabel.frame = CGRectMake(hMargin, vMargin, 265, 25);
    self.dcRightArrowImage.center = CGPointMake(288, self.dcDateLabel.center.y);
    self.dcEventImageView.frame = CGRectMake(hMargin, contentsHeight - 100 - vMargin, 100, 100);
    
    NSString* text = self.dcEventTitle.text;
    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString:text];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:lineSpacing];
    [attrString addAttributes:@{
                                NSForegroundColorAttributeName : UIColorWithRGBA(38, 38, 38, 1),
                                NSFontAttributeName : [UIFont fontWithName:HFONT_MEDIUM size:15],
                                NSParagraphStyleAttributeName : style
                                } range:NSMakeRange(0, text.length)];
    
    self.dcEventTitle.attributedText = attrString;
    
    rect = self.dcEventTitle.frame;
    rect.size.width = contentsWidth - 100 - hMargin * 2.0f - 15;
    self.dcEventTitle.frame = rect;
    [self.dcEventTitle sizeToFit];
    rect = self.dcEventTitle.frame;
    rect.origin.x = hMargin + 100 + 15;
    rect.origin.y = self.dcEventImageView.frame.origin.y;
    self.dcEventTitle.frame = rect;
    
    text = self.dcEventDetailLabel.text;
    attrString = [[NSMutableAttributedString alloc] initWithString:text];
    style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:lineSpacing];
    [style setLineBreakMode:NSLineBreakByTruncatingTail];
    [attrString addAttributes:@{
                                NSForegroundColorAttributeName : UIColorWithRGBA(38, 38, 38, 1),
                                NSFontAttributeName : [UIFont fontWithName:HFONT_THIN size:15],
                                NSParagraphStyleAttributeName : style
                                } range:NSMakeRange(0, text.length)];
    
    self.dcEventDetailLabel.attributedText = attrString;
    
    rect = self.dcEventDetailLabel.frame;
    rect.size.width = contentsWidth - 100 - hMargin * 2.0f - 30;
    self.dcEventDetailLabel.frame = rect;
    [self.dcEventDetailLabel sizeToFit];
    rect = self.dcEventDetailLabel.frame;
    rect.origin.x = hMargin + 100 + 15;
    rect.origin.y = self.dcEventTitle.frame.origin.y + self.dcEventTitle.frame.size.height;
    rect.size.height = 100 - self.dcEventTitle.frame.size.height;
    self.dcEventDetailLabel.frame = rect;
    
}
@end
