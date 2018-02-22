//
//  EventDetailViewController.m
//  Whiteley
//
//  Created by Alex Hong on 3/30/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import "EventDetailViewController.h"
#import "EventTableViewCell.h"
#import "DCDefines.h"

@interface EventDetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) UIImageView*    eventImageView;
@property (nonatomic, weak) UITextView*     titleTextView;
@property (nonatomic, weak) UITextView*     eventTextView;

@property (nonatomic, weak) UIImageView*    timeImageView;
@property (nonatomic, weak) UILabel*        dateLabel;
@property (nonatomic, weak) UILabel*        timeLabel;


@property (nonatomic, weak) UILabel*        moreEventLabel;

@property (nonatomic, weak) UITableView*    tableView;
@property (nonatomic, strong) NSDictionary*     dcEventDetail;
@property (nonatomic, strong) NSMutableArray*   dcOtherEvents;
@end


@implementation EventDetailViewController
@synthesize dcEventDetail, dcOtherEvents;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:NO];

    self.title = @"Latest Events";
    self.view.backgroundColor = UIColorWithRGBA(239, 240, 240, 1);
    
    [self performSelector:@selector(hideWaitingIndicator) withObject:nil afterDelay:10.0f];
    
    [CommonUtils showIndicator];
    
    NSString *url = [DCWEBAPI_GET_EVENTS_DETAIL stringByAppendingString:self.strEventID];
    
    [DCDefines getHttpAsyncResponse:url withHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    
        NSData *responseData = data;
        
        if (responseData == nil) {
            [CommonUtils hideIndicator];
            return;
        }
        
        NSError* errorInfo;
        NSDictionary *dic  = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&errorInfo];
        dcEventDetail = [dic valueForKey:@"result"];
        dcOtherEvents = dcEventDetail[@"other_events"];
        
        dispatch_async(dispatch_get_main_queue(), ^{

            UIImageView* imageView = nil;
            UITextView* textView = nil;
            UILabel* label = nil;
            
            imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
            imageView.image = [UIImage imageNamed:@"default_thumb_large"];
            [self setImageURL:imageView url:dcEventDetail[@"image"]];
            [self.scrollView addSubview:imageView];
            self.eventImageView = imageView;
            
            textView = [[UITextView alloc] initWithFrame:CGRectZero];
            [self.scrollView addSubview:textView];
            //    textView.textColor = UIColorWithRGBA(38, 38, 38, 1);
            //    textView.font = [UIFont fontWithName:HFONT_THIN size:16];
            textView.dataDetectorTypes = UIDataDetectorTypeAll;
            textView.editable = NO;
            textView.backgroundColor = [UIColor clearColor];
            textView.scrollEnabled = NO;
            self.titleTextView = textView;
            
            NSString* title = dcEventDetail[@"title"];
            NSMutableAttributedString* attrTitle = [[NSMutableAttributedString alloc] initWithString:title];
            NSMutableParagraphStyle *styleTitle = [[NSMutableParagraphStyle alloc] init];
            [styleTitle setLineSpacing:3];
            
            [attrTitle addAttributes:@{
                                        NSForegroundColorAttributeName : UIColorWithRGBA(74, 74, 74, 1),
                                        NSFontAttributeName : [UIFont fontWithName:HFONT_REGULAR size:20],
                                        NSParagraphStyleAttributeName : styleTitle
                                        } range:[[attrTitle string] rangeOfString:title]];
            self.titleTextView.attributedText = attrTitle;

            imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
            imageView.image = [UIImage imageNamed:@"iconAlarm"];
            [self.scrollView addSubview:imageView];
            self.timeImageView = imageView;
            
            label = [[UILabel alloc] initWithFrame:CGRectZero];
            [self.scrollView addSubview:label];
            label.text = dcEventDetail[@"date"];
            label.font = [UIFont fontWithName:HFONT_THIN size:20];
            label.textColor = UIColorWithRGBA(74, 74, 74, 1);
            self.dateLabel = label;

            label = [[UILabel alloc] initWithFrame:CGRectZero];
            [self.scrollView addSubview:label];
            label.text = @"09:00 - 20:00";
            label.font = [UIFont fontWithName:HFONT_THIN size:20];
            label.textColor = UIColorWithRGBA(74, 74, 74, 1);
            self.timeLabel = label;

            textView = [[UITextView alloc] initWithFrame:CGRectZero];
            [self.scrollView addSubview:textView];
            textView.dataDetectorTypes = UIDataDetectorTypeAll;
            textView.editable = NO;
            textView.backgroundColor = [UIColor clearColor];
            textView.scrollEnabled = NO;
            self.eventTextView = textView;

            NSString* text = dcEventDetail[@"text"];
            
            NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString:text];
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            [style setLineSpacing:3];
            
            [attrString addAttributes:@{
                                        NSForegroundColorAttributeName : UIColorWithRGBA(38, 38, 38, 1),
                                        NSFontAttributeName : [UIFont fontWithName:HFONT_THIN size:14.0f],
                                        NSParagraphStyleAttributeName : style
                                        } range:[[attrString string] rangeOfString:text]];
            
            
            self.eventTextView.attributedText = attrString;

            
            label = [[UILabel alloc] initWithFrame:CGRectZero];
            [self.scrollView addSubview:label];
            label.text = @"Other Events";
            label.font = [UIFont fontWithName:HFONT_THIN size:24];
            label.textColor = UIColorWithRGBA(74, 74, 74, 1);
            self.moreEventLabel = label;
            
            UITableView* table = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
            [self.scrollView addSubview:table];
            table.dataSource = self;
            table.delegate = self;
            table.scrollEnabled = NO;
            table.separatorStyle = UITableViewCellSeparatorStyleNone;
            self.tableView = table;
            
            [self layoutCustomControls];
            [CommonUtils hideIndicator];
        });
        
    }];
}

