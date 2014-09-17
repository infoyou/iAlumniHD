//
//  CheckinResultViewController.m
//  iAlumniHD
//
//  Created by MobGuang on 12-8-28.
//
//

#import "CheckinResultViewController.h"
#import "VerticalLayoutItemInfoCell.h"
#import "CheckinResultHeaderView.h"
#import "WXWColorfulButton.h"
#import "EventAlumniListViewController.h"
#import "Event.h"

enum {
    CHECKEDIN_ALUMNUS_SEC,
    DISCUSS_VOTE_SEC,
};

#define SECTION_COUNT         2

#define HEADER_VIEW_HEIGHT    90.0f

#define AVATAR_HEIGHT         66.0f

#define FOOTER_VIEW_HEIGHT    50.0f

#define BUTTON_WIDTH          150.0f
#define BUTTON_HEIGHT         40.0f

@interface CheckinResultViewController ()
@property (nonatomic, retain) Event *event;
@property (nonatomic, copy) NSString *backendMsg;
@end

@implementation CheckinResultViewController

@synthesize event = _eventDetail;
@synthesize backendMsg = _backendMsg;

#pragma mark - user actions
- (void)sureAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - header view height
- (BOOL)needShowNumber {
    
    if (self.event.checkinNumber.longLongValue > 0) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)shouldShowFee {
    if (self.event.requirementType.intValue == NEED_FEE_EVENT_TY) {
        return YES;
    } else {
        return NO;
    }
}

- (CGFloat)resultBoardHeight {
    // height of check in result text area
    NSString *result = nil;
    
    switch (_checkinResultType) {
        case CHECKIN_FAILED_TY:
            result = LocaleStringForKey(NSCheckinFailedMsg, nil);
            break;
            
        case CHECKIN_OK_TY:
            result = LocaleStringForKey(NSCheckinDoneMsg, nil);
            break;
            
        case CHECKIN_DUPLICATE_ERR_TY:
            result = LocaleStringForKey(NSEventDuplicateCheckinMsg, nil);
            break;
            
        case CHECKIN_FARAWAY_TY:
            result = LocaleStringForKey(NSAlumniCheckinFarAwayMsg, nil);
            break;
            
        case CHECKIN_EVENT_OVERDUE_TY:
            result = LocaleStringForKey(NSCheckinFailedEventOverdueMsg, nil);
            break;
            
        case CHECKIN_EVENT_NOT_BEGIN_TY:
            result = LocaleStringForKey(NSEventNotBeginMsg, nil);
            break;
            
        case CHECKIN_NEED_CONFIRM_TY:
            result = LocaleStringForKey(NSCheckinNeedConfirmMsg, nil);
            break;
            /*
             case CHECKIN_NOT_SIGNUP_TY:
             result = LocaleStringForKey(NSNotSignUpMsg, nil);
             break;
             */
        case CHECKIN_NO_REG_FEE_TY:
            result = LocaleStringForKey(NSNoRegistrationFeeMsg, nil);
            break;
            
        default:
            result = LocaleStringForKey(NSCheckinFailedMsg, nil);
            break;
    }
    
    if (self.backendMsg && self.backendMsg.length > 0) {
        //result = self.backendMsg;
    }
    
    CGFloat resultAreaWidth = LIST_WIDTH - MARGIN * 4;
    CGSize size = [result sizeWithFont:BOLD_FONT(16)
                     constrainedToSize:CGSizeMake(resultAreaWidth - MARGIN * 4, CGFLOAT_MAX)
                         lineBreakMode:UILineBreakModeWordWrap];
    CGFloat height = MARGIN + size.height;
    
    // if there is check in number
    if ([self needShowNumber]) {
        size = [[NSString stringWithFormat:@"%@", self.event.checkinNumber] sizeWithFont:BOLD_FONT(60)
                                                                       constrainedToSize:CGSizeMake(resultAreaWidth, CGFLOAT_MAX)
                                                                           lineBreakMode:UILineBreakModeCharacterWrap];
        height += MARGIN * 2 + size.height;
    }
    
    // if this event need fee
    if ([self shouldShowFee]) {
        
        // dash separator
        height += MARGIN;
        
        // payment result
        NSString *name = LocaleStringForKey(NSShouldPayTitle, nil);
        size = [name sizeWithFont:BOLD_FONT(16)
                constrainedToSize:CGSizeMake(resultAreaWidth/2.0f, CGFLOAT_MAX)
                    lineBreakMode:UILineBreakModeWordWrap];
        height += MARGIN * 2 + size.height;
        
        NSString *value = [NSString stringWithFormat:@"￥%@", self.event.fee];
        size = [value sizeWithFont:BOLD_FONT(24)
                 constrainedToSize:CGSizeMake(resultAreaWidth/2.0f, CGFLOAT_MAX)
                     lineBreakMode:UILineBreakModeWordWrap];
        height += MARGIN * 2 + size.height + MARGIN;
    }
    
    return height;
}

