//
//  ClubListViewController.m
//  iAlumniHD
//
//  Created by Adam on 12-11-24.
//
//

#import "ClubListViewController.h"
#import "GroupDiscussionViewController.h"
#import "SearchClubViewController.h"
#import "ClubListCell.h"
#import "EventCity.h"
#import "Club.h"

@interface ClubListViewController()
@end

@implementation ClubListViewController
@synthesize requestParam = _requestParam;
@synthesize pageIndex = _pageIndex;
@synthesize clubFliters;
@synthesize _likeIcon;
@synthesize _likeCountLabel;
@synthesize _commentIcon;
@synthesize _commentCountLabel;
@synthesize onlyMine;
@synthesize sortType;

- (id)initWithMOC:(NSManagedObjectContext *)MOC listType:(ClubListViewType)listType {
    
    self = [super initWithMOC:MOC
                       holder:nil
             backToHomeAction:nil
        needRefreshHeaderView:NO
        needRefreshFooterView:YES
                   tableStyle:UITableViewStylePlain
                   needGoHome:NO];
    
    if (self) {
        //init value
        [AppManager instance].clubType = @"";
        self.pageIndex = 0;
        _listType = listType;
        
        [AppManager instance].needSaveMyClassNum = NO;
        
        switch (_listType) {
                
            case CLUB_LIST_BY_POST_TIME:
            {
                self.sortType = @"2";
                self.onlyMine = @"0";
            }
                break;
                
            case CLUB_LIST_BY_NAME:
            {
                self.sortType = @"1";
                self.onlyMine = @"0";
            }
                break;
                
            default:
                break;
        }
    }
    
    return self;
}

- (void)dealloc {
    
    self.sortType = nil;
    self.onlyMine = nil;

    [NSFetchedResultsController deleteCacheWithName:nil];
    
    DELETE_OBJS_FROM_MOC(_MOC, @"Club", nil);
    
    if ([AppManager instance].rootVC) {
        [AppManager instance].rootVC = nil;
    }
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - load club
- (void)loadListData:(LoadTriggerType)triggerType forNew:(BOOL)forNew {
    
    [super loadListData:triggerType forNew:forNew];
    
    if (self.pageIndex == 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(usageType == %d)", ORDINARY_USAGE_GP_TY];
        DELETE_OBJS_FROM_MOC(_MOC, @"Club", predicate);
    }
    
    NSInteger index = 0;
    if (!forNew) {
        index = ++_currentStartIndex;
    }
    
    self.requestParam = [NSString stringWithFormat:@"<keyword>%@</keyword><sort_type>%@</sort_type><only_mine>%@</only_mine><host_type_value>%@</host_type_value><host_sub_type_value>%@</host_sub_type_value><page_size>30</page_size><page>%d</page>", [AppManager instance].clubKeyWord, self.sortType, self.onlyMine, [AppManager instance].supClubTypeValue, [AppManager instance].hostTypeValue, index];
    
    NSString *tmpStr = [NSString stringWithFormat:@"<page>%d</page>", self.pageIndex++];
    self.requestParam = [self.requestParam stringByReplacingOccurrencesOfString:@"<page>0</page>" withString:tmpStr];
    
    NSString *url = [CommonUtils geneUrl:self.requestParam itemType:CLUBLIST_TY];
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url contentType:CLUBLIST_TY];
    [connFacade fetchGets:url];
}

#pragma mark - core data
- (void)setPredicate {
    
    self.predicate = [NSPredicate predicateWithFormat:@"(usageType == %d)", ORDINARY_USAGE_GP_TY];
    self.entityName = @"Club";
    
    self.descriptors = [NSMutableArray array];
    NSSortDescriptor *dateDesc = [[[NSSortDescriptor alloc] initWithKey:@"showOrder" ascending:YES] autorelease];
    [self.descriptors addObject:dateDesc];
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (_listType == CLUB_LIST_BY_NAME) {
        self.title = LocaleStringForKey(NSSearchResultTitle, nil);
    }
    
    self.navigationItem.leftBarButtonItem = BAR_BUTTON(LocaleStringForKey(NSBackBtnTitle, nil), UIBarButtonItemStyleDone, self, @selector(doClose:));
}

