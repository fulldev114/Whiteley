//
//  HeaderView.m
//  Whiteley
//
//  Created by Alex Hong on 3/20/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import "HeaderView.h"
#import "UIImage+ImageEffects.h"
#import "DCDefines.h"
#import "StoreListViewController.h"
#import "MapViewController.h"
#import "OfferListViewController.h"
#import "OfferDetailViewController.h"
#import "EventListViewController.h"
#import "EventDetailViewController.h"
#import "HereViewController.h"
#import "CardViewController.h"
#import "MonsterFirstViewController.h"
#import "OpenWebSiteViewController.h"

#define kDefaultHeaderFrame CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)

static CGFloat kParallaxDeltaFactor = 0.5f;
//static CGFloat kLabelPaddingDist = 8.0f;

@interface HeaderView () <UIScrollViewDelegate>

@property (nonatomic, assign) BOOL          m_bBlurFlag;
@property (nonatomic, assign) BOOL          m_bEnableScroll;

@end

@implementation HeaderView
@synthesize aryHomeCarousel, m_bEnableScroll;

+ (id)headerViewWithData:(NSMutableArray*)aryData Delegate:(UIViewController*)delegate
{
    HeaderView *headerView = [[HeaderView alloc] initWithFrame:CGRectMake(0, 0, 320, 202)];
    headerView.homeController = delegate;
    [headerView initViewData:aryData];

    return headerView;
}

- (void)initViewData:(NSMutableArray*)data
{
    self.imageScroller = [[UIScrollView alloc] initWithFrame:self.bounds];
    [self.imageScroller setShowsHorizontalScrollIndicator:NO];
    self.imageScroller.delegate = self;
    [self addSubview:self.imageScroller];
    [self setAryHomeCarousel:data];

}
- (void)awakeFromNib {
}

- (void) setAryHomeCarousel:(NSMutableArray *)aryCarousel
{
    aryHomeCarousel = [[NSMutableArray alloc] init];

    for(UIView *subView in self.imageScroller.subviews)
        [subView removeFromSuperview];
    
    [self.pageControl removeFromSuperview];
    
    NSInteger image_index = 0;
    
    for (int i = 0; i < aryCarousel.count; i++) {
        
        NSDictionary *dic = [aryCarousel objectAtIndex:i];
        if ([dic[@"status"] isEqual:@"inactive"])
            continue;
        
        NSString *strImage = [NSString stringWithFormat:@"carousel_%@.png", dic[@"id"]];
        NSString *documentFolderPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString* file_name = [documentFolderPath stringByAppendingPathComponent:strImage];
        if ([[NSFileManager defaultManager] fileExistsAtPath:file_name]) {
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfFile:file_name]];
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.imageScroller.frame) * image_index, 0, CGRectGetWidth(self.imageScroller.frame), CGRectGetHeight(self.imageScroller.frame))];
            imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            imageView.image = image;
            imageView.tag = image_index;
            UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickScrollImageView:)];
            [imageView addGestureRecognizer:gesture];
            [imageView setUserInteractionEnabled:YES];
            [self.imageScroller addSubview:imageView];
            image_index++;
            [aryHomeCarousel addObject:dic];
        }
    }
    
    if (aryHomeCarousel.count == 0) {
        UIImage *image = [UIImage imageNamed:@"carousel_default"];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.imageScroller.frame) * image_index, 0, CGRectGetWidth(self.imageScroller.frame), CGRectGetHeight(self.imageScroller.frame))];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.image = image;
        imageView.tag = 0;
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickScrollImageView:)];
        [imageView addGestureRecognizer:gesture];
        [imageView setUserInteractionEnabled:YES];
        [self.imageScroller addSubview:imageView];
        image_index++;
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setValue:@"1" forKey:@"id"];
        [dic setValue:@"app" forKey:@"link_type"];
        [dic setValue:@"store" forKey:@"link_app"];
        [dic setValue:@"" forKey:@"link_url"];
        [aryHomeCarousel addObject:dic];

    }
    
    self.imageScroller.contentSize = CGSizeMake(CGRectGetWidth(self.imageScroller.frame) * image_index, CGRectGetHeight(self.imageScroller.frame));
    self.imageScroller.pagingEnabled = YES;
    self.imageScroller.delegate = self;
    
    TAPageControl* pageControl = [[TAPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageScroller.frame) - 25, CGRectGetWidth(self.imageScroller.frame), 8)];
    pageControl.numberOfPages   = image_index;
    // Custom dot view with image
    pageControl.dotSize = CGSizeMake(8, 8);
    pageControl.dotImage        = [UIImage imageNamed:@"carousel-dot-inactive"];
    pageControl.currentDotImage = [UIImage imageNamed:@"carousel-dot-active"];
    pageControl.spacingBetweenDots = 9;
    pageControl.userInteractionEnabled = NO;

    if ( aryHomeCarousel.count > 1 )
        [self addSubview:pageControl];
    
    self.pageControl = pageControl;
    
    self.bluredImageView = [[UIImageView alloc] initWithFrame:self.imageScroller.frame];
    self.bluredImageView.autoresizingMask = self.imageScroller.autoresizingMask;
    self.bluredImageView.alpha = 0.0f;
    [self.imageScroller addSubview:self.bluredImageView];
    
    [self performSelector:@selector(refreshBlurViewForNewImage) withObject:nil afterDelay:0.3f];

    self.m_bBlurFlag = NO;
}

