//
//  UserListViewController.m
//  iAlumniHD
//
//  Created by Adam on 12-11-27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UserListViewController.h"
#import "AdminCheckInViewController.h"
#import "AlumniProfileViewController.h"
#import "ChatListViewController.h"
#import "UIWebViewController.h"
#import "ShakeViewController.h"
#import "UserListCell.h"
#import "Alumni.h"
#import "Club.h"

#define SHAKE_HEADER_HEIGHT 85.0f

typedef enum {
    SHOW_DISTANCE_TY = 0,
    SHOW_TIME_TY,
    SHOW_SORT_TY,
} USER_LIST_SHOW_TY;

@interface UserListViewController()
@property (nonatomic, retain) Alumni *alumni;
@property (nonatomic, retain) Club *group;
@end

@implementation UserListViewController

static int iSize = 0;

@synthesize requestParam;
@synthesize pageIndex;
@synthesize alumni = _alumni;

- (id)initWithType:(WebItemType)aType
      needGoToHome:(BOOL)aNeedGoToHome
               MOC:(NSManagedObjectContext*)MOC {
    
    return [self initWithType:aType needGoToHome:aNeedGoToHome MOC:MOC group:nil];
}

- (id)initWithType:(WebItemType)aType
      needGoToHome:(BOOL)aNeedGoToHome
               MOC:(NSManagedObjectContext*)MOC
             group:(Club *)group {
    
    if (aType != SHAKE_USER_LIST_TY) {
        self = [super initWithMOC:MOC
                           holder:nil
                 backToHomeAction:nil
            needRefreshHeaderView:NO
            needRefreshFooterView:YES
                       tableStyle:UITableViewStylePlain
                       needGoHome:NO];
    } else {
        self = [super initWithMOC:MOC
                           holder:nil
                 backToHomeAction:nil
            needRefreshHeaderView:YES
            needRefreshFooterView:YES
                       tableStyle:UITableViewStylePlain
                       needGoHome:NO];
    }
    
    
    if (self) {
        _userListType = aType;
        needGoToHome = aNeedGoToHome;
        
        self.group = group;
        
        if (_userListType == SHAKE_USER_LIST_TY) {
            [super clearPickerSelIndex2Init:3];
            [self addRefreshBtn];
            
            [AppManager instance].shakeWinnerType = INIT_VALUE_WINNER_TY;
        }
        
	}
	
	return self;
}

#pragma mark - core data
- (void)setPredicate {
    
    self.entityName = @"Alumni";
    
    self.descriptors = [NSMutableArray array];
    
    NSSortDescriptor *dateDesc = [[[NSSortDescriptor alloc] initWithKey:@"orderId" ascending:YES] autorelease];
    
    [self.descriptors addObject:dateDesc];
}

#pragma mark - load user list from web
- (void)stopAutoRefreshUserList {
    [timer invalidate];
}

- (void)loadListData:(LoadTriggerType)triggerType forNew:(BOOL)forNew {
    
  [super loadListData:triggerType forNew:forNew];
  
    _currentType = _userListType;
    if (_currentType == ALUMNI_TY || _currentType == SHAKE_USER_LIST_TY) {
        [AppManager instance].clubAdmin = NO;
    }
    
    NSString *tmpStr = [NSString stringWithFormat:@"<page>%d</page>", (self.pageIndex++)];
    NSString *param = [self.requestParam stringByReplacingOccurrencesOfString:@"<page>0</page>" withString:tmpStr];
    
    if (_currentType == SHAKE_USER_LIST_TY) {
        
        if (isFirst) {
            param = [param stringByReplacingOccurrencesOfString:@"<refresh_only>0</refresh_only>" withString:@"<refresh_only>1</refresh_only>"];
            isFirst = NO;
        }else if (forNew) {
            param = [param stringByReplacingOccurrencesOfString:[AppManager instance].shakeLocationHistory withString:[NSString stringWithFormat:@"<longitude>%f</longitude><latitude>%f</latitude>", [AppManager instance].longitude, [AppManager instance].latitude]];
        }
        
        if (_TableCellSaveValArray && _TableCellSaveValArray.count > 2) {
            // distance
            param = [param stringByReplacingOccurrencesOfString:@"<distance_scope>10</distance_scope>" withString:[NSString stringWithFormat:@"<distance_scope>%@</distance_scope>", _TableCellSaveValArray[0]]];
            
            // time
            param = [param stringByReplacingOccurrencesOfString:@"<time_scope>1000</time_scope>" withString:[NSString stringWithFormat:@"<time_scope>%@</time_scope>", _TableCellSaveValArray[1]]];
            
            // sort
            param = [param stringByReplacingOccurrencesOfString:@"<order_by_column>datetime</order_by_column>" withString:[NSString stringWithFormat:@"<order_by_column>%@</order_by_column>", _TableCellSaveValArray[2]]];
        }
    }
    
    NSString *url = [CommonUtils geneUrl:param itemType:_userListType];
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                             contentType:_userListType];
    [connFacade fetchGets:url];
}

