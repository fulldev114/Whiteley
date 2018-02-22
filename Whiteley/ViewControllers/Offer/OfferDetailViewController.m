//
//  OfferDetailViewController.m
//  Whiteley
//
//  Created by Alex Hong on 3/26/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import "OfferDetailViewController.h"
#import "OfferTableViewCell.h"
#import "StoreDetailViewController.h"
#import "MapViewController.h"
#import "OpenWebSiteViewController.h"
#import "DCDefines.h"

@interface OfferDetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) UIImageView*        offerImageView;
@property (nonatomic, weak) UITextView*         offerTextView;

@property (nonatomic, weak) UIButton*           btnRedeem;
@property (nonatomic, weak) UIButton*           btnShop;
@property (nonatomic, weak) UIButton*           btnMap;

@property (nonatomic, weak) UILabel*            moreOffersLabel;
@property (nonatomic, weak) UIImageView*        redeemToolTipImageView;

@property (nonatomic, weak) UITableView*        tableView;
@property (nonatomic, strong) NSDictionary*     dcOfferDetail;
@property (nonatomic, strong) NSMutableArray*   dcGreatOffers;
@property (nonatomic, strong) NSMutableArray*   dcRetailStores;

@property (nonatomic, assign) BOOL              bAddRedeemButton;
@property (nonatomic, assign) BOOL              bRedeemed;
@property (nonatomic, strong) NSString          *addButtonType;
@property (nonatomic, strong) NSString          *addButtonText;
@property (nonatomic, strong) NSString          *addButtonLink;

@end

