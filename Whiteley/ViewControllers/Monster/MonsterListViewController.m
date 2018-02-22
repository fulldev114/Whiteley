//
//  MonsterListViewController.m
//  Whiteley
//
//  Created by Alex Hong on 4/21/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import "MonsterListViewController.h"
#import "MonsterHelpViewController.h"
#import "MenuViewController.h"
#import "DCNavigationViewController.h"
#import "GridCollectionViewCell.h"
#import "SCGIFImageView.h"
#import "BeaconMonitor.h"
#import "DXPopover.h"

@interface MonsterListViewController()<UIAlertViewDelegate>
@property (nonatomic, retain) DXPopover         *popover;
@property (nonatomic, retain) UIView            *popContainerView;
@property (nonatomic, retain) SCGIFImageView    *animateSearchImgView;
@property (nonatomic, strong) NSMutableArray    *aryMonster;
@property (nonatomic, strong) NSMutableArray    *aryMonsterImages;
@property (nonatomic, assign) NSInteger         m_nDelMonsterIndex;
@end

@implementation MonsterListViewController
@synthesize viewStatck, viewGrid, aryMonster, aryMonsterImages, collectGridView, viewShowMonster, imgShowMonster, btnClose;
@synthesize btnHelp, viewRunSearch, viewStartSearch, animateSearchImgView;

- (void) viewDidLoad
{
    if ([DCDefines isiPHone4]) {
        [self.viewBottom setCenter:CGPointMake(self.viewBottom.center.x, self.viewBottom.center.y - 86)];
        [self.viewStartSearch setCenter:CGPointMake(self.viewStartSearch.center.x, self.viewStartSearch.center.y - 86)];
        [self.viewRunSearch setCenter:CGPointMake(self.viewRunSearch.center.x, self.viewRunSearch.center.y - 86)];
        [self.lblMsg setCenter:CGPointMake(self.lblMsg.center.x, self.lblMsg.center.y - 20)];
    }
    
    self.popover = [DXPopover new];

    NSString *filePath = [[NSBundle mainBundle]
                          pathForResource:@"dc_monster_search" ofType:@"gif"];
    NSData *myGif = [NSData dataWithContentsOfFile:filePath];
    animateSearchImgView = [[SCGIFImageView alloc] initWithFrame:CGRectMake(253, 20, 50, 50)];
    [animateSearchImgView setData:myGif];
    [self.view addSubview:animateSearchImgView];
 
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"1" forKey:WHITELEY_SHOW_MONSTER_PAGE];
    
    aryMonster = [NSMutableArray arrayWithArray:[userDefaults valueForKey:WHITELEY_GOT_MONSTER]];
    NSInteger mCount = aryMonster.count;
    
    if (mCount > 6) {
        mCount = 6;
    }

    NSString *searchStatus = [userDefaults valueForKey:WHITELEY_ENABLE_FIND_MONSTER];
    NSInteger top_y = 104;
    
    if ([DCDefines isiPHone4]) {
        top_y = 100;
    }
    
    viewGrid = [[UIView alloc] initWithFrame:self.view.frame];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    collectGridView = [[UICollectionView alloc] initWithFrame:CGRectMake(14, top_y, 292, SCREEN_HEIGHT - 180) collectionViewLayout:layout];
    collectGridView.delegate = self;
    collectGridView.dataSource = self;
    [collectGridView registerClass:[GridCollectionViewCell class] forCellWithReuseIdentifier:@"CollectionViewCell"];
    [collectGridView setBackgroundColor:[UIColor clearColor]];
    [viewGrid addSubview:collectGridView];
    [self.view insertSubview:viewGrid belowSubview:self.viewBottom];
    
    self.viewStartSearch.hidden = NO;
    self.viewRunSearch.hidden = NO;
    self.imgViewNoMonsterBack.hidden = NO;
    self.lblMsg.hidden = YES;
    self.lblMCount.text = @"0/6";

    [[BeaconMonitor sharedBeaconMonitor] setIsEasterEgg:YES];
    
    if (searchStatus == nil || [searchStatus isEqualToString:@"0"]) {
        self.viewStartSearch.alpha = 1;
        self.viewRunSearch.alpha = 0;
        animateSearchImgView.hidden = YES;
        self.m_bStartedSearch = NO;
        self.btnSearch.selected = NO;
        self.lblSearch.text = @"START SEARCH";
    }
    else
    {
        self.viewStartSearch.alpha = 0;
        self.viewRunSearch.alpha = 1;
        animateSearchImgView.hidden = NO;
        self.m_bStartedSearch = YES;
        self.btnSearch.selected = YES;
        self.lblSearch.text = @"STOP SEARCH";
        [[BeaconMonitor sharedBeaconMonitor] restartBeaconRanging];
    }
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
   // [userDefault setValue:[NSNumber numberWithInteger:MENU_MONSTER] forKey:WHITELEY_MENU_SELECT];
    [userDefault synchronize];
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    aryMonster = [NSMutableArray arrayWithArray:[userDefaults valueForKey:WHITELEY_GOT_MONSTER]];
    NSInteger mCount = aryMonster.count;
    
    if (mCount > 6) {
        mCount = 6;
    }
    
