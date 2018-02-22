//
//  StoreDetailViewController.m
//  Whiteley
//
//  Created by Alex Hong on 3/23/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import "StoreDetailViewController.h"
#import "DCDefines.h"
#import "StoreTableViewCell.h"
#import "OfferDetailViewController.h"
#import "MapViewController.h"
#import "OpenWebSiteViewController.h"

@interface StoreDetailViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (nonatomic, assign) NSArray*  tableData;

// UI
@property (nonatomic, weak) UIView*         hoursView;
@property (nonatomic, weak) UIView*         upperView;
@property (nonatomic, weak) UIView*         headerView;
@property (nonatomic, weak) UIImageView*    shopLogoImageView;
@property (nonatomic, weak) UIImageView*    shopLogoDividerImageView;
@property (nonatomic, weak) UILabel*        shopNameLabel;
//@property (nonatomic, weak) UILabel*        shopLocationLabel;
@property (nonatomic, weak) UIImageView*    shopStateImageView;

@property (nonatomic, weak) UIImageView*    shopImageView;
@property (nonatomic, weak) UITextView*     shopTextView;

@property (nonatomic, weak) UIButton*       btnMapButton;
@property (nonatomic, weak) UIButton*       btnCallButton;
@property (nonatomic, weak) UIButton*       btnWebButton;

@property (nonatomic, weak) UIView*         hoursControlView;
@property (nonatomic, weak) UIImageView*    clockImageView;
@property (nonatomic, weak) UILabel*        hoursControlTitleLabel;
@property (nonatomic, weak) UIImageView*    plusImageView;
@property (nonatomic, weak) UIButton*       hoursControlButton;

@property (nonatomic, weak) UIView*         offerControlView;
@property (nonatomic, weak) UIImageView*    offerImageView;
@property (nonatomic, weak) UILabel*        offerControlTitleLabel;

@property (nonatomic, weak) UIImageView*    offerRightArrowImageView;
@property (nonatomic, weak) UIButton*       offerControlButton;

@property (nonatomic, weak) UIView*         favoriteView;
@property (nonatomic, weak) UILabel*        favoriteTitleLabel;
@property (nonatomic, weak) UILabel*        favoriteDetailLabel;

@property (nonatomic, weak) UIButton*       favoriteButton;
@property (nonatomic, weak) UIImageView*    favoriteToolTipImageView;

@property (nonatomic, weak) UILabel*        similarStoresLabel;

@property (nonatomic, weak) UITableView*    tableView;

@end

@implementation StoreDetailViewController {
    BOOL _showingOpeningHours;
    BOOL _isFavorite;
}
@synthesize dcStoreDetail, dcSimilarStore, dcFavoriteData;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _showingOpeningHours = NO;
    self.scrollView.userInteractionEnabled = YES;
    
    dcFavoriteData =[[NSMutableDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] valueForKey:WHITELEY_FOVORITE_STORE]];
    if ([[dcFavoriteData valueForKey:self.strStoreID] isEqualToString:@"1"])
        _isFavorite = YES;
    else
        _isFavorite = NO;
    
    self.title = @"Our Stores";
