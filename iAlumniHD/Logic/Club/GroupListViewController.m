//
//  GroupListViewController.m
//  iAlumniHD
//
//  Created by MobGuang on 12-10-5.
//
//

#import "GroupListViewController.h"
#import "PlainTabView.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "Club.h"
#import "AppManager.h"
#import "ClubListCell.h"
#import "SearchClubViewController.h"
#import "GroupInfoCell.h"
#import "ShareViewController.h"
#import "GroupDiscussionViewController.h"

enum {
    MY_GP_IDX = 0,
    ALL_GP_IDX,
};

enum {
    ALL_GP_SCOPE = 0,
    MY_GP_SCOPE = 1,
};

//#define HEADER_HEIGHT   40.0f

@interface GroupListViewController ()

@end

@implementation GroupListViewController

#pragma mark - user actions
- (void)search:(id)sender {
    [super close:nil];
    
    if (![AppManager instance].clubFliterLoaded) {
        [self loadOptions];
    } else {
        [self enterSearchView];
    }
}

- (void)enterGroup:(ClubViewType)showType group:(Club *)group {
    
    [AppManager instance].allowSendSMS = NO;
    
    GroupDiscussionViewController *postListVC = [[[GroupDiscussionViewController alloc] initWithMOC:_MOC
                                                                                              group:group
                                                                                             holder:nil
                                                                                   backToHomeAction:nil
                                                                                             parent:self
                                                                                refreshParentAction:@selector(setTriggerReloadListFlag)
                                                                                           listType:ALL_ITEM_LIST_TY
                                                                                           showType:showType] autorelease];
    if (showType == CLUB_ALL_POST_SHOW) {
        postListVC.title = LocaleStringForKey(NSClubPostTitle, nil);
    } else {
        postListVC.title = LocaleStringForKey(NSGroupTrendsTitle, nil);
    }
    
    switch (_showType) {
        case MENU_CLUB_SHOW:
        {
            postListVC.deSelectCellDelegate = self;
            
            [self setRefreshVC:self];
            
            WXWNavigationController *detailNC = [[[WXWNavigationController alloc] initWithRootViewController:postListVC] autorelease];
            
            [APP_DELEGATE addViewInSlider:detailNC
                       invokeByController:self
                           stackStartView:NO];
        }
            break;
            
        case PAGE_CLUB_SHOW:
        {
            postListVC.deSelectCellDelegate = self;
            
            [self setRefreshVC:self];
            
            WXWNavigationController *detailNC = [[[WXWNavigationController alloc] initWithRootViewController:postListVC] autorelease];
            
            [APP_DELEGATE addViewInSlider:detailNC
                       invokeByController:self
                           stackStartView:NO];
        }
            break;
            
        default:
            break;
    }
}

- (void)enterAllScopeGroup:(NSString *)title {
    ShareViewController *detailVC = [[[ShareViewController alloc] initWithMOC:_MOC
                                                                       holder:nil
                                                             backToHomeAction:nil
                                                                     listType:ALL_ITEM_LIST_TY] autorelease];
    detailVC.title = title;
    switch (_showType) {
        case MENU_CLUB_SHOW:
        {
            detailVC.deSelectCellDelegate = self;
            [self setRefreshVC:self];
            
            WXWNavigationController *detailNC = [[[WXWNavigationController alloc] initWithRootViewController:detailVC] autorelease];
            
            [APP_DELEGATE addViewInSlider:detailNC
                       invokeByController:self
                           stackStartView:NO];
        }
            break;
            
        case PAGE_CLUB_SHOW:
        {
            [self.navigationController pushViewController:detailVC animated:YES];
        }
            break;
            
        default:
            break;
    }
    
}

#pragma mark - load club
- (void)setPredicate {
    self.entityName = @"Club";
    
    self.descriptors = [NSMutableArray array];
    NSSortDescriptor *dateDesc = [[[NSSortDescriptor alloc] initWithKey:@"showOrder"
                                                              ascending:YES] autorelease];
    [self.descriptors addObject:dateDesc];
    
    self.predicate = [NSPredicate predicateWithFormat:@"(usageType == %d)", ORDINARY_USAGE_GP_TY];
}

- (void)loadListData:(LoadTriggerType)triggerType forNew:(BOOL)forNew {
    
    [super loadListData:triggerType forNew:forNew];
    
    _showNewLoadedItemCount = NO;
    
    NSInteger index = 0;
    if (!forNew) {
        index = ++_currentStartIndex;
    }
    
    NSString *requestParam = [NSString stringWithFormat:@"<keyword></keyword><sort_type>2</sort_type><only_mine>%d</only_mine><host_type_value></host_type_value><host_sub_type_value></host_sub_type_value><page_size>%@</page_size><page>%d</page>", _myGroupFlag, ITEM_LOAD_COUNT, index];
    
    NSString *url = [CommonUtils geneUrl:requestParam itemType:CLUBLIST_TY];
    WXWAsyncConnectorFacade *connFacade = [[[WXWAsyncConnectorFacade alloc] initWithDelegate:self
                                                                      interactionContentType:CLUBLIST_TY] autorelease];
    (self.connDic)[url] = connFacade;
    [connFacade fetchGets:url];
    
}