#if 1
    aryMonsterImages = [[NSMutableArray alloc] init];
    for (int i = (int)aryMonster.count - 1 ; i >= 0; i--) {
        if (aryMonsterImages.count >= 6)
            break;
        NSDictionary *dic = [aryMonster objectAtIndex:i];
        NSString *documentFolderPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *file_name = [documentFolderPath stringByAppendingPathComponent:dic[@"image"]];
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfFile:file_name]];
        
        if (image == nil)
            [aryMonster removeObjectAtIndex:i];
        else
            [aryMonsterImages addObject:image];
    }
    mCount = aryMonster.count;
    
#else
    aryMonsterImages = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 6; i++) {
        UIImage *image = [UIImage imageNamed:@"monster_help1"];
        [aryMonsterImages addObject:image];
    }
#endif
    
    if (aryMonsterImages.count > 0) {
        if (viewStatck.alpha == 0) {
            self.m_nShowType = GRID_TYPE;
            viewGrid.alpha = 1;
            viewStatck.alpha = 0;
            self.lblMsg.hidden = NO;
            self.lblMCount.text = [NSString stringWithFormat:@"%ld/6", (long)aryMonsterImages.count];
            self.imgViewNoMonsterBack.hidden = YES;
            self.viewStartSearch.hidden = YES;
            self.viewRunSearch.hidden = YES;
        }
    }
    [self.collectGridView reloadData];
}

- (void) setMonsterViewType
{
    if (self.m_nShowType == STACK_TYPE) {
        viewGrid.alpha = 1;
        viewStatck.alpha = 0;
        btnClose.alpha = 0;
        [UIView animateWithDuration:0.5 animations:^{
            viewGrid.alpha = 0;
            animateSearchImgView.alpha = 0;
            self.lblMsg.alpha = 0;
            self.btnHome.alpha = 0;
            self.viewBottom.alpha = 0;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                viewStatck.alpha = 1;
                btnClose.alpha = 1;
            }];
        }];
    }
    else
    {
        viewGrid.alpha = 0;
        btnClose.alpha = 1;
        viewStatck.alpha = 1;
        [UIView animateWithDuration:0.5 animations:^{
            viewStatck.alpha = 0;
            btnClose.alpha = 0;

        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                viewGrid.alpha = 1;
                animateSearchImgView.alpha = 1;
                self.lblMsg.alpha = 1;
                self.btnHome.alpha = 1;
                self.viewBottom.alpha = 1;
                [viewStatck removeFromSuperview];
                [btnClose removeFromSuperview];
            }];
        }];
    }
}

