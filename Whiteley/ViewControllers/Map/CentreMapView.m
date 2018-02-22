//
//  CentreMapView.m
//  Video Zoom
//
//  Created by Alex Hong on 05/10/2014.
//  Copyright (c) 2014 CaptureProof. All rights reserved.
//

// map size = 1/6,      dic facilities size = 1/8

#import "StoreDetailViewController.h"
#import "CentreMapView.h"
#import "DCDefines.h"
#import "DXPopover.h"

@interface CentreMapView ()
{
    CAShapeLayer            *highlightedLayer;
    BOOL                    highlighted;
    NSMutableArray          *aryShopLocation;
    NSMutableArray          *aryShopCentre;
    NSMutableArray          *aryShopAngle;
    NSMutableArray          *aryShopFrame;
    NSMutableArray          *aryShopLogoImageView;
    NSMutableDictionary     *dicFacilitesLocation;
    NSMutableArray          *allFacilitesLocation;
    NSArray*                aryFacilites;
    NSArray*                dcCategories;
    CGPoint                 storePoint;
    BOOL                    hasOffer;
    BOOL                    isFavourite;
    CGPoint                 init_offset;
    NSInteger               selectedShopIndex;
    NSInteger               facilitiesSize;
    BOOL                    facilitiesItemSelectedFlag;
    NSInteger               m_nSelectedFloor;
    NSMutableArray          *aryLowerFloorLogo;
    NSMutableArray          *aryUpperFloorLogo;
    NSMutableArray          *aryFoodFloorLogo;
    CGFloat                 map_scale;

}
@property (nonatomic, retain) DXPopover *popover;
@property (nonatomic, strong) UIButton  *btnFavourite;
@property (nonatomic, strong) UIButton  *btnStoreName;
@property (nonatomic, strong) UIButton  *btnStorePage;
@property (nonatomic, retain) UIView    *viewFacTooltip;
@property (nonatomic, strong) UIButton  *btnFacImage;
@property (nonatomic, strong) UILabel   *lblFacName;
@end

@implementation CentreMapView
@synthesize viewTooltip, viewFacTooltip;
@synthesize btnFavourite, btnStoreName, btnStorePage, btnFacImage, lblFacName;
#pragma mark View Initializer

- (id)initWithFrame:(CGRect)frame parentController:(UIViewController*)parent andImage:(UIImage *)image{

    self = [super init];
    
    if (self) {
        self.rootViewController = (MapViewController*)parent;
        
        self.frame = frame;
        self.delegate = self;
        [self setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
        self.imageView.image = image;
        self.imageView.userInteractionEnabled = YES;
        //self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        //[self.imageView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];

        [self addSubview:self.imageView];

        self.maximumZoomScale = MAX_SCALE;
        self.minimumZoomScale = MIN_SCALE;

        map_scale = 8;
        [self setShopPosition];
        [self setShopCentreAngle];
        
        highlightedLayer = [CAShapeLayer layer];
        [highlightedLayer setBounds:self.imageView.frame];
        [highlightedLayer setPosition:CGPointMake(self.imageView.frame.size.width/2, self.imageView.frame.size.height/2)];
        [highlightedLayer setFillColor:[[UIColor colorWithRed:223/255.0f green:181/255.0 blue:53/255.0 alpha:1.0f] CGColor]];
        [highlightedLayer setHidden:YES];
        [[self.imageView layer] addSublayer:highlightedLayer];
        
        m_nSelectedFloor = self.rootViewController.m_nCentureFloor;
        [self setFacilitesInfo:m_nSelectedFloor];

        // ---------- Shop Name Tooltip -------------
        viewTooltip = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 240, 70)];
        [viewTooltip setBackgroundColor:[UIColor clearColor]];
        [viewTooltip setHidden:YES];
        
        btnFavourite = [[UIButton alloc] initWithFrame:CGRectMake(15, 6, 45, 45)];
        [btnFavourite addTarget:self action:@selector(onClickFavouriteButton:) forControlEvents:UIControlEventTouchUpInside];
        [btnFavourite setUserInteractionEnabled:YES];
        
        btnStoreName = [[UIButton alloc] initWithFrame:CGRectMake(55, 17, 160, 20)];
        btnStoreName.titleLabel.font = [UIFont fontWithName:HFONT_REGULAR size:15.0f];;
        [btnStoreName setTitleColor:UIColorWithRGBA(74, 74, 74, 1) forState:UIControlStateNormal];
        [btnStoreName addTarget:self action:@selector(onClickStorePageButton:) forControlEvents:UIControlEventTouchUpInside];
        
        btnStorePage = [[UIButton alloc] initWithFrame:CGRectMake(206, 19, 32, 22)];
        [btnStorePage setImage:[UIImage imageNamed:@"icon-disclosure-arrow"] forState:UIControlStateNormal];
        [btnStorePage addTarget:self action:@selector(onClickStorePageButton:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView *backImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 240, 70)];
        [backImgView setImage:[UIImage imageNamed:@"dc_map_alert_name"]];
        
        [viewTooltip addSubview:backImgView];
        [viewTooltip addSubview:btnFavourite];
        [viewTooltip addSubview:btnStoreName];
        [viewTooltip addSubview:btnStorePage];
        [viewTooltip setUserInteractionEnabled:YES];
        [viewTooltip setAlpha:0.0f];
        [self addSubview:viewTooltip];
        
        // ---------- Facilities Name Tooltip -------------
        viewFacTooltip = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 70)];
        [viewFacTooltip setBackgroundColor:[UIColor clearColor]];
        [viewFacTooltip setHidden:YES];
        
        btnFacImage = [[UIButton alloc] initWithFrame:CGRectMake(14, 13, 30, 30)];
        [btnFacImage setUserInteractionEnabled:YES];
        
        lblFacName = [[UILabel alloc] initWithFrame:CGRectMake(44, 17, 155, 20)];
        lblFacName.font = [UIFont fontWithName:HFONT_REGULAR size:15.0f];
        lblFacName.textColor = UIColorWithRGBA(74, 74, 74, 1);
        lblFacName.textAlignment = NSTextAlignmentCenter;
        
        backImgView = [[UIImageView alloc] initWithFrame:viewFacTooltip.frame];
        [backImgView setImage:[UIImage imageNamed:@"dc_map_alert_name"]];
        
        [viewFacTooltip addSubview:backImgView];
        [viewFacTooltip addSubview:btnFacImage];
        [viewFacTooltip addSubview:lblFacName];
        [viewFacTooltip setUserInteractionEnabled:YES];
        [viewFacTooltip setAlpha:0.0f];
        [self addSubview:viewFacTooltip];
        //-------------------------------------------------

        self.popover = [DXPopover new];
        facilitiesItemSelectedFlag = NO;
        
        //------------ Logo Image ------------
        aryLowerFloorLogo = [[NSMutableArray alloc] init];
        aryUpperFloorLogo = [[NSMutableArray alloc] init];
        aryFoodFloorLogo = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void) setHiddenHighlitedView
{
    viewFacTooltip.hidden = YES;
    viewTooltip.hidden = YES;
}

- (void) showSelectedShop:(NSInteger) index
{
    selectedShopIndex = index;
    [self showShopUnitTooltip:index searchFlag:YES];
}

- (void)viewDidLayoutSubviews {
    
    self.contentSize = self.imageView.bounds.size;
}

- (void) setFacilitesInfo:(NSInteger) floor_index
{
    for (int i = (int)self.imageView.subviews.count-1; i >= 0; i--) {
        UIView *button = [self.imageView.subviews objectAtIndex:i];
        if (([button isKindOfClass:[UIButton class]] || [button isKindOfClass:[SCGIFImageView class]]) && button.hidden == NO) {
            [button removeFromSuperview];
        }
    }
    allFacilitesLocation = [[NSMutableArray alloc] init];
    dicFacilitesLocation = [[NSMutableDictionary alloc] init];
    
    // Facilities
    // atm
    NSMutableArray *points = [[NSMutableArray alloc] init];
    [points addObject:[Coordinate coordinateWithX:830 Y:2220]];
    [points addObject:[Coordinate coordinateWithX:1500 Y:1450]];
    [dicFacilitesLocation setValue:points forKey:@"dc_atm_p"];
    
    // car parking
    points = [[NSMutableArray alloc] init];
    [points addObject:[Coordinate coordinateWithX:556 Y:832]];
    [points addObject:[Coordinate coordinateWithX:650 Y:2278]];
    [points addObject:[Coordinate coordinateWithX:1172 Y:1213]];
    [points addObject:[Coordinate coordinateWithX:1636 Y:1181]];
    [points addObject:[Coordinate coordinateWithX:1770 Y:2335]];
    //[points addObject:[Coordinate coordinateWithX:906 Y:3258]];
    //[points addObject:[Coordinate coordinateWithX:1544 Y:3338]];
    [dicFacilitesLocation setValue:points forKey:@"dc_park_p"];
    
    // toilet
    points = [[NSMutableArray alloc] init];
    [points addObject:[Coordinate coordinateWithX:860 Y:2220]];
    [dicFacilitesLocation setValue:points forKey:@"dc_toilet_p"];
    
    points = [[NSMutableArray alloc] init];
    [points addObject:[Coordinate coordinateWithX:1220 Y:1660]];
    [dicFacilitesLocation setValue:points forKey:@"dc_info_p"];  // info
    
    points = [[NSMutableArray alloc] init];
    [points addObject:[Coordinate coordinateWithX:885 Y:2220]];
    [points addObject:[Coordinate coordinateWithX:1865 Y:1440]];
    [dicFacilitesLocation setValue:points forKey:@"dc_photo_p"];  // photo

    points = [[NSMutableArray alloc] init];
    [points addObject:[Coordinate coordinateWithX:1559 Y:2661]];
    [dicFacilitesLocation setValue:points forKey:@"dc_gift_p"]; // gift
    
    points = [[NSMutableArray alloc] init];
    [points addObject:[Coordinate coordinateWithX:870 Y:2185]];
    [dicFacilitesLocation setValue:points forKey:@"dc_lost_p"]; // lost
    
    // iBeacon
    /*
    points = [[NSMutableArray alloc] init];
    [points addObject:[Coordinate coordinateWithX:1074 Y:1424]];
    [points addObject:[Coordinate coordinateWithX:1347 Y:2065]];
    [points addObject:[Coordinate coordinateWithX:1034 Y:2265]];
    [points addObject:[Coordinate coordinateWithX:1322 Y:2472]];
    [points addObject:[Coordinate coordinateWithX:1470 Y:2863]];
    [dicFacilitesLocation setValue:points forKey:@"dc_ibeacon_p"];
    */
    [allFacilitesLocation addObject:dicFacilitesLocation];

    dicFacilitesLocation = [allFacilitesLocation objectAtIndex:self.rootViewController.m_nCentureFloor];
    
    NSMutableArray* tempList = [NSMutableArray array];
    
    NSDictionary *store = [NSDictionary dictionaryWithObjectsAndKeys:@"ATM", @"name", @"dc_atm_p", @"image", @"dc_atm_wa", @"image_sel", nil];
    [tempList addObject:store];
    
    store = [NSDictionary dictionaryWithObjectsAndKeys:@"Car Parking", @"name", @"dc_park_p", @"image", @"dc_park_wa", @"image_sel", nil];
    [tempList addObject:store];
    
    store = [NSDictionary dictionaryWithObjectsAndKeys:@"Information Pod", @"name", @"dc_info_p", @"image", @"dc_info_wa", @"image_sel", nil];
    [tempList addObject:store];
    
    //store = [NSDictionary dictionaryWithObjectsAndKeys:@"iBeacon Locations", @"name", @"dc_ibeacon_p", @"image", @"dc_ibeacon_wa", @"image_sel", nil];
    //[tempList addObject:store];
    
    store = [NSDictionary dictionaryWithObjectsAndKeys:@"Photo Booths", @"name", @"dc_photo_p", @"image", @"dc_photo_wa", @"image_sel", nil];
    [tempList addObject:store];
    
    store = [NSDictionary dictionaryWithObjectsAndKeys:@"Toilets/Baby Change", @"name", @"dc_toilet_p", @"image", @"dc_toilet_wa", @"image_sel", nil];
    [tempList addObject:store];
    
    store = [NSDictionary dictionaryWithObjectsAndKeys:@"Lost & Found", @"name", @"dc_lost_p", @"image", @"dc_lost_wa", @"image_sel", nil];
    [tempList addObject:store];
    
    store = [NSDictionary dictionaryWithObjectsAndKeys:@"Phone Charging", @"name", @"dc_charge_p", @"image", @"dc_charge_wa", @"image_sel", nil];
    [tempList addObject:store];
    
    aryFacilites = tempList;
    CGFloat scale = 1.0;
#pragma makr Facilities Size
    facilitiesSize = 7;
    for (int f_index = 0; f_index < aryFacilites.count; f_index++) {
        NSDictionary *dic = [aryFacilites objectAtIndex:f_index];
        NSString *f_id = [dic valueForKey:@"image"];
        NSMutableArray *aryPoint = [dicFacilitesLocation objectForKey:f_id];
        if (aryPoint.count > 0) {
            
//            if ([f_id isEqualToString:@"dc_ibeacon_p"]) {
//                NSDictionary *dic = [[NSUserDefaults standardUserDefaults] valueForKey:WHITELEY_NOTIFY_USER_DETECT];
//                
//                NSString *filePath = [[NSBundle mainBundle]
//                                      pathForResource:@"dc_map_fac_ibeacon" ofType:@"gif"];
//                NSData *myGif = [NSData dataWithContentsOfFile:filePath];
//                for (int p_index = 0; p_index < aryPoint.count; p_index++) {
//                    Coordinate *p = [aryPoint objectAtIndex:p_index];
//                    SCGIFImageView *animateSearchImgView = [[SCGIFImageView alloc] initWithFrame:CGRectMake(0, 0, facilitiesSize * scale * 2, facilitiesSize * scale * 2)];
//                    [animateSearchImgView setCenter:CGPointMake(p.x * scale, p.y * scale)];
//                    [animateSearchImgView setData:myGif];
//                    NSInteger tag = (f_index + 1 ) * 10 + p_index + 1;
//                    animateSearchImgView.tag = tag;
//                    [animateSearchImgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickFacItemButton:)]];
//                    [animateSearchImgView setUserInteractionEnabled:YES];
//                    [self.imageView addSubview:animateSearchImgView];
//                    
//                    if (dic == nil)
//                        animateSearchImgView.hidden = YES;
//                    else
//                        animateSearchImgView.hidden = NO;
//                }
//            }
//            else
            {
                UIImage *image = [UIImage imageNamed:f_id];
                
                for (int p_index = 0; p_index < aryPoint.count; p_index++) {
                    Coordinate *p = [aryPoint objectAtIndex:p_index];
                    UIButton *imgButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, facilitiesSize * scale / 2, facilitiesSize * scale / 2) ];
                    [imgButton setCenter:CGPointMake(p.x * scale / map_scale, p.y * scale / map_scale)];
                    [imgButton setImage:image forState:UIControlStateNormal];
                    NSInteger tag = (f_index + 1 ) * 10 + p_index + 1;
                    imgButton.tag = tag;
                    [imgButton addTarget:self action:@selector(onClickFacItemButton:) forControlEvents:UIControlEventTouchUpInside];
                    [self.imageView addSubview:imgButton];
                }
            }
        }
    }

}

