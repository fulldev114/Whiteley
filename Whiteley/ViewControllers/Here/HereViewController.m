//
//  HereViewController.m
//  Whiteley
//
//  Created by Alex Hong on 3/31/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import "HereViewController.h"
#import "DCDefines.h"

typedef NS_ENUM(NSInteger, DCHereType) {
    DCHereTypeCar = 1,
    DCHereTypeTrain,
    DCHereTypeBus
};

@interface HereViewController ()

@property (nonatomic, assign) NSInteger hereType;
@property (nonatomic, strong) NSMutableArray* detailTexts;

@end

@implementation HereViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.view.backgroundColor = UIColorWithRGBA(239, 240, 240, 1);

    self.button1.layer.borderWidth = 1;
    self.button1.layer.borderColor = UIColorWithRGBA(151, 151, 151, 1).CGColor;
    [self.button1 setTitle:@"CAR" forState:UIControlStateNormal];
    self.button1.titleLabel.font = [UIFont fontWithName:NFONT_DEMI_BOLD size:12];
    
    self.button2.layer.borderWidth = 1;
    self.button2.layer.borderColor = UIColorWithRGBA(151, 151, 151, 1).CGColor;
    [self.button2 setTitle:@"TRAIN" forState:UIControlStateNormal];
    self.button2.titleLabel.font = [UIFont fontWithName:NFONT_DEMI_BOLD size:12];
    
    self.button3.layer.borderWidth = 1;
    self.button3.layer.borderColor = UIColorWithRGBA(151, 151, 151, 1).CGColor;
    [self.button3 setTitle:@"BUS" forState:UIControlStateNormal];
    self.button3.titleLabel.font = [UIFont fontWithName:NFONT_DEMI_BOLD size:12];
    
    self.detailTexts = [NSMutableArray array];
    
    CGFloat lineSpacing = 2;
    CGFloat fontSize = 15;
    
    NSString* text = @"Getting here by car\n\nWhiteley is located just one mile from Junction 9 on the M27. After exiting the motorway, follow the signs for 'shopping centre'.\n\nIf you are using a GPS or route finder system, enter PO15 7PD as the destination postcode.\n\nWe have 1,300 parking spaces across seven car parks.";
    
    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString:text];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:lineSpacing];
    [attrString addAttributes:@{
                                NSForegroundColorAttributeName : UIColorWithRGBA(38, 38, 38, 1),
                                NSFontAttributeName : [UIFont fontWithName:HFONT_THIN size:fontSize],
                                NSParagraphStyleAttributeName : style
                                } range:NSMakeRange(0, text.length)];
    
    [attrString addAttributes:@{
                                NSForegroundColorAttributeName : UIColorWithRGBA(74, 74, 74, 1),
                                NSFontAttributeName : [UIFont fontWithName:HFONT_THIN size:20],
                                NSParagraphStyleAttributeName : style
                                } range:NSMakeRange(0, 19)];
    
    [self.detailTexts addObject:attrString];
    
    NSString *title = @"Getting here by train\n\nSwanwick railway station is located within a 25 minute walk from Whiteley Shopping. There is also a taxi rank located at the station.";// Details of all connections and further information can be found at ";