- (IBAction)onClickStartSearchButton:(id)sender {
    
   if (![DCDefines isNotifiyEnableBluetooth] && ![DCDefines isNotifyEnableLocation]) {
        CGPoint startPoint = CGPointMake(160, SCREEN_HEIGHT - 88);
        
        UIView *notfiyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 204)];
        [notfiyView setBackgroundColor:[UIColor redColor]];
        
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(32, 16, 26, 25)];
        [icon setImage:[UIImage imageNamed:@"monster_warn"]];
        [notfiyView addSubview:icon];
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(68, 21, 185, 16)];
        title.text = @"WOAH THERE PARTNER!";
        title.font = [UIFont fontWithName:NFONT_BOLD size:15];
        title.textColor = [UIColor whiteColor];
        [notfiyView addSubview:title];
        
        UILabel *content = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, 280, 46)];
        content.numberOfLines = 3;
        content.text = @"TO PLAY THIS GAME YOU MUST TURN ON\nBLUETOOTH AND ENABLE LOCATION\nSHARING IN THE APP SETTINGS.";
        content.font = [UIFont fontWithName:NFONT_LIGHT size:12];
        content.textColor = [UIColor whiteColor];
        content.textAlignment = NSTextAlignmentCenter;
        [notfiyView addSubview:content];

        UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(60, 125, 160, 55)];
        [button1 addTarget:self action:@selector(onClickAppSettings) forControlEvents:UIControlEventTouchUpInside];
        [button1 setImage:[UIImage imageNamed:@"monster_setting"] forState:UIControlStateNormal];
        [notfiyView addSubview:button1];
        
        self.popContainerView = notfiyView;
        [self.popover showAtPoint:startPoint popoverPostion:DXPopoverPositionUp withContentView:self.popContainerView inView:self.view];
        return;
    }
    else if (![DCDefines isNotifiyEnableBluetooth])
    {
        CGPoint startPoint = CGPointMake(160, SCREEN_HEIGHT - 88);
        
        UIView *notfiyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 136)];
        [notfiyView setBackgroundColor:[UIColor redColor]];
        
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(30, 24, 17, 32)];
        [icon setImage:[UIImage imageNamed:@"monster_ble"]];
        [notfiyView addSubview:icon];
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(66, 33, 185, 16)];
        title.text = @"WOAH THERE PARTNER!";
        title.font = [UIFont fontWithName:NFONT_BOLD size:15];
        title.textColor = [UIColor whiteColor];
        [notfiyView addSubview:title];
        
        UILabel *content = [[UILabel alloc] initWithFrame:CGRectMake(0, 72, 280, 29)];
        content.numberOfLines = 3;
        content.text = @"TO PLAY THIS GAME YOU MUST FIRST\nTURN ON YOUR PHONE'S BLUETOOTH.";
        content.font = [UIFont fontWithName:NFONT_LIGHT size:12];
        content.textColor = [UIColor whiteColor];
        content.textAlignment = NSTextAlignmentCenter;
        [notfiyView addSubview:content];
        
        self.popContainerView = notfiyView;
        [self.popover showAtPoint:startPoint popoverPostion:DXPopoverPositionUp withContentView:self.popContainerView inView:self.view];
        return;
    }
    else if (![DCDefines isNotifyEnableLocation])
    {
        CGPoint startPoint = CGPointMake(160, SCREEN_HEIGHT - 88);
        
        UIView *notfiyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 204)];
        [notfiyView setBackgroundColor:[UIColor redColor]];
        
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(32, 16, 24, 24)];
        [icon setImage:[UIImage imageNamed:@"monster_location"]];
        [notfiyView addSubview:icon];
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(68, 21, 185, 16)];
        title.text = @"WOAH THERE PARTNER!";
        title.font = [UIFont fontWithName:NFONT_BOLD size:15];
        title.textColor = [UIColor whiteColor];
        [notfiyView addSubview:title];
        
        UILabel *content = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, 280, 46)];
        content.numberOfLines = 3;
        content.text = @"TO PLAY THIS GAME YOU MUST FIRST\nENABLE LOCATION SHARING\nIN THE APP SETTINGS.";
        content.font = [UIFont fontWithName:NFONT_LIGHT size:12];
        content.textColor = [UIColor whiteColor];
        content.textAlignment = NSTextAlignmentCenter;
        [notfiyView addSubview:content];
        
        UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(60, 125, 160, 55)];
        [button1 addTarget:self action:@selector(onClickAppSettings) forControlEvents:UIControlEventTouchUpInside];
        [button1 setImage:[UIImage imageNamed:@"monster_setting"] forState:UIControlStateNormal];
        [notfiyView addSubview:button1];
        
        self.popContainerView = notfiyView;
        [self.popover showAtPoint:startPoint popoverPostion:DXPopoverPositionUp withContentView:self.popContainerView inView:self.view];
        return;
    }
    
    self.m_bStartedSearch = !self.m_bStartedSearch;
    [self.btnSearch setSelected:self.m_bStartedSearch];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (self.m_bStartedSearch) {
        if (aryMonsterImages.count == 0) {
            [UIView animateWithDuration:0.3 animations:^{
                self.viewStartSearch.alpha = 0;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.3 animations:^{
                    self.viewRunSearch.alpha = 1;
                }];
            }];
        }
        [userDefaults setValue:@"1" forKey:WHITELEY_ENABLE_FIND_MONSTER];
        animateSearchImgView.hidden = NO;
        self.lblSearch.text = @"STOP SEARCH";
        
        [[BeaconMonitor sharedBeaconMonitor] restartBeaconRanging];
    }
    else
    {
        if (aryMonsterImages.count == 0) {
            [UIView animateWithDuration:0.3 animations:^{
                self.viewRunSearch.alpha = 0;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.3 animations:^{
                    self.viewStartSearch.alpha = 1;
                }];
            }];
        }
        [userDefaults setValue:@"0" forKey:WHITELEY_ENABLE_FIND_MONSTER];
        animateSearchImgView.hidden = YES;
        self.lblSearch.text = @"START SEARCH";
        
        [[BeaconMonitor sharedBeaconMonitor] stopBeaconRanging];
    }
    
    [userDefaults synchronize];
}