#pragma mark Show Facilities Tooltip
- (void) onClickFacItemButton:(id) sender
{
    NSInteger tag;
    CGRect senderRect;
    CGPoint senderCenter;
   // NSDictionary *dicHereCenter = [[NSUserDefaults standardUserDefaults] valueForKey:WHITELEY_NOTIFY_USER_DETECT];
    
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton*)sender;
        tag = button.tag;
        senderRect = button.frame;
        senderCenter = button.center;
    }
    else
    {
        UITapGestureRecognizer *gesture = (UITapGestureRecognizer*)sender;
        tag = gesture.view.tag;
        senderRect = gesture.view.frame;
        senderCenter = gesture.view.center;
    }
    
    NSInteger f_index = tag / 10 - 1;
    CGPoint offsetPoint = self.contentOffset;
    
    viewTooltip.hidden = YES;
    highlightedLayer.hidden = YES;

    if (f_index < 0)
        return;
    
    NSDictionary *dic = [aryFacilites objectAtIndex:f_index];
    NSString *f_id = [dic valueForKey:@"image"];
    NSMutableArray *aryPoint = [dicFacilitesLocation objectForKey:f_id];
    
  
    if ( aryPoint != nil && aryPoint.count == 0 )
    {
        NSInteger haveFacFloor = -1;
        NSInteger selectedFloor = self.rootViewController.m_nCentureFloor;
        
        if (selectedFloor == FOOD_COURT) {
            for (int i = 1; i >= 0; i--) {
                NSMutableDictionary *dic = [allFacilitesLocation objectAtIndex:i];
                aryPoint = [dic objectForKey:f_id];
                
                if (aryPoint.count != 0) {
                    haveFacFloor = i;
                    break;
                }
            }
            
        }
        else
        {
            for (int i = 0; i < 3; i++) {
                if (selectedFloor == i)
                    continue;
                
                NSMutableDictionary *dic = [allFacilitesLocation objectAtIndex:i];
                aryPoint = [dic objectForKey:f_id];
                
                if (aryPoint.count != 0) {
                    haveFacFloor = i;
                    break;
                }
            }
        }
        
        if (haveFacFloor == -1)
        {
            if (facilitiesItemSelectedFlag) {
                for (int i = 0; i < aryFacilites.count; i++) {
                    NSDictionary *dic = [aryFacilites objectAtIndex:i];
                    UIImage *image = [UIImage imageNamed:[dic valueForKey:@"image"]];
                    
                    NSString *f_id = [dic valueForKey:@"image"];
                    
//                    if ([f_id isEqualToString:@"dc_ibeacon_p"]) {
//                        if (aryPoint.count > 0) {
//                            for (int p_index = 0; p_index < aryPoint.count; p_index++) {
//                                NSInteger tag = (i + 1 ) * 10 + p_index + 1;
//                                UIImageView *imgView = (UIImageView*)[self viewWithTag:tag];
//                                
//                                if (dicHereCenter == nil)
//                                    imgView.hidden = YES;
//                                else
//                                    imgView.hidden = NO;
//                            }
//                        }
//                    }
//                    else
                    {
                        NSMutableArray *aryPoint = [dicFacilitesLocation objectForKey:f_id];
                        if (aryPoint.count > 0) {
                            for (int p_index = 0; p_index < aryPoint.count; p_index++) {
                                NSInteger tag = (i + 1 ) * 10 + p_index + 1;
                                UIButton *imgButton = (UIButton*)[self viewWithTag:tag];
                                [imgButton setImage:image forState:UIControlStateNormal];
                            }
                        }
                    }
                }
                facilitiesItemSelectedFlag = NO;
                viewFacTooltip.hidden = YES;
            }
            return;
        }
        
        NSString *floorName = nil;
        NSString *mapName;
        
        if (haveFacFloor == 0)
        {
            floorName = @"Lower Mall";
            mapName = @"floor_0";
        }else if ( haveFacFloor == 1)
        {
            floorName = @"Upper Mall";
            mapName = @"floor_1";
        }
        else if (haveFacFloor == 2) {
            floorName = @"Food Court";
            mapName = @"floor_2";
        }
        
        dicFacilitesLocation = [allFacilitesLocation objectAtIndex:haveFacFloor];
        
        self.rootViewController.m_nCentureFloor = haveFacFloor;
        [self.rootViewController.btnFloor setTitle:floorName forState:UIControlStateNormal];
        [self.rootViewController setStoreInfo:haveFacFloor];
        [self.imageView setImage:[UIImage imageNamed:mapName]];
        [self setFacilitesInfo:haveFacFloor];
        [self setShopPosition];
        [self setShopCentreAngle];
        
        [self setZoomScale:MIN_SCALE];
        
        if (haveFacFloor == LOWER_MALL)
            [self setContentOffset:CGPointMake(0, 0)];
        else if (haveFacFloor == UPPER_MALL)
            [self setContentOffset:CGPointMake(0, 0)];
        else //Food Court
            [self setContentOffset:CGPointMake(300, 0)];
    }
    
    for (int i = 0; i < aryFacilites.count; i++) {
        UIImage *image = nil;
        dic = [aryFacilites objectAtIndex:i];
        if (i == f_index)
            image= [UIImage imageNamed:[dic valueForKey:@"image_sel"]];
        else
            image= [UIImage imageNamed:[dic valueForKey:@"image"]];
        
        NSString *f_id = [dic valueForKey:@"image"];
        NSMutableArray *aryPoint = [dicFacilitesLocation objectForKey:f_id];
        
//        if ([f_id isEqualToString:@"dc_ibeacon_p"]) {
//            if (aryPoint.count > 0) {
//                for (int p_index = 0; p_index < aryPoint.count; p_index++) {
//                    NSInteger tag = (i + 1 ) * 10 + p_index + 1;
//                    UIImageView *imgView = (UIImageView*)[self viewWithTag:tag];
//                    
//                    if (dicHereCenter == nil)
//                        imgView.hidden = YES;
//                    else
//                        imgView.hidden = NO;
//                }
//            }
//        }
//        else {
        
            if (aryPoint.count > 0) {
                for (int p_index = 0; p_index < aryPoint.count; p_index++) {
                    NSInteger tag = (i + 1 ) * 10 + p_index + 1;
                    UIButton *imgButton = (UIButton*)[self viewWithTag:tag];
                    [imgButton setImage:image forState:UIControlStateNormal];
                }
            }
        //}
    }
    
    if (aryPoint == nil) {
        [viewFacTooltip setHidden:YES];
        return;
    }
    
    facilitiesItemSelectedFlag = YES;
    
    // ------------ show facilities tooltip --------------
    CGFloat scale = self.zoomScale;
    dic = [aryFacilites objectAtIndex:f_index];
    UIImage *facImage = [UIImage imageNamed:[dic valueForKey:@"image"]];
    [btnFacImage setImage:facImage forState:UIControlStateNormal];
    lblFacName.text = [dic valueForKey:@"name"];
    
    // disable location service
    CGRect rect = viewFacTooltip.frame;
    CGPoint centrePoint;
    
    if (tag % 10 == 0) {
        Coordinate *userLocation = self.rootViewController.userMapLocation;
        
        if ( userLocation.x == 0 || userLocation.y == 0 )
            centrePoint = CGPointMake(offsetPoint.x + 320/2, offsetPoint.y + SCREEN_HEIGHT/2);
        else
            centrePoint = CGPointMake(userLocation.x * self.zoomScale, userLocation.y * self.zoomScale);
        
        
        NSDictionary *dic = [aryFacilites objectAtIndex:f_index];
        NSString *f_id = [dic valueForKey:@"image"];
        CGFloat min_distance = 0;
        CGPoint nearPoint;
        NSMutableArray *aryPoint = [dicFacilitesLocation objectForKey:f_id];
        
        for (int i = 0; i < aryPoint.count; i++) {
            Coordinate *facPoint = [aryPoint objectAtIndex:i];
            facPoint = [Coordinate coordinateWithX:facPoint.x/map_scale Y:facPoint.y/map_scale];
            CGFloat distance = pow( facPoint.x * scale - centrePoint.x ,2) + pow( facPoint.y * scale - centrePoint.y , 2);
            if (min_distance == 0) {
                min_distance = distance;
                nearPoint = CGPointMake(facPoint.x, facPoint.y);
            }else
            {
                if (min_distance > distance) {
                    min_distance = distance;
                    nearPoint = CGPointMake(facPoint.x, facPoint.y);
                }
            }
        }
        
        rect.origin.x = nearPoint.x * scale - viewFacTooltip.frame.size.width  / 2;
        rect.origin.y = nearPoint.y * scale - viewFacTooltip.frame.size.height - facilitiesSize * scale / 2;
        centrePoint = CGPointMake((nearPoint.x + facilitiesSize / 2 ) * scale
                                  , (nearPoint.y + facilitiesSize / 2) * scale );
    }
    else
    {
        centrePoint = CGPointMake(senderCenter.x * scale
                                  , senderCenter.y * scale );
        rect.origin.x = senderRect.origin.x * scale - (viewFacTooltip.frame.size.width - senderRect.size.width * scale) / 2;
        rect.origin.y = senderRect.origin.y * scale - viewFacTooltip.frame.size.height;
    }
    
    [viewFacTooltip setFrame:rect];
    [viewFacTooltip setAlpha:0];
    
    [UIView animateWithDuration:0.5f animations:^{
        [viewFacTooltip setHidden:NO];
        [viewFacTooltip setAlpha:1.0f];
    }];
    
    
    if( centrePoint.x - offsetPoint.x < rect.size.width / 2) {
        offsetPoint.x -= rect.size.width / 2 - (centrePoint.x - offsetPoint.x) + 10;
    }else if ( centrePoint.x - offsetPoint.x > 320 - rect.size.width / 2)
        offsetPoint.x += rect.size.width/2 -(320 -(centrePoint.x - offsetPoint.x)) + 10;
    
    if( centrePoint.y - offsetPoint.y < rect.size.height / 2 + 120) {
        offsetPoint.y -= rect.size.height / 2 + 120 - (centrePoint.y - offsetPoint.y);
    }else if ( centrePoint.y - offsetPoint.y > SCREEN_HEIGHT - rect.size.height / 2 - 120)
        offsetPoint.y += rect.size.height/2 -(SCREEN_HEIGHT -(centrePoint.y - offsetPoint.y) - 120);
    
    [UIView animateWithDuration:.25 animations:^{
        [self setContentOffset:CGPointMake(offsetPoint.x, offsetPoint.y)];
    }];
    
}