//    NSString *rail = @"National Rail";
//    NSString *train = @"South West Trains";
//    NSString *railways = @"Southern Railways";
    
    //text  = [NSString stringWithFormat:@"%@%@, %@ and %@.", title, rail, train, railways];
    
    attrString = [[NSMutableAttributedString alloc] initWithString:title];
    [attrString addAttributes:@{
                                NSForegroundColorAttributeName : UIColorWithRGBA(38, 38, 38, 1),
                                NSFontAttributeName : [UIFont fontWithName:HFONT_THIN size:fontSize],
                                NSParagraphStyleAttributeName : style
                                } range:NSMakeRange(0, title.length)];
    
    [attrString addAttributes:@{
                                NSForegroundColorAttributeName : UIColorWithRGBA(74, 74, 74, 1),
                                NSFontAttributeName : [UIFont fontWithName:HFONT_THIN size:20],
                                NSParagraphStyleAttributeName : style
                                } range:NSMakeRange(0, 21)];
    /*
    [attrString addAttributes:@{
                                 NSForegroundColorAttributeName : UIColorWithRGBA(38, 38, 38, 1),
                                 NSFontAttributeName : [UIFont fontWithName:HFONT_THIN size:fontSize],
                                 NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)
                                 }
                         range:NSMakeRange(title.length, rail.length)];
    
    [attrString addAttributes:@{
                                NSForegroundColorAttributeName : UIColorWithRGBA(38, 38, 38, 1),
                                NSFontAttributeName : [UIFont fontWithName:HFONT_THIN size:fontSize],
                                NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)
                                }
                        range:NSMakeRange(title.length+rail.length+2, train.length)];
    
    [attrString addAttributes:@{
                                NSForegroundColorAttributeName : UIColorWithRGBA(38, 38, 38, 1),
                                NSFontAttributeName : [UIFont fontWithName:HFONT_THIN size:fontSize],
                                NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)
                                }
                        range:NSMakeRange(title.length+rail.length+train.length+7, railways.length)];
    */
    [self.detailTexts addObject:attrString];
    
    text = @"Getting here by bus\n\nFirst Group operate a local service to and from Whiteley (Number 28 and 28A). The nearest bus stop is located on Whiteley Way by Tesco.";
    
    attrString = [[NSMutableAttributedString alloc] initWithString:text];
    [attrString addAttributes:@{
                                NSForegroundColorAttributeName : UIColorWithRGBA(38, 38, 38, 1),
                                NSFontAttributeName : [UIFont fontWithName:HFONT_THIN size:fontSize],
                                NSParagraphStyleAttributeName : style
                                } range:NSMakeRange(0, text.length)];
    
    [attrString addAttributes:@{
                                NSForegroundColorAttributeName : UIColorWithRGBA(74, 74, 74, 1),
                                NSFontAttributeName : [UIFont fontWithName:HFONT_THIN size:20],
                                NSParagraphStyleAttributeName : style
                                } range:NSMakeRange(0, 19)];
    /*
    [attrString addAttributes:@{
                                NSForegroundColorAttributeName : UIColorWithRGBA(38, 38, 38, 1),
                                NSFontAttributeName : [UIFont fontWithName:HFONT_THIN size:fontSize],
                                NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)
                                }
                        range:NSMakeRange(21, 11)];*/
    
    [self.detailTexts addObject:attrString];
    
    self.hereType = DCHereTypeCar;
    [self updateButtons];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setValue:[NSNumber numberWithInteger:MENU_HERE] forKey:WHITELEY_MENU_SELECT];
    [userDefault synchronize];
    
}

- (void)updateButtons {
    
    NSAttributedString* attrString = self.detailTexts[self.hereType-1];
    
    if (self.hereType == DCHereTypeCar) {
        // button1
        self.button1.backgroundColor = UIColorWithRGBA(215, 163, 2, 1);
        [self.button1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.button1.layer.borderColor = [UIColor clearColor].CGColor;

        // button2
        self.button2.backgroundColor = [UIColor whiteColor];
        [self.button2 setTitleColor:UIColorWithRGBA(74, 74, 74, 1) forState:UIControlStateNormal];
        self.button2.layer.borderColor = UIColorWithRGBA(151, 151, 151, 1).CGColor;

        // button3
        self.button3.backgroundColor = [UIColor whiteColor];
        [self.button3 setTitleColor:UIColorWithRGBA(74, 74, 74, 1) forState:UIControlStateNormal];
        self.button3.layer.borderColor = UIColorWithRGBA(151, 151, 151, 1).CGColor;

    }
    else if (self.hereType == DCHereTypeTrain){
        // button1
        self.button1.backgroundColor = [UIColor whiteColor];
        [self.button1 setTitleColor:UIColorWithRGBA(74, 74, 74, 1) forState:UIControlStateNormal];
        self.button1.layer.borderColor = UIColorWithRGBA(151, 151, 151, 1).CGColor;

        // button2
        self.button2.backgroundColor = UIColorWithRGBA(215, 163, 2, 1);
        [self.button2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.button2.layer.borderColor = [UIColor clearColor].CGColor;

        // button3
        self.button3.backgroundColor = [UIColor whiteColor];
        [self.button3 setTitleColor:UIColorWithRGBA(74, 74, 74, 1) forState:UIControlStateNormal];
        self.button3.layer.borderColor = UIColorWithRGBA(151, 151, 151, 1).CGColor;

    }
    else {
        // button1
        self.button1.backgroundColor = [UIColor whiteColor];
        [self.button1 setTitleColor:UIColorWithRGBA(74, 74, 74, 1) forState:UIControlStateNormal];
        self.button1.layer.borderColor = UIColorWithRGBA(151, 151, 151, 1).CGColor;

        // button2
        self.button2.backgroundColor = [UIColor whiteColor];
        [self.button2 setTitleColor:UIColorWithRGBA(74, 74, 74, 1) forState:UIControlStateNormal];
        self.button2.layer.borderColor = UIColorWithRGBA(151, 151, 151, 1).CGColor;

        // button3
        self.button3.backgroundColor = UIColorWithRGBA(215, 163, 2, 1);
        [self.button3 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.button3.layer.borderColor = [UIColor clearColor].CGColor;

    }
    
    self.dcTextView.attributedText = attrString;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onButtonClicked:(UIButton *)sender {
    if (self.hereType != sender.tag) {
        self.hereType = sender.tag;
        [self updateButtons];
    }
}

@end
