//
//  MonsterListViewController.h
//  Whiteley
//
//  Created by Alex Hong on 4/21/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCDragView.h"

typedef NS_ENUM(NSInteger, MONSTER_SHOW_TYPE) {
    STACK_TYPE = 0,
    GRID_TYPE = 1
};

@interface MonsterListViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate>
@property(nonatomic, assign) NSInteger          m_nShowType;
@property (nonatomic, assign) BOOL              m_bStartedSearch;

@property (strong, nonatomic) IBOutlet UILabel  *lblMsg;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewNoMonsterBack;
@property (weak, nonatomic) IBOutlet UIButton *btnHome;
@property (weak, nonatomic) IBOutlet UIView *viewStartSearch;
@property (weak, nonatomic) IBOutlet UIView *viewRunSearch;
@property (weak, nonatomic) IBOutlet UIButton *btnSearch;
@property (weak, nonatomic) IBOutlet UILabel *lblSearch;
@property (weak, nonatomic) IBOutlet UILabel *lblMCount;
@property (weak, nonatomic) IBOutlet UIView *viewBottom;
@property (retain, nonatomic) UIButton          *btnHelp;
@property (nonatomic, retain) DCDragView        *viewStatck;
@property (nonatomic, strong) UIView            *viewGrid;
@property (nonatomic, strong) UIView            *viewShowMonster;
@property (nonatomic, strong) UICollectionView  *collectGridView;
@property (nonatomic, strong) UIImageView       *imgShowMonster;
@property (nonatomic, retain) UIButton          *btnClose;

- (IBAction)onClickStartSearchButton:(id)sender;
- (IBAction)onClickHomeButton:(id)sender;
- (void) setMonsterViewType;
- (IBAction)onClickHelpButton:(id)sender;

@end