- (void) onClickAppSettings
{
    [self.popover dismiss];
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    
}

- (IBAction)onClickHelpButton:(id)sender {
    MonsterHelpViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MonsterHelpViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onClickHomeButton:(id)sender {
    CGPoint startPoint = CGPointMake(32, 54);
    
    UIView *notfiyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 166)];
    [notfiyView setBackgroundColor:[UIColor redColor]];
    
    UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(24, 17, 253, 55)];
    [button1 addTarget:self action:@selector(onClickExitKeepButton) forControlEvents:UIControlEventTouchUpInside];
    [button1 setImage:[UIImage imageNamed:@"monster_exit1"] forState:UIControlStateNormal];
    [notfiyView addSubview:button1];
    
    UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(24, 90, 253, 55)];
    [button2 addTarget:self action:@selector(onClickExitStopButton) forControlEvents:UIControlEventTouchUpInside];
    [button2 setImage:[UIImage imageNamed:@"monster_exit2"] forState:UIControlStateNormal];
    [notfiyView addSubview:button2];
    
    self.popContainerView = notfiyView;
    [self.popover showAtPoint:startPoint popoverPostion:DXPopoverPositionDown withContentView:self.popContainerView inView:self.view];
}

- (void)onClickExitKeepButton
{
    [[BeaconMonitor sharedBeaconMonitor] setIsEasterEgg:NO];
    [[BeaconMonitor sharedBeaconMonitor] restartBeaconRanging];
    [self removeSubViews];

    [self.navigationController popToRootViewControllerAnimated:YES];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:@"1" forKey:WHITELEY_ENABLE_FIND_MONSTER];
    [userDefaults setValue:@"0" forKey:WHITELEY_SHOW_MONSTER_PAGE];
    [userDefaults synchronize];
}

- (void)onClickExitStopButton
{
    [[BeaconMonitor sharedBeaconMonitor] setIsEasterEgg:NO];
    [[BeaconMonitor sharedBeaconMonitor] restartBeaconRanging];
    [self removeSubViews];
    [self.navigationController popToRootViewControllerAnimated:YES];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:@"0" forKey:WHITELEY_ENABLE_FIND_MONSTER];
    [userDefaults setValue:@"0" forKey:WHITELEY_SHOW_MONSTER_PAGE];
    [userDefaults synchronize];

}

- (void) removeSubViews {
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            UIImageView *imgView = (UIImageView*)view;
            imgView.image = nil;
        }
        [view removeFromSuperview];
    }
    
    for (UIView *view in self.viewStatck.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            UIImageView *imgView = (UIImageView*)view;
            imgView.image = nil;
        }
        [view removeFromSuperview];
    }
    
    for (int i = 0; i < aryMonsterImages.count; i++) {
        NSIndexPath *indexPath = [[NSIndexPath alloc] initWithIndex:i];
        GridCollectionViewCell *cell = (GridCollectionViewCell*)[self.collectGridView cellForItemAtIndexPath:indexPath];
        cell.imgMonster.image = nil;
        [cell.imgMonster removeFromSuperview];
        cell.btnRemove.imageView.image = nil;
        [cell.btnRemove removeFromSuperview];
    }
}