- (void)addRefreshBtn {
    self.navigationItem.rightBarButtonItem = BAR_BUTTON(LocaleStringForKey(NSRefreshTitle, nil),UIBarButtonItemStyleDone, self, @selector(doRefresh:));
}

#pragma mark - UITableView lifecycle

- (void)doBack:(id)sender {
    
    if (_userListType != SHAKE_USER_LIST_TY) {
        [super close:nil];
    } else {
        [self goShake];
    }
}

- (void)goShake
{
    [AppManager instance].isAdminCheckIn = NO;
    
    ShakeViewController *shakeVC = [[[ShakeViewController alloc] initWithMOC:_MOC] autorelease];
    shakeVC.title = LocaleStringForKey(NSShakeTitle, nil);
    
    if ([CommonUtils currentOSVersion] < IOS5) {
        [shakeVC viewDidAppear:YES];
    }
    
    [APP_DELEGATE addViewInSlider:shakeVC
               invokeByController:self
                   stackStartView:YES];
    
    [APP_DELEGATE setMenuTitle:LocaleStringForKey(NSShakeTitle, nil)];
}

#pragma mark - life cycle
- (void)viewDidLoad {
    
	[super viewDidLoad];
    
    if (_userListType == SHAKE_USER_LIST_TY) {
        
        self.navigationItem.leftBarButtonItem = BAR_BUTTON(LocaleStringForKey(NSBackTitle, nil),UIBarButtonItemStyleBordered, self, @selector(doBack:));
        
        _toolTitleView = [[PostToolView alloc] initForShake:CGRectMake(0, 0, self.view.frame.size.width, SHAKE_HEADER_HEIGHT)
                                                   topColor:COLOR(236, 232, 226)
                                                bottomColor:COLOR(223, 220, 212)
                                                   delegate:self
                                           userListDelegate:self];
        [_toolTitleView setBackValue:([AppManager instance].distanceList)[0][1]
                                time:([AppManager instance].timeList)[0][1]
                                sort:([AppManager instance].sortList)[0][1]];
        [self.view addSubview:_toolTitleView];
        
        _tableView.frame = CGRectMake(0, _tableView.frame.origin.y + SHAKE_HEADER_HEIGHT, _tableView.frame.size.width, _tableView.frame.size.height - SHAKE_HEADER_HEIGHT);
        
        _TableCellShowValArray = [[NSMutableArray alloc] init];
        _TableCellSaveValArray = [[NSMutableArray alloc] init];
        for (NSUInteger i=0; i<3; i++) {
            [_TableCellShowValArray insertObject:[NSString stringWithFormat:@"%d",iOriginalSelIndexVal] atIndex:i];
            [_TableCellSaveValArray insertObject:@"" atIndex:i];
        }
        
        if ([AppManager instance].sortList.count > 0) {
            if (((NSArray *)([AppManager instance].sortList)[0]).count > 1) {
                [_TableCellShowValArray insertObject:([AppManager instance].sortList)[0][1] atIndex:2];
            }
        }
        [_TableCellSaveValArray insertObject:@"datetime" atIndex:2];
        
    }
    
    [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    isFirst = YES;
    
    // Club manage alumni
    if (_userListType == CLUB_MANAGE_USER_TY && [AppManager instance].clubAdmin && ![[AppManager instance].clubSupType isEqualToString:SELF_CLASS_TYPE] && [AppManager instance].isNeedReLoadUserList) {
        [CommonUtils doDelete:_MOC entityName:@"Alumni"];
        self.pageIndex = 0;
        _autoLoaded = NO;
        
        [AppManager instance].isNeedReLoadUserList = NO;
    }
    
    if (_userListType == CHAT_USER_LIST_TY) {
        self.pageIndex = self.pageIndex-1;
        if (self.pageIndex < 0) {
            self.pageIndex = 0;
        }
        _autoLoaded = NO;
    }
    
	[super deselectCell];
	
	if (!_autoLoaded) {
		[self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
	}
    
}

- (void)viewWillDisappear:(BOOL)animated {
	
    [super viewWillDisappear:animated];
    [WXWUIUtils closeActivityView];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
    
    self.alumni = nil;
    self.requestParam = nil;
    
    [NSFetchedResultsController deleteCacheWithName:nil];
	[super dealloc];
}

#pragma mark - UITableViewDelegate and UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedRC sections][section];
	iSize = [sectionInfo numberOfObjects];
	return iSize + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == iSize) {
		UITableViewCell *footerCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                              reuseIdentifier:@"footer"] autorelease];
		if (_footerRefreshView) {
			[_footerRefreshView removeFromSuperview];
		}
        
        footerCell.accessoryType = UITableViewCellAccessoryNone;
        footerCell.selectionStyle = UITableViewCellSelectionStyleNone;
		[footerCell addSubview:_footerRefreshView];
		
		return footerCell;
	}
    
	static NSString *kCellIdentifier = @"AlumniCell";
    
	UserListCell *cell = nil;
    
    cell = [[[UserListCell alloc] initWithStyle:UITableViewCellStyleDefault
                                reuseIdentifier:kCellIdentifier
                         imageDisplayerDelegate:self
                         imageClickableDelegate:self
                                            MOC:_MOC] autorelease];
    
    Alumni *aAlumni = (Alumni *)[self.fetchedRC objectAtIndexPath:indexPath];
    [cell drawCell:aAlumni userListType:_userListType];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return USER_LIST_CELL_HEIGHT;
}

