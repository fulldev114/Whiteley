//
//  EventListViewController.m
//  Whiteley
//
//  Created by Alex Hong on 3/30/15.
//  Copyright (c) 2015 Alex Hong. All rights reserved.
//

#import "EventListViewController.h"
#import "EventTableViewCell.h"
#import "EventDetailViewController.h"
#import "DCDefines.h"

@interface EventListViewController ()

@end

@implementation EventListViewController
@synthesize aryEventsData;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:NO];

    CGFloat contentsWidth = 320;
    CGFloat contentsHeight = 50;
    CGFloat lineSpacing = 3;
    CGRect rect;
    
    rect = self.sadImageView.frame;
    rect.size.width = 86;
    self.sadImageView.frame = rect;
    [self.sadImageView sizeToFit];
    rect = self.sadImageView.frame;
    rect.origin.x = ( contentsWidth - self.sadImageView.frame.size.width ) / 2;
    rect.origin.y = contentsHeight;
    self.sadImageView.frame = rect;
    
    contentsHeight += self.sadImageView.frame.size.height + 50;
    
    self.noItemContent.text = @"Sorry\nNo events are currently\nscheduled - check back soon";
    
    NSString *text = self.noItemContent.text;
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:text];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:lineSpacing];
    [style setAlignment:NSTextAlignmentCenter];
    
    [attrString addAttributes:@{
                                NSForegroundColorAttributeName : UIColorWithRGBA(74, 74, 74, 1),
                                NSFontAttributeName : [UIFont fontWithName:HFONT_THIN size:20],
                                NSParagraphStyleAttributeName : style
                                } range:NSMakeRange(0, text.length)];
    
    [attrString addAttributes:@{
                                NSForegroundColorAttributeName : UIColorWithRGBA(74, 74, 74, 1),
                                NSFontAttributeName : [UIFont fontWithName:HFONT_MEDIUM size:20],
                                NSParagraphStyleAttributeName : style
                                } range:NSMakeRange(0, 5)];
    
    self.noItemContent.attributedText = attrString;
    
    rect = self.noItemContent.frame;
    rect.size.width = contentsWidth - 20;
    self.noItemContent.frame = rect;
    [self.noItemContent sizeToFit];
    rect = self.noItemContent.frame;
    rect.origin.x = ( contentsWidth - rect.size.width ) /2;
    rect.origin.y = contentsHeight;
    self.noItemContent.frame = rect;
    
    [self.backView setHidden:YES];
    [self.tableView setHidden:NO];
    
    [self addHeader];
    //[self addFooter];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setValue:[NSNumber numberWithInteger:MENU_EVENTS] forKey:WHITELEY_MENU_SELECT];
    [userDefault synchronize];
    
    [self.header beginRefreshing];
    [self getEventsFromWebServer];
    
}
- (void) getEventsFromWebServer
{
    [DCDefines getHttpAsyncResponse:DCWEBAPI_GET_EVENTS_NAME withHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        NSData *responseData = data;
        
        if (responseData == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.header endRefreshing];
                self.tableView.hidden = YES;
                self.backView.hidden = NO;
            });
            return;
        }
        
        NSError* errorInfo;
        NSDictionary *dic  = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&errorInfo];
        aryEventsData = [dic valueForKey:@"result"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.header endRefreshing];
            
            if (aryEventsData.count == 0 )
            {
                self.tableView.hidden = YES;
                self.backView.hidden = NO;
            }
            else
            {
                self.tableView.hidden = NO;
                self.backView.hidden = YES;
                [self.tableView reloadData];
            }
        });
        
    }];
}

- (void)addFooter
{
    MJRefreshFooterView *footer = [MJRefreshFooterView footer];
    footer.scrollView = self.tableView;
    footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        [self performSelector:@selector(doneWithView:) withObject:refreshView afterDelay:DC_SESSION_TIME_OUT];
        
        //        NSLog(@"%@----Begin Refreshing开始进入刷新状态", refreshView.class);
    };
    self.footer = footer;
}

- (void)addHeader
{
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    header.scrollView = self.tableView;
    header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        [self performSelector:@selector(doneWithView:) withObject:refreshView afterDelay:DC_SESSION_TIME_OUT];
    };
    header.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
        
    };
    header.refreshStateChangeBlock = ^(MJRefreshBaseView *refreshView, MJRefreshState state) {
        switch (state) {
            case MJRefreshStateNormal:
                //                NSLog(@"%@----Change State：Normal普通状态", refreshView.class);
                break;
                
            case MJRefreshStatePulling:
                //                NSLog(@"%@----Change State：Can Refresh if release松开即可刷新的状态", refreshView.class);
                break;
                
            case MJRefreshStateRefreshing:
                //                NSLog(@"%@----Change State：Now Refreshing正在刷新状态", refreshView.class);
                break;
            default:
                break;
        }
    };
    self.header = header;
}

- (void)doneWithView:(MJRefreshBaseView *)refreshView
{
    if (aryEventsData.count == 0) {
        self.tableView.hidden = YES;
        self.backView.hidden = NO;
    }
    else
    {
        self.tableView.hidden = NO;
        self.backView.hidden = YES;
        [self.tableView reloadData];
    }
    [refreshView endRefreshing];
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

#pragma mark <UITableViewDataSource&Delegate>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return aryEventsData.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EventTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"EventTableViewCell"];
    if (indexPath.row % 2 == 0) {
        cell.backgroundColor = UIColorWithRGBA(237, 236, 236, 1);
    }
    else {
        cell.backgroundColor = UIColorWithRGBA(249, 249, 249, 1);
    }
    
    NSDictionary *dic = [aryEventsData objectAtIndex:indexPath.row];
    
    cell.dcDateLabel.text = dic[@"event_date"];
    cell.dcEventTitle.text = dic[@"event_name"];
    cell.dcEventDetailLabel.text = dic[@"event_detail"];
    cell.imageURL = dic[@"event_image"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    EventDetailViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"EventDetailViewController"];
    NSDictionary *dic = [aryEventsData objectAtIndex:indexPath.row];
    vc.strEventID = dic[@"id"];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