- (void)viewDidAppear:(BOOL)animated {
    
	NSIndexPath *selection = [_tableView indexPathForSelectedRow];
	if (selection) {
		[_tableView deselectRowAtIndexPath:selection animated:YES];
	}
	
	if (!_autoLoaded) {
		[self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	return self.fetchedRC.fetchedObjects.count + 1;
}

- (void)updateTable:(NSArray *)indexPaths {
    [_tableView beginUpdates];
    [_tableView reloadRowsAtIndexPaths:indexPaths
                      withRowAnimation:UITableViewRowAnimationNone];
    [_tableView endUpdates];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Foot Cell
    if (indexPath.row == self.fetchedRC.fetchedObjects.count) {
        return [self drawFooterCell];
	}
    
    // Club Cell
    static NSString *kEventCellIdentifier = @"ClubListCell";
    ClubListCell *cell = nil;
    
    cell = [[[ClubListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kEventCellIdentifier] autorelease];
    
    Club *club = [self.fetchedRC objectAtIndexPath:indexPath];
    [cell drawClub:club];
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == _fetchedRC.fetchedObjects.count) {
        return;
    }
    
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    Club *club = [self.fetchedRC objectAtIndexPath:indexPath];
    [AppManager instance].clubId = [NSString stringWithFormat:@"%@", club.clubId];
    [AppManager instance].clubType = [NSString stringWithFormat:@"%@", club.clubType];
    [AppManager instance].hostSupTypeValue = club.hostSupTypeValue;
    [AppManager instance].hostTypeValue = club.hostTypeValue;
    
    [self goPostView:CLUB_SELF_VIEW group:club];
    
    //    self.pageIndex --;
    //    _autoLoaded = NO;
    //    [super deselectCell];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CLUB_LIST_CELL_HEIGHT;
}

#pragma mark - load Event list from web

- (void)stopAutoRefreshUserList {
    [timer invalidate];
}

#pragma mark - reset refresh header/footer view status
- (void)resetHeaderRefreshViewStatus {
	_reloading = NO;
	[WXWUIUtils dataSourceDidFinishLoadingNewData:_tableView
                                    headerView:_headerRefreshView];
}

- (void)resetFooterRefreshViewStatus {
	_reloading = NO;
	
	[WXWUIUtils dataSourceDidFinishLoadingOldData:_tableView
                                    footerView:_footerRefreshView];
}

- (void)resetHeaderOrFooterViewStatus {
    
    if (_loadForNewItem) {
        [self resetHeaderRefreshViewStatus];
    } else {
        [self resetFooterRefreshViewStatus];
    }
}

- (void)resetUIElementsForConnectDoneOrFailed {
    switch (_currentLoadTriggerType) {
        case TRIGGERED_BY_AUTOLOAD:
            _autoLoaded = YES;
            break;
            
        case TRIGGERED_BY_SCROLL:
            [self resetHeaderOrFooterViewStatus];
            break;
            
        default:
            break;
    }
}

#pragma mark - WXWConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(WebItemType)contentType
{
    
    [WXWUIUtils showActivityView:[APP_DELEGATE foundationView] text:LocaleStringForKey(NSLoadingTitle, nil)];
    [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(WebItemType)contentType
{
    
    switch (contentType) {
            
        case CLUBLIST_TY:
        {
            if ([XMLParser parserSyncResponseXml:result type:FETCH_CLUB_SRC MOC:_MOC]) {
                [self refreshTable];
                _autoLoaded = YES;
                [self resetUIElementsForConnectDoneOrFailed];
            } else {
                [WXWUIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSActionFaildMsg, nil)
                                              msgType:ERROR_TY
                                   belowNavigationBar:YES];
                
            }
            break;
        }
            
        default:
            break;
    }
    
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

#pragma mark - Post List View
- (void)goPostView:(ClubViewType)showType group:(Club *)group {
    
    [CommonUtils doDelete:_MOC entityName:@"Post"];
    
    GroupDiscussionViewController *postListVC = [[[GroupDiscussionViewController alloc] initWithMOC:_MOC
                                                                                              group:group
                                                                                             holder:nil
                                                                                   backToHomeAction:nil
                                                                                             parent:self
                                                                                refreshParentAction:nil
                                                                                           listType:ALL_ITEM_LIST_TY
                                                                                           showType:showType] autorelease];
    
    if (showType == CLUB_ALL_POST_SHOW) {
        postListVC.title = LocaleStringForKey(NSClubPostTitle, nil);
    } else {
        postListVC.title = @"协会动态";
    }
    
    [self setRefreshVC:self];
    
    WXWNavigationController *detailNC = [[[WXWNavigationController alloc] initWithRootViewController:postListVC] autorelease];
    
    [APP_DELEGATE addViewInSlider:detailNC
               invokeByController:self
                   stackStartView:NO];
    
}

- (void)doUserDetail:(id)sender {
    
}

- (void)doClose:(id)sender {
    
    if (_listType == CLUB_LIST_BY_NAME) {
        [self.navigationController popViewControllerAnimated:YES];
        [super close:nil];
    } else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)doParentRefreshView {
    [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
}

@end