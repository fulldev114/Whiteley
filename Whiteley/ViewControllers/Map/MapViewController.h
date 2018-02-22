//
//  MapViewController.h
//  Whiteley
//
//  Created by Alex Hong on 4/10/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "DCBaseViewController.h"

typedef NS_ENUM(NSInteger, FLOOR_TYPE) {
    LOWER_MALL = 0,
    UPPER_MALL = 1,
    FOOD_COURT = 2
};

@interface Coordinate : NSObject

@property float x;
@property float y;
+ (Coordinate*) coordinateWithX:(double)sx Y:(double)sy;
@end

@interface MapViewController : DCBaseViewController<UITextFieldDelegate,UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, CLLocationManagerDelegate>
{
   CLLocationManager *locationManager;
}
@property (strong, nonatomic) IBOutlet UIButton     *btnFacilites;
@property (strong, nonatomic) IBOutlet UIButton     *btnFloor;
@property (strong, nonatomic) IBOutlet UIButton     *btnArrow;
@property (strong, nonatomic) IBOutlet UITextField  *txtSearch;
@property (strong, nonatomic) IBOutlet UIView       *mapSearchView;
@property (nonatomic, retain) UIView                *mapFacilitesView;
@property (strong, nonatomic) IBOutlet UITableView  *tableView;
@property (nonatomic, retain) NSMutableArray        *dcAllStores;
@property (nonatomic, retain) NSMutableArray        *dcCategoryStores;
@property (nonatomic, retain) NSMutableArray        *dcStores;
@property (nonatomic, strong) NSArray               *dcCategories;
@property (nonatomic, assign) NSInteger             m_nCentureFloor;
@property (nonatomic, assign) NSString              *m_sSelectedShopID;

@property (strong, nonatomic) IBOutlet UIButton     *button1;
@property (strong, nonatomic) IBOutlet UIButton     *button2;
@property (nonatomic, retain) UIButton              *viewLocationTooltip;
@property (nonatomic, retain) UIButton              *viewOutsideTooltip;
@property (nonatomic, strong) UIImageView           *userMapArrow;
@property (nonatomic, assign) BOOL                  m_bSectionFacilites;
@property (nonatomic, assign) BOOL                  m_bOutsideAlert;
@property (nonatomic, retain) Coordinate            *userMapLocation;
@property (strong, nonatomic) UIView                *backView;
@property (strong, nonatomic) UIImageView           *sadImageView;
@property (strong, nonatomic) UITextView            *noItemContent;

- (IBAction)onClickCloseSearchViewButton:(id)sender;
- (IBAction)onClickListButton:(id)sender;
- (void) setStoreInfo:(NSInteger) floor;
- (void) removeMapView;

@end