- (void) onClickDeleteMonster:(UIButton*)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Remove this Easter Egg?" message:@"Select 'Remove' to permanently delete\nthis egg from your phone." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Remove", nil];
    [alert show];
    self.m_nDelMonsterIndex = sender.tag;
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {

    if (aryMonsterImages.count == 0) {
        return 0;
    }
    return 6;
}

-(void) onClickCloseGridView
{
    self.m_nShowType = GRID_TYPE;
    [self setMonsterViewType];
}

#define kImageViewTag 1 // the image view inside the collection view cell prototype is tagged with "1"

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    GridCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"CollectionViewCell" forIndexPath:indexPath];
    
    // apply the image to the cell
    if (indexPath.row > aryMonsterImages.count-1) {
        UIImage *img = [UIImage imageNamed:@"monster_empty"];
        [cell.imgMonster setImage:img];
        cell.btnRemove.hidden = YES;
    }
    else
    {
        UIImage *img = [aryMonsterImages objectAtIndex:indexPath.row];
        [cell.imgMonster setImage:img];
        [cell.btnRemove addTarget:self action:@selector(onClickDeleteMonster:) forControlEvents:UIControlEventTouchUpInside];
        cell.btnRemove.tag = indexPath.row;
        cell.btnRemove.hidden = NO;
    }
    return cell;
}


#pragma mark - Segue support

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"showPhoto"]) {
        
        // hand off the assets of this album to our singleton data source
    }
}

- (void)collectionView:(UICollectionView *)cv didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row > aryMonsterImages.count-1) {
        return;
    }
    self.m_nShowType = STACK_TYPE;
    viewStatck = [[DCDragView alloc] initWithFrame:self.view.frame andImages:aryMonsterImages currentIndex:indexPath.row];
    viewStatck.rootController = self;
    [self.view insertSubview:viewStatck aboveSubview:self.btnHome];
    [self.view addSubview:viewStatck];
    btnClose = [[UIButton alloc] initWithFrame:CGRectMake(274, 33, 40, 40)];
    [btnClose setImage:[UIImage imageNamed:@"dc_monster_close"] forState:UIControlStateNormal];
    [btnClose addTarget:self action:@selector(onClickCloseGridView) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:btnClose aboveSubview:viewStatck];
    [self setMonsterViewType];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([DCDefines isiPHone4])
        return CGSizeMake(85, 115);

    return CGSizeMake(85, 180);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        return;
    }
    
    NSInteger del_index = self.m_nDelMonsterIndex;
    [aryMonsterImages removeObjectAtIndex:del_index];

    del_index = aryMonster.count - del_index - 1;
    NSDictionary *dic = [aryMonster objectAtIndex:del_index];
    NSString *strImage = [NSString stringWithFormat:@"photo_%@.png", dic[@"id"]];
    NSString *documentFolderPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString* file_name = [documentFolderPath stringByAppendingPathComponent:strImage];
    NSError *error = nil;
    
    [[NSFileManager defaultManager] removeItemAtPath:file_name error:&error];

    [aryMonster removeObjectAtIndex:del_index];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setValue:aryMonster forKey:WHITELEY_GOT_MONSTER];
    [userDefaults synchronize];
    
    NSString *searchStatus = [userDefaults valueForKey:WHITELEY_ENABLE_FIND_MONSTER];
    
    if (aryMonsterImages.count == 0) {
        self.viewStartSearch.hidden = NO;
        self.viewRunSearch.hidden = NO;
        self.imgViewNoMonsterBack.hidden = NO;
        self.lblMsg.hidden = YES;
        self.lblMCount.text = @"0/6";
        
        if (searchStatus == nil || [searchStatus isEqualToString:@"0"]) {
            self.viewStartSearch.alpha = 1;
            self.viewRunSearch.alpha = 0;
        }
        else
        {
            self.viewStartSearch.alpha = 0;
            self.viewRunSearch.alpha = 1;
        }
    }
    else
    {
        self.lblMCount.text = [NSString stringWithFormat:@"%ld/6", (long)aryMonsterImages.count];
    }

    [self.collectGridView reloadData];
    
    if ( self.m_bStartedSearch )
        [[BeaconMonitor sharedBeaconMonitor] restartBeaconRanging];

}
@end