- (CGFloat)tableViewHeaderViewHeight {
    // height of avatar area
    CGFloat height = MARGIN * 2 + AVATAR_HEIGHT + MARGIN;
    
    // height of check in result text area
    _checkinResultBoardHeight = [self resultBoardHeight];
    height += _checkinResultBoardHeight;
    
    height += MARGIN * 2;
    
    return height;
}

#pragma mark - lifecycle methods
- (id)initWithMOC:(NSManagedObjectContext *)MOC
checkinResultType:(CheckinResultType)checkinResultType
            event:(Event *)event
         entrance:(UIViewController *)entrance
       backendMsg:(NSString *)backendMsg {
    
    self = [super initWithMOC:MOC
              showCloseButton:NO
        needRefreshHeaderView:NO
        needRefreshFooterView:NO
                   tableStyle:UITableViewStyleGrouped];
    
    if (self) {
        _checkinResultType = checkinResultType;
        
        self.event = event;
        
        _checkinEntrance = entrance;
        
        self.backendMsg = backendMsg;
        
        _noNeedDisplayEmptyMsg = YES;
    }
    return self;
}

- (void)dealloc {
    
    self.event = nil;
    
    self.backendMsg = nil;
    
    [super dealloc];
}

- (void)initTableViewHeaderView {
    
    CGFloat height = [self tableViewHeaderViewHeight];
    
    _headerView = [[CheckinResultHeaderView alloc] initWithFrame:CGRectMake(0, 0,
                                                                            LIST_WIDTH,
                                                                            height)
                                          imageDisplayerDelegate:self
                                                      backendMsg:self.backendMsg];
    [_headerView drawView:_checkinResultBoardHeight event:self.event];
    
    _headerView.backgroundColor = TRANSPARENT_COLOR;
    
    _tableView.tableHeaderView = _headerView;
}

- (void)initTableViewFooterView {
    _footerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0,
                                                            LIST_WIDTH,
                                                            FOOTER_VIEW_HEIGHT)] autorelease];
    _footerView.backgroundColor = TRANSPARENT_COLOR;
    
    WXWColorfulButton *button = [[[ECStandardButton alloc] initWithFrame:CGRectMake((LIST_WIDTH - BUTTON_WIDTH)/2.0f,
                                                                                   (FOOTER_VIEW_HEIGHT - BUTTON_HEIGHT)/2.0f,
                                                                                   BUTTON_WIDTH,
                                                                                   BUTTON_HEIGHT)
                                                                 target:self
                                                                 action:@selector(sureAction:)
                                                                  title:LocaleStringForKey(NSIKnowTitle, nil)
                                                              tintColor:NAVIGATION_BAR_COLOR
                                                              titleFont:BOLD_FONT(18)
                                                            borderColor:nil]  autorelease];
    [_footerView addSubview:button];
    
    _tableView.tableFooterView = _footerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initTableViewHeaderView];
    
    [self initTableViewFooterView];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - handle empty list
- (BOOL)listIsEmpty {
    return NO;
}

#pragma mark - UITableViewDataSource, UITableViewDelegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return SECTION_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}