//    self.view.backgroundColor = [UIColor blackColor];
    [CommonUtils showIndicator];
    [self performSelector:@selector(hideWaitingIndicator) withObject:nil afterDelay:10.0f];
    
    NSString *url = [DCWEBAPI_GET_STORE_DETAIL stringByAppendingString:self.strStoreID];

    [DCDefines getHttpAsyncResponse:url withHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        NSData *responseData = data;
        
        if (responseData == nil) {
            [CommonUtils hideIndicator];
            return;
        }
        
        NSError* errorInfo;
        NSDictionary *dic  = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&errorInfo];
        
        dcStoreDetail = [dic valueForKey:@"result"];
        dcSimilarStore = [[NSMutableArray alloc] init];
        
        if (dcStoreDetail.count == 0) {
            [CommonUtils hideIndicator];
            return;
        }
        
        NSMutableArray *arySimilarStore = [dcStoreDetail objectForKey:@"similar_stores"];
        
        for (int i = 0; i < arySimilarStore.count; i++) {
            NSMutableDictionary *dicStore = [arySimilarStore objectAtIndex:i];
            NSString *favoriteFlag = [dcFavoriteData valueForKey:dicStore[@"id"]];
            BOOL m_bFlag = NO;

            if([favoriteFlag isEqualToString:@"1"])
                m_bFlag = YES;
            
            NSMutableDictionary *store = [NSMutableDictionary dictionaryWithObjectsAndKeys:[dicStore valueForKey:@"id"], @"id",
                                   [dicStore valueForKey:@"name"], @"name",
                                   [dicStore valueForKey:@"has_offer"],  @"hasoffer",
                                   [NSNumber numberWithBool:m_bFlag], @"favorite", nil];
            [dcSimilarStore addObject:store];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // Add UI Controls
            UIView* view = nil;
            UIImageView* imageView = nil;
            UILabel* label = nil;
            UITextView* textView = nil;
            UIButton* button = nil;
            
            view = [[UIView alloc] initWithFrame:CGRectZero];
            view.backgroundColor = UIColorWithRGBA(239, 240, 240, 1);
            [self.scrollView addSubview:view];
            self.hoursView = view;
            
            NSDictionary *dicShopOpen = dcStoreDetail[@"open"];
            
            for (int i = 0; i < 7; i++) {
                label = [[UILabel alloc] initWithFrame:CGRectZero];
                label.tag = i+1;
                NSString* dayString = nil;
                NSString* hourString = nil;
                switch (i) {
                    case 0:
                        dayString = @"Monday";
                        hourString = dicShopOpen[@"mon"];
                        break;
                    case 1:
                        dayString = @"Tuesday";
                        hourString = dicShopOpen[@"tue"];
                        break;
                    case 2:
                        dayString = @"Wednesday";
                        hourString = dicShopOpen[@"wed"];
                        break;
                    case 3:
                        dayString = @"Thursday";
                        hourString = dicShopOpen[@"thu"];
                        break;
                    case 4:
                        dayString = @"Friday";
                        hourString = dicShopOpen[@"fri"];
                        break;
                    case 5:
                        dayString = @"Saturday";
                        hourString = dicShopOpen[@"sat"];
                        break;
                    default:
                        dayString = @"Sunday";
                        hourString = dicShopOpen[@"sun"];
                        break;
                }
                
                label.text = dayString;
                label.font = [UIFont fontWithName:HFONT_THIN size:17];
                label.textColor = UIColorWithRGBA(38, 38, 38, 1);
                [view addSubview:label];
                
                hourString = [hourString stringByReplacingOccurrencesOfString:@"-" withString:@"        -        "];
                label = [[UILabel alloc] initWithFrame:CGRectZero];
                label.tag = i+10+1;
                label.text = hourString;
                label.font = [UIFont fontWithName:HFONT_THIN size:17];
                label.textColor = UIColorWithRGBA(38, 38, 38, 1);
                [view addSubview:label];
            }
            
            view = [[UIView alloc] initWithFrame:CGRectZero];
            [self.scrollView addSubview:view];
            view.backgroundColor = UIColorWithRGBA(239, 240, 240, 1);
            self.upperView = view;
            
            view = [[UIView alloc] initWithFrame:CGRectZero];
            [self.upperView addSubview:view];
            view.backgroundColor = [UIColor whiteColor];
            self.headerView = view;
            
            imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
            [view addSubview:imageView];
            self.shopLogoImageView = imageView;
            //----------------------
            
            imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
            [view addSubview:imageView];
            imageView.image = [UIImage imageNamed:@"logo-divider-line"];
            self.shopLogoDividerImageView = imageView;
            
            label = [[UILabel alloc] initWithFrame:CGRectZero];
            [view addSubview:label];
            label.font = [UIFont fontWithName:HFONT_THIN size:20];
            label.textColor = UIColorWithRGBA(74, 74, 74, 1);
            self.shopNameLabel = label;
            
//            label = [[UILabel alloc] initWithFrame:CGRectZero];
//            [view addSubview:label];
//            label.font = [UIFont fontWithName:HFONT_MEDIUM size:12];
//            label.textColor = UIColorWithRGBA(74, 74, 74, 1);
//            self.shopLocationLabel = label;
            
            view = self.upperView;
            imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
            imageView.image = [UIImage imageNamed:@"default_thumb_large"];
            [view addSubview:imageView];
            self.shopImageView = imageView;
            
            textView = [[UITextView alloc] initWithFrame:CGRectZero];
            [view addSubview:textView];
            textView.textColor = UIColorWithRGBA(38, 38, 38, 1);
            textView.font = [UIFont fontWithName:HFONT_THIN size:16];
            textView.dataDetectorTypes = UIDataDetectorTypeAll;
            textView.editable = NO;
            textView.backgroundColor = [UIColor clearColor];
            textView.scrollEnabled = NO;
            self.shopTextView = textView;
            
            CGFloat edgeControl = 50;
            CGFloat fontHeight = 17;
            
            button = [[UIButton alloc] initWithFrame:CGRectZero];
            [view addSubview:button];
            UIImage* btnImage = [UIImage imageNamed:@"btn-icon-map"];
            [button setBackgroundImage:[UIImage imageNamed:@"purple-button"] forState:UIControlStateNormal];
            [button setImage:btnImage forState:UIControlStateNormal];
            [button addTarget:self action:@selector(onClickMapButton:) forControlEvents:UIControlEventTouchUpInside];
            [button setTitle:@"View store on centre map" forState:UIControlStateNormal];
            button.titleLabel.textColor = [UIColor whiteColor];
            button.titleLabel.font = [UIFont fontWithName:HFONT_THIN size:fontHeight];
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            button.imageEdgeInsets = UIEdgeInsetsMake(0, (edgeControl - btnImage.size.width) / 2.0f, 0, 0);
            button.titleEdgeInsets = UIEdgeInsetsMake(0, edgeControl - btnImage.size.width, 0, 0);
            self.btnMapButton = button;
            
            button = [[UIButton alloc] initWithFrame:CGRectZero];
            [view addSubview:button];
            btnImage = [UIImage imageNamed:@"btn-icon-phone"];
            [button setBackgroundImage:[UIImage imageNamed:@"purple-button"] forState:UIControlStateNormal];
            [button setImage:btnImage forState:UIControlStateNormal];
            [button addTarget:self action:@selector(onClickPhoneButton:) forControlEvents:UIControlEventTouchUpInside];
            NSString *strPhone = [@"Tap to call store: " stringByAppendingString:dcStoreDetail[@"phone"]];
            [button setTitle:strPhone forState:UIControlStateNormal];
            button.titleLabel.textColor = [UIColor whiteColor];
            button.titleLabel.font = [UIFont fontWithName:HFONT_THIN size:fontHeight];
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            button.imageEdgeInsets = UIEdgeInsetsMake(0, (edgeControl - btnImage.size.width) / 2.0f, 0, 0);
            button.titleEdgeInsets = UIEdgeInsetsMake(0, edgeControl - btnImage.size.width, 0, 0);
            self.btnCallButton = button;
            
            button = [[UIButton alloc] initWithFrame:CGRectZero];
            [view addSubview:button];
            btnImage = [UIImage imageNamed:@"btn-icon-laptop"];
            [button setBackgroundImage:[UIImage imageNamed:@"purple-button"] forState:UIControlStateNormal];
            [button setImage:btnImage forState:UIControlStateNormal];
            [button setTitle:@"Launch store website" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(onClickWebButton:) forControlEvents:UIControlEventTouchUpInside];
            button.titleLabel.textColor = [UIColor whiteColor];
            button.titleLabel.font = [UIFont fontWithName:HFONT_THIN size:fontHeight];
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            button.imageEdgeInsets = UIEdgeInsetsMake(0, (edgeControl - btnImage.size.width) / 2.0f, 0, 0);
            button.titleEdgeInsets = UIEdgeInsetsMake(0, edgeControl - btnImage.size.width, 0, 0);
            self.btnWebButton = button;
            
            // Open Hours
            view = [[UIView alloc] initWithFrame:CGRectZero];
            [self.upperView addSubview:view];
            view.backgroundColor = UIColorWithRGBA(230, 232, 232, 1);
            self.hoursControlView = view;
            
            imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
            [view addSubview:imageView];
            imageView.image = [UIImage imageNamed:@"icon-opening-hours"];
            self.clockImageView = imageView;
            
            label = [[UILabel alloc] initWithFrame:CGRectZero];
            [view addSubview:label];
            label.text = @"Opening Hours";
            label.font = [UIFont fontWithName:HFONT_THIN size:20];
            label.textColor = UIColorWithRGBA(74, 74, 74, 1);
            self.hoursControlTitleLabel = label;
            
            imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
            [view addSubview:imageView];
            imageView.image = [UIImage imageNamed:@"plus"];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            self.plusImageView = imageView;
            
            button = [[UIButton alloc] initWithFrame:CGRectZero];
            [view addSubview:button];
            [button addTarget:self action:@selector(openHoursView) forControlEvents:UIControlEventTouchUpInside];
            self.hoursControlButton = button;
            
            // Offers
            view = [[UIView alloc] initWithFrame:CGRectZero];
            [self.scrollView addSubview:view];
            view.backgroundColor = UIColorWithRGBA(230, 232, 232, 1);
            self.offerControlView = view;
            
            imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
            [view addSubview:imageView];
            imageView.image = [UIImage imageNamed:@"icon-offers"];
            self.offerImageView = imageView;
            
            label = [[UILabel alloc] initWithFrame:CGRectZero];
            [view addSubview:label];
            NSString *strOffer = dcStoreDetail[@"offer_id"];

            if ( strOffer.length == 0 )
                label.text = @"No Offers";
            else
                label.text = @"Offers available";
            
            label.font = [UIFont fontWithName:HFONT_THIN size:20];
            label.textColor = UIColorWithRGBA(74, 74, 74, 1);
            self.offerControlTitleLabel = label;
            
            imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
            [view addSubview:imageView];
            imageView.image = [UIImage imageNamed:@"icon-disclosure-arrow"];
            if ( strOffer.length == 0 )
                imageView.hidden = YES;
            else
                imageView.hidden = NO;
            self.offerRightArrowImageView = imageView;
            
            button = [[UIButton alloc] initWithFrame:CGRectZero];
            [view addSubview:button];
            [button addTarget:self action:@selector(onClickOfferAvailableButton:) forControlEvents:UIControlEventTouchUpInside];
            self.offerControlButton = button;
            
            view = [[UIView alloc] initWithFrame:CGRectZero];
            [self.scrollView addSubview:view];
            view.backgroundColor = UIColorWithRGBA(230, 232, 232, 1);
            self.favoriteView = view;
            
            label = [[UILabel alloc] initWithFrame:CGRectZero];
            [view addSubview:label];
            label.text = @"Like this store?";
            label.font = [UIFont fontWithName:HFONT_THIN size:24];
            label.textColor = UIColorWithRGBA(74, 74, 74, 1);
            self.favoriteTitleLabel = label;
            
            label = [[UILabel alloc] initWithFrame:CGRectZero];
            [view addSubview:label];
            label.text = @"Add to favourites to get personalised offers, events, notifications and more.";
            label.numberOfLines = 0;
            label.font = [UIFont fontWithName:HFONT_THIN size:16];
            label.textColor = UIColorWithRGBA(38, 38, 38, 1);
            self.favoriteDetailLabel = label;
            
            button = [[UIButton alloc] initWithFrame:CGRectZero];
            [self.scrollView addSubview:button];
            btnImage = [UIImage imageNamed:@"big-heart-off"];
            [button setImage:btnImage forState:UIControlStateNormal];
            button.contentMode = UIViewContentModeScaleAspectFit;
            [button addTarget:self action:@selector(onFavoriteButtonClicked) forControlEvents:UIControlEventTouchUpInside];
            self.favoriteButton = button;
            if (_isFavorite) {
                [self.favoriteButton setImage:[UIImage imageNamed:@"big-heart-on"] forState:UIControlStateNormal];
            }
            else {
                [self.favoriteButton setImage:[UIImage imageNamed:@"big-heart-off"] forState:UIControlStateNormal];
            }
            
            imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
            [self.scrollView addSubview:imageView];
            imageView.image = [UIImage imageNamed:@"added-to-favourites-top"];
            imageView.hidden = YES;
            self.favoriteToolTipImageView = imageView;
            
            label = [[UILabel alloc] initWithFrame:CGRectZero];
            [self.scrollView addSubview:label];
            label.text = @"Similar Stores";
            label.font = [UIFont fontWithName:HFONT_THIN size:24];
            label.textColor = UIColorWithRGBA(74, 74, 74, 1);
            self.similarStoresLabel = label;
            
            if (dcSimilarStore.count == 0) {
                [self.similarStoresLabel setHidden:YES];
            }
            
            UITableView* table = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
            [self.scrollView addSubview:table];
            table.dataSource = self;
            table.delegate = self;
            table.scrollEnabled = NO;
            table.separatorStyle = UITableViewCellSeparatorStyleNone;
            self.tableView = table;
            
            self.tableData = self.dcSimilarStore;
            
            [self updateControls];
            [self layoutCustomControls];

            [self.tableView reloadData];
            [CommonUtils hideIndicator];

        });
        
    }];
    
}

