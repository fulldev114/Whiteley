//
//  CoachViewController.m
//  Whiteley
//
//  Created by Alex Hong on 4/8/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import "CoachViewController.h"
#import "DCNavigationViewController.h"

@interface CoachViewController ()
{
    CGFloat         out_time;
    CGFloat         in_time;
    NSInteger       m_PlayStep;
    BOOL            m_bPlaying;
    NSMutableArray  *dcStores;
    NSMutableArray  *aryCarousel;
}

@property (strong, nonatomic) MPMoviePlayerController *mPlayer;
@property (strong, nonatomic) MPMoviePlayerController *mPlayer2;

@end

@implementation CoachViewController
@synthesize textViewIncoming, textViewOutgoing, btnNext, imgBigPageIcon, imgNextBigPageIcon, imgPageIcon1, imgPageIcon2, imgPageIcon3; //imgPageIcon4;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.navigationController setNavigationBarHidden:YES animated:NO];

    [[UIApplication sharedApplication] setStatusBarHidden:YES];

    if ([DCDefines isiPHone4])
        btnNext.hidden = YES;
    
    m_PlayStep = 1;
    
    [self.view setBackgroundColor:[UIColor colorWithRed:3/255.0f green:182/255.0f blue:217/255.0f alpha:1]];
    
    CGFloat topCorrect = ([textViewIncoming bounds].size.height - [textViewIncoming contentSize].height);
    topCorrect = (topCorrect <0.0 ? 0.0 : topCorrect);
    [textViewIncoming setContentInset:UIEdgeInsetsMake(topCorrect/2, 0, topCorrect/2, 0)];
    
    topCorrect = ([textViewOutgoing bounds].size.height - [textViewOutgoing contentSize].height);
    topCorrect = (topCorrect <0.0 ? 0.0 : topCorrect);
    [textViewOutgoing setContentInset:UIEdgeInsetsMake(topCorrect/2, 0, topCorrect/2, 0)];
    
    btnNext.alpha = 0;
    imgPageIcon1.alpha = 0.0f;
    imgPageIcon2.alpha = 0.0f;
    imgPageIcon3.alpha = 0.0f;
    //imgPageIcon4.alpha = 0.0f;
    imgBigPageIcon.alpha = 0.0f;
    imgNextBigPageIcon.alpha = 0.0f;
    
    self.mPlayer = [[MPMoviePlayerController alloc] init];
    self.mPlayer.movieSourceType = MPMovieSourceTypeFile;
    self.mPlayer.fullscreen = YES;
    self.mPlayer.scalingMode = MPMovieScalingModeFill;
    self.mPlayer.controlStyle = MPMovieControlStyleNone;
    self.mPlayer.backgroundView.backgroundColor = [UIColor clearColor];
    self.mPlayer.view.frame = CGRectMake(0, 0, 320, 320);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieFinishedCallback:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:self.mPlayer];
    
    self.mPlayer2 = [[MPMoviePlayerController alloc] init];
    self.mPlayer2.movieSourceType = MPMovieSourceTypeFile;
    self.mPlayer2.fullscreen = YES;
    self.mPlayer2.scalingMode = MPMovieScalingModeFill;
    self.mPlayer2.controlStyle = MPMovieControlStyleNone;
    self.mPlayer2.backgroundView.backgroundColor = [UIColor clearColor];
    self.mPlayer2.view.frame = CGRectMake(0, 0, 320, 320);
    self.mPlayer2.view.hidden = YES;
    
    NSString *file_path = [NSString stringWithFormat:@"section_0%ld", (long)m_PlayStep];
    NSString *movFilePath = [[NSBundle mainBundle] pathForResource:file_path ofType:@"mov"];
    NSURL *path = [NSURL fileURLWithPath:movFilePath];
    [self.mPlayer setContentURL:path];
    [self.mPlayer prepareToPlay];
    
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(addMovPlayer) userInfo:nil repeats:NO];
    
    [self getStoreFromWebServer];
    
    [self performSelectorInBackground:@selector(getCarouselFromWebServer) withObject:nil];
    
    UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onClickPanGesture:)];
    [self.view addGestureRecognizer:gesture];
    self.view.userInteractionEnabled = YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void) addMovPlayer
{
    [self.mPlayer play];
    //[btnNext setUserInteractionEnabled:NO];
    [self.view addSubview:[self.mPlayer view]];
    [self showInfoView:m_PlayStep];
    
}