- (void)didSelectCell:(Alumni *)alumni {
    switch (_userListType) {
        case ALUMNI_TY:
            [self showAlumniDetailByLocal:alumni needAddContact:NO];
            break;
            
        case CHAT_USER_LIST_TY:
            [self goChatView:alumni];
            break;
            
        default:
            [self showAlumniDetailByNet:alumni needAddContact:YES];
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == [[self.fetchedRC fetchedObjects] count]) {
        return;
    }
    
    Alumni *alumni = [self.fetchedRC objectAtIndexPath:indexPath];
    self.selectedIndexPath = indexPath;
    [self didSelectCell:alumni];
}

#pragma mark - show alumni detail info
- (void)showAlumniDetailByNet:(Alumni*)aAlumni needAddContact:(BOOL)needAddContact
{
    
    if (_userListType == SHAKE_USER_LIST_TY) {
        AlumniProfileViewController *profileVC = [[[AlumniProfileViewController alloc] initWithMOC:_MOC alumni:aAlumni userType:ALUMNI_USER_TY] autorelease];
        profileVC.title = LocaleStringForKey(NSAlumniDetailTitle, nil);
        
        WXWNavigationController *mNC = [[[WXWNavigationController alloc] initWithRootViewController:profileVC] autorelease];
        
        [APP_DELEGATE addViewInSlider:mNC
                   invokeByController:self
                       stackStartView:NO];
    } else {
        AlumniProfileViewController *profileVC = [[[AlumniProfileViewController alloc] initWithMOC:_MOC alumni:aAlumni userType:ALUMNI_USER_TY] autorelease];
        profileVC.title = LocaleStringForKey(NSAlumniDetailTitle, nil);
        
        [self.navigationController pushViewController:profileVC animated:YES];
    }
}