- (void) hideWaitingIndicator
{
    [CommonUtils hideIndicator];
}

- (void)updateControls {
    if (![dcStoreDetail[@"logo"] isEqualToString:@""])
        [self setImageURL:self.shopLogoImageView url:dcStoreDetail[@"logo"]];

    self.shopNameLabel.text = dcStoreDetail[@"name"];
    //self.shopLocationLabel.text = dcStoreDetail[@"location"];
    
    self.shopStateImageView.image = [UIImage imageNamed:@"open"];
   
    if (![dcStoreDetail[@"image"] isEqualToString:@""])
        [self setImageURL:self.shopImageView url:dcStoreDetail[@"image"]];
    
    NSString* text = dcStoreDetail[@"text"];
    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString:text];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:3];
    [attrString addAttributes:@{
                                NSForegroundColorAttributeName : UIColorWithRGBA(38, 38, 38, 1),
                                NSFontAttributeName : [UIFont fontWithName:HFONT_THIN size:16],
                                NSParagraphStyleAttributeName : style
                                } range:NSMakeRange(0, text.length)];
    
    self.shopTextView.attributedText = attrString;
}

- (void)onClickOfferAvailableButton:(id)sender
{
    NSString *strOfferID = dcStoreDetail[@"offer_id"];
    
    if (strOfferID.length == 0) {
        return;
    }
    
    OfferDetailViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OfferDetailViewController"];
    vc.strOfferID = strOfferID;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onClickMapButton:(id)sender
{
    MapViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
    controller.m_bSectionFacilites = NO;
    controller.title = @"Centre Map";
    controller.m_sSelectedShopID = dcStoreDetail[@"id"];
    NSString *floorName = dcStoreDetail[@"location"];
    
    if ([floorName isEqualToString:@"G Lower Mall"])
        controller.m_nCentureFloor = LOWER_MALL;
    else if ([floorName isEqualToString:@"1 Upper Mall"])
        controller.m_nCentureFloor = UPPER_MALL;
    else
        controller.m_nCentureFloor = FOOD_COURT;
    
    NSMutableArray *aryController = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
    NSInteger count = aryController.count;
    UIViewController *beforeController = [aryController objectAtIndex:count-2];

    if ([beforeController isKindOfClass:[MapViewController class]]) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if ( count > 10 )
    {
        for (int i = 1; i < count - 9; i++) {
            UIViewController *controller = [aryController objectAtIndex:i];
            if ([controller isKindOfClass:[MapViewController class]]) {
                MapViewController *mapController = (MapViewController*)controller;
                [mapController removeMapView];
            }
            [aryController removeObjectAtIndex:i];
        }
        [self.navigationController setViewControllers:(NSArray*)aryController];
    }

    [self.navigationController pushViewController:controller animated:YES];

}

- (void)onClickPhoneButton:(id)sender
{
    UIButton *button = sender;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Call this store?" message:[NSString stringWithFormat:@"Would you like to call %@?", dcStoreDetail[@"name"]] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Call now", nil];
    alert.tag = button.tag;
    [alert show];
}

