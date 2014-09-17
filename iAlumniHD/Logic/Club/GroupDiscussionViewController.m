//
//  GroupDiscussionViewController.m
//  iAlumniHD
//
//  Created by MobGuang on 12-10-23.
//
//

#import "GroupDiscussionViewController.h"
#import "ItemPropertiesListViewController.h"
#import "GroupMemberListViewController.h"
#import "ClubEventListViewController.h"
#import "AlumniProfileViewController.h"
#import "AlumniProfileViewController.h"
#import "PostDetailViewController.h"
#import "AllScopeGroupHeaderView.h"
#import "ComposerViewController.h"
#import "ClubDetailController.h"
#import "ECHandyImageBrowser.h"
#import "GroupDiscussionCell.h"
#import "PostListCell.h"
#import "SortOption.h"
#import "Country.h"
#import "Place.h"
#import "Post.h"
#import "Tag.h"
#import "Club.h"

#define CLUB_HEADER_HEIGHT        230.0f
#define ALL_SCOPE_HEADER_HEIGHT   117.0f
#define TAB_H   45.0f

#define TAG_HEIGHT      20.0f

@interface GroupDiscussionViewController ()

@property (nonatomic, copy) NSString *filterCountryId;
@property (nonatomic, copy) NSString *currentTagIds;
@property (nonatomic, copy) NSString *currentFiltersTitle;
@property (nonatomic, copy) NSString *distanceParams;
@property (nonatomic, copy) NSString *filterCityId;
@property (nonatomic, copy) NSString *targetUserId;
@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, retain) Club *group;
@end

@implementation GroupDiscussionViewController
@synthesize pageIndex = _pageIndex;
@synthesize currentTagIds = _currentTagIds;
@synthesize currentFiltersTitle = _currentFiltersTitle;
@synthesize filterCountryId = _filterCountryId;
@synthesize distanceParams = _distanceParams;
@synthesize filterCityId = _filterCityId;
@synthesize targetUserId = _targetUserId;
@synthesize group = _group;
@synthesize postListType;

#pragma mark - ClubManagementDelegate methods
- (void)doPost {
  
  ComposerViewController *composerVC =  [[[ComposerViewController alloc] initForShareWithMOC:_MOC
                                                                                    delegate:self
                                                                                     groupId:LLINT_TO_STRING(self.group.clubId.longLongValue)] autorelease];
  composerVC.title = LocaleStringForKey(NSNewFeedTitle, nil);
  
  WXWNavigationController *composerNC = [[[WXWNavigationController alloc] initWithRootViewController:composerVC] autorelease];
  composerNC.modalPresentationStyle = UIModalPresentationPageSheet;
  
  [self presentModalViewController:composerNC animated:YES];
  
  _returnFromComposer = YES;
}

#pragma mark - action
- (void)doJoin2Quit:(BOOL)joinStatus ifAdmin:(NSString*)ifAdmin
{
  
  if (!joinStatus) {
    _currentType = CLUB_JOIN_TY;
    NSString *param = nil;
    param = [NSString stringWithFormat:@"<host_type>%@</host_type><host_id>%@</host_id><if_admin_submit>%@</if_admin_submit><target_user_id>%@</target_user_id><target_user_type>%@</target_user_type>",
             [AppManager instance].clubType,
             [AppManager instance].clubId,
             ifAdmin,
             [AppManager instance].personId,
             [AppManager instance].userType];
    NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                             contentType:_currentType];
    [connFacade fetchGets:url];
  } else {
    
    ShowAlertWithTwoButton(self,LocaleStringForKey(NSNoteTitle, nil),LocaleStringForKey(NSQuitNoteTitle, nil),LocaleStringForKey(NSCancelTitle, nil),LocaleStringForKey(NSSureTitle, nil));
  }
}

#pragma mark - action
- (void)doManage {
  [AppManager instance].clubAdmin = YES;
  [self goClubUserList];
}

- (void)doDetail {
  
  ClubDetailController *clubDetail = [[[ClubDetailController alloc] initWithMOC:_MOC] autorelease];
  
  clubDetail.title = LocaleStringForKey(NSClubDetailTitle, nil);
  
  [self.navigationController pushViewController:clubDetail animated:YES];
}