- (void) movieFinishedCallback:(NSNotification*) aNotification
{
    //[btnNext setUserInteractionEnabled:YES];
    if (m_PlayStep >= 4) {
        //[self.navigationController popViewControllerAnimated:YES];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:@"read" forKey:@"coach_read"];
        [userDefaults synchronize];

        [userDefaults setObject:@"start" forKey:WHITELEY_NOTIFY_STEP];

        UIViewController *homeController = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
        
        DCNavigationViewController *dc = [[DCNavigationViewController alloc] initWithRootViewController:homeController];
        dc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:dc animated:YES completion:nil];
    }
}

- (void) getCarouselFromWebServer
{
    [DCDefines getHttpAsyncResponse:DCWEBAPI_GET_HOME_CAROUSEL withHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSData *responseData = data;
        
        if (responseData == nil) {
            return;
        }
        
        NSError* errorInfo;
        NSDictionary *dic  = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&errorInfo];
        aryCarousel = [dic valueForKey:@"result"];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:aryCarousel forKey:WHITELEY_CAROUSEL_LIST];
        [userDefaults synchronize];
        
        [self performSelectorInBackground:@selector(downloadCarouselImageFromWebServer) withObject:nil];
    }];
}

- (void)downloadCarouselImageFromWebServer
{
    for (int i = 0; i < aryCarousel.count; i++)
    {
        NSDictionary *dic = [aryCarousel objectAtIndex:i];
        NSString *imgURL = dic[@"image"];
        
        if (imgURL.length ==0 || imgURL == nil)
            continue;
        
        NSString *URL = [imgURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        // new download
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:URL]];
        
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
         {
             if (connectionError == nil)
             {
                 UIImage *img = [UIImage imageWithData:data];
                 
                 NSString *strImage = [NSString stringWithFormat:@"carousel_%@.png", dic[@"id"]];
                 if ( img != nil )
                 {
                     NSString *documentFolderPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
                     NSString* file_name = [documentFolderPath stringByAppendingPathComponent:strImage];
                     
                     NSData *imgData = UIImagePNGRepresentation(img);
                     [imgData writeToFile:file_name atomically:YES];
                     
                 }
                 
             }
         }];
    }
}

- (void) getStoreFromWebServer
{
    dcStores = [[NSMutableArray alloc] init];

    NSMutableArray *dcCategories = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *dcFavoriteData = [[[NSUserDefaults standardUserDefaults] valueForKey:WHITELEY_FOVORITE_STORE] mutableCopy];
    
    if (dcFavoriteData == nil)
        dcFavoriteData = [[NSMutableDictionary alloc] init];
    
    [DCDefines getHttpAsyncResponse:DCWEBAPI_GET_STORE_NAME withHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSData *responseData = data;
        
        if (responseData == nil) {
            return;
        }
        
        NSError* errorInfo;
        NSDictionary *dic  = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&errorInfo];
        NSMutableArray *aryStoreName = [dic valueForKey:@"result"];
        for (int i = 0; i < aryStoreName.count; i++) {
            NSMutableDictionary *dicStore = [aryStoreName objectAtIndex:i];
            NSString *favoriteFlag = [dcFavoriteData valueForKey:dicStore[@"id"]];
            if (favoriteFlag == nil || favoriteFlag.length == 0)
            {
                [dcFavoriteData setValue:@"0" forKey:dicStore[@"id"]];
                favoriteFlag = @"0";
            }
            NSMutableDictionary *store = [[NSMutableDictionary alloc] init];
            [store setValue:[dicStore valueForKey:@"id"] forKey:@"id"];
            [store setValue:[dicStore valueForKey:@"label"] forKey:@"label"];
            [store setValue:[dicStore valueForKey:@"name"] forKey:@"name"];
            [store setValue:[dicStore valueForKey:@"location"] forKey:@"location"];
            [store setValue:[dicStore valueForKey:@"unit_num"] forKey:@"unit_num"];
            [store setValue:[dicStore valueForKey:@"has_offer"] forKey:@"hasoffer"];
            [store setValue:[dicStore valueForKey:@"cat_id"] forKey:@"cat_id"];
            [store setValue:favoriteFlag forKey:@"favorite"];
            
            [dcStores addObject:store];
        }
        
        [self performSelectorInBackground:@selector(downloadLogoImageFromWebServer) withObject:nil];

        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:dcStores forKey:WHITELEY_STORE_LIST];
        [userDefaults setObject:dcFavoriteData forKey:WHITELEY_FOVORITE_STORE];
        [userDefaults synchronize];
        
        [DCDefines getHttpAsyncResponse:DCWEBAPI_GET_STORE_CATEGORY withHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            NSData *responseData = data;
            
            if (responseData == nil)
            {
                return;
            }
            
            NSError* errorInfo;
            NSDictionary *dic  = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&errorInfo];
            NSMutableArray *aryCategoryName = [dic valueForKey:@"result"];
            for (int i = 0; i < aryCategoryName.count; i++) {
                NSMutableDictionary *dicCategory = [aryCategoryName objectAtIndex:i];
                NSMutableDictionary *category = [NSMutableDictionary dictionaryWithObjectsAndKeys:[dicCategory valueForKey:@"id"], @"id",
                                                 [dicCategory valueForKey:@"name"], @"name", nil];
                [dcCategories addObject:category];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:dcCategories forKey:WHITELEY_CATEGORY_LIST];
                [userDefaults synchronize];
            });
        }];
        
    }];
    
}

