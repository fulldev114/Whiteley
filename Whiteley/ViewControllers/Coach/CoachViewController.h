//
//  CoachViewController.h
//  Whiteley
//
//  Created by Alex Hong on 4/8/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface CoachViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *textViewIncoming;
@property (weak, nonatomic) IBOutlet UITextView *textViewOutgoing;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UIImageView *imgPageIcon1;
@property (weak, nonatomic) IBOutlet UIImageView *imgPageIcon2;
@property (weak, nonatomic) IBOutlet UIImageView *imgPageIcon3;
//perty (weak, nonatomic) IBOutlet UIImageView *imgPageIcon4;
@property (weak, nonatomic) IBOutlet UIImageView *imgBigPageIcon;
@property (weak, nonatomic) IBOutlet UIImageView *imgNextBigPageIcon;
- (IBAction)onClickNextButton:(id)sender;

@end
