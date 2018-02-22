//
//  DCDragView.m
//  DrakeCircus
//
//  Created by Alex Hong on 4/28/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import "DCDragView.h"
#import "MonsterListViewController.h"
#import "DCDefines.h"

typedef enum {
    DCDragViewDirectionUp,
    DCDragViewDirectionDown
}DCDragViewDirection;

@interface DCDragView ()

@property (nonatomic, assign)DCDragViewDirection direction;
@property (nonatomic, assign)NSInteger  nextIndex;
@property (nonatomic, assign)NSInteger  imageCount;
@property (nonatomic, strong)NSMutableArray *imageViews;
@property (nonatomic, assign)CGRect     orgViewRect;
@property (assign) BOOL m_bAnimated;

@end

@implementation DCDragView
{
    UIImageView *currentImageView;
    UIImageView *nextImageView;
    NSLock      *swipLock;
    NSLock      *swipEndLock;
    
}

@synthesize aryImages, currentIndex, showCount, imageCount, orgViewRect, rootController, m_bAnimated;

-(id)initWithFrame:(CGRect)frame andImages:(NSMutableArray *)images currentIndex:(NSInteger)index
{
    self = [super initWithFrame:frame];
    if (self) {
        aryImages = [[NSMutableArray alloc] initWithArray:images];
        imageCount = aryImages.count;
        currentIndex = index;
        
        if (imageCount > 6)
            showCount = 6;
        else
            showCount = aryImages.count;
        
        NSMutableArray *aryIndex = [[NSMutableArray alloc] init];
        for (int i = 0; i < showCount; i++) {
            NSInteger index = currentIndex + i;
            if (index >= imageCount) {
                [aryIndex addObject:[NSNumber numberWithInteger:index-imageCount]];
            }
            else
                [aryIndex addObject:[NSNumber numberWithInteger:index]];
        }
        
        for (int i = (int)showCount-1; i>=0; i--) {
            UIImageView *imgView = [[UIImageView alloc] initWithImage:[aryImages objectAtIndex:[[aryIndex objectAtIndex:i] integerValue]]];
            [self addSubview:imgView];
        }
        
        [self setFrameToImageViews];
        
        self.userInteractionEnabled = YES;
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        pan.maximumNumberOfTouches = 1;
        [self addGestureRecognizer:pan];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:tap];
        
        swipLock = [[NSLock alloc] init];
        swipEndLock = [[NSLock alloc] init];
        
        m_bAnimated = NO;
    }
    return self;
}

- (void)setFrameToImageViews
{
    NSInteger top_y = 120;
    if ([DCDefines isiPHone4]) {
        top_y = 60;
    }
    
    for (int i = 0; i < showCount; i++) {
        CGPoint p = CGPointMake(30 + 10 * (showCount - i - 1), top_y + 8 * i);
        CGRect rect = CGRectMake(p.x, p.y, 320 - p.x * 2, (320 - p.x * 2) * 1.48);
        UIImageView *view = [self.subviews objectAtIndex:i];
        view.frame = rect;
    }
    
}