- (void)downloadLogoImageFromWebServer
{
    for (int i = 0; i < dcStores.count; i++)
    {
        NSDictionary *dic = [dcStores objectAtIndex:i];
        NSString *imgURL = dic[@"label"];
        
        if (imgURL.length ==0 || imgURL == nil)
            continue;
        
        NSString *URL = [dic[@"label"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [DCDefines getHttpAsyncResponse:URL withHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error == nil)
            {
                UIImage *img = [UIImage imageWithData:data];
                
                NSString *strImage = [NSString stringWithFormat:@"logo_%@.png", dic[@"id"]];
                if ( img != nil )
                {
                    NSString *documentFolderPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
                    NSString* file_name = [documentFolderPath stringByAppendingPathComponent:strImage];
                    
                    NSData *imgData = UIImagePNGRepresentation(img);
                    [imgData writeToFile:file_name atomically:YES];
                    
                }
                
            }
        }];
        
#if 0
        // new download
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:URL]];
        
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
         {
             if (connectionError == nil)
             {
                 UIImage *img = [UIImage imageWithData:data];
                 
                 NSString *strImage = [NSString stringWithFormat:@"logo_%@.png", dic[@"id"]];
                 if ( img != nil )
                 {
                     NSString *documentFolderPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
                     NSString* file_name = [documentFolderPath stringByAppendingPathComponent:strImage];
                     
                     NSData *imgData = UIImagePNGRepresentation(img);
                     [imgData writeToFile:file_name atomically:YES];
                     
                 }
                 
             }
         }];
#endif
    }
}

