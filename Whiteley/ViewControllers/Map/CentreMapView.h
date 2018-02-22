//
//  CentreMapView.h
//  Video Zoom
//
//  Created by Danny Witters on 05/10/2014.
//  Copyright (c) 2014 CaptureProof. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapViewController.h"
#import "SCGIFImageView.h"

@interface CentreMapView : UIScrollView <UIScrollViewDelegate>
@property (nonatomic, strong) NSArray           *dcStores;
@property (nonatomic, retain) MapViewController *rootViewController;
@property (nonatomic, strong) UIImageView       *imageView;
@property (nonatomic, retain) UIView            *viewTooltip;
- (id)initWithFrame:(CGRect)frame parentController:(UIViewController*)parent andImage:(UIImage *)image;
- (void) showShopUnitTooltip:(NSInteger) index searchFlag:(BOOL) flag;
- (void) onClickFacItemButton:(id) sender;
- (void) setFacilitesInfo:(NSInteger) floor_index;
- (void) setHiddenHighlitedView;
- (void) setShopPosition;
- (void) setShopCentreAngle;
- (void) showSelectedShop:(NSInteger) index;
-(BOOL)point:(Coordinate*)c In:(NSArray*)pointArray;
@end