- (void)handleTap:(UITapGestureRecognizer *)sender
{
    CGPoint p = [sender locationInView:self];
    BOOL isBackFlag = YES;
    
    for (int i = 0; i < self.subviews.count; i++) {
        UIView *view = [self.subviews objectAtIndex:i];
        CGRect rect = view.frame;
        if (p.x >= rect.origin.x && p.y >= rect.origin.y && p.x <= rect.origin.x + rect.size.width && p.y <= rect.origin.y + rect.size.height) {
            isBackFlag = NO;
            break;
        }
    }
    if (isBackFlag) {
        MonsterListViewController *vc = (MonsterListViewController*)rootController;
        vc.m_nShowType = GRID_TYPE;
        [vc setMonsterViewType];
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)sender
{
    //    CGPoint velocity = [sender velocityInView:sender.view];
    
    //    if (sender.state == UIGestureRecognizerStateBegan) {
    //
    //        if (velocity.y > 0) {
    //            _direction = DCDragViewDirectionDown;
    //        } else {
    //            _direction = DCDragViewDirectionUp;
    //        }
    //
    //    }
    if (!m_bAnimated) {
        [self handleUpDownGesture:sender];
    }
    
}
- (void)handleUpDownGesture:(UIPanGestureRecognizer *)sender
{
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        if (m_bAnimated) {
            return;
        }
        
        currentImageView = [[self subviews] lastObject];
        orgViewRect = currentImageView.frame;
        MonsterListViewController *vc = (MonsterListViewController*)rootController;
        vc.btnClose.alpha = 0;
        
        if ( imageCount != 1) {
            NSInteger nextIndex = currentIndex - 1;
            
            if (nextIndex < 0)
                nextIndex = imageCount - 1;
            
            [nextImageView removeFromSuperview];
            nextImageView = [[UIImageView alloc] initWithImage:[aryImages objectAtIndex:nextIndex]];
            UIImageView *beforeImageView = [[self subviews] objectAtIndex:showCount- 2];
            nextImageView.frame = beforeImageView.frame;
            [self insertSubview:nextImageView belowSubview:currentImageView];
            nextImageView.hidden = YES;
            
        }
    }
    
    if (!m_bAnimated) {
        CGPoint velocity = [sender velocityInView:sender.view];
        CGRect rect = currentImageView.frame;
        rect.origin.y += velocity.y * 0.01;
        currentImageView.frame = rect;
        
        if (rect.origin.y < orgViewRect.origin.y) {
            if (nextImageView.hidden) {
                nextImageView.hidden = NO;
            }
        }
        else
        {
            if (!nextImageView.hidden) {
                nextImageView.hidden = YES;
            }
        }
    }
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        if (m_bAnimated) {
            return;
        }
        
        CGRect rect = currentImageView.frame;
        
        if (rect.origin.y < orgViewRect.origin.y)
            _direction = DCDragViewDirectionUp;
        else
            _direction = DCDragViewDirectionDown;
        
        MonsterListViewController *vc = (MonsterListViewController*)rootController;
        if (ABS(orgViewRect.origin.y - currentImageView.frame.origin.y) < 15 || imageCount == 1) {
            [nextImageView removeFromSuperview];
            [UIView animateWithDuration:0.5 animations:^{
                currentImageView.frame = orgViewRect;
            } completion:^(BOOL finished) {
                vc.btnClose.alpha = 1;
            }];
            return;
        }
        
        m_bAnimated = YES;
        
        if (_direction == DCDragViewDirectionDown) {
            [UIView animateWithDuration:0.5 animations:^{
                
                CGRect rect = currentImageView.frame;
                rect.origin.y = self.frame.size.height;
                currentImageView.frame = rect;
                
            } completion:^(BOOL finished) {
                
                [nextImageView removeFromSuperview];
                
                UIImageView *imgView = [[self subviews] lastObject];
                [imgView removeFromSuperview];
                
                currentIndex++;
                if (currentIndex == imageCount)
                    currentIndex = 0;
                
                NSInteger newIndex = currentIndex + showCount - 1;
                
                if (newIndex >= imageCount )
                    newIndex -= imageCount;
                
                UIImageView *newImgView = [[UIImageView alloc] initWithImage:[aryImages objectAtIndex:newIndex]];
                
                [self insertSubview:newImgView atIndex:0];
                newImgView.alpha = 0;
                
                [UIView animateWithDuration:0.3 animations:^{
                    [self setFrameToImageViews];
                    
                } completion:^(BOOL finished) {
                    newImgView.alpha = 1;
                    vc.btnClose.alpha = 1;
                    m_bAnimated = NO;
                    
                }];
            }];
            
        }
        else
        {
            [UIView animateWithDuration:0.5 animations:^{
                
                CGRect rect = currentImageView.frame;
                rect.origin.y = -self.frame.size.height;
                currentImageView.frame = rect;
                
            } completion:^(BOOL finished) {
                [self bringSubviewToFront:nextImageView];
                UIImageView *imgView = [[self subviews] firstObject];
                [imgView removeFromSuperview];
                
                currentIndex--;
                
                if (currentIndex < 0 )
                    currentIndex = imageCount - 1;
                
                UIImageView *newImgView = [[UIImageView alloc] initWithImage:[aryImages objectAtIndex:currentIndex]];
                [self insertSubview:newImgView atIndex:showCount-1];
                newImgView.alpha = 0;
                currentImageView.alpha = 0;
                [UIView animateWithDuration:0.3 animations:^{
                    [self setFrameToImageViews];
                    UIImageView *view = [[self subviews] objectAtIndex:showCount-1];
                    nextImageView.frame = view.frame;
                } completion:^(BOOL finished) {
                    [nextImageView removeFromSuperview];
                    newImgView.alpha = 1;
                    currentImageView.alpha = 1;
                    vc.btnClose.alpha = 1;
                    m_bAnimated = NO;
                    currentImageView = [[self subviews] lastObject];
                    if ( imageCount != 1) {
                        NSInteger nextIndex = currentIndex - 1;
                        
                        if (nextIndex < 0)
                            nextIndex = imageCount - 1;
                        
                        nextImageView = [[UIImageView alloc] initWithImage:[aryImages objectAtIndex:nextIndex]];
                        UIImageView *beforeImageView = [[self subviews] objectAtIndex:showCount- 2];
                        nextImageView.frame = beforeImageView.frame;
                        [self insertSubview:nextImageView belowSubview:currentImageView];
                        nextImageView.hidden = YES;
                        
                    }
                }];
            }];
        }
        
    }
    
    
}

@end