- (void)goClubActivity {
  ClubEventListViewController *eventListVC = [[ClubEventListViewController alloc] initWithMOC:_MOC];
  eventListVC.title = LocaleStringForKey(NSClubEventTitle, nil);
  [self.navigationController pushViewController:eventListVC animated:YES];
  [eventListVC release];
}

- (void)goClubUserList {
  GroupMemberListViewController *groupMembersVC = [[[GroupMemberListViewController alloc] initWithMOC:_MOC group:self.group] autorelease];
  groupMembersVC.title = LocaleStringForKey(NSAlumniTitle, nil);
  
  [self.navigationController pushViewController:groupMembersVC animated:YES];
}

- (void)showFilters {
  if (_tagsFetched) {
    [self goFliterView];
  } else {
    [WXWUIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSFetchingTagMsg, nil)
                                  msgType:WARNING_TY
                       belowNavigationBar:YES];
  }
}

#pragma mark - display the tag
- (void)goFliterView {
  _filtersChanged = YES;
  
  ItemPropertiesListViewController *filterListVC = [[[ItemPropertiesListViewController alloc] initWithMOC:_MOC
                                                                                                   holder:_holder
                                                                                         backToHomeAction:_backToHomeAction
                                                                                     parentEditorDelegate:self
                                                                                             propertyType:SHARING_FILTER_TY
                                                                                          filterCountryId:self.filterCountryId.longLongValue
                                                                                                  tagType:SHARE_TY]autorelease];
  
  self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:LocaleStringForKey(NSDoFilterTitle, nil)
                                                                            style:UIBarButtonItemStyleBordered
                                                                           target:nil
                                                                           action:nil] autorelease];
  
  [self.navigationController pushViewController:filterListVC animated:YES];
  
  [self clearLastSelectedIndexPath];
}

#pragma mark - load posts

- (void)allTagSelected {
  self.currentTagIds = NULL_PARAM_VALUE;
  self.currentFiltersTitle = LocaleStringForKey(NSAllTitle, nil);
}

- (void)allScopeSearch {
  self.filterCityId = NULL_PARAM_VALUE;
  self.distanceParams = NULL_PARAM_VALUE;
}

- (void)oneTagSelected:(Tag *)selectedTag {
  self.currentTagIds = [NSString stringWithFormat:@"%@", selectedTag.tagId];
  self.currentFiltersTitle = selectedTag.tagName;
}

- (void)parserSelectedTags {
  
  NSArray *tags = [CoreDataUtils fetchObjectsFromMOC:_MOC
                                          entityName:@"Tag"
                                           predicate:SELECTED_PREDICATE];
  if (tags && [tags count] > 0) {
    NSInteger index = 0;
    self.currentTagIds = nil;
    self.currentFiltersTitle = nil;
    
    if (tags.count == 1) {
      
      // only 'All' tag selected
      Tag *selectedTag = (Tag *)tags.lastObject;
      if (selectedTag.tagId.longLongValue == TAG_ALL_ID) {
        [self allTagSelected];
      } else {
        [self oneTagSelected:selectedTag];
      }
      
    } else {
      for (Tag *tag in tags) {
        if (index == 0) {
          [self oneTagSelected:tag];
        } else {
          self.currentTagIds = [NSString stringWithFormat:@"%@,%@", self.currentTagIds, tag.tagId];
          self.currentFiltersTitle = [NSString stringWithFormat:@"%@, %@", self.currentFiltersTitle, tag.tagName];
        }
        
        index++;
      }
    }
  } else {
    [self allTagSelected];
  }
}

- (void)parserSeletedPlace {
  Place *place = (Place *)[CoreDataUtils fetchObjectFromMOC:_MOC
                                                 entityName:@"Place"
                                                  predicate:SELECTED_PREDICATE];
  if (place) {
    
    if ([ALL_RADIUS_PLACE_ID isEqualToString:place.placeId]) {
      [self allScopeSearch];
    } else {
      
      if (place.distance.floatValue == 0.0f) {
        // place is city
        self.filterCityId = [NSString stringWithFormat:@"%@", place.cityId];
        self.distanceParams = NULL_PARAM_VALUE;
        
      } else {
        // place is radius search area
        self.filterCityId = NULL_PARAM_VALUE;
        self.distanceParams = @"place.distance.floatValue, [AppManager instance].latitude, [AppManager instance].longitude";
      }
      
      self.currentFiltersTitle = [NSString stringWithFormat:@"%@, %@",
                                  self.currentFiltersTitle,
                                  place.placeName];
    }
    
  } else {
    [self allScopeSearch];
  }
}