@implementation OfferDetailViewController
@synthesize dcGreatOffers, dcOfferDetail, dcRetailStores;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:NO];

    [CommonUtils showIndicator];
    [self performSelector:@selector(hideWaitingIndicator) withObject:nil afterDelay:10.0f];

    self.title = @"Latest Offers";
    self.view.backgroundColor = UIColorWithRGBA(239, 240, 240, 1);
    NSString *url = [NSString stringWithFormat:@"%@%@&offer_id=%@", DCWEBAPI_GET_OFFERS_DETAIL, deviceTokenID, self.strOfferID];
    
    [DCDefines getHttpAsyncResponse:url withHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        NSData *responseData = data;
        
        if (responseData == nil) {
            [CommonUtils hideIndicator];
            return;
        }

        NSError* errorInfo;
        NSDictionary *dic  = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&errorInfo];
        dcOfferDetail = [dic valueForKey:@"result"];
        dcGreatOffers = dcOfferDetail[@"great_offers"];
        dcRetailStores = dcOfferDetail[@"retailers"];
        
        NSDictionary *dicButton = dcOfferDetail[@"add_button"];
        
        if ([dicButton[@"enabled"] isEqualToString:@"1"]) {
            self.bAddRedeemButton = YES;
            self.addButtonType = dicButton[@"type"];
            self.addButtonText = dicButton[@"text"];
            self.addButtonLink = dicButton[@"link"];
        }
        else
            self.bAddRedeemButton = NO;
   
        if ([dicButton[@"redeemed"] isEqualToString:@"1"])
            self.bRedeemed = YES;
        else
            self.bRedeemed = NO;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIImageView* imageView = nil;
            UITextView* textView = nil;
            UIButton* button = nil;
            UILabel* label = nil;
            
            imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
            imageView.image = [UIImage imageNamed:@"default_thumb_large"];
            [self.scrollView addSubview:imageView];
            self.offerImageView = imageView;
            
            textView = [[UITextView alloc] initWithFrame:CGRectZero];
            [self.scrollView addSubview:textView];
            //    textView.textColor = UIColorWithRGBA(38, 38, 38, 1);
            //    textView.font = [UIFont fontWithName:HFONT_THIN size:16];
            textView.dataDetectorTypes = UIDataDetectorTypeAll;
            textView.editable = NO;
            textView.backgroundColor = [UIColor clearColor];
            textView.scrollEnabled = NO;
            self.offerTextView = textView;
            
            NSString* title = dcOfferDetail[@"name"];
            NSString* text = dcOfferDetail[@"text"];
            
            if (title == nil) {
                title = @"";
            }
            
            if (text == nil) {
                text = @"";
            }
            
            NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n%@", title, text]];
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            [style setLineSpacing:3];
            [attrString addAttributes:@{
                                        NSForegroundColorAttributeName : UIColorWithRGBA(74, 74, 74, 1),
                                        NSFontAttributeName : [UIFont fontWithName:HFONT_REGULAR size:20],
                                        NSParagraphStyleAttributeName : style
                                        } range:[[attrString string] rangeOfString:title]];
            
            [attrString addAttributes:@{
                                        NSForegroundColorAttributeName : UIColorWithRGBA(38, 38, 38, 1),
                                        NSFontAttributeName : [UIFont fontWithName:HFONT_THIN size:16],
                                        NSParagraphStyleAttributeName : style
                                        } range:NSMakeRange(title.length, [[attrString string] length] - title.length)];
            
            
            self.offerTextView.attributedText = attrString;
            
            CGFloat edgeControl = 50;
            CGFloat fontHeight = 17;
            
            // Reddem button
            if (self.bAddRedeemButton) {
                button = [[UIButton alloc] initWithFrame:CGRectZero];
                [self.scrollView addSubview:button];
                [button setBackgroundColor:UIColorWithRGBA(209, 152, 4, 1)];

                UIImage* btnImage;
                NSString *title;

                if ([self.addButtonType isEqualToString:@"redeem"]){
                    btnImage = [UIImage imageNamed:@"btn-icon-offer-r"];
                    
                    if (!self.bRedeemed)
                        title = @"Click here to redeem offer";
                    else {
                        title = @"Offer claimed. Go to store.";
                        [button setBackgroundColor:UIColorWithRGBA(135, 135, 135, 1)];
                    }
                }
                else {
                    btnImage = [UIImage imageNamed:@"btn-icon-offer-c"];
                    title = self.addButtonText;
                }
                
                [button setImage:btnImage forState:UIControlStateNormal];
                [button setTitle:title forState:UIControlStateNormal];
                button.titleLabel.textColor = [UIColor whiteColor];
                button.titleLabel.font = [UIFont fontWithName:HFONT_THIN size:fontHeight];
                button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                button.imageEdgeInsets = UIEdgeInsetsMake(0, (edgeControl - btnImage.size.width) / 2.0f, 0, 0);
                button.titleEdgeInsets = UIEdgeInsetsMake(0, edgeControl - btnImage.size.width, 0, 0);
                [button addTarget:self action:@selector(onClickRedeemButton) forControlEvents:UIControlEventTouchUpInside];
                self.btnRedeem = button;
            }
            
            imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
            [self.scrollView addSubview:imageView];
            imageView.image = [UIImage imageNamed:@"redeem-tooltip"];
            imageView.hidden = YES;
            self.redeemToolTipImageView = imageView;
            
            // Shop button
            if (dcRetailStores.count > 0) {
                button = [[UIButton alloc] initWithFrame:CGRectZero];
                [self.scrollView addSubview:button];
                UIImage* btnImage = [UIImage imageNamed:@"btn-icon-store"];
                [button setBackgroundImage:[UIImage imageNamed:@"purple-button"] forState:UIControlStateNormal];
                [button setImage:btnImage forState:UIControlStateNormal];
                NSString *shopName = [[dcRetailStores objectAtIndex:0] valueForKey:@"name"];
                [button setTitle:shopName forState:UIControlStateNormal];
                button.titleLabel.textColor = [UIColor whiteColor];
                button.titleLabel.font = [UIFont fontWithName:HFONT_THIN size:fontHeight];
                button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                button.imageEdgeInsets = UIEdgeInsetsMake(0, (edgeControl - btnImage.size.width) / 2.0f, 0, 0);
                button.titleEdgeInsets = UIEdgeInsetsMake(0, edgeControl - btnImage.size.width, 0, 0);
                [button addTarget:self action:@selector(onClickShopButton) forControlEvents:UIControlEventTouchUpInside];
                self.btnShop = button;
            }

            button = [[UIButton alloc] initWithFrame:CGRectZero];
            [self.scrollView addSubview:button];
            UIImage* btnImage = [UIImage imageNamed:@"btn-icon-map"];
            [button setBackgroundImage:[UIImage imageNamed:@"purple-button"] forState:UIControlStateNormal];
            [button setImage:btnImage forState:UIControlStateNormal];
            [button setTitle:@"View store on centre map" forState:UIControlStateNormal];
            button.titleLabel.textColor = [UIColor whiteColor];
            button.titleLabel.font = [UIFont fontWithName:HFONT_THIN size:fontHeight];
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            button.imageEdgeInsets = UIEdgeInsetsMake(0, (edgeControl - btnImage.size.width) / 2.0f, 0, 0);
            button.titleEdgeInsets = UIEdgeInsetsMake(0, edgeControl - btnImage.size.width, 0, 0);
            [button addTarget:self action:@selector(onClickMapButton) forControlEvents:UIControlEventTouchUpInside];
            self.btnMap = button;
            
            label = [[UILabel alloc] initWithFrame:CGRectZero];
            [self.scrollView addSubview:label];
            label.text = @"More Great Offers";
            label.font = [UIFont fontWithName:HFONT_THIN size:24];
            label.textColor = UIColorWithRGBA(74, 74, 74, 1);
            self.moreOffersLabel = label;
            
            UITableView* table = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
            [self.scrollView addSubview:table];
            table.dataSource = self;
            table.delegate = self;
            table.scrollEnabled = NO;
            table.separatorStyle = UITableViewCellSeparatorStyleNone;
            self.tableView = table;
            
            [self layoutCustomControls];
            [CommonUtils hideIndicator];

        });
        
    }];
    
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hideWaitingIndicator
{
    [CommonUtils hideIndicator];
}