- (void) showInfoView:(NSInteger) index
{
    CGFloat lineSpacing = 3;
    
    NSString *in_text, *out_text = nil;
    NSInteger in_nTitle = 0, out_nTitle = 0;
    if (index == 1) {
        in_text = @"Favourites\nAdd the stores you like to your favourites\n and get personalised offer notifications";
        out_text = @"";
        in_nTitle = 11;
        out_nTitle = 0;
    }
    else if (index == 2)
    {
        out_text = @"Favourites\nAdd the stores you like to your favourites\n and get personalised offer notifications";
        out_nTitle = 11;
        
        in_text = @"Offers\nWhen you see a store with this icon, it\nmeans they have an offer available";
        in_nTitle = 6;
        
        imgBigPageIcon.center = imgPageIcon1.center;
        imgNextBigPageIcon.center = imgPageIcon2.center;
        
        out_time = 0.4;
        in_time = 0.4;
    }
/*    else if (index == 3)
    {
        out_text = @"Offers\nWhen you see a store with this icon, it\nmeans they have an offer available";
        out_nTitle = 6;
        
        in_text = @"Join the Hunt\nWe've hidden virtual easter eggs in the\ncentre. Turn on your bluetooth and go\nfind them.";
        in_nTitle = 13;
        
        imgBigPageIcon.center = imgPageIcon2.center;
        imgNextBigPageIcon.center = imgPageIcon3.center;
        
        out_time = 0.6;
        in_time = 0.5;
    }*/
    else if (index == 3)
    {
        in_text = @"App Permissions\nTo make use of the iBeacon feature of\nthis app, please accept bluetooth,\nlocation & notification requests.";
        in_nTitle = 15;
        
        out_text = @"Offers\nWhen you see a store with this icon, it\nmeans they have an offer available";
        //@"Join the Hunt\nWe've hidden virtual easter eggs in the\ncentre. Turn on your bluetooth and go\nfind them.";
        out_nTitle = 6;
        
        imgBigPageIcon.center = imgPageIcon2.center;
        imgNextBigPageIcon.center = imgPageIcon3.center;
    }
    else
    {
        in_text = @"";
        in_nTitle = 0;
        
        out_text = @"App Permissions\nTo make use of the iBeacon feature of\nthis app, please accept bluetooth,\nlocation & notification requests.";
        out_nTitle = 15;
        
        imgBigPageIcon.center = imgPageIcon3.center;
    }
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:lineSpacing];
    [style setAlignment:NSTextAlignmentCenter];
    NSMutableAttributedString *in_attrString = [[NSMutableAttributedString alloc] initWithString:in_text];
    [in_attrString addAttributes:@{
                                   NSForegroundColorAttributeName : UIColorWithRGBA(255, 255, 255, 1),
                                   NSFontAttributeName : [UIFont fontWithName:HFONT_THIN size:17],
                                   NSParagraphStyleAttributeName : style
                                   } range:NSMakeRange(0, in_text.length)];
    [in_attrString addAttributes:@{
                                   NSForegroundColorAttributeName : UIColorWithRGBA(255, 255, 255, 1),
                                   NSFontAttributeName : [UIFont fontWithName:HFONT_MEDIUM size:17],
                                   NSParagraphStyleAttributeName : style
                                   } range:NSMakeRange(0, in_nTitle)];
    self.textViewIncoming.attributedText = in_attrString;
    
    NSMutableAttributedString *out_attrString = [[NSMutableAttributedString alloc] initWithString:out_text];
    [out_attrString addAttributes:@{
                                    NSForegroundColorAttributeName : UIColorWithRGBA(255, 255, 255, 1),
                                    NSFontAttributeName : [UIFont fontWithName:HFONT_THIN size:17],
                                    NSParagraphStyleAttributeName : style
                                    } range:NSMakeRange(0, out_text.length)];
    [out_attrString addAttributes:@{
                                    NSForegroundColorAttributeName : UIColorWithRGBA(255, 255, 255, 1),
                                    NSFontAttributeName : [UIFont fontWithName:HFONT_MEDIUM size:17],
                                    NSParagraphStyleAttributeName : style
                                    } range:NSMakeRange(0, out_nTitle)];
    self.textViewOutgoing.attributedText = out_attrString;
    
    CGRect frame;
    
    if (index == 1) {
        frame = textViewIncoming.frame;
        frame.origin.x = 320;
        textViewIncoming.frame = frame;
        btnNext.alpha = 0.0f;
        
        [UIView animateWithDuration:0.4 animations:^{
            textViewIncoming.layer.transform = CATransform3DMakeTranslation(-320, 0, 0);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:1.5 animations:^{
                btnNext.alpha = 1.0f;
            }];
        }];
        
        imgBigPageIcon.center = imgPageIcon1.center;
        
        [UIView animateWithDuration:1 animations:^{
            imgPageIcon1.alpha = 1.0f;
            imgPageIcon2.alpha = 1.0f;
            imgPageIcon3.alpha = 1.0f;
            //imgPageIcon4.alpha = 1.0f;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.6 animations:^{
                imgBigPageIcon.alpha = 1.0f;
            }];
        }];
    }
    else if ( index == 2)
    {
        frame = textViewOutgoing.frame;
        frame.origin.x = 0;
        textViewOutgoing.frame = frame;
        
        CGRect frame1 = textViewIncoming.frame;
        frame1.origin.x = 320;
        [textViewIncoming setFrame:frame1];
        
        imgBigPageIcon.alpha = 1;
        imgNextBigPageIcon.alpha = 0;
        
        [UIView animateWithDuration:out_time animations:^{
            CGRect frame = textViewOutgoing.frame;
            frame.origin.x = -320;
            textViewOutgoing.frame = frame;
            imgBigPageIcon.alpha = 0;
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:in_time animations:^{
                CGRect frame = textViewIncoming.frame;
                frame.origin.x = 0;
                textViewIncoming.frame = frame;
                imgNextBigPageIcon.alpha = 1;
            }];
        }];
        
    }
  /*  else if ( index == 3)
    {
        frame = textViewOutgoing.frame;
        frame.origin.x = 0;
        textViewOutgoing.frame = frame;
        
        CGRect frame1 = textViewIncoming.frame;
        frame1.origin.x = 320;
        [textViewIncoming setFrame:frame1];
        
        imgBigPageIcon.alpha = 1;
        imgNextBigPageIcon.alpha = 0;
        
        [UIView animateWithDuration:out_time delay:0.2f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            
            CGRect frame = textViewOutgoing.frame;
            frame.origin.x = -320;
            textViewOutgoing.frame = frame;
            imgBigPageIcon.alpha = 0;
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:in_time animations:^{
                CGRect frame = textViewIncoming.frame;
                frame.origin.x = 0;
                textViewIncoming.frame = frame;
                imgNextBigPageIcon.alpha = 1;
            }];
        }];
        
    }*/
    else if ( index == 3 )
    {
        frame = textViewOutgoing.frame;
        frame.origin.x = 0;
        textViewOutgoing.frame = frame;
        
        CGRect frame1 = textViewIncoming.frame;
        frame1.origin.x = 320;
        [textViewIncoming setFrame:frame1];
        
        imgBigPageIcon.alpha = 1;
        imgNextBigPageIcon.alpha = 0;
//        [UIView animateWithDuration:0.6f delay:0.2f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [UIView animateWithDuration:0.6f animations:^{
            CGRect frame = textViewOutgoing.frame;
            frame.origin.x = -320;
            textViewOutgoing.frame = frame;
            imgBigPageIcon.alpha = 0;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 animations:^{
                CGRect frame = textViewIncoming.frame;
                frame.origin.x = 0;
                textViewIncoming.frame = frame;
                imgNextBigPageIcon.alpha = 1;
            }];
            
        }];
    }
    else
    {
        frame = textViewOutgoing.frame;
        frame.origin.x = 0;
        textViewOutgoing.frame = frame;
        
        imgNextBigPageIcon.hidden = YES;
        imgBigPageIcon.hidden = YES;
        
        [UIView animateWithDuration:0.5 animations:^{
            CGRect frame = textViewOutgoing.frame;
            frame.origin.x = -320;
            textViewOutgoing.frame = frame;
        }];
        
        [UIView animateWithDuration:1 animations:^{
            imgPageIcon1.alpha = 0;
            imgPageIcon2.alpha = 0;
            imgPageIcon3.alpha = 0;
            //imgPageIcon4.alpha = 0;
            imgBigPageIcon.alpha = 0;
            imgNextBigPageIcon.alpha = 0;
            btnNext.alpha = 0;
        }];
        
    }
}
- (void)setMovPlaySection:(NSInteger) section
{
    NSString *file_path = [NSString stringWithFormat:@"section_0%ld", (long)section];
    NSString *movFilePath = [[NSBundle mainBundle] pathForResource:file_path ofType:@"mov"];
    NSURL *path = [NSURL fileURLWithPath:movFilePath];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:movFilePath]) {
        return;
    }
    [self.mPlayer setContentURL:path];
    [self.mPlayer prepareToPlay];
    [self.mPlayer play];
    //[btnNext setUserInteractionEnabled:NO];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) pauseMovFile
{
    [self.mPlayer pause];
    m_PlayStep++;
}

- (void)onClickNextButton:(id)sender {
    
    m_PlayStep++;
    [self setMovPlaySection:m_PlayStep];
    [self showInfoView:m_PlayStep];
    
}

- (void)onClickPanGesture:(UIPanGestureRecognizer*)sender
{
    CGPoint velocity = [sender velocityInView:sender.view];
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        
        if (velocity.x < 0) {
            m_PlayStep++;
            [self setMovPlaySection:m_PlayStep];
            [self showInfoView:m_PlayStep];
        }
    }
    
}
@end