- (void)applyFilters {
  
  [self parserSelectedTags];
  
  [self parserSeletedPlace];
}

#pragma mark - override methods
- (void)setPredicate {
  
  switch (_listType) {
    case SENT_ITEM_LIST_TY:
      // filter the posts that sent by a specified user
      self.predicate = [NSPredicate predicateWithFormat:@"(authorId == %@)", self.targetUserId];
      break;
      
    case ALL_ITEM_LIST_TY:
      self.predicate = [NSPredicate predicateWithFormat:@"(clubId == %@)", self.group.clubId];
      break;
      
    default:
      break;
  }
  
  self.entityName = @"Post";
  self.descriptors = [NSMutableArray array];
  
  switch (_sortType) {
    case SORT_BY_ID_TY:
    {
      NSSortDescriptor *descriptor = [[[NSSortDescriptor alloc] initWithKey:@"postId" ascending:NO] autorelease];
      [self.descriptors addObject:descriptor];
      break;
    }
      
    case SORT_BY_PRAISE_COUNT_TY:
    {
      NSSortDescriptor *descriptor1 = [[[NSSortDescriptor alloc] initWithKey:@"likeCount" ascending:NO] autorelease];
      [self.descriptors addObject:descriptor1];
      NSSortDescriptor *descriptor2 = [[[NSSortDescriptor alloc] initWithKey:@"postId" ascending:NO] autorelease];
      [self.descriptors addObject:descriptor2];
      break;
    }
      
    case SORT_BY_COMMENT_COUNT_TY:
    {
      NSSortDescriptor *descriptor1 = [[[NSSortDescriptor alloc] initWithKey:@"commentCount" ascending:NO] autorelease];
      [self.descriptors addObject:descriptor1];
      NSSortDescriptor *descriptor2 = [[[NSSortDescriptor alloc] initWithKey:@"postId" ascending:NO] autorelease];
      [self.descriptors addObject:descriptor2];
      break;
    }
      
    default:
      break;
  }
}

#pragma mark - load posts and tags
- (void)loadListData:(LoadTriggerType)triggerType forNew:(BOOL)forNew {

  [super loadListData:triggerType forNew:forNew];
  
  _showNewLoadedItemCount = NO;
  
  _currentType = CLUB_POST_LIST_TY;
  
  NSString *param = [NSString stringWithFormat:@"<page_size>%@</page_size><tag_ids>%@</tag_ids>%@<sort_type>%d</sort_type><post_type>%d</post_type><latitude>%f</latitude><longitude>%f</longitude><host_type>%@</host_type><host_id>%@</host_id><list_type>%@</list_type>",
                     ITEM_LOAD_COUNT,
                     self.currentTagIds,
                     self.distanceParams,
                     _sortType,
                     DISCUSS_POST_TY,
                     [AppManager instance].latitude,
                     [AppManager instance].longitude,
                     self.group.clubType,
                     self.group.clubId,
                     self.postListType];
  
  NSString *requestParam = nil;
  if (forNew) {
    requestParam = param;
  } else {
    NSString *tmpStr = [NSString stringWithFormat:@"<page>%d</page>", self.pageIndex++];
    requestParam = [param stringByReplacingOccurrencesOfString:@"<page>0</page>" withString:tmpStr];
  }
  
  NSString *url = [CommonUtils geneUrl:requestParam itemType:_currentType];
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                           contentType:_currentType];
  [connFacade fetchNews:url];
}

- (void)loadTagData
{
  DELETE_OBJS_FROM_MOC(_MOC, @"Tag", nil);
  _currentType = POST_TAG_LIST_TY;
  
  NSString *param = [NSString stringWithFormat:@"<post_type>%d</post_type><item_id>%@</item_id>", GROUP_TAG_TY, self.group.clubId];
  
  NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                           contentType:_currentType];
  [connFacade fetchGets:url];
}

