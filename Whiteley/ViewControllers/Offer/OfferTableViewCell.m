//
//  OfferTableViewCell.m
//  Whiteley
//
//  Created by Alex Hong on 3/26/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import "OfferTableViewCell.h"
#import "DCDefines.h"

@implementation OfferTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.dcShopNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.dcShopNameLabel];
        self.dcOfferTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.dcOfferTitleLabel];
        self.dcOfferDetailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.dcOfferDetailLabel];
        
        self.dcOfferImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.dcOfferImageView];
        
        self.dcRightArrowImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.dcRightArrowImageView];
        
        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
    self.dcShopNameLabel.font = [UIFont fontWithName:HFONT_THIN size:20];
    self.dcShopNameLabel.textColor = UIColorWithRGBA(74, 74, 74, 1);
    
    self.dcOfferTitleLabel.font = [UIFont fontWithName:HFONT_MEDIUM size:14];
    self.dcOfferTitleLabel.textColor = UIColorWithRGBA(38, 38, 38, 1);
    self.dcOfferTitleLabel.numberOfLines = 0;
    
    self.dcOfferDetailLabel.font = [UIFont fontWithName:HFONT_THIN size:14];
    self.dcOfferDetailLabel.textColor = UIColorWithRGBA(38, 38, 38, 1);
    self.dcOfferDetailLabel.numberOfLines = 0;
    
    UIImage* image = [UIImage imageNamed:@"icon-disclosure-arrow"];
    self.dcRightArrowImageView.image = image;
    self.dcRightArrowImageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    
    self.dcOfferImageView.frame = CGRectMake(0, 0, 100, 100);
    
//    self.dcOfferDetailLabel.backgroundColor = [UIColor redColor];
//    self.dcOfferTitleLabel.backgroundColor = [UIColor redColor];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat contentsWidth = 320;
    CGFloat contentsHeight = 190;
    CGFloat vMargin = 25;
    CGFloat hMargin = 12;
    CGFloat lineSpacing = 3;
    
    CGRect rect;
    
    self.dcShopNameLabel.frame = CGRectMake(hMargin, vMargin, 265, 25);
    self.dcRightArrowImageView.center = CGPointMake(288, self.dcShopNameLabel.center.y);
    self.dcOfferImageView.frame = CGRectMake(hMargin, contentsHeight - 100 - vMargin, 100, 100);
    
    NSString* text = self.dcOfferTitleLabel.text;
    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString:text];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:lineSpacing];
    [attrString addAttributes:@{
                               NSForegroundColorAttributeName : UIColorWithRGBA(38, 38, 38, 1),
                               NSFontAttributeName : [UIFont fontWithName:HFONT_MEDIUM size:15],
                               NSParagraphStyleAttributeName : style
                               } range:NSMakeRange(0, text.length)];

    self.dcOfferTitleLabel.attributedText = attrString;
    
    rect = self.dcOfferTitleLabel.frame;
    rect.size.width = contentsWidth - 100 - hMargin * 2.0f - 15;
    self.dcOfferTitleLabel.frame = rect;
    [self.dcOfferTitleLabel sizeToFit];
    rect = self.dcOfferTitleLabel.frame;
    rect.origin.x = hMargin + 100 + 15;
    rect.origin.y = self.dcOfferImageView.frame.origin.y;
    self.dcOfferTitleLabel.frame = rect;

    text = self.dcOfferDetailLabel.text;
    attrString = [[NSMutableAttributedString alloc] initWithString:text];
    style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:lineSpacing];
    [style setLineBreakMode:NSLineBreakByTruncatingTail];
    [attrString addAttributes:@{
                                NSForegroundColorAttributeName : UIColorWithRGBA(38, 38, 38, 1),
                                NSFontAttributeName : [UIFont fontWithName:HFONT_THIN size:14],
                                NSParagraphStyleAttributeName : style
                                } range:NSMakeRange(0, text.length)];
    
    self.dcOfferDetailLabel.attributedText = attrString;

    rect = self.dcOfferDetailLabel.frame;
    rect.size.width = contentsWidth - 100 - hMargin * 2.0f - 30;
    self.dcOfferDetailLabel.frame = rect;
    [self.dcOfferDetailLabel sizeToFit];
    rect = self.dcOfferDetailLabel.frame;
    rect.origin.x = hMargin + 100 + 15;
    rect.origin.y = self.dcOfferTitleLabel.frame.origin.y + self.dcOfferTitleLabel.frame.size.height;
    rect.size.height = 100 - self.dcOfferTitleLabel.frame.size.height;
    self.dcOfferDetailLabel.frame = rect;

}

- (void)setImageURL:(NSString *)imageURL {
    
    imageURL = [imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if ([_imageURL isEqualToString:imageURL]) {
        return;
    }
    
    self.dcOfferImageView.image = [UIImage imageNamed:@"default_thumb"];

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
             self.dcOfferImageView.image = [UIImage imageWithData:data];
             self.dcOfferImageView.backgroundColor = [UIColor clearColor];
         }
     }];
}
@end