- (void)onClickWebButton:(id)sender
{
    OpenWebSiteViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OpenWebSiteViewController"];
    vc.title = @"Our Stores";
    vc.strURL = dcStoreDetail[@"url"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onFavoriteButtonClicked {
    _isFavorite = !_isFavorite;

    if (_isFavorite) {
        [self.favoriteButton setImage:[UIImage imageNamed:@"big-heart-on"] forState:UIControlStateNormal];
        [dcFavoriteData setObject:@"1" forKey:self.strStoreID];
    }
    else {
        [self.favoriteButton setImage:[UIImage imageNamed:@"big-heart-off"] forState:UIControlStateNormal];
        [dcFavoriteData setObject:@"0" forKey:self.strStoreID];
    }
    
     [[NSUserDefaults standardUserDefaults] setObject:dcFavoriteData forKey:WHITELEY_FOVORITE_STORE];

    if (_isFavorite) {
        
        [self.favoriteToolTipImageView.layer removeAllAnimations];
        
        self.favoriteToolTipImageView.hidden = NO;
        self.favoriteToolTipImageView.alpha = 1;
        
        self.favoriteToolTipImageView.transform = CGAffineTransformMakeScale(0.0, 1.0);
        
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.favoriteToolTipImageView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            if (finished) {
            }
        }];
        
        [UIView animateWithDuration:0.5 delay:1 options:UIViewAnimationOptionTransitionNone animations:^{
            self.favoriteToolTipImageView.alpha = 0;
        } completion:^(BOOL finished) {
            self.favoriteToolTipImageView.alpha = 1;
            self.favoriteToolTipImageView.hidden = YES;
        }];
    }
}