#pragma mark - load club simple detail
- (void)loadClubSimpleDetail {
  //[CommonUtils doDelete:_MOC entityName:@"ClubSimple"];
  
  _currentType = CLUB_DETAIL_SIMPLE_TY;
  NSString *param = [NSString stringWithFormat:@"<host_id>%@</host_id>", [AppManager instance].clubId];
  
  NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                           contentType:_currentType];
  [connFacade fetchGets:url];
}

#pragma mark - post delete handle
- (void)selectedFeedBeDeleted {
  _selectedFeedBeDeleted = YES;
}

#pragma mark - lifecycle methods

- (void)prepareMetaData {
  NSPredicate *predicate = nil;
  
  if (!_delPostFlag) {
    predicate = [NSPredicate predicateWithFormat:@"(clubId == %@)", self.group.clubId];
  }
  
  DELETE_OBJS_FROM_MOC(_MOC, @"Post", predicate);
  DELETE_OBJS_FROM_MOC(_MOC, @"Tag", nil);
  DELETE_OBJS_FROM_MOC(_MOC, @"ClubSimple", nil);
  [CoreDataUtils resetDistance:_MOC];
}

- (void)initValue
{
  isFirst = YES;
  _sortType = SORT_BY_ID_TY;
  
  self.currentTagIds = NULL_PARAM_VALUE;
  self.filterCountryId = NULL_PARAM_VALUE;
  self.distanceParams = NULL_PARAM_VALUE;
  self.filterCityId = NULL_PARAM_VALUE;
  
  [self prepareMetaData];
  
  _currentContentOffset_y = 0;
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(selectedFeedBeDeleted)
                                               name:FEED_DELETED_NOTIFY
                                             object:nil];
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
            group:(Club *)group
           parent:(id)parent
refreshParentAction:(SEL)refreshParentAction
         listType:(ItemListType)listType
         showType:(ClubViewType)showType
{
  self = [super initWithMOC:MOC
            showCloseButton:NO
      needRefreshHeaderView:YES
      needRefreshFooterView:YES];
  
  if (self) {
    _delPostFlag = NO;
    
    self.group = group;
    _showType = showType;
    _listType = listType;
    _parent = parent;
    _refreshParentAction = refreshParentAction;
    
    _noNeedDisplayEmptyMsg = YES;
    
    [self initValue];
  }
  
  return self;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
            group:(Club *)group
           holder:(id)holder
 backToHomeAction:(SEL)backToHomeAction
           parent:(id)parent
refreshParentAction:(SEL)refreshParentAction
         listType:(ItemListType)listType
         showType:(ClubViewType)showType {
  
  self = [super initWithMOC:MOC
            showCloseButton:NO
      needRefreshHeaderView:YES
      needRefreshFooterView:YES];
  
  if (self) {
    _delPostFlag = YES;
    self.group = group;
    _showType = showType;
    _listType = listType;
    _parent = parent;
    _refreshParentAction = refreshParentAction;
    
    _noNeedDisplayEmptyMsg = YES;
    
    [self initValue];
  }
  
  return self;
}

/*
 - (id)initWithMOC:(NSManagedObjectContext *)MOC
 holder:(id)holder
 backToHomeAction:(SEL)backToHomeAction
 targetUserId:(NSString *)targetUserId {
 self = [self initWithMOC:MOC
 group:nil
 holder:holder
 backToHomeAction:backToHomeAction
 parent:nil
 refreshParentAction:nil
 listType:SENT_ITEM_LIST_TY
 showType:CLUB_ALL_POST_SHOW];
 if (self) {
 isFirst = YES;
 self.targetUserId = targetUserId;
 }
 
 return self;
 }
 */

- (void)arrangeHeaderViewIfNeeded {
  
  _tableView.frame = CGRectMake(0, 0,
                                _tableView.frame.size.width,
                                _tableView.frame.size.height);
  switch (_showType) {
    case CLUB_ALL_ALUMNUS_VIEW:
    {
      if (nil == _allScopeGroupHeaderView) {
        _allScopeGroupHeaderView = [[AllScopeGroupHeaderView alloc] initWithFrame:CGRectMake(0, 0,
                                                                                             LIST_WIDTH,
                                                                                             ALL_SCOPE_HEADER_HEIGHT)
                                                                        groupType:ALL_ALUMNI_GP_TY
                                                                         delegate:self];
      }
      
      _tableView.tableHeaderView = _allScopeGroupHeaderView;
      break;
    }
      
    case CLUB_SELF_VIEW:
    {
      if (nil == _clubHeaderView) {
        _clubHeaderView = [[ClubHeadView alloc] initWithFrame:CGRectMake(0.f, 0.f,
                                                                         LIST_WIDTH,
                                                                         CLUB_HEADER_HEIGHT)
                                                          MOC:_MOC
                                             clubHeadDelegate:self];
      }
      _tableView.tableHeaderView = _clubHeaderView;
      break;
    }
      
    default:
      break;
  }
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self hideTable];
  
  _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
  
  self.view.backgroundColor = CELL_COLOR;
  
  if (_showType == CLUB_POST_VIEW) {
    
    [AppManager instance].clubId = @"";
    
    self.postListType = @"2";
    _tabView = [[UITabView alloc] initWithFrame:CGRectMake(0, 0, LIST_WIDTH, TAB_H) tab0Str:LocaleStringForKey(NSMyClassCircleTitle, nil) tab1Str:LocaleStringForKey(NSEntireTitle, nil) delegate:self];
    [self.view addSubview:_tabView];
    
    _tableView.frame = CGRectMake(0, _tableView.frame.origin.y + TAB_H, _tableView.frame.size.width, _tableView.frame.size.height - TAB_H);
    
  } else if (_showType == CLUB_SELF_VIEW){
    
    self.postListType = @"1";
    _tableView.frame = CGRectMake(0, _tableView.frame.origin.y, _tableView.frame.size.width, _tableView.frame.size.height);
    
    //        self.navigationItem.rightBarButtonItem = BAR_BUTTON(LocaleStringForKey(NSClubDescTitle, nil), UIBarButtonItemStyleDone, self, @selector(goClubDetail:));
  }
  
  [self arrangeHeaderViewIfNeeded];
  
  // fetch tags firstly for prepare meta data for send post and filtering
  [self loadTagData];
}