- (void)onClickShopButton
{
    NSString *storeID = [[dcRetailStores objectAtIndex:0] valueForKey:@"id"];
    StoreDetailViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"StoreDetailViewController"];
    vc.strStoreID = storeID;
    [self.navigationController pushViewController:vc animated:YES];

}

- (void)onClickMapButton
{
    NSDictionary *store = [dcRetailStores objectAtIndex:0];
    
    MapViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
    controller.m_bSectionFacilites = NO;
    controller.m_sSelectedShopID = store[@"id"];
    controller.title = @"Centre Map";

    NSString *floorName = store[@"location"];
    
    if ([floorName isEqualToString:@"G Lower Mall"])
        controller.m_nCentureFloor = LOWER_MALL;
    else if ([floorName isEqualToString:@"1 Upper Mall"])
        controller.m_nCentureFloor = UPPER_MALL;
    else
        controller.m_nCentureFloor = FOOD_COURT;
    
    NSMutableArray *aryController = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
    NSInteger count = aryController.count;
    
    if ( count > 5 )
    {
        for (int i = 1; i < count - 4; i++) {
            [aryController removeObjectAtIndex:i];
        }
        [self.navigationController setViewControllers:(NSArray*)aryController];
    }

    [self.navigationController pushViewController:controller animated:YES];

}