- (void)showAlumniDetailByLocal:(Alumni*)aAlumni needAddContact:(BOOL)needAddContact
{
    AlumniProfileViewController *profileVC = [[[AlumniProfileViewController alloc] initWithMOC:_MOC alumni:aAlumni userType:ALUMNI_USER_TY] autorelease];
    profileVC.title = LocaleStringForKey(NSAlumniDetailTitle, nil);
    [self.navigationController pushViewController:profileVC animated:YES];
}

#pragma mark - WXWConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(WebItemType)contentType {
    
    [WXWUIUtils showActivityView:[APP_DELEGATE foundationView] text:LocaleStringForKey(NSLoadingTitle, nil)];
    [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(WebItemType)contentType{
    
    switch (contentType) {
            
        case CLUB_MANAGE_USER_TY:
        case CLUB_MANAGE_QUERY_USER_TY:
        case SIGNUP_USER_TY:
        case WINNER_USER_TY:
        {
            if ([XMLParser parserSyncResponseXml:result type:FETCH_EVENT_ALUMNI_SRC MOC:_MOC]) {
                [self resetUIElementsForConnectDoneOrFailed];
            } else {
                [WXWUIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSFetchAlumniFailedMsg, nil)
                                              msgType:ERROR_TY
                                   belowNavigationBar:YES];
                
            }
            
            break;
        }
            
        case POST_LIKE_USER_LIST_TY:
        {
            if ([XMLParser parserSyncResponseXml:result type:FETCH_POST_LIKE_USER_SRC MOC:_MOC]) {
                [self resetUIElementsForConnectDoneOrFailed];
            } else {
                [WXWUIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSActionFaildMsg, nil)
                                              msgType:ERROR_TY
                                   belowNavigationBar:YES];
                
            }
            
            break;
        }
            
        case CHAT_USER_LIST_TY:
        {
            if ([XMLParser parserSyncResponseXml:result type:CHART_LIST_USER_SRC MOC:_MOC]) {
                [self resetUIElementsForConnectDoneOrFailed];
            } else {
                [WXWUIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSActionFaildMsg, nil)
                                              msgType:ERROR_TY
                                   belowNavigationBar:YES];
                
            }
            
            break;
        }
            
        case SHAKE_USER_LIST_TY:
        {
            if ([XMLParser parserSyncResponseXml:result
                                            type:FETCH_SHAKE_USER_SRC
                                             MOC:_MOC]) {
                
                [_toolTitleView setWinnerInfo:[AppManager instance].shakeWinnerInfo
                                   winnerType:[AppManager instance].shakeWinnerType];
                
                [self resetUIElementsForConnectDoneOrFailed];
            } else {
                [WXWUIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSFetchAlumniFailedMsg, nil)
                                              msgType:ERROR_TY
                                   belowNavigationBar:YES];
                
            }
            
            break;
        }
            
        case ALUMNI_TY:
        {
            if ([XMLParser parserSyncResponseXml:[EncryptUtil TripleDESforNSData:result encryptOrDecrypt:kCCDecrypt]
                                            type:FETCH_ALUMNI_SRC MOC:_MOC]) {
                [self resetUIElementsForConnectDoneOrFailed];
                
            } else {
                [WXWUIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSFetchAlumniFailedMsg, nil)
                                              msgType:ERROR_TY
                                   belowNavigationBar:YES];
                
            }
            break;
        }
            
        default:
            break;
    }
    
    [self refreshTable];
    
    _autoLoaded = YES;
  
  [super connectDone:result url:url contentType:contentType];
}

