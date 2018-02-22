//
//  GridCollectionViewCell.m
//  Whiteley
//
//  Created by Alex Hong on 4/29/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import "GridCollectionViewCell.h"

@implementation GridCollectionViewCell
@synthesize imgMonster, btnRemove;
-(id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if(self != nil)
    {
        imgMonster = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 85, 130)];
        [self addSubview:imgMonster];
        
        btnRemove = [[UIButton alloc] initWithFrame:CGRectMake(0, 132, 85, 44)];
        [btnRemove setImage:[UIImage imageNamed:@"dc_monster_remove"] forState:UIControlStateNormal];
        [self addSubview:btnRemove];
    }
    return self;
}

-(void)layoutSubviews
{

}

@end
