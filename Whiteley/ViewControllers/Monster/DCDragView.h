//
//  DCDragView.h
//  Whiteley
//
//  Created by Alex Hong on 4/28/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DCDragView : UIView

@property (nonatomic, strong)NSArray    *aryImages;
@property (nonatomic, assign)NSInteger  currentIndex;
@property (nonatomic, assign)NSInteger  showCount;
@property (nonatomic, retain)UIViewController *rootController;

-(id)initWithFrame:(CGRect)frame andImages:(NSMutableArray *)images currentIndex:(NSInteger)index;

@end