- (void)loadOptions {
    NSString *url = [CommonUtils geneUrl:@"" itemType:CLUB_FLITER_TY];
    WXWAsyncConnectorFacade *connFacade = [[[WXWAsyncConnectorFacade alloc] initWithDelegate:self
                                                                      interactionContentType:CLUB_FLITER_TY] autorelease];
    (self.connDic)[url] = connFacade;
    [connFacade fetchGets:url];
}

- (void)setTriggerReloadListFlag {
    _needReloadGroups = YES;
}

#pragma mark - show search view
- (void)enterSearchView {
    
    SearchClubViewController *searchClubVC = [[[SearchClubViewController alloc] initWithMOC:_MOC] autorelease];
    
    searchClubVC.title = LocaleStringForKey(NSSearchTitle, nil);
    [AppManager instance].clubKeyWord = @"";
    [AppManager instance].supClubTypeValue = @"";
    [AppManager instance].hostTypeValue = @"";
    
    [self.navigationController pushViewController:searchClubVC animated:YES];
    
    _needReloadGroups = YES;
    
    [self clearList];
}

#pragma mark - lifecycle methods
- (id)initWithMOC:(NSManagedObjectContext *)MOC
{
    
    self = [super initWithMOC:MOC
                       holder:nil
             backToHomeAction:nil
        needRefreshHeaderView:NO
        needRefreshFooterView:YES
                   needGoHome:YES];
    
    if (self) {
        _showType = MENU_CLUB_SHOW;
        _currentStartIndex = 0;
        _startTabIndex = MY_GP_IDX;
        
        _myGroupFlag = MY_GP_SCOPE;
        
        _noNeedDisplayEmptyMsg = YES;
        
        [self clearData];
    }
    
    return self;
}

- (id)initForAllGroupsWithMOC:(NSManagedObjectContext *)MOC {
    
    self = [super initWithMOC:MOC
                       holder:nil
             backToHomeAction:nil
        needRefreshHeaderView:NO
        needRefreshFooterView:YES
                   needGoHome:NO];
    
    if (self) {
        _showType = PAGE_CLUB_SHOW;
        _currentStartIndex = 0;
        
        _startTabIndex = MY_GP_IDX;
        
        _myGroupFlag = ALL_GP_SCOPE;
        
        _noNeedDisplayEmptyMsg = YES;
        
        [self clearData];
    }
    return self;
}

- (void)clearData {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(usageType == %d)", ORDINARY_USAGE_GP_TY];
    DELETE_OBJS_FROM_MOC(_MOC, @"Club", predicate);
}

- (void)dealloc {
    
    if ([AppManager instance].rootVC) {
        [AppManager instance].rootVC = nil;
    }
    
    [super dealloc];
}

- (void)setTableViewProperties {
    _tableView.frame = CGRectMake(0, HEADER_HEIGHT,
                                  _tableView.frame.size.width,
                                  _tableView.frame.size.height - HEADER_HEIGHT);
}

- (void)addSearchButton {
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:LocaleStringForKey(NSSearchTitle, nil)
                                                                               style:UIBarButtonItemStyleBordered
                                                                              target:self
                                                                              action:@selector(search:)] autorelease];
}

