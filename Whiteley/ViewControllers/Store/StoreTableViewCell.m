//
//  StoreTableViewCell.m
//  Whiteley
//
//  Created by Alex Hong on 3/21/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import "StoreTableViewCell.h"
#import "StoreListViewController.h"
#import "MapViewController.h"
#import "DCDefines.h"

@implementation StoreTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.favoriteButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [self.favoriteButton addTarget:self action:@selector(onFavoriteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.favoriteButton];
        self.dcTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.dcTextLabel];
        self.rightArrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-disclosure-arrow"]];
        [self.contentView addSubview:self.rightArrowView];
        self.toolTipView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Added-to-favourites"]];
        [self.contentView addSubview:self.toolTipView];

        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
    
    self.dcTextLabel.font = [UIFont fontWithName:HFONT_LIGHT size:18];
    self.dcTextLabel.textColor = UIColorWithRGBA(74, 74, 74, 1);
    self.dcTextLabel.text = @"";
    self.toolTipView.hidden = YES;
    
//    self.favoriteButton.backgroundColor = [UIColor blackColor];
//    self.dcTextLabel.backgroundColor = [UIColor blackColor];
//    self.rightArrowView.backgroundColor = [UIColor blackColor];
    
    [self updateButtons];
}

- (void)updateButtons {
    
    if (self.storeCellType == StoreTableViewCellTypeStore) {
        self.favoriteButton.hidden = NO;
    }
    else {
        self.favoriteButton.hidden = YES;
    }

    UIImage* favoriteImage = nil;
    if (self.hasOffer) {
        if (self.isFavorite) {
            favoriteImage = [UIImage imageNamed:@"icon-favourite-on-plusOffer"];
        }
        else {
            favoriteImage = [UIImage imageNamed:@"icon-favourite-off-plusOffer"];
        }
    }
    else {
        if (self.isFavorite) {
            favoriteImage = [UIImage imageNamed:@"icon-favourite-on"];
        }
        else {
            favoriteImage = [UIImage imageNamed:@"icon-favourite-off"];
        }
    }

//    self.favoriteButton.frame = CGRectMake(self.favoriteButton.frame.origin.x, self.favoriteButton.frame.origin.y, favoriteImage.size.width +1, favoriteImage.size.height +1);
    [self.favoriteButton setImage:favoriteImage forState:UIControlStateNormal];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self updateButtons];
    
    CGRect frameRect;
    CGRect rect;
    
    rect = CGRectMake(0, 0, 320, 69);
    frameRect = rect;
    
    if (self.storeCellType == StoreTableViewCellTypeStore) {
//        [self.favoriteButton sizeToFit];
        rect = self.favoriteButton.frame;
        rect.origin.x = 10;
        rect.size.width = 45;
        rect.size.height = 45;
        self.favoriteButton.frame = rect;
        self.favoriteButton.center = CGPointMake(self.favoriteButton.center.x, frameRect.size.height / 2.0f);
        
        self.toolTipView.frame = CGRectMake(50, 0, self.toolTipView.frame.size.width, self.toolTipView.frame.size.height);
        self.toolTipView.center = CGPointMake(self.toolTipView.center.x, self.favoriteButton.center.y-5);
        
        rect = CGRectMake(60, 0, frameRect.size.width - 100, frameRect.size.height);
        self.dcTextLabel.frame = rect;
        
    }
    else {
        rect = CGRectMake(15, 0, frameRect.size.width - 61, frameRect.size.height);
        self.dcTextLabel.frame = rect;
    }

    rect = CGRectMake(frameRect.size.width - 30, (frameRect.size.height - self.rightArrowView.frame.size.height) / 2.0f, self.rightArrowView.frame.size.width, self.rightArrowView.frame.size.height);
    self.rightArrowView.frame = rect;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onFavoriteButtonClicked:(UIButton *)sender {
    self.isFavorite = !self.isFavorite;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *favDic =[[NSMutableDictionary alloc] initWithDictionary:[userDefaults valueForKey:WHITELEY_FOVORITE_STORE]];
    NSString *mID = [NSString stringWithFormat:@"%ld", (long)sender.tag];
    NSString *mFavorite;
    if (self.isFavorite)
        mFavorite = @"1";
    else
        mFavorite = @"0";
    
    [favDic setValue:mFavorite forKey:mID];
    [userDefaults setObject:favDic forKey:WHITELEY_FOVORITE_STORE];
    [userDefaults synchronize];
    
    NSMutableArray *tableData = nil;
    if (self.m_nCellType == STORE_TYPE) {
        StoreListViewController *vc = (StoreListViewController*)self.parent;
        tableData = vc.dcStores;
    }
    else
    {
        MapViewController *vc = (MapViewController*)self.parent;
        tableData = vc.dcAllStores;
    }

    for (int i = 0; i < tableData.count; i++) {
        NSMutableDictionary *dic = [tableData objectAtIndex:i];
        if ([dic[@"id"] isEqualToString:mID])
            [dic setObject:mFavorite forKey:@"favorite"];
    }
    
    [self updateButtons];

    if (self.isFavorite) {
        
        [self.toolTipView.layer removeAllAnimations];
        
        self.toolTipView.hidden = NO;
        self.toolTipView.alpha = 1;
        
        self.toolTipView.transform = CGAffineTransformMakeScale(1.0, 0.0);
        
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.toolTipView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            if (finished) {
            }
        }];
        
        [UIView animateWithDuration:0.5 delay:1 options:UIViewAnimationOptionTransitionNone animations:^{
            self.toolTipView.alpha = 0;
        } completion:^(BOOL finished) {
            self.toolTipView.alpha = 1;
            self.toolTipView.hidden = YES;
        }];
    }
}

@end