- (void)clearAllPosts {
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(clubId == %@)", self.group.clubId];
  
  DELETE_OBJS_FROM_MOC(_MOC, @"Post", predicate);
}

- (void)clearTableView {
  self.fetchedRC = nil;
  
  [self clearAllPosts];
  
  [_tableView reloadData];
}

- (void)reloadForFiltersChangeIfNecessary {
  if (_filtersChanged) {
    [self applyFilters];
    
    [self clearTableView];
    
    [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
    
    _filtersChanged = NO;
  }
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  if ((_showType == CLUB_SELF_VIEW || _showType == CLUB_ALL_ALUMNUS_VIEW)
      && [AppManager instance].isNeedReLoadClubDetail) {
    
    [self loadClubSimpleDetail];
    
    [AppManager instance].isNeedReLoadClubDetail = NO;
  }
  
  // if the selected post be deleted, then should not update the cell, because the post has been removed from MOC
  if (!_selectedFeedBeDeleted) {
    [self updateLastSelectedCell];
  } else {
    [self deleteLastSelectedCell];
  }
  
  [self reloadForFiltersChangeIfNecessary];
}

- (void)viewDidAppear:(BOOL)animated {
  
  [super viewDidAppear:animated];
  
  if (!_returnFromComposer) {
    
    // if the selected post be deleted, then no need to load new post
    if (!_selectedFeedBeDeleted) {
      
      if (!_autoLoaded) {
        
        // check whether this is first time user use this list (user this app first time)
        if ([CoreDataUtils objectInMOC:_MOC entityName:@"Post" predicate:nil]) {
          
          _userFirstUseThisList = NO;
          
          // this is not first time user entered this list, so take following actions:
          
          // 1. load local posts firstly
          [self refreshTable];
          
        } else {
          // this is user first time use this app
          _userFirstUseThisList = YES;
        }
        
        // then load new posts secondly
        [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
      }
      
    } else {
      
      _selectedFeedBeDeleted = NO;
    }
    
  } else {
    _returnFromComposer = NO;
  }
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)dealloc {
  [[AppManager instance].imageCache clearAllCachedImages];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:FEED_DELETED_NOTIFY
                                                object:nil];
  
  RELEASE_OBJ(_allScopeGroupHeaderView);
  RELEASE_OBJ(_clubHeaderView);
  
  self.currentTagIds = nil;
  self.currentFiltersTitle = nil;
  self.filterCountryId = nil;
  self.distanceParams = nil;
  self.filterCityId = nil;
  self.targetUserId = nil;
  self.postListType = nil;
  
  DELETE_OBJS_FROM_MOC(_MOC, @"ClubSimple", nil);
  
  DELETE_OBJS_FROM_MOC(_MOC, @"Tag", nil);
  
  [super dealloc];
}

#pragma mark - scrolling overrides

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[super scrollViewDidScroll:scrollView];
  _currentContentOffset_y = scrollView.contentOffset.y;
}