- (void)initTabSwitchView {
    _tabSwitchView = [[[PlainTabView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, HEADER_HEIGHT) buttonTitles:@[LocaleStringForKey(NSMyGroupsTitle, nil), LocaleStringForKey(NSAllGroupsTitle, nil)] tapSwitchDelegate:self selTabIndex:_startTabIndex] autorelease];
    
    [self.view addSubview:_tabSwitchView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
    self.view.backgroundColor = CELL_COLOR;
    
    [self initTabSwitchView];
    
    [self setTableViewProperties];
    
    [self addSearchButton];
    
    self.navigationItem.leftBarButtonItem = BAR_BUTTON(LocaleStringForKey(NSBackBtnTitle, nil), UIBarButtonItemStyleDone, self, @selector(doClose:));
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (_autoLoaded) {
        [self updateLastSelectedCell];
    }
    
    if (!_autoLoaded || _needReloadGroups) {
        
        [self clearData];
        
        [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - WXWConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(WebItemType)contentType {
    
    [WXWUIUtils showActivityView:[APP_DELEGATE foundationView]
                            text:LocaleStringForKey(NSLoadingTitle, nil)];
    [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(WebItemType)contentType {
    
    switch (contentType) {
        case CLUBLIST_TY:
        {
            if ([XMLParser parserSyncResponseXml:result type:FETCH_CLUB_SRC MOC:_MOC]) {
                if (!_autoLoaded) {
                    _autoLoaded = YES;
                }
                
                if (_needReloadGroups) {
                    _needReloadGroups = NO;
                }
                
                [self refreshTable];
                
            } else {
                [WXWUIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSLoadGroupFailedMsg, nil)
                                                 msgType:ERROR_TY
                                      belowNavigationBar:YES];
                
            }
            
            break;
        }
            
        case CLUB_FLITER_TY:
        {
            BOOL ret = [XMLParser parserSyncResponseXml:result
                                                   type:FETCH_CLUB_FLITER_SRC
                                                    MOC:_MOC];
            
            if (ret) {
                [AppManager instance].clubFliterLoaded = YES;
                [self enterSearchView];
            } else {
                [WXWUIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSLoadFilterOptionsFailedMsg, nil)
                                                 msgType:ERROR_TY
                                      belowNavigationBar:YES];
                
            }
            
            [WXWUIUtils closeActivityView];
            break;
        }
            
        default:
            break;
    }
    
    [super connectDone:result url:url contentType:contentType];
}

- (void)connectCancelled:(NSString *)url
             contentType:(WebItemType)contentType {
    [WXWUIUtils closeActivityView];
    
    [super connectCancelled:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(WebItemType)contentType {
    
    NSString *msg = nil;
    
    switch (contentType) {
        case CLUBLIST_TY:
        {
            msg = LocaleStringForKey(NSLoadGroupFailedMsg, nil);
            break;
        }
            
        case CLUB_FLITER_TY:
        {
            msg = LocaleStringForKey(NSLoadFilterOptionsFailedMsg, nil);
            
            [WXWUIUtils closeActivityView];
            break;
        }
            
        default:
            break;
    }
    
    if ([self connectionMessageIsEmpty:error]) {
        self.connectionErrorMsg = msg;
    }
    
    [super connectFailed:error url:url contentType:contentType];
}

#pragma mark - clear list
- (void)clearList {
    self.fetchedRC = nil;
    [_tableView reloadData];
    
    _currentStartIndex = 0;
    _autoLoaded = NO;
}

#pragma mark - TapSwitchDelegate method
- (void)selectTapByIndex:(NSInteger)index {
    
    [super close:nil];
    [self clearData];
    [self clearList];
    
    switch (index) {
        case MY_GP_IDX:
            _myGroupFlag = MY_GP_SCOPE;
            break;
            
        case ALL_GP_IDX:
            _myGroupFlag = ALL_GP_SCOPE;
            break;
            
        default:
            break;
    }
    
    _tableView.frame = CGRectMake(0, HEADER_HEIGHT,
                                  _tableView.frame.size.width,
                                  self.view.frame.size.height);
    
    [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
}

#pragma mark - UITableViewDelegate and UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fetchedRC.fetchedObjects.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == self.fetchedRC.fetchedObjects.count) {
        return [self drawFooterCell];
	}
    
    // Club Cell
    static NSString *kCellIdentifier = @"ClubListCell";
    
    Club *club = [self.fetchedRC objectAtIndexPath:indexPath];
    
    GroupInfoCell *cell = (GroupInfoCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    if (nil == cell) {
        cell = [[[GroupInfoCell alloc] initWithStyle:UITableViewCellStyleDefault
                                     reuseIdentifier:kCellIdentifier] autorelease];
    }
    
    [cell drawCell:club];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CLUB_LIST_CELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == _fetchedRC.fetchedObjects.count) {
        return;
    }
    
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    self.selectedIndexPath = indexPath;
    
    Club *club = [self.fetchedRC objectAtIndexPath:indexPath];
    
    if (club.clubId.intValue == ALL_SCOPE_GP_ID) {
        
        [self enterAllScopeGroup:club.clubName];
        
    } else {
        [AppManager instance].clubName = [NSString stringWithFormat:@"%@", club.clubName];
        [AppManager instance].clubId = [NSString stringWithFormat:@"%@", club.clubId];
        [AppManager instance].clubType = [NSString stringWithFormat:@"%@", club.clubType];
        [AppManager instance].hostSupTypeValue = club.hostSupTypeValue;
        [AppManager instance].hostTypeValue = club.hostTypeValue;
        
        [AppManager instance].isNeedReLoadClubDetail = YES;
        
        club.badgeNum = @"";
        SAVE_MOC(_MOC);
        
        [self enterGroup:CLUB_SELF_VIEW group:club];
    }
    
}

- (void)doParentRefreshView {
    [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
}

- (void)doClose:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [super close:nil];
}

@end