- (void)layoutCustomControls {
    CGFloat contentsHeight = 0;
    CGFloat contentsWidth = 320;
    
    CGRect viewRect = CGRectMake(0, 0, contentsWidth, 568);
    CGRect rect;
    
    self.headerView.frame = CGRectMake(0, 0, contentsWidth, 90);
    
    rect.size.width = 68;
    rect.size.height = 68;
    rect.origin.x = 4;
    rect.origin.y = (self.headerView.frame.size.height - rect.size.height) / 2.0f;
    self.shopLogoImageView.frame = rect;
    
    rect.size = self.shopLogoDividerImageView.image.size;
    rect.origin.x = self.shopLogoImageView.frame.origin.x + self.shopLogoImageView.frame.size.width + 4;
    rect.origin.y = (self.headerView.frame.size.height - rect.size.height) / 2.0f;
    self.shopLogoDividerImageView.frame = rect;
    
    rect.origin.x = self.shopLogoDividerImageView.frame.origin.x + self.shopLogoDividerImageView.frame.size.width + 15;
    rect.origin.y = 30;
    rect.size.width = self.headerView.frame.size.width - rect.origin.x - 4;
    rect.size.height = 25;
    self.shopNameLabel.frame = rect;
       
    rect.origin.y = 50;
    rect.size = self.shopStateImageView.image.size;
    rect.origin.x = self.headerView.frame.size.width - 16 - rect.size.width;
    self.shopStateImageView.frame = rect;
    
    contentsHeight += self.headerView.frame.size.height;

    NSString *strImageUrl = dcStoreDetail[@"image"];
    
    if (strImageUrl.length == 0)
        self.shopImageView.frame = CGRectMake(0, self.headerView.frame.origin.y + self.headerView.frame.size.height, 0, 0);
    else
        self.shopImageView.frame = CGRectMake(0, self.headerView.frame.origin.y + self.headerView.frame.size.height, contentsWidth, 148);
    
    contentsHeight += self.shopImageView.frame.size.height;

    rect.size.width = contentsWidth - 20;
    self.shopTextView.frame = rect;
    [self.shopTextView sizeToFit];
    rect = self.shopTextView.frame;
    rect.origin.x = 10;
    rect.origin.y = self.shopImageView.frame.origin.y + self.shopImageView.frame.size.height +10;
    self.shopTextView.frame = rect;
    
    contentsHeight = self.shopTextView.frame.origin.y + self.shopTextView.frame.size.height + 10;
    
    rect.size.width = 298;
    rect.size.height = 55;
    
    NSString *strMap = dcStoreDetail[@"unit_num"];
    if (strMap.length == 0 || strMap == nil) {
        self.btnMapButton.hidden = YES;
    }
    else {
        rect.origin.x = (contentsWidth - rect.size.width) / 2.0f;
        rect.origin.y = contentsHeight + 15;
        self.btnMapButton.frame = rect;
        contentsHeight = self.btnMapButton.frame.origin.y + self.btnMapButton.frame.size.height;

    }
    
    NSString *strPhone = dcStoreDetail[@"phone"];
    if (strPhone.length == 0 || strPhone == nil) {
        self.btnCallButton.hidden = YES;
    }
    else{
        self.btnCallButton.hidden = NO;
        rect.origin.y = contentsHeight + 15;
        self.btnCallButton.frame = rect;
        contentsHeight = self.btnCallButton.frame.origin.y + self.btnCallButton.frame.size.height;
    }
    
    NSString *strURL= dcStoreDetail[@"url"];
    if (strURL.length == 0 || strURL == nil) {
        self.btnWebButton.hidden = YES;
        contentsHeight += 23;
    }
    else{
        self.btnWebButton.hidden = NO;
        rect.origin.y = contentsHeight + 15;
        self.btnWebButton.frame = rect;
        contentsHeight = self.btnWebButton.frame.origin.y + self.btnWebButton.frame.size.height + 23;
    }
    
    self.hoursControlView.frame = CGRectMake(0, contentsHeight, contentsWidth, 53);
    self.clockImageView.frame = CGRectMake(0, 0, self.clockImageView.image.size.width, self.clockImageView.image.size.width);
    self.clockImageView.center = CGPointMake(35, self.hoursControlView.frame.size.height / 2.0f);
    
    self.hoursControlTitleLabel.frame = CGRectMake(65, 0, 300, self.hoursControlView.frame.size.height);
    
    self.plusImageView.frame = CGRectMake(0, 0, 17, 17);
    self.plusImageView.center = CGPointMake(290, self.hoursControlView.frame.size.height / 2.0f);
    
    self.hoursControlButton.frame = CGRectMake(0, 0, self.hoursControlView.frame.size.width, self.hoursControlView.frame.size.height);
    
    contentsHeight = self.hoursControlView.frame.origin.y + self.hoursControlView.frame.size.height;
    
    self.upperView.frame = CGRectMake(0, 0, contentsWidth, contentsHeight);
    
    CGFloat topMargin = 12;
    CGFloat btnHeight = 30;
    for (int i=0; i<7; i++) {
        UILabel* label;
        label = (UILabel*)[self.hoursView viewWithTag:i+1];
        rect.origin.x = 13;
        rect.origin.y = topMargin + btnHeight * i;
        rect.size.width = 100;
        rect.size.height = btnHeight;
        label.frame = rect;
        
        label = (UILabel*)[self.hoursView viewWithTag:i+10+1];
        rect.origin.x = 130;
        rect.origin.y = topMargin + btnHeight * i;
        rect.size.width = 190;
        rect.size.height = btnHeight;
        label.frame = rect;
    }
    
    rect = CGRectMake(0, contentsHeight, contentsWidth, btnHeight*7+topMargin*2);
    if (_showingOpeningHours) {
        rect.origin.y = contentsHeight;
        if (self.scrollView.contentOffset.y + self.scrollView.bounds.size.height < rect.origin.y + rect.size.height + 5) {
            self.scrollView.contentOffset = CGPointMake(0, self.scrollView.contentOffset.y + rect.size.height);
//            self.scrollView.contentOffset = CGPointMake(0, rect.origin.y + rect.size.height + 5 - self.scrollView.bounds.size.height);
        }
    }
    else {
        rect.origin.y = contentsHeight - rect.size.height;
    }
    self.hoursView.frame = rect;
    
    contentsHeight = self.hoursView.frame.origin.y + self.hoursView.frame.size.height + 5;
    
    NSString *offerID = dcStoreDetail[@"offer_id"];
    if (offerID == nil || offerID.length == 0) {
        self.offerControlView.hidden = YES;
    }
    else
    {
        self.offerControlView.hidden = NO;
        self.offerControlView.frame = CGRectMake(0, contentsHeight, contentsWidth, 53);
        self.offerImageView.frame = CGRectMake(0, 0, self.offerImageView.image.size.width, self.offerImageView.image.size.width);
        self.offerImageView.center = CGPointMake(35, self.offerControlView.frame.size.height / 2.0f);
        
        self.offerControlTitleLabel.frame = CGRectMake(65, 0, 300, self.offerControlView.frame.size.height);
        
        self.offerRightArrowImageView.frame = CGRectMake(0, 0, 12, 23);
        self.offerRightArrowImageView.center = CGPointMake(290, self.offerControlView.frame.size.height / 2.0f);
        
        self.offerControlButton.frame = CGRectMake(0, 0, self.offerControlView.frame.size.width, self.offerControlView.frame.size.height);
        contentsHeight = self.offerControlView.frame.origin.y + self.offerControlView.frame.size.height + 5;
    }
    
    self.favoriteView.frame = CGRectMake(0, contentsHeight, contentsWidth, 160);
    self.favoriteTitleLabel.frame = CGRectMake(14, 18, 300, 30);
    self.favoriteDetailLabel.frame = CGRectMake(14, 63, 300, 40);
    
    contentsHeight = self.favoriteView.frame.origin.y + self.favoriteView.frame.size.height;
    
    self.favoriteButton.frame = CGRectMake(0, 0, 74, 74);
    self.favoriteButton.center = CGPointMake(contentsWidth / 2.0f, contentsHeight);
    
    self.favoriteToolTipImageView.frame = CGRectMake(0, 0, self.favoriteToolTipImageView.image.size.width, self.favoriteToolTipImageView.image.size.height);
    self.favoriteToolTipImageView.center =  CGPointMake(contentsWidth / 2.0f, contentsHeight - 60);
    
    self.similarStoresLabel.frame = CGRectMake(14, contentsHeight + 50, 300, 25);

    contentsHeight = self.favoriteView.frame.origin.y + self.favoriteView.frame.size.height + 100;
    
    CGFloat tableHeight = [self tableView:self.tableView numberOfRowsInSection:0] * [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    self.tableView.frame = CGRectMake(0, contentsHeight, contentsWidth, tableHeight);
    
    contentsHeight = self.tableView.frame.origin.y + self.tableView.frame.size.height;
    
    viewRect.size.height = contentsHeight;
    self.scrollView.contentSize = viewRect.size;

}

- (void)openHoursView {
    _showingOpeningHours = !_showingOpeningHours;
    [UIView animateWithDuration:0.5 animations:^{
        if (_showingOpeningHours) {
            self.plusImageView.image = [UIImage imageNamed:@"minus"];
        }
        else {
            self.plusImageView.image = [UIImage imageNamed:@"plus"];
        }
        [self layoutCustomControls];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UITableViewDataSource&Delegate>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 69;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StoreTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"StoreTableViewCell"];
    
    if (cell == nil) {
        cell = [[StoreTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"StoreTableViewCell"];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row % 2 == 0) {
        cell.backgroundColor = UIColorWithRGBA(237, 236, 236, 1);
    }
    else {
        cell.backgroundColor = UIColorWithRGBA(249, 249, 249, 1);
    }
    
    cell.storeCellType = StoreTableViewCellTypeStore;
    
    NSMutableDictionary* store = self.tableData[indexPath.row];
    cell.hasOffer = [store[@"hasoffer"] boolValue];
    cell.isFavorite = [store[@"favorite"] boolValue];
    cell.dcTextLabel.text = store[@"name"];
    cell.favoriteButton.tag = [store[@"id"] integerValue];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    StoreDetailViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"StoreDetailViewController"];
    NSMutableDictionary *store = self.tableData[indexPath.row];
    vc.strStoreID = store[@"id"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        return;
    }
    
    NSString *phone = dcStoreDetail[@"phone"];
    phone = [phone stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [phone length])];

    NSString *phoneNumber = [NSString stringWithFormat:@"tel://%@", phone];
    NSURL *phoneUrl = [NSURL URLWithString:phoneNumber];
   
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Call establishment is not available!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

@end