- (void) onClickScrollImageView:(UITapGestureRecognizer*)sender
{
    NSInteger index = sender.view.tag;
    
    NSDictionary *dicCarousel = [aryHomeCarousel objectAtIndex:index];
   
    [DCDefines getHttpAsyncResponse:DCWEBAPI_GET_HOME_CAROUSEL withHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSData *responseData = data;
        
        if (responseData == nil) {
            return;
        }
        
        NSError* errorInfo;
        NSDictionary *dic  = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&errorInfo];
        NSMutableArray *aryCarousel = [dic valueForKey:@"result"];
        
        for (int i = 0; i < aryCarousel.count; i++) {
            NSDictionary *dic = aryCarousel[i];
            if ([dicCarousel[@"id"] isEqualToString:dic[@"id"]]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([dic[@"link_type"] isEqualToString:@"app"]) {
                        NSString *section = dic[@"link_app"];
                        UIViewController *vc = nil;
                        
                        if ([section isEqualToString:@"store"]) {
                            vc = [self.homeController.storyboard instantiateViewControllerWithIdentifier:@"StoreListViewController"];
                            StoreListViewController* storeVC = (StoreListViewController*)vc;
                            storeVC.listType = DCStoresListTypeStore;
                            vc.title = @"Our Stores";
                        }
                        else if ([section isEqualToString:@"map"])
                        {
                            vc = [self.homeController.storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
                            MapViewController *controller = (MapViewController*)vc;
                            controller.m_bSectionFacilites = NO;
                            controller.m_nCentureFloor = LOWER_MALL;
                            controller.m_sSelectedShopID = @"";
                            vc.title = @"Centre Map";
                        }
                        else if ([section isEqualToString:@"offers"])
                        {
                            vc = [self.homeController.storyboard instantiateViewControllerWithIdentifier:@"OfferListViewController"];
                            vc.title = @"Latest Offers";
                        }
                        else if ([section isEqualToString:@"offer_id"])
                        {
                            OfferDetailViewController* offerVC = [self.homeController.storyboard instantiateViewControllerWithIdentifier:@"OfferDetailViewController"];
                            offerVC.strOfferID = dic[@"link_id"];
                            vc = offerVC;
                        }
                        else if ([section isEqualToString:@"events"])
                        {
                            vc = [self.homeController.storyboard instantiateViewControllerWithIdentifier:@"EventListViewController"];
                            vc.title = @"Latest Events";
                        }
                        else if ([section isEqualToString:@"event_id"])
                        {
                            EventDetailViewController* eventVC = [self.homeController.storyboard instantiateViewControllerWithIdentifier:@"EventDetailViewController"];
                            eventVC.strEventID = dic[@"link_id"];
                            vc = eventVC;
                            vc.title = @"Latest Events";
                        }
                        else if ([section isEqualToString:@"food"])
                        {
                            vc = [self.homeController.storyboard instantiateViewControllerWithIdentifier:@"StoreListViewController"];
                            StoreListViewController *storeVC = (StoreListViewController*)vc;
                            storeVC.listType = DCFoodOutletsTypeCategory;
                            vc.title = @"Food Outlets";
                        }
                        else if ([section isEqualToString:@"here"])
                        {
                            vc = [self.homeController.storyboard instantiateViewControllerWithIdentifier:@"HereViewController"];
                            vc.title = @"Getting Here";
                        }
                        else if ([section isEqualToString:@"facilities"])
                        {
                            vc = [self.homeController.storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
                            MapViewController *controller = (MapViewController*)vc;
                            controller.m_bSectionFacilites = YES;
                            controller.m_nCentureFloor = LOWER_MALL;
                            controller.m_sSelectedShopID = @"";
                            vc.title = @"Our Facilities";
                        }
                        else if ([section isEqualToString:@"game"])
                        {
                            vc = [self.homeController.storyboard instantiateViewControllerWithIdentifier:@"MonsterFirstViewController"];
                        }
                        else if ([section isEqualToString:@"cinema"])
                        {
                            vc = [self.homeController.storyboard instantiateViewControllerWithIdentifier:@"OpenWebSiteViewController"];
                            OpenWebSiteViewController *controller = (OpenWebSiteViewController*) vc;
                            controller.title = @"Cinema Times";
                            controller.strURL = @"http://www1.cineworld.co.uk/cinemas/whiteley";
                        }
                        else if ([section isEqualToString:@"rock"])
                        {
                            vc = [self.homeController.storyboard instantiateViewControllerWithIdentifier:@"OpenWebSiteViewController"];
                            OpenWebSiteViewController *controller = (OpenWebSiteViewController*) vc;
                            controller.title = @"Rock Up";
                            controller.strURL = @"http://www.rock-up.co.uk/book-online/";
                        }
                        else if ([section isEqualToString:@"sign"])
                        {
                            vc = [self.homeController.storyboard instantiateViewControllerWithIdentifier:@"OpenWebSiteViewController"];
                            OpenWebSiteViewController *controller = (OpenWebSiteViewController*) vc;
                            controller.title = @"Sign Up";
                            controller.strURL = @"http://eepurl.com/JEbsb";
                        }
                        else if ([section isEqualToString:@"survey"])
                        {
                            vc = [self.homeController.storyboard instantiateViewControllerWithIdentifier:@"FeedbackViewController"];
                        }
                        else
                            return;
                        
                        [self.homeController.navigationController pushViewController:vc animated:YES];
                    }
                    else
                    {
                        OpenWebSiteViewController *vc = [self.homeController.storyboard instantiateViewControllerWithIdentifier:@"OpenWebSiteViewController"];
                        vc.title = @"Opening Site";
                        vc.strURL = dic[@"link_url"];
                        [self.homeController.navigationController pushViewController:vc animated:YES];
                    }
                });
            }
        }
    }];
    
    
}