- (void) onClickFavouriteButton:(id)sender
{
    isFavourite = !isFavourite;
    
    UIImage *favoriteImage;
    if (hasOffer) {
        if (isFavourite) {
            favoriteImage = [UIImage imageNamed:@"icon-favourite-on-plusOffer"];
        }
        else {
            favoriteImage = [UIImage imageNamed:@"icon-favourite-off-plusOffer"];
        }
    }
    else {
        if (isFavourite) {
            favoriteImage = [UIImage imageNamed:@"icon-favourite-on"];
        }
        else {
            favoriteImage = [UIImage imageNamed:@"icon-favourite-off"];
        }
    }
    
    [btnFavourite setImage:favoriteImage forState:UIControlStateNormal];

    NSMutableDictionary *dic = self.rootViewController.dcStores[selectedShopIndex];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *fav_dic =[[NSMutableDictionary alloc] initWithDictionary:[userDefaults valueForKey:WHITELEY_FOVORITE_STORE]];
    NSString *mID = dic[@"id"];
    
    if (isFavourite)
    {
        [fav_dic setValue:@"1" forKey:mID];
        [dic setValue:@"1" forKey:@"favorite"];
    }
    else
    {
        [fav_dic setValue:@"0" forKey:mID];
        [dic setValue:@"0" forKey:@"favorite"];
    }
    
    [userDefaults setObject:fav_dic forKey:WHITELEY_FOVORITE_STORE];
    [userDefaults synchronize];
    
    for (int i = 0; i < self.rootViewController.dcAllStores.count; i++) {
        NSMutableDictionary *dic = [self.rootViewController.dcAllStores objectAtIndex:i];
        if ([dic[@"id"] isEqualToString:mID]) {
            if (isFavourite)
                [dic setValue:@"1" forKey:@"favorite"];
            else
                [dic setValue:@"0" forKey:@"favorite"];

        }
    }
    if (isFavourite) {

        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(3, - 55, 165, 55)];
        [imgView setImage:[UIImage imageNamed:@"dc_map_favourite"]];
        
        [self.viewTooltip addSubview:imgView];
        imgView.alpha = 0;
        
        [UIView animateWithDuration:0.5 animations:^{
            imgView.alpha = 1;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:1.5 delay:0.5 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                imgView.alpha = 0;
            } completion:^(BOOL finished) {
                [imgView removeFromSuperview];
            }];
        }];

    }
}

- (void) onClickStorePageButton:(id)sender
{
    StoreDetailViewController* vc = [self.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"StoreDetailViewController"];
    NSMutableDictionary *store = self.rootViewController.dcStores[selectedShopIndex];
    vc.strStoreID = store[@"id"];
    [viewTooltip setHidden:YES];
    [self.rootViewController.navigationController pushViewController:vc animated:YES];
}

#pragma mark Show Shop Tooltip

- (void) showShopUnitTooltip:(NSInteger) index searchFlag:(BOOL) flag;
{
    
    NSDictionary* store = self.rootViewController.dcStores[index];
    if ([store[@"name"] isEqualToString:NEW_RETAILER_SHOP]) {
        return;
    }
    
    selectedShopIndex = index;
  
    NSMutableArray *points = [aryShopLocation objectAtIndex:index];
    Coordinate *p = [points objectAtIndex:0];
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(p.x / map_scale, p.y / map_scale)];
    
    for (int i = 1; i < points.count; i++) {
        p = [points objectAtIndex:i];
        [path addLineToPoint:CGPointMake(p.x / map_scale, p.y / map_scale)];
    }
    
   /*
    NSMutableArray *aryMapLatLongLocation = [[NSMutableArray alloc] init];
    
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.884157 Y:1.245199]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.884671 Y:1.246962]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.885040 Y:1.247179]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.885930 Y:1.247635]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.886052 Y:1.248697]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.886363 Y:1.248617]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.886207 Y:1.247404]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.886702 Y:1.245548]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.886394 Y:1.245232]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.886062 Y:1.245553]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.885947 Y:1.245891]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.884417 Y:1.244502]];
   // [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.884644 Y:ABS(-1.246921)]];


    
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.884228 Y:1.245366]];

    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.884228 Y:1.245366]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.884431 Y:1.245618]];

    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.884390 Y:1.245945]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.884644 Y:1.246739]];

    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.884671 Y:1.246962]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.884999 Y:1.246948]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.885040 Y:1.247179]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.885192 Y:1.247157]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.885930 Y:1.247635]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.886052 Y:1.248697]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.886363 Y:1.248617]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.886370 Y:1.246514]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.886455 Y:1.246347]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.886576 Y:1.246026]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.886702 Y:1.245548]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.886394 Y:1.245232]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.886062 Y:1.245553]];
    
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.885947 Y:1.245891]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.885808 Y:1.245843]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.885321 Y:1.245435]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.884777 Y:1.244871]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.884725 Y:1.244754]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.884644 Y:ABS(-1.246921)]];
    [aryMapLatLongLocation addObject:[Coordinate coordinateWithX:50.884417 Y:1.244502]];
    
    Coordinate *p = [aryMapLatLongLocation objectAtIndex:0];
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake((p.y-1.24)*10000*3,(p.x-50.88)*10000*3)];
     
    for (int i = 1; i < aryMapLatLongLocation.count; i++) {
         p = [aryMapLatLongLocation objectAtIndex:i];
         [path addLineToPoint:CGPointMake((p.y-1.24)*10000*3,(p.x-50.88)*10000*3)];
    }
    */
    
    [highlightedLayer setPath:[path CGPath]];
    highlightedLayer.hidden = NO;
    
    hasOffer = [store[@"hasoffer"] boolValue];
    NSDictionary *dicFav = [[NSUserDefaults standardUserDefaults] valueForKey:WHITELEY_FOVORITE_STORE];
    isFavourite = [[dicFav valueForKey:store[@"id"]] boolValue];
    
    [btnStoreName setTitle:store[@"name"] forState:UIControlStateNormal];
    
    UIImage* favoriteImage = nil;
    if (hasOffer) {
        if (isFavourite) {
            favoriteImage = [UIImage imageNamed:@"icon-favourite-on-plusOffer"];
        }
        else {
            favoriteImage = [UIImage imageNamed:@"icon-favourite-off-plusOffer"];
        }
    }
    else {
        if (isFavourite) {
            favoriteImage = [UIImage imageNamed:@"icon-favourite-on"];
        }
        else {
            favoriteImage = [UIImage imageNamed:@"icon-favourite-off"];
        }
    }
    [btnFavourite setImage:favoriteImage forState:UIControlStateNormal];
    
    p = [aryShopCentre objectAtIndex:index];
    p = [Coordinate coordinateWithX:p.x / map_scale Y:p.y / map_scale];
    
    CGPoint centrePoint = CGPointMake(p.x * self.zoomScale, p.y * self.zoomScale);
    CGPoint offsetPoint = self.contentOffset;
    CGRect rect = viewTooltip.frame;
    if( centrePoint.x - offsetPoint.x < rect.size.width / 2) {
        offsetPoint.x -= rect.size.width / 2 - (centrePoint.x - offsetPoint.x) + 10;
    }else if ( centrePoint.x - offsetPoint.x > 320 - rect.size.width / 2)
        offsetPoint.x += rect.size.width/2 -(320 -(centrePoint.x - offsetPoint.x)) + 10;
    
    if( centrePoint.y - offsetPoint.y < rect.size.height / 2 + 100) {
        offsetPoint.y -= rect.size.height / 2 + 100 - (centrePoint.y - offsetPoint.y);
    }else if ( centrePoint.y - offsetPoint.y > SCREEN_HEIGHT - rect.size.height / 2 - 100)
        offsetPoint.y += rect.size.height/2 -(SCREEN_HEIGHT -(centrePoint.y - offsetPoint.y) - 100);
    
    [UIView animateWithDuration:0.5 animations:^{
        [self setContentOffset:CGPointMake(offsetPoint.x, offsetPoint.y)];
    }];
    
    rect = self.viewTooltip.frame;
    rect.origin.x = centrePoint.x - rect.size.width / 2;//offset.x - init_offset.x;
    rect.origin.y = centrePoint.y - rect.size.height;//offset.y - init_offset.y;
    
    [viewTooltip setFrame:rect];
    [viewTooltip setAlpha:0];
    [viewTooltip setHidden:NO];

    [UIView animateWithDuration:0.8f animations:^{
        [viewTooltip setAlpha:1.0f];
    }];
}

#pragma mark ZOOM Methods

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    return self.imageView;
}