- (void)onClickRedeemButton {
    if ([self.addButtonType isEqualToString:@"redeem"]){
        if (!self.bRedeemed) {
            [self.btnRedeem setBackgroundColor:UIColorWithRGBA(135, 135, 135, 1)];
            NSString *title = @"Offer claimed. Go to store.";
            [self.btnRedeem setTitle:title forState:UIControlStateNormal];
            
            NSString *url = [NSString stringWithFormat:@"%@%@&offer_id=%@", DCWEBAPI_SET_REDEEM, deviceTokenID, self.strOfferID];
            [DCDefines getHttpAsyncResponse:url withHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            }];
            
            self.bRedeemed = YES;
        }
        else {
         
            if (!self.redeemToolTipImageView.hidden) 
                return;
            
            [self.redeemToolTipImageView.layer removeAllAnimations];
            
            self.redeemToolTipImageView.hidden = NO;
            self.redeemToolTipImageView.alpha = 1;
            
            self.redeemToolTipImageView.transform = CGAffineTransformMakeScale(0.0, 1.0);
            
            [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.redeemToolTipImageView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                if (finished) {
                }
            }];
            
            [UIView animateWithDuration:0.5 delay:2.5 options:UIViewAnimationOptionTransitionNone animations:^{
                self.redeemToolTipImageView.alpha = 0;
            } completion:^(BOOL finished) {
                self.redeemToolTipImageView.alpha = 1;
                self.redeemToolTipImageView.hidden = YES;
            }];
        }
    }
    else {
        NSString *url = [NSString stringWithFormat:@"%@%@&offer_id=%@", DCWEBAPI_SET_REDEEM, deviceTokenID, self.strOfferID];
        [DCDefines getHttpAsyncResponse:url withHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        }];
        
        OpenWebSiteViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"OpenWebSiteViewController"];
        controller.title = @"Offer Detail";
        controller.strURL = self.addButtonLink;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)layoutCustomControls {
    CGFloat contentsHeight = 0;
    CGFloat contentsWidth = 320;
    
    CGRect viewRect = CGRectMake(0, 0, contentsWidth, 568);
    CGRect rect;

    self.offerImageView.frame = CGRectMake(0, 0, contentsWidth, 148);

    [self setImageURL:self.offerImageView url:dcOfferDetail[@"image"]];

    contentsHeight += self.offerImageView.frame.size.height;
    
    if (self.offerTextView.text.length > 0) {
        rect.size.width = contentsWidth - 20;
        self.offerTextView.frame = rect;
        [self.offerTextView sizeToFit];
        rect = self.offerTextView.frame;
        rect.origin.x = 10;
        rect.origin.y = contentsHeight +10;
        self.offerTextView.frame = rect;
        
        contentsHeight = self.offerTextView.frame.origin.y + self.offerTextView.frame.size.height + 10;
    }
    
    rect.size.width = 298;
    rect.size.height = 55;
    rect.origin.x = (contentsWidth - rect.size.width) / 2.0f;
    
    if (self.bAddRedeemButton) {
        self.redeemToolTipImageView.frame = CGRectMake(0, 0, self.redeemToolTipImageView.image.size.width, self.redeemToolTipImageView.image.size.height);
        self.redeemToolTipImageView.center =  CGPointMake(contentsWidth / 2.0f, contentsHeight - 24);

        rect.origin.y = contentsHeight + 15;
        self.btnRedeem.frame = rect;
        contentsHeight = self.btnRedeem.frame.origin.y + self.btnRedeem.frame.size.height;
    }
    
    if (dcRetailStores.count > 0) {
        rect.origin.y = contentsHeight + 15;
        self.btnShop.frame = rect;
        contentsHeight = self.btnShop.frame.origin.y + self.btnShop.frame.size.height;
        
        rect.origin.y = contentsHeight + 15;
        self.btnMap.frame = rect;
        contentsHeight = self.btnMap.frame.origin.y + self.btnMap.frame.size.height;
    }
    
    rect.origin.x = 10;
    rect.origin.y = contentsHeight;
    rect.size.width = contentsWidth - 20;
    rect.size.height = 100;
    self.moreOffersLabel.frame = rect;
    contentsHeight = self.moreOffersLabel.frame.origin.y + self.moreOffersLabel.frame.size.height;
    
    CGFloat tableHeight = [self tableView:self.tableView numberOfRowsInSection:0] * [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    self.tableView.frame = CGRectMake(0, contentsHeight, contentsWidth, tableHeight);
    
    contentsHeight = self.tableView.frame.origin.y + self.tableView.frame.size.height;
    
    viewRect.size.height = contentsHeight;
    self.scrollView.contentSize = viewRect.size;

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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dcGreatOffers.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 190;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OfferTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"OfferTableViewCell"];
    
    if (cell == nil) {
        cell = [[OfferTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"OfferTableViewCell"];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row % 2 == 0) {
        cell.backgroundColor = UIColorWithRGBA(237, 236, 236, 1);
    }
    else {
        cell.backgroundColor = UIColorWithRGBA(249, 249, 249, 1);
    }
    NSDictionary *dic = [dcGreatOffers objectAtIndex:indexPath.row];
    cell.dcShopNameLabel.text = dic[@"shop_name"];
    cell.dcOfferTitleLabel.text = dic[@"offer_name"];
    cell.dcOfferDetailLabel.text = dic[@"offer_detail"];
    cell.imageURL = dic[@"offer_image"];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OfferDetailViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OfferDetailViewController"];
    NSDictionary *dic = [dcGreatOffers objectAtIndex:indexPath.row];
    vc.strOfferID = dic[@"id"];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