- (VerticalLayoutItemInfoCell *)drawShadowVerticalInfoCell:(NSString *)title
                                                  subTitle:(NSString *)subTitle
                                                   content:(NSString *)content
                                            cellIdentifier:(NSString *)cellIdentifier
                                                    height:(CGFloat)height
                                                 clickable:(BOOL)clickable {
    
    VerticalLayoutItemInfoCell *cell = (VerticalLayoutItemInfoCell *)[_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (nil == cell) {
        
        cell = [[[VerticalLayoutItemInfoCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                  reuseIdentifier:cellIdentifier] autorelease];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    [cell drawShadowInfoCell:title
                    subTitle:subTitle
                     content:content
                  cellHeight:height
                   clickable:clickable];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case CHECKEDIN_ALUMNUS_SEC:
        {
            static NSString *kCellIdentifier = @"CheckedinAlumnusCell";
            return [self drawShadowVerticalInfoCell:LocaleStringForKey(NSCheckedinAlumnusTitle, nil)
                                           subTitle:[NSString stringWithFormat:@"%@", self.event.checkinCount]
                                            content:nil
                                     cellIdentifier:kCellIdentifier
                                             height:DEFAULT_CELL_HEIGHT
                                          clickable:YES];
        }
            
        case DISCUSS_VOTE_SEC:
        {
            
            static NSString *kCellIdentifier = @"DiscussVoteCell";
            return [self drawShadowVerticalInfoCell:LocaleStringForKey(NSJoinEventDiscussTitle, nil)
                                           subTitle:nil
                                            content:nil
                                     cellIdentifier:kCellIdentifier
                                             height:DEFAULT_CELL_HEIGHT
                                          clickable:YES];
        }
            
        default:
            return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case CHECKEDIN_ALUMNUS_SEC:
            return DEFAULT_CELL_HEIGHT;
            
        case DISCUSS_VOTE_SEC:
            return DEFAULT_CELL_HEIGHT;
            
        default:
            return 0;
    }
}

- (void)showCheckedinAlumnus:(NSIndexPath *)indexPath {
    EventAlumniListViewController *eventAlumniListVC = [[[EventAlumniListViewController alloc] initWithMOC:_MOC
                                                                                     checkinResultDelegate:self
                                                                                                     event:self.event
                                                                                         checkinResultType:_checkinResultType
                                                                                                  entrance:_checkinEntrance
                                                                                                  listType:EVENT_APPEAR_ALUMNUS_TY] autorelease];
    eventAlumniListVC.title = LocaleStringForKey(NSCheckedinAlumnusListTitle, nil);
    [self.navigationController pushViewController:eventAlumniListVC animated:YES];
}

- (void)showDiscussVote:(NSIndexPath *)indexPath {
    
    EventAlumniListViewController *eventAlumniListVC = [[[EventAlumniListViewController alloc] initWithMOC:_MOC
                                                                                     checkinResultDelegate:self
                                                                                                     event:self.event
                                                                                         checkinResultType:_checkinResultType
                                                                                                  entrance:_checkinEntrance
                                                                                                  listType:EVENT_DISCUSS_TY] autorelease];
    eventAlumniListVC.title = LocaleStringForKey(NSEventDiscussionTitle, nil);
    [self.navigationController pushViewController:eventAlumniListVC animated:YES];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    switch (indexPath.section) {
        case CHECKEDIN_ALUMNUS_SEC:
            [self showCheckedinAlumnus:indexPath];
            break;
            
        case DISCUSS_VOTE_SEC:
            [self showDiscussVote:indexPath];
            break;
            
        default:
            break;
    }
    
    [super deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - EventCheckinDelegate methods
- (void)setCheckinResultType:(CheckinResultType)type {
    _checkinResultType = type;
    
    if (type == CHECKIN_OK_TY) {
        
        // refresh the check in result view
        _checkinResultBoardHeight = [self resultBoardHeight];
        
        [_headerView drawView:_checkinResultBoardHeight event:self.event];
        
        [_tableView reloadData];
    }
}
/*
 - (void)setCheckinNumber:(long long)number {
 self.event.checkinNumber = [NSNumber numberWithLongLong:number];
 
 SAVE_MOC(_MOC);
 }
 */
@end