- (void)centerScrollViewContents {
    
    CGSize boundsSize = self.bounds.size;
    CGRect contentsFrame = self.imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.imageView.frame = contentsFrame;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    if (viewTooltip.hidden == NO)
        [viewTooltip setHidden:YES];
    
    if (viewFacTooltip.hidden == NO)
        [viewFacTooltip setHidden:YES];
    
    if (highlightedLayer.hidden == NO)
        [highlightedLayer setHidden:YES];

}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    [self centerScrollViewContents];
    if (!self.rootViewController.userMapArrow.hidden) {
        self.rootViewController.userMapArrow.center = CGPointMake(self.rootViewController.userMapLocation.x * self.zoomScale, self.rootViewController.userMapLocation.y * self.zoomScale);
    }
    
    for (int i = 0; i < aryShopLogoImageView.count; i++) {
        UIImageView *imgView = [aryShopLogoImageView objectAtIndex:i];
        Coordinate *p = [aryShopCentre objectAtIndex:i];
        p = [Coordinate coordinateWithX:p.x / map_scale Y:p.y /map_scale];
        float angle =[[aryShopAngle objectAtIndex:i] floatValue];
        [imgView setCenter:CGPointMake(p.x*self.zoomScale , p.y*self.zoomScale)];
        
        CGRect rect = imgView.frame;
        Coordinate *pLeftTop;
        Coordinate *pRightBottom;

        NSMutableArray *points = [aryShopLocation objectAtIndex:i];

        pLeftTop = [Coordinate coordinateWithX:rect.origin.x * map_scale Y:rect.origin.y * map_scale ];
        pRightBottom = [Coordinate coordinateWithX:(rect.origin.x+rect.size.width) * map_scale Y:(rect.origin.y+rect.size.height) * map_scale];
        
        NSMutableArray *zoomPoints = [[NSMutableArray alloc] init];
        Coordinate *c_p = [points objectAtIndex:0];
        Coordinate *cLeftTop = [Coordinate coordinateWithX:c_p.x Y:c_p.y];
        Coordinate *cRightBottom = [Coordinate coordinateWithX:c_p.x Y:c_p.y];
        
        for (int j = 1; j < points.count; j++) {
            Coordinate *cPoint = [points objectAtIndex:j];
            CGPoint point = CGPointMake(cPoint.x, cPoint.y);
            if (point.x < cLeftTop.x)
                cLeftTop.x = point.x;
            if (point.x > cRightBottom.x)
                cRightBottom.x = point.x;
            
            if (point.y < cLeftTop.y)
                cLeftTop.y = point.y;
            if (point.y > cRightBottom.y)
                cRightBottom.y = point.y;
        }
        
        [zoomPoints addObject:[Coordinate coordinateWithX:cLeftTop.x*self.zoomScale Y:cLeftTop.y*self.zoomScale]];
        [zoomPoints addObject:[Coordinate coordinateWithX:cRightBottom.x*self.zoomScale Y:cLeftTop.y*self.zoomScale]];
        [zoomPoints addObject:[Coordinate coordinateWithX:cRightBottom.x*self.zoomScale Y:cRightBottom.y*self.zoomScale]];
        [zoomPoints addObject:[Coordinate coordinateWithX:cLeftTop.x*self.zoomScale Y:cRightBottom.y*self.zoomScale]];

        if (self.zoomScale < MIN_SCALE )
        {
            imgView.hidden = YES;
            continue;
        }
        
        if (ABS(angle) < 90 && ABS(angle) > 0 ){
            if ([self point:pLeftTop In:zoomPoints] && [self point:pRightBottom In:zoomPoints])
                imgView.hidden = NO;
            else
                imgView.hidden = YES;
        }
        else
        {
            if ([self point:pLeftTop In:zoomPoints] && [self point:pRightBottom In:zoomPoints])
                imgView.hidden = NO;
            else
                imgView.hidden = YES;
        }
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    UIView *view = [self.rootViewController.view viewWithTag:100];
    if (view!= nil && !view.hidden) {
        [UIView animateWithDuration:0.1 animations:^{
            view.alpha = 0;
        } completion:^(BOOL finished) {
            [view removeFromSuperview];
        }];
    }

}

#pragma mark Touch Map View
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    NSUInteger tapCount = touch.tapCount;
    
    if (!self.rootViewController.viewLocationTooltip.hidden)
        self.rootViewController.viewLocationTooltip.hidden = YES;
    
    if (!self.rootViewController.viewOutsideTooltip.hidden)
        self.rootViewController.viewOutsideTooltip.hidden = YES;
    
    if (facilitiesItemSelectedFlag) {
        for (int i = 0; i < aryFacilites.count; i++) {
            NSDictionary *dic = [aryFacilites objectAtIndex:i];
            UIImage *image = [UIImage imageNamed:[dic valueForKey:@"image"]];
            
            NSString *f_id = [dic valueForKey:@"image"];
            
            //if (![f_id isEqualToString:@"dc_ibeacon_p"])
            {
                NSMutableArray *aryPoint = [dicFacilitesLocation objectForKey:f_id];
                if (aryPoint.count > 0) {
                    for (int p_index = 0; p_index < aryPoint.count; p_index++) {
                        NSInteger tag = (i + 1 ) * 10 + p_index + 1;
                        UIButton *imgButton = (UIButton*)[self viewWithTag:tag];
                        [imgButton setImage:image forState:UIControlStateNormal];
                    }
                }
            }
        }
        facilitiesItemSelectedFlag = NO;
        viewFacTooltip.hidden = YES;
    }
    
    if (tapCount == 1 )
    {
        CGPoint localPoint = [[touches anyObject] locationInView:self];
        
        storePoint = localPoint;

        localPoint.x = localPoint.x / self.zoomScale;
        localPoint.y = localPoint.y / self.zoomScale;
        
        NSInteger index = -1;
        for (int i = 0; i < aryShopLocation.count; i++ ) {
            NSMutableArray *points = [aryShopLocation objectAtIndex:i];
            
            if([self point:[Coordinate coordinateWithX:localPoint.x * map_scale Y:localPoint.y * map_scale] In:points])
            {
                index = i;
                break;
            }
        }
        
        if(index == -1)
        {
            highlightedLayer.hidden = YES;
            [viewTooltip setHidden:YES];
        }
        else
        {
            [self showShopUnitTooltip:index searchFlag:NO];
        }
    }
    else if (tapCount == 2) {
        [self handleDoubleTapBegan:[touch locationInView:self.superview]];
    }
    
    [[self nextResponder] touchesEnded:touches withEvent:event];
}

- (void)handleDoubleTapBegan:(CGPoint)touchPoint {
    
    if (!highlightedLayer.hidden)
        [highlightedLayer setHidden:YES];
    
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         if (self.zoomScale == MIN_SCALE)
                             [self setZoomScale:MAX_SCALE animated:NO];
                         else
                             [self setZoomScale:MIN_SCALE animated:NO];
                     }
                     completion:nil];
}

-(BOOL)point:(Coordinate*)c In:(NSArray*)pointArray
{
    int intersectionCount = 0;
    for(int i = 0; i < pointArray.count; i++)
    {
        Coordinate* cCoord1 = pointArray[i];
        Coordinate* cCoord2 = pointArray[(i + 1) % pointArray.count];
        CGPoint coord1 = CGPointMake(cCoord1.x, cCoord1.y);
        CGPoint coord2 = CGPointMake(cCoord2.x, cCoord2.y);

        if(coord1.x > c.x || coord2.x > c.x)
        {
            if((c.y < coord1.y && c.y > coord2.y))
            {
                float cx = 0;
                cx = ((c.y - coord2.y) / (coord1.y - coord2.y)) * (coord1.x - coord2.x) + coord2.x;
                if(cx > c.x)
                    intersectionCount++;
            }
            if(c.y > coord1.y && c.y < coord2.y)
            {
                float cx = 0;
                cx = ((c.y - coord1.y) / (coord2.y - coord1.y)) * (coord2.x - coord1.x) + coord1.x;
                if(cx > c.x)
                    intersectionCount++;
            }
        }
    }
    if(intersectionCount % 2 == 1)
        return true;
    else
        return false;
}