#pragma mark - WXWConnectorDelegate methoes
- (void)connectStarted:(NSString *)url contentType:(WebItemType)contentType {
  
  switch (contentType) {
    case CLUB_POST_LIST_TY:
    {
      [WXWUIUtils showActivityView:[APP_DELEGATE foundationView]
                           text:LocaleStringForKey(NSLoadingTitle, nil)];
    }
    default:
      break;
  }
    
  [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(WebItemType)contentType {
  
  switch (contentType) {
    case POST_TAG_LIST_TY:
    {
      if ([XMLParser parserSyncResponseXml:result type:POST_TAG_LIST_SRC MOC:_MOC]) {
        _tagsFetched = YES;
        
      } else {
        _tagsFetched = NO;
      }
      
      [super connectDone:result url:url contentType:contentType];
      break;
    }
      
    case CLUB_DETAIL_SIMPLE_TY:
    {
      
      if ([XMLParser parserSyncResponseXml:result
                                      type:FETCH_CLUB_DETAIL_SIMPLE_SRC
                                       MOC:_MOC]) {
        
        if (_showType == CLUB_SELF_VIEW) {
          [_clubHeaderView loadData];
          [self showTable];
        }
      } else {
        _tableView.tableHeaderView = nil;
      }
      
      [super connectDone:result
                     url:url
             contentType:contentType];
      
      break;
    }
      
    case CLUB_JOIN_TY:
    case CLUB_QUIT_TY:
    {
      if (result == nil || [result length] == 0) {
        [WXWUIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSActionFaildMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
        return;
      }
      
      ReturnCode ret = [XMLParser handleCommonResult:result showFlag:YES];
      if (ret == RESP_OK) {
        [self loadClubSimpleDetail];
        
        if (_parent && _refreshParentAction) {
          [_parent performSelector:_refreshParentAction];
        }
      }
    }
      break;
      
    case CLUB_POST_LIST_TY:
    {
      if ([XMLParser parserSyncResponseXml:result
                                      type:FETCH_CLUB_POST_SRC
                                       MOC:_MOC]) {
        
        [self refreshTable];
        
        if (!_autoLoadAfterSent) {
          // we hope table view keep the position for auto load, so we adjust content offset of table view auto load;
          // if the table view refresh triggered by load new post after post send, then we hope the latest sent post (just be downloaded) could be displayed for user, then we will not adjust the content offset
          
          CGFloat beforeRefreshTableHeight = _tableView.contentSize.height;
          CGPoint offsetPoint = _tableView.contentOffset;
          
          if (_loadForNewData && beforeRefreshTableHeight > FEED_CELL_HEIGHT) {
            // only keep the table position when user start up app from second time, no need to keep position for user
            // enter news list first time
            // beforeRefreshTableHeight will be larger than 0 if there are news existing in local already
            CGFloat afterRefreshTableHeight = _tableView.contentSize.height;
            _currentContentOffset_y += afterRefreshTableHeight - beforeRefreshTableHeight;
            if (_currentContentOffset_y < 0) {
              _currentContentOffset_y = 0;
            } else {
              _tableView.contentOffset = CGPointMake(offsetPoint.x, _currentContentOffset_y);
            }
          }
        }
        
        if ([AppManager instance].loadedItemCount > 0 && !_autoLoadAfterSent) {
          
          // if table view refresh triggered by new post send, then the load successful message no need to be displayed for user;
          // if table view refresh triggered by auto load, then the new downloaded posts message should be displayed for user
          
          self.connectionResultMessage = [NSString stringWithFormat:LocaleStringForKey(NSNewFeedLoadedMsg, nil), [AppManager instance].loadedItemCount];
          
        } else if (_autoLoadAfterSent) {
          _autoLoadAfterSent = NO;
        }
        
      } else {
        [WXWUIUtils showNotificationOnTopWithMsg:(self.errorMsgDic)[url]
                               alternativeMsg:LocaleStringForKey(NSLoadFeedFailedMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
      }
      
      [self resetUIElementsForConnectDoneOrFailed];
      
      if (_userFirstUseThisList) {
        _userFirstUseThisList = NO;
      }
      
      if ((_showType == CLUB_SELF_VIEW || _showType == CLUB_ALL_ALUMNUS_VIEW)
          && isFirst) {
        [self loadClubSimpleDetail];
        isFirst = NO;
      } else {
        // should be called at end of method to clear connFacade instance
        //[super connectDone:result url:url contentType:contentType];
      }
      
      [WXWUIUtils closeActivityView];
    }
      break;
      
    default:
      break;
  }
}

- (void)connectCancelled:(NSString *)url contentType:(WebItemType)contentType {
  
  // should be called at end of method to clear connFacade instance
  [super connectCancelled:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error url:(NSString *)url contentType:(WebItemType)contentType {
  
  NSString *msg = nil;
  
  switch (contentType) {
      
    case CLUB_POST_LIST_TY:
    {
      if (_autoLoadAfterSent) {
        _autoLoadAfterSent = NO;
      }
      
      msg = LocaleStringForKey(NSLoadFeedFailedMsg, nil);
      
      [WXWUIUtils showNotificationOnTopWithMsg:msg
                                    msgType:ERROR_TY
                         belowNavigationBar:YES];
      
      if (_userFirstUseThisList) {
        _userFirstUseThisList = NO;
      }
      
    }
      break;
      
    default:
      break;
  }
  
  if ([self connectionMessageIsEmpty:error]) {
    self.connectionErrorMsg = msg;
  }
  
  // should be called at end of method to clear connFacade instance
  [super connectFailed:error url:url contentType:contentType];
}

#pragma mark - ItemUploaderDelegate methods
- (void)afterUploadFinishAction:(WebItemType)actionType {
  
  _autoLoadAfterSent = YES;
  [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  
  NSLog(@"count: %d", _fetchedRC.fetchedObjects.count + 1);
  
  return _fetchedRC.fetchedObjects.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (indexPath.row == _fetchedRC.fetchedObjects.count) {
    static NSString *kFooterCellIdentifier = @"footerCell";
    UITableViewCell *footerCell = [_tableView dequeueReusableCellWithIdentifier:kFooterCellIdentifier];
    if (nil == footerCell) {
      footerCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:kFooterCellIdentifier] autorelease];
      
      if (_footerRefreshView) {
        [_footerRefreshView removeFromSuperview];
      }
      [footerCell.contentView addSubview:_footerRefreshView];
      footerCell.accessoryType = UITableViewCellAccessoryNone;
      footerCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return footerCell;
  }
  
  Post *post = [_fetchedRC objectAtIndexPath:indexPath];
  
  static NSString *cellIdentifier = @"PostListCell";
  GroupDiscussionCell *cell = (GroupDiscussionCell *)[_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (nil == cell) {
    
    cell = [[[GroupDiscussionCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:cellIdentifier
                                imageDisplayerDelegate:self
                                imageClickableDelegate:self
                                                   MOC:_MOC] autorelease];
  }
  
  [cell drawPost:post MOC:_MOC];
  
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (indexPath.row == _fetchedRC.fetchedObjects.count) {
    return FEED_CELL_HEIGHT;
  } else {
    
    Post *post = [_fetchedRC objectAtIndexPath:indexPath];
    
    CGFloat height = MARGIN * 8;
    
    CGFloat x = MARGIN * 2 + POSTLIST_PHOTO_WIDTH + MARGIN * 2;
    CGFloat width = self.view.frame.size.width - x - MARGIN * 2;
    CGSize size = [post.content sizeWithFont:FONT(15)
                           constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                               lineBreakMode:UILineBreakModeWordWrap];
    
    if (_showType != CLUB_SELF_VIEW) {
      size = [[NSString stringWithFormat:@"%@: %@", post.authorName, post.content] sizeWithFont:FONT(15)
                                                                              constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                                                                                  lineBreakMode:UILineBreakModeWordWrap];
    }
    
    height += size.height;
    
    if (post.imageAttached.boolValue) {
      height += MARGIN * 2;
      height += POST_IMG_LONG_SIDE;
      height += MARGIN;
    } else {
      height += MARGIN * 2;
    }
    
    height += CELL_BASE_INFO_HEIGHT;
    if (post.tagNames && post.tagNames.length > 0) {
      height += TAG_HEIGHT;
    }
    height += MARGIN * 2;
    
    if (height < FEED_CELL_HEIGHT) {
      return FEED_CELL_HEIGHT;
    } else {
      return height;
    }
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (indexPath.row == _fetchedRC.fetchedObjects.count) {
    return;
  }
  
  [super tableView:tableView didSelectRowAtIndexPath:indexPath];
  
  Post *post = [_fetchedRC objectAtIndexPath:indexPath];
  
  PostDetailViewController *detailVC = [[[PostDetailViewController alloc] initWithMOC:_MOC
                                                                               holder:_holder
                                                                     backToHomeAction:_backToHomeAction
                                                                                 post:post
                                                                             postType:DISCUSS_POST_TY] autorelease];
  
  detailVC.title = LocaleStringForKey(NSPostDetailTitle, nil);
  
  [AppManager instance].isPostDetail = YES;
  
  [self.navigationController pushViewController:detailVC animated:YES];
  [super deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - ECClickableElementDelegate method
- (void)openImageUrl:(NSString *)imageUrl {
  ECHandyImageBrowser *imageBrowser = [[[ECHandyImageBrowser alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
                                                                           imgUrl:imageUrl] autorelease];
  [self.view addSubview:imageBrowser];
  [imageBrowser setNeedsLayout];
}

- (void)openProfile:(NSString*)personId userType:(NSString*)userType
{
  AlumniProfileViewController *profileVC = [[[AlumniProfileViewController alloc] initWithMOC:_MOC
                                                                                    personId:personId
                                                                                    userType:[userType intValue]] autorelease];
  profileVC.title = LocaleStringForKey(NSAlumniDetailTitle, nil);
  [self.navigationController pushViewController:profileVC animated:YES];
}

#pragma mark - TabTapDelegate
- (void)tabTap:(int)selIndex {
  
  switch (selIndex) {
      
    case CLUB_MY_POST_SHOW:
    {
      self.postListType = @"2";
      break;
    }
      
    case CLUB_ALL_POST_SHOW:
    {
      self.postListType = @"3";
      break;
    }
      
    default:
      break;
  }
  
  [self clearTableView];
  [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  
  if (buttonIndex == 1) {
    NSString *param = nil;
    _currentType = CLUB_QUIT_TY;
    param = [NSString stringWithFormat:@"<host_type>%@</host_type><host_id>%@</host_id><target_user_id>%@</target_user_id><target_user_type>%@</target_user_type>",
             [AppManager instance].clubType,
             [AppManager instance].clubId,
             [AppManager instance].personId,
             [AppManager instance].userType];
    
    NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                             contentType:_currentType];
    
    [connFacade fetchGets:url];
    
    return;
  }
}

- (void)goPostClub:(id)sender {
  
  [self goPostView:CLUB_SELF_VIEW];
}

- (void)goPostView:(ClubViewType)showType {
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(clubId == %@)", self.group.clubId];
  
  DELETE_OBJS_FROM_MOC(_MOC, @"Post", predicate);
  
  GroupDiscussionViewController *postListVC = [[GroupDiscussionViewController alloc] initWithMOC:_MOC
                                                                                           group:nil
                                                                                          holder:self
                                                                                backToHomeAction:@selector(backToHomepage:)
                                                                                          parent:nil
                                                                             refreshParentAction:nil
                                                                                        listType:ALL_ITEM_LIST_TY
                                                                                        showType:showType];
  if (showType == CLUB_ALL_POST_SHOW) {
    postListVC.title = LocaleStringForKey(NSClubPostTitle, nil);
  } else {
    postListVC.title = @"协会动态";
  }
  
  [self.navigationController pushViewController:postListVC animated:YES];
  RELEASE_OBJ(postListVC);
}

@end