- (void)connectCancelled:(NSString *)url
             contentType:(WebItemType)contentType {
  [super connectCancelled:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(WebItemType)contentType {
  [super connectFailed:error url:url contentType:contentType];
}

#pragma mark - action

- (void)doRefresh:(id)sender
{
    [self getCurrentLocationInfoIfNecessary];
}

- (void)doSelect
{
    [CommonUtils doDelete:_MOC entityName:@"Alumni"];
    self.pageIndex = 0;
    [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
}

#pragma mark - UIPickerViewDelegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    pickSel0Index = row;
    isPickSelChange = YES;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_PickData count];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return _frame.size.width;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _PickData[row];
}

- (void)setDropDownValueArray:(UIButton *)sender type:(int)type
{
    [NSFetchedResultsController deleteCacheWithName:nil];
    iFliterIndex = type;
    self.descriptors = [NSMutableArray array];
    
    self.DropDownValArray = [[[NSMutableArray alloc] init] autorelease];
    
    switch (type) {
            
        case SHOW_DISTANCE_TY:
        {
            self.DropDownValArray = [AppManager instance].distanceList;
        }
            break;
            
        case SHOW_TIME_TY:
        {
            self.DropDownValArray = [AppManager instance].timeList;
        }
            break;
            
        case SHOW_SORT_TY:
        {
            self.DropDownValArray = [AppManager instance].sortList;
        }
            break;
    }
    
    _UIPopoverArrowDirection = UIPopoverArrowDirectionUp;
    [super setPopView];
    
    [_popViewController presentPopoverFromRect:CGRectMake(sender.frame.origin.x, sender.frame.origin.y, sender.frame.size.width, TOOLBAR_HEIGHT)
                                        inView:self.view
                      permittedArrowDirections:UIPopoverArrowDirectionAny
                                      animated:YES];
}

-(void)onPopCancle:(id)sender {
    [super onPopCancle];
    
    [_TableCellShowValArray removeObjectAtIndex:iFliterIndex];
    [_TableCellShowValArray insertObject:[NSString stringWithFormat:@"%d",iOriginalSelIndexVal] atIndex:iFliterIndex];
    
    [_TableCellSaveValArray removeObjectAtIndex:iFliterIndex];
    [_TableCellSaveValArray insertObject:@"" atIndex:iFliterIndex];
    
    [_tableView reloadData];
}

-(void)onPopOk:(id)sender {
    
    [super onPopSelectedOk];
    int iPickSelectIndex = [super pickerList0Index];
    
    [self setTableCellVal:iFliterIndex aShowVal:(self.DropDownValArray)[iPickSelectIndex][RECORD_NAME]
                 aSaveVal:(self.DropDownValArray)[iPickSelectIndex][RECORD_ID] isFresh:YES];
    
    [self doSelect];
}

-(void)setTableCellVal:(int)index aShowVal:(NSString*)aShowVal aSaveVal:(NSString*)aSaveVal isFresh:(BOOL)isFresh
{
    [_TableCellShowValArray removeObjectAtIndex:index];
    [_TableCellShowValArray insertObject:aShowVal atIndex:index];
    
    [_TableCellSaveValArray removeObjectAtIndex:index];
    [_TableCellSaveValArray insertObject:aSaveVal atIndex:index];
    
    [_toolTitleView setBackValue:_TableCellShowValArray[0]
                            time:_TableCellShowValArray[1]
                            sort:_TableCellShowValArray[2]];
    
}

#pragma mark - FilterListDelegate
- (void)showDistanceList:(id)sender
{
    [self setDropDownValueArray:sender type:SHOW_DISTANCE_TY];
}

- (void)showTimeList:(id)sender
{
    [self setDropDownValueArray:sender type:SHOW_TIME_TY];
}

- (void)showSortList:(id)sender
{
    [self setDropDownValueArray:sender type:SHOW_SORT_TY];
}

#pragma mark - location result
- (void)locationResult:(int)type {
    NSLog(@"shake type is %d", type);
    
    [WXWUIUtils closeActivityView];
    
    switch (type) {
        case 0:
        {
            _reloading = YES;
            [self loadListData:TRIGGERED_BY_SCROLL forNew:YES];
            
            if (_toolTitleView) {
                [_toolTitleView animationGift];
            }
        }
            break;
            
        case 1:
        {
            [WXWUIUtils showNotificationOnTopWithMsg:@"定位失败"
                                          msgType:ERROR_TY
                               belowNavigationBar:YES];
            
        }
            break;
            
        default:
            break;
    }
    
}

#pragma mark - ECClickableElementDelegate method
- (void)doChat:(Alumni*)aAlumni sender:(id)sender
{
    
    //    [self goActionSheet:sender];
    //    self.alumni = aAlumni;
    [self goChatView:aAlumni];
}

- (void)openProfile:(NSString*)personId userType:(NSString*)userType
{
    if (_userListType == SHAKE_USER_LIST_TY) {
        return;
    }
    
    AlumniProfileViewController *profileVC = [[[AlumniProfileViewController alloc]
                                               initWithMOC:_MOC
                                               personId:personId
                                               userType:ALUMNI_USER_TY] autorelease];
    profileVC.title = LocaleStringForKey(NSAlumniDetailTitle, nil);
    
    [self.navigationController pushViewController:profileVC animated:YES];
}

- (void)goChatView:(Alumni *)aAlumni {
    
    [CommonUtils doDelete:_MOC entityName:@"Chat"];
    ChatListViewController *chatVC = [[[ChatListViewController alloc] initWithMOC:_MOC alumni:(AlumniDetail*)aAlumni] autorelease];
    
    if (_userListType != SHAKE_USER_LIST_TY) {
        
        [self.navigationController pushViewController:chatVC animated:YES];
    } else {
        WXWNavigationController *mNC = [[[WXWNavigationController alloc] initWithRootViewController:chatVC] autorelease];
        
        [APP_DELEGATE addViewInSlider:mNC
                   invokeByController:self
                       stackStartView:NO];
    }
}

- (void)goActionSheet:(id)sender {
    
    UIActionSheet *as = [[[UIActionSheet alloc] initWithTitle:LocaleStringForKey(NSActionSheetTitle, nil)
                                                     delegate:self
                                            cancelButtonTitle:nil
                                       destructiveButtonTitle:LocaleStringForKey(NSChatActionSheetTitle, nil)
                                            otherButtonTitles:nil] autorelease];
    
    [as addButtonWithTitle:LocaleStringForKey(NSProfileActionSheetTitle, nil)];
    [as addButtonWithTitle:LocaleStringForKey(NSCancelTitle, nil)];
    as.cancelButtonIndex = [as numberOfButtons] - 1;
    
    NSIndexPath *indexPath = [_tableView indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
    
    UIButton *button = (UIButton *)sender;
    [as showFromRect:CGRectMake(cell.bounds.origin.x + button.frame.origin.x + 4*MARGIN, cell.bounds.origin.y + button.frame.origin.y, button.frame.size.width, button.frame.size.height)
              inView:cell
            animated:YES];
}

- (void)showWinnersAndAwards {
    
    NSString *url = [NSString stringWithFormat:@"%@event?action=page_load&page_name=shake_it_off_wap&locale=%@&user_id=%@&plat=%@&version=%@&sessionId=%@&person_id=%@&channel=%d&user_name=%@&user_type=%@&class_id=%@&class_name=%@&latitude=%f&longitude=%f&winner_type=%d",
                     [AppManager instance].hostUrl,
                     [AppManager instance].currentLanguageDesc,
                     [AppManager instance].userId,
                     PLATFORM,
                     VERSION,
                     [AppManager instance].sessionId,
                     [AppManager instance].personId,
                     [AppManager instance].releaseChannelType,
                     [AppManager instance].username,
                     [AppManager instance].userType,
                     [AppManager instance].classGroupId,
                     [AppManager instance].className,
                     [AppManager instance].latitude,
                     [AppManager instance].longitude,
                     [AppManager instance].shakeWinnerType];
    
    [self goUrl:url aTitle:@""];
    
}

#pragma mark - Action Sheet
- (void)actionSheet:(UIActionSheet*)aSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	switch (buttonIndex) {
		case CHAT_SHEET_IDX:
		{
            [self goChatView:self.alumni];
            return;
		}
            
		case DETAIL_SHEET_IDX:
            [self didSelectCell:self.alumni];
			return;
			
        case CANCEL_SHEET_IDX:
            return;
            
		default:
			break;
	}
}

@end