- (void) setShopCentreAngle
{
    aryShopCentre = [[NSMutableArray alloc] init];
    aryShopAngle = [[NSMutableArray alloc] init];
#pragma mark set Center floor 0

    if (self.rootViewController.m_nCentureFloor == LOWER_MALL) {
        [aryShopCentre addObject:[Coordinate coordinateWithX:1324 Y:2998]];//1 M&S
        [aryShopCentre addObject:[Coordinate coordinateWithX:1028 Y:2806]];//2 wagammama
        [aryShopCentre addObject:[Coordinate coordinateWithX:1028 Y:2741]];//3 MONSOON
        [aryShopCentre addObject:[Coordinate coordinateWithX:1028 Y:2675]];//4 schuh
        [aryShopCentre addObject:[Coordinate coordinateWithX:1028 Y:2595]];//5 RIVER ISLAND
        [aryShopCentre addObject:[Coordinate coordinateWithX:1028 Y:2473]];//6 H&M
        [aryShopCentre addObject:[Coordinate coordinateWithX:966 Y:2347]];//7 TOPSHOP
        [aryShopCentre addObject:[Coordinate coordinateWithX:826 Y:2341]];//8 XPRESS
        [aryShopCentre addObject:[Coordinate coordinateWithX:782 Y:2396]];//9 LITTLE
        [aryShopCentre addObject:[Coordinate coordinateWithX:759 Y:2424]];//10 SWEETS
        [aryShopCentre addObject:[Coordinate coordinateWithX:724 Y:2467]];//11 SOLENT
        [aryShopCentre addObject:[Coordinate coordinateWithX:740 Y:2137]];//12 HAIR OTT
        [aryShopCentre addObject:[Coordinate coordinateWithX:771 Y:2162]];//13 GREENGEROCER
        [aryShopCentre addObject:[Coordinate coordinateWithX:800 Y:2185]];//14 BAKER
        [aryShopCentre addObject:[Coordinate coordinateWithX:875 Y:2195]];//15 BLANK4
        [aryShopCentre addObject:[Coordinate coordinateWithX:991 Y:2146]];//16 next
        [aryShopCentre addObject:[Coordinate coordinateWithX:1022 Y:2018]];//17 TIGER
        [aryShopCentre addObject:[Coordinate coordinateWithX:1022 Y:1947]];//18 BANK
        [aryShopCentre addObject:[Coordinate coordinateWithX:1022 Y:1875]];//19 Blacks
        [aryShopCentre addObject:[Coordinate coordinateWithX:1022 Y:1803]];//20 Clanks
        [aryShopCentre addObject:[Coordinate coordinateWithX:1022 Y:1722]];//21 SPORTS
        [aryShopCentre addObject:[Coordinate coordinateWithX:1004 Y:1641]];//22 mamas
        [aryShopCentre addObject:[Coordinate coordinateWithX:1004 Y:1570]];//23 Entertainer
        [aryShopCentre addObject:[Coordinate coordinateWithX:1004 Y:1491]];//24 Rock Up
        [aryShopCentre addObject:[Coordinate coordinateWithX:976 Y:1389]];//25 FIVE GUYS
        [aryShopCentre addObject:[Coordinate coordinateWithX:868 Y:1386]];//26 Nando's
        [aryShopCentre addObject:[Coordinate coordinateWithX:853 Y:1313]];//27 PIZZ
        [aryShopCentre addObject:[Coordinate coordinateWithX:769 Y:1305]];//28 coast
        [aryShopCentre addObject:[Coordinate coordinateWithX:694 Y:1290]];//29 dimt
        [aryShopCentre addObject:[Coordinate coordinateWithX:721 Y:1179]];//30 BLANK3
        [aryShopCentre addObject:[Coordinate coordinateWithX:654 Y:1162]];//31 BLANK2
        [aryShopCentre addObject:[Coordinate coordinateWithX:601 Y:1106]];//32 BLANK1
        [aryShopCentre addObject:[Coordinate coordinateWithX:1695 Y:1549]];//33 TESCO
        [aryShopCentre addObject:[Coordinate coordinateWithX:1435 Y:1501]];//34 Card Factory
        [aryShopCentre addObject:[Coordinate coordinateWithX:1398 Y:1501]];//35 Ladbrokes
        [aryShopCentre addObject:[Coordinate coordinateWithX:1361 Y:1501]];//36 SUBWAY
        [aryShopCentre addObject:[Coordinate coordinateWithX:1324 Y:1501]];//37 Walker
        [aryShopCentre addObject:[Coordinate coordinateWithX:1288 Y:1501]];//38 TUI
        [aryShopCentre addObject:[Coordinate coordinateWithX:1252 Y:1511]];//39 CAFFE
        [aryShopCentre addObject:[Coordinate coordinateWithX:1168 Y:1515]];//40 MONTAGUS'S
        [aryShopCentre addObject:[Coordinate coordinateWithX:1343 Y:1607]];//41 TRESPASS
        [aryShopCentre addObject:[Coordinate coordinateWithX:1344 Y:1715]];//42 Books
        [aryShopCentre addObject:[Coordinate coordinateWithX:1252 Y:1812]];//43 Ernest Jones
        [aryShopCentre addObject:[Coordinate coordinateWithX:1252 Y:1867]];//44 HOLLAND
        [aryShopCentre addObject:[Coordinate coordinateWithX:1252 Y:1913]];//45 PANDORA
        [aryShopCentre addObject:[Coordinate coordinateWithX:1252 Y:1949]];//46 smiggle
        [aryShopCentre addObject:[Coordinate coordinateWithX:1252 Y:1985]];//47 claire's
        [aryShopCentre addObject:[Coordinate coordinateWithX:1252 Y:2020]];//48 clintons
        [aryShopCentre addObject:[Coordinate coordinateWithX:1242 Y:2074]];//49 MOSS
        [aryShopCentre addObject:[Coordinate coordinateWithX:1251 Y:2164]];//50 FATFACE
        [aryShopCentre addObject:[Coordinate coordinateWithX:1344 Y:2162]];//51 WHSMith
        [aryShopCentre addObject:[Coordinate coordinateWithX:1436 Y:2149]];//52 STARBUCKS
        [aryShopCentre addObject:[Coordinate coordinateWithX:1443 Y:2026]];//53 Harvester
        [aryShopCentre addObject:[Coordinate coordinateWithX:1467 Y:2263]];//54 YO sushi
        [aryShopCentre addObject:[Coordinate coordinateWithX:1440 Y:2604]];//55 ChiMiCHANGA
        [aryShopCentre addObject:[Coordinate coordinateWithX:1440 Y:2514]];//56 PREZZO
        [aryShopCentre addObject:[Coordinate coordinateWithX:1434 Y:2399]];//57 Frankie
        [aryShopCentre addObject:[Coordinate coordinateWithX:1344 Y:2364]];//58 Jonles
        [aryShopCentre addObject:[Coordinate coordinateWithX:1250 Y:2337]];//59 BEAVERBROOKS
        [aryShopCentre addObject:[Coordinate coordinateWithX:1238 Y:2393]];//60 THE BODY SHOP
        [aryShopCentre addObject:[Coordinate coordinateWithX:1232 Y:2454]];//61 vision express
        [aryShopCentre addObject:[Coordinate coordinateWithX:1232 Y:2526]];//62 Phase Eight
        [aryShopCentre addObject:[Coordinate coordinateWithX:1232 Y:2598]];//63 Jones
        [aryShopCentre addObject:[Coordinate coordinateWithX:1233 Y:2663]];//64 Pirper
        [aryShopCentre addObject:[Coordinate coordinateWithX:1235 Y:2745]];//65 Carhp
        [aryShopCentre addObject:[Coordinate coordinateWithX:1289 Y:2778]];//66 COSTA
        //[aryShopCentre addObject:[Coordinate coordinateWithX:1334 Y:2778]];//67 GLOW & CO
        [aryShopCentre addObject:[Coordinate coordinateWithX:1363 Y:2778]];//68 FUSSY NATION
        [aryShopCentre addObject:[Coordinate coordinateWithX:1455 Y:2778]];//69 Dearis
        
#pragma mark set Angle
        [aryShopAngle addObject:[NSNumber numberWithInteger:0]];//1
        [aryShopAngle addObject:[NSNumber numberWithInteger:0]];//2
        [aryShopAngle addObject:[NSNumber numberWithInteger:0]];//3
        [aryShopAngle addObject:[NSNumber numberWithInteger:0]];//4 schuh
        [aryShopAngle addObject:[NSNumber numberWithInteger:0]];//5 RIVER
        [aryShopAngle addObject:[NSNumber numberWithInteger:0]];//6
        [aryShopAngle addObject:[NSNumber numberWithInteger:0]];//7 TOPSHOP
        [aryShopAngle addObject:[NSNumber numberWithInteger:-90]];//8
        [aryShopAngle addObject:[NSNumber numberWithInteger:-140]];//9 Rock Up
        [aryShopAngle addObject:[NSNumber numberWithInteger:-140]];//10
        [aryShopAngle addObject:[NSNumber numberWithInteger:-140]];//11
        [aryShopAngle addObject:[NSNumber numberWithInteger:-50]];//12
        [aryShopAngle addObject:[NSNumber numberWithInteger:-50]];//13
        [aryShopAngle addObject:[NSNumber numberWithInteger:-50]];//14
        [aryShopAngle addObject:[NSNumber numberWithInteger:0]];//15
        [aryShopAngle addObject:[NSNumber numberWithInteger:0]];//16 next
        [aryShopAngle addObject:[NSNumber numberWithInteger:0]];//17 TIGER
        [aryShopAngle addObject:[NSNumber numberWithInteger:0]];//18 BANK
        [aryShopAngle addObject:[NSNumber numberWithInteger:0]];//19
        [aryShopAngle addObject:[NSNumber numberWithInteger:0]];//20
        [aryShopAngle addObject:[NSNumber numberWithInteger:0]];//21
        [aryShopAngle addObject:[NSNumber numberWithInteger:0]];//22
        [aryShopAngle addObject:[NSNumber numberWithInteger:0]];//23
        [aryShopAngle addObject:[NSNumber numberWithInteger:0]];//24 Rock Up
        [aryShopAngle addObject:[NSNumber numberWithInteger:0]];//25 FIVE GUYS
        [aryShopAngle addObject:[NSNumber numberWithInteger:-50]];//26
        [aryShopAngle addObject:[NSNumber numberWithInteger:-50]];//27
        [aryShopAngle addObject:[NSNumber numberWithInteger:-50]];//28
        [aryShopAngle addObject:[NSNumber numberWithInteger:-50]];//29
        [aryShopAngle addObject:[NSNumber numberWithInteger:-50]];//30
        [aryShopAngle addObject:[NSNumber numberWithInteger:-50]];//31
        [aryShopAngle addObject:[NSNumber numberWithInteger:-50]];//32
        [aryShopAngle addObject:[NSNumber numberWithInteger:0]];//33 TESCO
        [aryShopAngle addObject:[NSNumber numberWithInteger:-90]];//34 Card Factory
        [aryShopAngle addObject:[NSNumber numberWithInteger:-90]];//35 Ladbrokers
        [aryShopAngle addObject:[NSNumber numberWithInteger:-90]];//36
        [aryShopAngle addObject:[NSNumber numberWithInteger:-90]];//37
        [aryShopAngle addObject:[NSNumber numberWithInteger:-90]];//38
        [aryShopAngle addObject:[NSNumber numberWithInteger:-90]];//39
        [aryShopAngle addObject:[NSNumber numberWithInteger:-90]];//40
        [aryShopAngle addObject:[NSNumber numberWithInteger:0]];//41 TRESPASS
        [aryShopAngle addObject:[NSNumber numberWithInteger:0]];//42
        [aryShopAngle addObject:[NSNumber numberWithInteger:0]];//43
        [aryShopAngle addObject:[NSNumber numberWithInteger:0]];//44
        [aryShopAngle addObject:[NSNumber numberWithInteger:0]];//45
        [aryShopAngle addObject:[NSNumber numberWithInteger:0]];//46
        [aryShopAngle addObject:[NSNumber numberWithInteger:0]];//47
        [aryShopAngle addObject:[NSNumber numberWithInteger:0]];//48
        [aryShopAngle addObject:[NSNumber numberWithInteger:0]];//49
        [aryShopAngle addObject:[NSNumber numberWithInteger:0]];//50
        [aryShopAngle addObject:[NSNumber numberWithInteger:-90]];//51 WHSMith
        [aryShopAngle addObject:[NSNumber numberWithInteger:0]];//52
        [aryShopAngle addObject:[NSNumber numberWithInteger:0]];//53
        [aryShopAngle addObject:[NSNumber numberWithInteger:0]];//54
        [aryShopAngle addObject:[NSNumber numberWithInteger:0]];//55
        [aryShopAngle addObject:[NSNumber numberWithInteger:0]];//56
        [aryShopAngle addObject:[NSNumber numberWithInteger:0]];//57
        [aryShopAngle addObject:[NSNumber numberWithInteger:-90]];//58 Jonles
        [aryShopAngle addObject:[NSNumber numberWithInteger:0]];//59
        [aryShopAngle addObject:[NSNumber numberWithInteger:0]];//60
        [aryShopAngle addObject:[NSNumber numberWithInteger:0]];//61
        [aryShopAngle addObject:[NSNumber numberWithInteger:0]];//62
        [aryShopAngle addObject:[NSNumber numberWithInteger:0]];//63
        [aryShopAngle addObject:[NSNumber numberWithInteger:0]];//64
        [aryShopAngle addObject:[NSNumber numberWithInteger:0]];//65
        [aryShopAngle addObject:[NSNumber numberWithInteger:-90]];//66 COSTA
        //[aryShopAngle addObject:[NSNumber numberWithInteger:-90]];//67
        [aryShopAngle addObject:[NSNumber numberWithInteger:0]];//68
        [aryShopAngle addObject:[NSNumber numberWithInteger:-90]];//69

    }
   
    if (aryShopLogoImageView == nil)
        aryShopLogoImageView = [[NSMutableArray alloc] init];
    
    if ( aryShopFrame == nil )
        aryShopFrame = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < aryShopLogoImageView.count; i++) {
        UIImageView *imgView = [aryShopLogoImageView objectAtIndex:i];
        [imgView removeFromSuperview];
    }
    
    [aryShopLogoImageView removeAllObjects];
    [aryShopFrame removeAllObjects];
    
    NSMutableArray *aryFloorLogo;
    if (self.rootViewController.m_nCentureFloor == LOWER_MALL)
        aryFloorLogo = aryLowerFloorLogo;
    
    for (int i = 0; i < aryShopCentre.count; i++) {
        
        NSDictionary *dic = [self.rootViewController.dcStores objectAtIndex:i];
        NSString *strImage = [NSString stringWithFormat:@"logo_%@.png", dic[@"id"]];
        UIImage *image = nil;
        if (aryFloorLogo.count > i) {
            image = [aryFloorLogo objectAtIndex:i];
        }
        else
        {
            NSString *documentFolderPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            NSString* file_name = [documentFolderPath stringByAppendingPathComponent:strImage];
            if ([[NSFileManager defaultManager] fileExistsAtPath:file_name]) {
                image = [UIImage imageWithData:[NSData dataWithContentsOfFile:file_name] scale:2.0f];
            }
        }
         
        //image = [UIImage imageNamed:[NSString stringWithFormat:@"%ld", (long)i+1]];
        UIImageView *imgView = [[UIImageView alloc] initWithImage:image];
        [imgView sizeToFit];
    
        Coordinate *p = [aryShopCentre objectAtIndex:i];
        CGRect rect = imgView.frame;
        [imgView setFrame:rect];
        [imgView setCenter:CGPointMake(p.x*self.zoomScale , p.y*self.zoomScale)];
        NSMutableDictionary *dicSize = [[NSMutableDictionary alloc] init];
        [dicSize setObject:[NSNumber numberWithInt:rect.size.width] forKey:@"width"];
        [dicSize setObject:[NSNumber numberWithInt:rect.size.height] forKey:@"height"];
        [aryShopFrame addObject:dicSize];
        
        float degree = [[aryShopAngle objectAtIndex:i] floatValue];
        [imgView setTransform:CGAffineTransformMakeRotation(degree * M_PI / 180.0f)];
        [self addSubview:imgView];
        
        [aryShopLogoImageView addObject:imgView];
    }
    [self bringSubviewToFront:viewTooltip];
    [self bringSubviewToFront:viewFacTooltip];

    [self scrollViewDidZoom:self];
}