#pragma mark - ScrollView delegate

- (void)layoutHeaderViewForScrollViewOffset:(CGPoint)offset
{
    CGRect frame = self.imageScroller.frame;
    
    if (offset.y >= 0)
    {
        if (frame.origin.y == 0 && !self.m_bBlurFlag) {
            //[self refreshBlurViewForNewImage];
            self.m_bBlurFlag = YES;
        }

        frame.origin.y = MAX(offset.y *kParallaxDeltaFactor, 0);
        self.imageScroller.frame = frame;
        self.bluredImageView.alpha =   1 / kDefaultHeaderFrame.size.height * offset.y * 2;
        self.clipsToBounds = YES;
    }
}

- (UIImage *)screenShotOfView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(kDefaultHeaderFrame.size, YES, 0.0);
    [self drawViewHierarchyInRect:kDefaultHeaderFrame afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)refreshBlurViewForNewImage
{
    UIImage *screenShot = [self screenShotOfView:self.imageScroller];
    screenShot = [screenShot applyBlurWithRadius:5 tintColor:[UIColor colorWithWhite:0.6 alpha:0.2] saturationDeltaFactor:1.0 maskImage:nil];
    self.bluredImageView.image = screenShot;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!m_bEnableScroll)
    {
        CGPoint point = self.imageScroller.contentOffset;
        point.x = 320 * self.pageControl.currentPage ;
        [self.imageScroller setContentOffset:point];
    }

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger pageIndex = scrollView.contentOffset.x / CGRectGetWidth(scrollView.frame);
    
    self.pageControl.currentPage = pageIndex;
    
    if ( m_bEnableScroll)
    {
        CGRect frame = self.bluredImageView.frame;
        frame.origin.x = 320 * self.pageControl.currentPage;
        [self.bluredImageView setFrame:frame];
        [self refreshBlurViewForNewImage];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    CGRect rect = self.imageScroller.frame;
    if (rect.origin.y == 0)
        m_bEnableScroll = YES;
    else
        m_bEnableScroll = NO;

}

@end