- (void)layoutCustomControls {
    CGFloat contentsHeight = 0;
    CGFloat contentsWidth = 320;
    
    CGRect viewRect = CGRectMake(0, 0, contentsWidth, 568);
    CGRect rect;
    
    self.eventImageView.frame = CGRectMake(0, 0, contentsWidth, 148);
    
    contentsHeight += self.eventImageView.frame.size.height;
    
    rect.size.width = contentsWidth - 20;
    self.titleTextView.frame = rect;
    [self.titleTextView sizeToFit];
    rect = self.titleTextView.frame;
    rect.origin.x = 10;
    rect.origin.y = contentsHeight + 10;
    self.titleTextView.frame = rect;
    
    contentsHeight = self.titleTextView.frame.origin.y + self.titleTextView.frame.size.height + 15;

    //rect.size.width = self.timeImageView.image.size.width;
    //self.timeImageView.frame = rect;
    //[self.timeImageView sizeToFit];
    //rect = self.timeImageView.frame;
    //rect.origin.x = 17;
    //rect.origin.y = contentsHeight + 11;
    //self.timeImageView.frame = rect;

    rect.size.width = contentsWidth - self.timeImageView.frame.size.width - 50;
    self.dateLabel.frame = rect;
    [self.dateLabel sizeToFit];
    rect = self.dateLabel.frame;
    rect.origin.x = 17;
    rect.origin.y = contentsHeight;
    self.dateLabel.frame = rect;
    
    //rect.size.width = contentsWidth - self.timeImageView.frame.size.width - 50;
    //self.timeLabel.frame = rect;
    //[self.timeLabel sizeToFit];
    //rect = self.timeLabel.frame;
    //rect.origin.x = 35 + self.timeImageView.frame.size.width;
    //rect.origin.y = self.dateLabel.frame.origin.y + self.dateLabel.frame.size.height;
    //self.timeLabel.frame = rect;
    
    //contentsHeight = self.timeImageView.frame.origin.y + self.timeImageView.frame.size.height + 10;

    contentsHeight = self.dateLabel.frame.origin.y + self.dateLabel.frame.size.height + 15;
    
    rect.size.width = contentsWidth - 20;
    self.eventTextView.frame = rect;
    [self.eventTextView sizeToFit];
    rect = self.eventTextView.frame;
    rect.origin.x = 10;
    rect.origin.y = contentsHeight;
    self.eventTextView.frame = rect;
    
    contentsHeight = self.eventTextView.frame.origin.y + self.eventTextView.frame.size.height;
    
    rect.origin.x = 10;
    rect.origin.y = contentsHeight;
    rect.size.width = contentsWidth - 20;
    rect.size.height = 65;
    self.moreEventLabel.frame = rect;
    contentsHeight = self.moreEventLabel.frame.origin.y + self.moreEventLabel.frame.size.height + 10;
    
    if (dcOtherEvents.count == 0)
        [self.moreEventLabel setHidden:YES];
    
    CGFloat tableHeight = [self tableView:self.tableView numberOfRowsInSection:0] * [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    self.tableView.frame = CGRectMake(0, contentsHeight, contentsWidth, tableHeight);
    
    contentsHeight = self.tableView.frame.origin.y + self.tableView.frame.size.height;
    
    viewRect.size.height = contentsHeight;
    self.scrollView.contentSize = viewRect.size;
    
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

- (void) hideWaitingIndicator
{
    [CommonUtils hideIndicator];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dcOtherEvents.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 190;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EventTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"EventTableViewCell"];
    
    if (cell == nil) {
        cell = [[EventTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EventTableViewCell"];
    }
    
    if (indexPath.row % 2 == 0) {
        cell.backgroundColor = UIColorWithRGBA(237, 236, 236, 1);
    }
    else {
        cell.backgroundColor = UIColorWithRGBA(249, 249, 249, 1);
    }
    
    NSDictionary *dic = [dcOtherEvents objectAtIndex:indexPath.row];
    
    cell.dcDateLabel.text = dic[@"event_date"];
    cell.dcEventTitle.text = dic[@"event_name"];
    cell.dcEventDetailLabel.text = dic[@"event_detail"];
    cell.imageURL = dic[@"event_image"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    EventDetailViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"EventDetailViewController"];
    NSDictionary *dic = [dcOtherEvents objectAtIndex:indexPath.row];
    vc.strEventID = dic[@"id"];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