- (void) setShopPosition
{
    
    aryShopLocation = [[NSMutableArray alloc] init];
    NSMutableArray *points = [[NSMutableArray alloc] init];

    if (self.rootViewController.m_nCentureFloor == LOWER_MALL) {
        // Shop1 M&S
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:1195 Y:2890]];
        [points addObject:[Coordinate coordinateWithX:1521 Y:2890]];
        [points addObject:[Coordinate coordinateWithX:1521 Y:3150]];
        [points addObject:[Coordinate coordinateWithX:1160 Y:3150]];
        [points addObject:[Coordinate coordinateWithX:1160 Y:3074]];
        [points addObject:[Coordinate coordinateWithX:1125 Y:3074]];
        [points addObject:[Coordinate coordinateWithX:1125 Y:2923]];
        [points addObject:[Coordinate coordinateWithX:1195 Y:2923]];
        [aryShopLocation addObject:points];
        
        // Shop2 wagamama
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:919 Y:2785]];
        [points addObject:[Coordinate coordinateWithX:1138 Y:2785]];
        [points addObject:[Coordinate coordinateWithX:1138 Y:2827]];
        [points addObject:[Coordinate coordinateWithX:1101 Y:2827]];
        [points addObject:[Coordinate coordinateWithX:1101 Y:2853]];
        [points addObject:[Coordinate coordinateWithX:1030 Y:2853]];
        [points addObject:[Coordinate coordinateWithX:1030 Y:2827]];
        [points addObject:[Coordinate coordinateWithX:919 Y:2827]];
        [aryShopLocation addObject:points];
        
        // Shop3 MONSOON
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:919 Y:2712]];
        [points addObject:[Coordinate coordinateWithX:1138 Y:2712]];
        [points addObject:[Coordinate coordinateWithX:1138 Y:2771]];
        [points addObject:[Coordinate coordinateWithX:919 Y:2771]];
        [aryShopLocation addObject:points];
        
        // Shop4 schuh
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:919 Y:2652]];
        [points addObject:[Coordinate coordinateWithX:1138 Y:2652]];
        [points addObject:[Coordinate coordinateWithX:1138 Y:2698]];
        [points addObject:[Coordinate coordinateWithX:919 Y:2698]];
        [aryShopLocation addObject:points];
        
        // Shop5 RIVER ISLAND
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:919 Y:2551]];
        [points addObject:[Coordinate coordinateWithX:1138 Y:2551]];
        [points addObject:[Coordinate coordinateWithX:1138 Y:2639]];
        [points addObject:[Coordinate coordinateWithX:919 Y:2639]];
        [aryShopLocation addObject:points];
        
        // Shop6 H&M
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:919 Y:2409]];
        [points addObject:[Coordinate coordinateWithX:1138 Y:2409]];
        [points addObject:[Coordinate coordinateWithX:1138 Y:2538]];
        [points addObject:[Coordinate coordinateWithX:919 Y:2538]];
        [aryShopLocation addObject:points];
        
        // Shop7 TOPSHOP TOPMAN
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:856 Y:2298]];
        [points addObject:[Coordinate coordinateWithX:1076 Y:2298]];
        [points addObject:[Coordinate coordinateWithX:1076 Y:2396]];
        [points addObject:[Coordinate coordinateWithX:856 Y:2396]];
        [aryShopLocation addObject:points];
        
        // Shop8 XPRESS BEAUTY
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:852 Y:2311]];
        [points addObject:[Coordinate coordinateWithX:852 Y:2372]];
        [points addObject:[Coordinate coordinateWithX:843 Y:2372]];
        [points addObject:[Coordinate coordinateWithX:823 Y:2396]];
        [points addObject:[Coordinate coordinateWithX:773 Y:2357]];
        [points addObject:[Coordinate coordinateWithX:811 Y:2311]];
        [aryShopLocation addObject:points];
        
        // Shop9 LITTLE SOLES
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:766 Y:2366]];
        [points addObject:[Coordinate coordinateWithX:815 Y:2406]];
        [points addObject:[Coordinate coordinateWithX:799 Y:2425]];
        [points addObject:[Coordinate coordinateWithX:749 Y:2386]];
        [aryShopLocation addObject:points];
        
        // Shop10 SWEETS
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:743 Y:2395]];
        [points addObject:[Coordinate coordinateWithX:792 Y:2434]];
        [points addObject:[Coordinate coordinateWithX:776 Y:2453]];
        [points addObject:[Coordinate coordinateWithX:726 Y:2414]];
        [aryShopLocation addObject:points];

        // Shop11 SOLENT
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:719 Y:2423]];
        [points addObject:[Coordinate coordinateWithX:769 Y:2463]];
        [points addObject:[Coordinate coordinateWithX:729 Y:2511]];
        [points addObject:[Coordinate coordinateWithX:679 Y:2472]];
        [aryShopLocation addObject:points];
        
        // Shop12 HAIR OTT
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:780 Y:2114]];
        [points addObject:[Coordinate coordinateWithX:725 Y:2180]];
        [points addObject:[Coordinate coordinateWithX:700 Y:2161]];
        [points addObject:[Coordinate coordinateWithX:755 Y:2094]];
        [aryShopLocation addObject:points];
        
        // Shop13 GREENGROCER
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:788 Y:2120]];
        [points addObject:[Coordinate coordinateWithX:808 Y:2137]];
        [points addObject:[Coordinate coordinateWithX:754 Y:2203]];
        [points addObject:[Coordinate coordinateWithX:733 Y:2187]];
        [aryShopLocation addObject:points];
        
        // Shop14 BAKER
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:817 Y:2143]];
        [points addObject:[Coordinate coordinateWithX:837 Y:2160]];
        [points addObject:[Coordinate coordinateWithX:783 Y:2226]];
        [points addObject:[Coordinate coordinateWithX:761 Y:2210]];
        [aryShopLocation addObject:points];
        
        // Shop15 blank
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:903 Y:2166]];
        [points addObject:[Coordinate coordinateWithX:903 Y:2219]];
        [points addObject:[Coordinate coordinateWithX:816 Y:2219]];
        [points addObject:[Coordinate coordinateWithX:807 Y:2213]];
        [points addObject:[Coordinate coordinateWithX:846 Y:2166]];
        [aryShopLocation addObject:points];
        
        // Shop16 next
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:907 Y:2063]];
        [points addObject:[Coordinate coordinateWithX:1138 Y:2063]];
        [points addObject:[Coordinate coordinateWithX:1138 Y:2123]];
        [points addObject:[Coordinate coordinateWithX:1076 Y:2123]];
        [points addObject:[Coordinate coordinateWithX:1076 Y:2231]];
        [points addObject:[Coordinate coordinateWithX:907 Y:2231]];
        [aryShopLocation addObject:points];
        
        // Shop17 TIGER
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:907 Y:1989]];
        [points addObject:[Coordinate coordinateWithX:1138 Y:1989]];
        [points addObject:[Coordinate coordinateWithX:1138 Y:2048]];
        [points addObject:[Coordinate coordinateWithX:907 Y:2048]];
        [aryShopLocation addObject:points];
        
        // Shop18 BANK
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:907 Y:1918]];
        [points addObject:[Coordinate coordinateWithX:1138 Y:1918]];
        [points addObject:[Coordinate coordinateWithX:1138 Y:1975]];
        [points addObject:[Coordinate coordinateWithX:907 Y:1975]];
        [aryShopLocation addObject:points];
        
        // Shop19 Blacks
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:907 Y:1849]];
        [points addObject:[Coordinate coordinateWithX:1138 Y:1849]];
        [points addObject:[Coordinate coordinateWithX:1138 Y:1903]];
        [points addObject:[Coordinate coordinateWithX:907 Y:1903]];
        [aryShopLocation addObject:points];
        
        // Shop20 Clanks
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:907 Y:1775]];
        [points addObject:[Coordinate coordinateWithX:1138 Y:1775]];
        [points addObject:[Coordinate coordinateWithX:1138 Y:1834]];
        [points addObject:[Coordinate coordinateWithX:907 Y:1834]];
        [aryShopLocation addObject:points];
        
        // Shop21 SPORTS DIRECT
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:907 Y:1684]];
        [points addObject:[Coordinate coordinateWithX:1138 Y:1684]];
        [points addObject:[Coordinate coordinateWithX:1138 Y:1762]];
        [points addObject:[Coordinate coordinateWithX:907 Y:1762]];
        [aryShopLocation addObject:points];

        // Shop22 mamas & papas
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:907 Y:1613]];
        [points addObject:[Coordinate coordinateWithX:1102 Y:1613]];
        [points addObject:[Coordinate coordinateWithX:1102 Y:1670]];
        [points addObject:[Coordinate coordinateWithX:907 Y:1670]];
        [aryShopLocation addObject:points];
        
        // Shop23 Entertainer
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:907 Y:1542]];
        [points addObject:[Coordinate coordinateWithX:1102 Y:1542]];
        [points addObject:[Coordinate coordinateWithX:1102 Y:1598]];
        [points addObject:[Coordinate coordinateWithX:907 Y:1598]];
        [aryShopLocation addObject:points];
        
        // Shop24 Rock Up
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:907 Y:1455]];
        [points addObject:[Coordinate coordinateWithX:1102 Y:1455]];
        [points addObject:[Coordinate coordinateWithX:1102 Y:1527]];
        [points addObject:[Coordinate coordinateWithX:907 Y:1527]];
        [aryShopLocation addObject:points];
        
        // Shop25 FIVE GUYS
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:959 Y:1329]];
        [points addObject:[Coordinate coordinateWithX:1030 Y:1370]];
        [points addObject:[Coordinate coordinateWithX:1030 Y:1416]];
        [points addObject:[Coordinate coordinateWithX:936 Y:1416]];
        [points addObject:[Coordinate coordinateWithX:920 Y:1402]];
        [points addObject:[Coordinate coordinateWithX:848 Y:1491]];
        [points addObject:[Coordinate coordinateWithX:835 Y:1480]];
        [aryShopLocation addObject:points];
        
        // Shop26 Nando's
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:909 Y:1296]];
        [points addObject:[Coordinate coordinateWithX:951 Y:1324]];
        [points addObject:[Coordinate coordinateWithX:828 Y:1475]];
        [points addObject:[Coordinate coordinateWithX:787 Y:1444]];
        [aryShopLocation addObject:points];
        
        // Shop27 PIZZ & EXPRESS
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:866 Y:1256]];
        [points addObject:[Coordinate coordinateWithX:906 Y:1283]];
        [points addObject:[Coordinate coordinateWithX:780 Y:1438]];
        [points addObject:[Coordinate coordinateWithX:757 Y:1420]];
        [points addObject:[Coordinate coordinateWithX:807 Y:1360]];
        [points addObject:[Coordinate coordinateWithX:807 Y:1349]];
        [points addObject:[Coordinate coordinateWithX:797 Y:1340]];
        [aryShopLocation addObject:points];
        
        // Shop28 COAST
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:806 Y:1210]];
        [points addObject:[Coordinate coordinateWithX:856 Y:1250]];
        [points addObject:[Coordinate coordinateWithX:786 Y:1335]];
        [points addObject:[Coordinate coordinateWithX:786 Y:1346]];
        [points addObject:[Coordinate coordinateWithX:798 Y:1356]];
        [points addObject:[Coordinate coordinateWithX:750 Y:1414]];
        [points addObject:[Coordinate coordinateWithX:681 Y:1361]];
        [aryShopLocation addObject:points];
        
        // Shop29 dimt
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:768 Y:1175]];
        [points addObject:[Coordinate coordinateWithX:798 Y:1203]];
        [points addObject:[Coordinate coordinateWithX:675 Y:1355]];
        [points addObject:[Coordinate coordinateWithX:634 Y:1323]];
        [points addObject:[Coordinate coordinateWithX:636 Y:1320]];
        [points addObject:[Coordinate coordinateWithX:636 Y:1312]];
        [points addObject:[Coordinate coordinateWithX:708 Y:1225]];
        [points addObject:[Coordinate coordinateWithX:720 Y:1234]];
        [aryShopLocation addObject:points];
        
        // Shop30 blank
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:726 Y:1137]];
        [points addObject:[Coordinate coordinateWithX:760 Y:1169]];
        [points addObject:[Coordinate coordinateWithX:719 Y:1220]];
        [points addObject:[Coordinate coordinateWithX:707 Y:1211]];
        [points addObject:[Coordinate coordinateWithX:629 Y:1306]];
        [points addObject:[Coordinate coordinateWithX:628 Y:1314]];
        [points addObject:[Coordinate coordinateWithX:626 Y:1317]];
        [points addObject:[Coordinate coordinateWithX:620 Y:1311]];
        [points addObject:[Coordinate coordinateWithX:659 Y:1263]];
        [points addObject:[Coordinate coordinateWithX:659 Y:1253]];
        [points addObject:[Coordinate coordinateWithX:657 Y:1251]];
        [points addObject:[Coordinate coordinateWithX:670 Y:1235]];
        [points addObject:[Coordinate coordinateWithX:670 Y:1225]];
        [points addObject:[Coordinate coordinateWithX:661 Y:1217]];
        [aryShopLocation addObject:points];
        
        // Shop31 blank
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:678 Y:1089]];
        [points addObject:[Coordinate coordinateWithX:719 Y:1129]];
        [points addObject:[Coordinate coordinateWithX:650 Y:1213]];
        [points addObject:[Coordinate coordinateWithX:650 Y:1224]];
        [points addObject:[Coordinate coordinateWithX:660 Y:1232]];
        [points addObject:[Coordinate coordinateWithX:649 Y:1245]];
        [points addObject:[Coordinate coordinateWithX:589 Y:1197]];
        [aryShopLocation addObject:points];
        
        // Shop32 blank
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:618 Y:1013]];
        [points addObject:[Coordinate coordinateWithX:655 Y:1046]];
        [points addObject:[Coordinate coordinateWithX:678 Y:1073]];
        [points addObject:[Coordinate coordinateWithX:580 Y:1194]];
        [points addObject:[Coordinate coordinateWithX:580 Y:1205]];
        [points addObject:[Coordinate coordinateWithX:648 Y:1260]];
        [points addObject:[Coordinate coordinateWithX:611 Y:1305]];
        [points addObject:[Coordinate coordinateWithX:466 Y:1190]];
        [points addObject:[Coordinate coordinateWithX:466 Y:1171]];
        [points addObject:[Coordinate coordinateWithX:483 Y:1150]];
        [points addObject:[Coordinate coordinateWithX:497 Y:1161]];
        [points addObject:[Coordinate coordinateWithX:508 Y:1148]];
        [points addObject:[Coordinate coordinateWithX:517 Y:1156]];
        [points addObject:[Coordinate coordinateWithX:548 Y:1118]];
        [points addObject:[Coordinate coordinateWithX:548 Y:1108]];
        [points addObject:[Coordinate coordinateWithX:544 Y:1104]];
        [aryShopLocation addObject:points];
        
        // Shop33 TESCO
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:1500 Y:1411]];
        [points addObject:[Coordinate coordinateWithX:1594 Y:1411]];
        [points addObject:[Coordinate coordinateWithX:1594 Y:1402]];
        [points addObject:[Coordinate coordinateWithX:1598 Y:1398]];
        [points addObject:[Coordinate coordinateWithX:1638 Y:1398]];
        [points addObject:[Coordinate coordinateWithX:1643 Y:1403]];
        [points addObject:[Coordinate coordinateWithX:1643 Y:1411]];
        [points addObject:[Coordinate coordinateWithX:1702 Y:1411]];
        [points addObject:[Coordinate coordinateWithX:1702 Y:1436]];
        [points addObject:[Coordinate coordinateWithX:1890 Y:1436]];
        [points addObject:[Coordinate coordinateWithX:1890 Y:1661]];
        [points addObject:[Coordinate coordinateWithX:1650 Y:1661]];
        [points addObject:[Coordinate coordinateWithX:1650 Y:1789]];
        [points addObject:[Coordinate coordinateWithX:1500 Y:1789]];
        [aryShopLocation addObject:points];
        
        // Shop34 Card Factory
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:1418 Y:1456]];
        [points addObject:[Coordinate coordinateWithX:1453 Y:1456]];
        [points addObject:[Coordinate coordinateWithX:1453 Y:1546]];
        [points addObject:[Coordinate coordinateWithX:1418 Y:1546]];
        [aryShopLocation addObject:points];
        
        // Shop35 Ladbrokes
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:1383 Y:1456]];
        [points addObject:[Coordinate coordinateWithX:1415 Y:1456]];
        [points addObject:[Coordinate coordinateWithX:1415 Y:1546]];
        [points addObject:[Coordinate coordinateWithX:1383 Y:1546]];
        [aryShopLocation addObject:points];
        
        // Shop36 SUBWAY
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:1344 Y:1456]];
        [points addObject:[Coordinate coordinateWithX:1379 Y:1456]];
        [points addObject:[Coordinate coordinateWithX:1379 Y:1546]];
        [points addObject:[Coordinate coordinateWithX:1344 Y:1546]];
        [aryShopLocation addObject:points];
        
        // Shop37 Walker
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:1309 Y:1456]];
        [points addObject:[Coordinate coordinateWithX:1341 Y:1456]];
        [points addObject:[Coordinate coordinateWithX:1341 Y:1546]];
        [points addObject:[Coordinate coordinateWithX:1309 Y:1546]];
        [aryShopLocation addObject:points];
        
        // Shop38 TUI
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:1272 Y:1456]];
        [points addObject:[Coordinate coordinateWithX:1306 Y:1456]];
        [points addObject:[Coordinate coordinateWithX:1306 Y:1546]];
        [points addObject:[Coordinate coordinateWithX:1272 Y:1546]];
        [aryShopLocation addObject:points];
        
        // Shop39 CAFFE NERO
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:1235 Y:1456]];
        [points addObject:[Coordinate coordinateWithX:1268 Y:1456]];
        [points addObject:[Coordinate coordinateWithX:1268 Y:1559]];
        [points addObject:[Coordinate coordinateWithX:1282 Y:1559]];
        [points addObject:[Coordinate coordinateWithX:1282 Y:1565]];
        [points addObject:[Coordinate coordinateWithX:1235 Y:1565]];
        [aryShopLocation addObject:points];
        
        // Shop40 MONTAOUE
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:1151 Y:1484]];
        [points addObject:[Coordinate coordinateWithX:1186 Y:1484]];
        [points addObject:[Coordinate coordinateWithX:1186 Y:1545]];
        [points addObject:[Coordinate coordinateWithX:1151 Y:1545]];
        [aryShopLocation addObject:points];
        
        // Shop41 TRESPASS
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:1235 Y:1579]];
        [points addObject:[Coordinate coordinateWithX:1453 Y:1579]];
        [points addObject:[Coordinate coordinateWithX:1453 Y:1636]];
        [points addObject:[Coordinate coordinateWithX:1235 Y:1636]];
        [aryShopLocation addObject:points];
        
        // Shop42 Books
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:1236 Y:1651]];
        [points addObject:[Coordinate coordinateWithX:1453 Y:1651]];
        [points addObject:[Coordinate coordinateWithX:1453 Y:1779]];
        [points addObject:[Coordinate coordinateWithX:1196 Y:1779]];
        [points addObject:[Coordinate coordinateWithX:1196 Y:1682]];
        [points addObject:[Coordinate coordinateWithX:1236 Y:1682]];
        [aryShopLocation addObject:points];
        
        // Shop43 Ernest Jones
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:1196 Y:1793]];
        [points addObject:[Coordinate coordinateWithX:1307 Y:1793]];
        [points addObject:[Coordinate coordinateWithX:1307 Y:1831]];
        [points addObject:[Coordinate coordinateWithX:1196 Y:1831]];
        [aryShopLocation addObject:points];
        
        // Shop44 HOLLAND
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:1196 Y:1846]];
        [points addObject:[Coordinate coordinateWithX:1307 Y:1846]];
        [points addObject:[Coordinate coordinateWithX:1307 Y:1887]];
        [points addObject:[Coordinate coordinateWithX:1196 Y:1887]];
        [aryShopLocation addObject:points];
        
        // Shop45 PANDORA
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:1196 Y:1903]];
        [points addObject:[Coordinate coordinateWithX:1307 Y:1903]];
        [points addObject:[Coordinate coordinateWithX:1307 Y:1923]];
        [points addObject:[Coordinate coordinateWithX:1196 Y:1923]];
        [aryShopLocation addObject:points];
        
        // Shop46 smiggle
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:1196 Y:1937]];
        [points addObject:[Coordinate coordinateWithX:1307 Y:1937]];
        [points addObject:[Coordinate coordinateWithX:1307 Y:1960]];
        [points addObject:[Coordinate coordinateWithX:1196 Y:1960]];
        [aryShopLocation addObject:points];
        
        // Shop47 claire's
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:1196 Y:1975]];
        [points addObject:[Coordinate coordinateWithX:1307 Y:1975]];
        [points addObject:[Coordinate coordinateWithX:1307 Y:1995]];
        [points addObject:[Coordinate coordinateWithX:1196 Y:1995]];
        [aryShopLocation addObject:points];
        
        // Shop48 Clintone
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:1196 Y:2009]];
        [points addObject:[Coordinate coordinateWithX:1307 Y:2009]];
        [points addObject:[Coordinate coordinateWithX:1307 Y:2031]];
        [points addObject:[Coordinate coordinateWithX:1196 Y:2031]];
        [aryShopLocation addObject:points];
        
        // Shop49 MOSS
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:1196 Y:2046]];
        [points addObject:[Coordinate coordinateWithX:1307 Y:2046]];
        [points addObject:[Coordinate coordinateWithX:1307 Y:2078]];
        [points addObject:[Coordinate coordinateWithX:1290 Y:2078]];
        [points addObject:[Coordinate coordinateWithX:1290 Y:2103]];
        [points addObject:[Coordinate coordinateWithX:1196 Y:2103]];
        [aryShopLocation addObject:points];
        
        // Shop50 FATFACE
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:1196 Y:2117]];
        [points addObject:[Coordinate coordinateWithX:1293 Y:2117]];
        [points addObject:[Coordinate coordinateWithX:1293 Y:2091]];
        [points addObject:[Coordinate coordinateWithX:1305 Y:2091]];
        [points addObject:[Coordinate coordinateWithX:1305 Y:2212]];
        [points addObject:[Coordinate coordinateWithX:1196 Y:2212]];
        [aryShopLocation addObject:points];
        
        // Shop51 WHSmith
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:1310 Y:2113]];
        [points addObject:[Coordinate coordinateWithX:1378 Y:2113]];
        [points addObject:[Coordinate coordinateWithX:1378 Y:2212]];
        [points addObject:[Coordinate coordinateWithX:1310 Y:2212]];
        [aryShopLocation addObject:points];
        
        // Shop52 STARBUCKES
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:1381 Y:2115]];
        [points addObject:[Coordinate coordinateWithX:1396 Y:2115]];
        [points addObject:[Coordinate coordinateWithX:1396 Y:2101]];
        [points addObject:[Coordinate coordinateWithX:1407 Y:2101]];
        [points addObject:[Coordinate coordinateWithX:1407 Y:2117]];
        [points addObject:[Coordinate coordinateWithX:1491 Y:2117]];
        [points addObject:[Coordinate coordinateWithX:1491 Y:2180]];
        [points addObject:[Coordinate coordinateWithX:1381 Y:2180]];
        [aryShopLocation addObject:points];
        
        // Shop53 Harvester
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:1396 Y:1966]];
        [points addObject:[Coordinate coordinateWithX:1491 Y:1966]];
        [points addObject:[Coordinate coordinateWithX:1491 Y:2103]];
        [points addObject:[Coordinate coordinateWithX:1410 Y:2103]];
        [points addObject:[Coordinate coordinateWithX:1410 Y:2087]];
        [points addObject:[Coordinate coordinateWithX:1396 Y:2087]];
        [aryShopLocation addObject:points];
        
        // Shop54 SUSHI
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:1407 Y:2264]];
        [points addObject:[Coordinate coordinateWithX:1409 Y:2259]];
        [points addObject:[Coordinate coordinateWithX:1411 Y:2256]];
        [points addObject:[Coordinate coordinateWithX:1414 Y:2252]];
        [points addObject:[Coordinate coordinateWithX:1420 Y:2247]];
        [points addObject:[Coordinate coordinateWithX:1429 Y:2242]];
        [points addObject:[Coordinate coordinateWithX:1439 Y:2238]];
        [points addObject:[Coordinate coordinateWithX:1453 Y:2235]];
        [points addObject:[Coordinate coordinateWithX:1467 Y:2234]];
        [points addObject:[Coordinate coordinateWithX:1479 Y:2235]];
        [points addObject:[Coordinate coordinateWithX:1491 Y:2237]];
        [points addObject:[Coordinate coordinateWithX:1503 Y:2241]];
        [points addObject:[Coordinate coordinateWithX:1517 Y:2249]];
        [points addObject:[Coordinate coordinateWithX:1523 Y:2256]];
        [points addObject:[Coordinate coordinateWithX:1527 Y:2263]];
        [points addObject:[Coordinate coordinateWithX:1523 Y:2270]];
        [points addObject:[Coordinate coordinateWithX:1520 Y:2274]];
        [points addObject:[Coordinate coordinateWithX:1517 Y:2276]];
        [points addObject:[Coordinate coordinateWithX:1510 Y:2282]];
        [points addObject:[Coordinate coordinateWithX:1496 Y:2288]];
        [points addObject:[Coordinate coordinateWithX:1485 Y:2290]];
        [points addObject:[Coordinate coordinateWithX:1467 Y:2292]];
        [points addObject:[Coordinate coordinateWithX:1446 Y:2290]];
        [points addObject:[Coordinate coordinateWithX:1432 Y:2286]];
        [points addObject:[Coordinate coordinateWithX:1426 Y:2283]];
        [points addObject:[Coordinate coordinateWithX:1419 Y:2279]];
        [points addObject:[Coordinate coordinateWithX:1411 Y:2271]];
        [aryShopLocation addObject:points];
        
        // Shop55 CHiMiCHANGA
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:1393 Y:2566]];
        [points addObject:[Coordinate coordinateWithX:1488 Y:2566]];
        [points addObject:[Coordinate coordinateWithX:1488 Y:2643]];
        [points addObject:[Coordinate coordinateWithX:1393 Y:2643]];
        [aryShopLocation addObject:points];
        
        // Shop56 PERZZO
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:1393 Y:2476]];
        [points addObject:[Coordinate coordinateWithX:1488 Y:2476]];
        [points addObject:[Coordinate coordinateWithX:1488 Y:2553]];
        [points addObject:[Coordinate coordinateWithX:1393 Y:2553]];
        [aryShopLocation addObject:points];
        
        // Shop57 Frankie
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:1381 Y:2347]];
        [points addObject:[Coordinate coordinateWithX:1488 Y:2347]];
        [points addObject:[Coordinate coordinateWithX:1488 Y:2463]];
        [points addObject:[Coordinate coordinateWithX:1393 Y:2463]];
        [points addObject:[Coordinate coordinateWithX:1393 Y:2452]];
        [points addObject:[Coordinate coordinateWithX:1381 Y:2452]];
        [aryShopLocation addObject:points];
        
        // Shop58 Jonles
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:1310 Y:2317]];
        [points addObject:[Coordinate coordinateWithX:1378 Y:2317]];
        [points addObject:[Coordinate coordinateWithX:1378 Y:2412]];
        [points addObject:[Coordinate coordinateWithX:1310 Y:2412]];
        [aryShopLocation addObject:points];
        
        // Shop59 BEAVERBROOKS
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:1195 Y:2317]];
        [points addObject:[Coordinate coordinateWithX:1305 Y:2317]];
        [points addObject:[Coordinate coordinateWithX:1305 Y:2412]];
        [points addObject:[Coordinate coordinateWithX:1293 Y:2412]];
        [points addObject:[Coordinate coordinateWithX:1293 Y:2398]];
        [points addObject:[Coordinate coordinateWithX:1288 Y:2398]];
        [points addObject:[Coordinate coordinateWithX:1288 Y:2358]];
        [points addObject:[Coordinate coordinateWithX:1195 Y:2358]];
        [aryShopLocation addObject:points];
        
        // Shop60 THE SOOY
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:1195 Y:2373]];
        [points addObject:[Coordinate coordinateWithX:1284 Y:2373]];
        [points addObject:[Coordinate coordinateWithX:1284 Y:2412]];
        [points addObject:[Coordinate coordinateWithX:1195 Y:2412]];
        [aryShopLocation addObject:points];
        
        // Shop61 vision express
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:1195 Y:2426]];
        [points addObject:[Coordinate coordinateWithX:1271 Y:2426]];
        [points addObject:[Coordinate coordinateWithX:1271 Y:2484]];
        [points addObject:[Coordinate coordinateWithX:1195 Y:2484]];
        [aryShopLocation addObject:points];
        
        // Shop62 Phase Eight
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:1195 Y:2497]];
        [points addObject:[Coordinate coordinateWithX:1271 Y:2497]];
        [points addObject:[Coordinate coordinateWithX:1271 Y:2555]];
        [points addObject:[Coordinate coordinateWithX:1195 Y:2555]];
        [aryShopLocation addObject:points];
        
        // Shop63 JONES
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:1195 Y:2569]];
        [points addObject:[Coordinate coordinateWithX:1271 Y:2569]];
        [points addObject:[Coordinate coordinateWithX:1271 Y:2627]];
        [points addObject:[Coordinate coordinateWithX:1195 Y:2627]];
        [aryShopLocation addObject:points];
        
        // Shop64 Pirper
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:1195 Y:2641]];
        [points addObject:[Coordinate coordinateWithX:1271 Y:2641]];
        [points addObject:[Coordinate coordinateWithX:1271 Y:2686]];
        [points addObject:[Coordinate coordinateWithX:1257 Y:2686]];
        [points addObject:[Coordinate coordinateWithX:1257 Y:2700]];
        [points addObject:[Coordinate coordinateWithX:1195 Y:2700]];
        [aryShopLocation addObject:points];
        
        // Shop65 Carphone
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:1195 Y:2713]];
        [points addObject:[Coordinate coordinateWithX:1260 Y:2713]];
        [points addObject:[Coordinate coordinateWithX:1260 Y:2699]];
        [points addObject:[Coordinate coordinateWithX:1271 Y:2699]];
        [points addObject:[Coordinate coordinateWithX:1271 Y:2777]];
        [points addObject:[Coordinate coordinateWithX:1195 Y:2777]];
        [aryShopLocation addObject:points];
        
        // Shop66 COSTA
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:1195 Y:2790]];
        [points addObject:[Coordinate coordinateWithX:1274 Y:2790]];
        [points addObject:[Coordinate coordinateWithX:1274 Y:2730]];
        [points addObject:[Coordinate coordinateWithX:1305 Y:2730]];
        [points addObject:[Coordinate coordinateWithX:1305 Y:2827]];
        [points addObject:[Coordinate coordinateWithX:1195 Y:2827]];
        [aryShopLocation addObject:points];
        
        // Shop67 FUSSY
        //        points = [[NSMutableArray alloc] init];
        //        [points addObject:[Coordinate coordinateWithX:1363 Y:2730]];
        //        [points addObject:[Coordinate coordinateWithX:1419 Y:2730]];
        //        [points addObject:[Coordinate coordinateWithX:1419 Y:2827]];
        //        [points addObject:[Coordinate coordinateWithX:1363 Y:2827]];
        //        [aryShopLocation addObject:points];

        // Shop68 D2A
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:1308 Y:2730]];
        [points addObject:[Coordinate coordinateWithX:1419 Y:2730]];
        [points addObject:[Coordinate coordinateWithX:1419 Y:2827]];
        [points addObject:[Coordinate coordinateWithX:1308 Y:2827]];
        [aryShopLocation addObject:points];
        
        // Shop68 Dearnis
        points = [[NSMutableArray alloc] init];
        [points addObject:[Coordinate coordinateWithX:1422 Y:2730]];
        [points addObject:[Coordinate coordinateWithX:1488 Y:2730]];
        [points addObject:[Coordinate coordinateWithX:1488 Y:2827]];
        [points addObject:[Coordinate coordinateWithX:1422 Y:2827]];
        [aryShopLocation addObject:points];
    }
}

@end
