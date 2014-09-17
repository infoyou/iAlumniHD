//
//  EventAlumniListViewController.m
//  iAlumniHD
//
//  Created by MobGuang on 12-8-29.
//
//

#import "EventAlumniListViewController.h"
#import "NearbyPeopleCell.h"
#import "AlumniProfileViewController.h"
#import "Alumni.h"
#import "EventCheckinAlumni.h"
#import "CoreDataUtils.h"
#import "ChatListViewController.h"
#import "AlumniFounder.h"
#import "QuickBackForCheckinView.h"
#import "Post.h"
#import "PostListCell.h"
#import "PostDetailViewController.h"
#import "ECHandyImageBrowser.h"
#import "ComposerViewController.h"
#import "WXWNavigationController.h"
#import "Event.h"
#import "GlobalConstants.h"

#define BUTTON_WIDTH          150.0f
#define BUTTON_HEIGHT         30.0f

@interface EventAlumniListViewController ()
@property (nonatomic, retain) Event *event;
@property (nonatomic, retain) Alumni *alumni;
@property (nonatomic, retain) UIViewController *checkinEntrance;
@property (nonatomic, retain) id<EventCheckinDelegate> checkinResultDelegate;
@end

@implementation EventAlumniListViewController

@synthesize alumni = _alumni;
@synthesize event = _eventDetail;
@synthesize checkinEntrance = _checkinEntrance;
@synthesize checkinResultDelegate = _checkinResultDelegate;

#pragma mark - arrange quick tips
- (BOOL)shouldShowQuickTips {
    
    return NO;
    
    /****** the logic need be clarified further ******
     switch (_checkinResultType) {
     // if check in done, venue is far way or event is overdue, then no need to display the
     // quick tips
     case CHECKIN_NONE_TY:
     case CHECKIN_OK_TY:
     case CHECKIN_FAILED_TY: // this type should not be here actually
     case CHECKIN_FARAWAY_TY:
     case CHECKIN_EVENT_OVERDUE_TY:
     case CHECKIN_EVENT_NOT_BEGIN_TY:
     case CHECKIN_DUPLICATE_ERR_TY:
     return NO;
     
     default:
     return YES;
     }
     */
}

- (void)addQuickBackViewIfNeeded {
    
    if (![self shouldShowQuickTips]) {
        return;
    }
    
    NSString *title = nil;
    switch (_checkinResultType) {
        case CHECKIN_NEED_CONFIRM_TY:
            title = LocaleStringForKey(NSCheckAdminWhetherApprovedMsg, nil);
            break;
            
        case CHECKIN_NO_REG_FEE_TY:
            //case CHECKIN_NOT_SIGNUP_TY:
            title = LocaleStringForKey(NSContinueCheckinTitle, nil);
            break;
            
        default:
            break;
    }
    
    CGSize size = [title sizeWithFont:BOLD_FONT(13)
                    constrainedToSize:CGSizeMake(self.view.frame.size.width, CGFLOAT_MAX)
                        lineBreakMode:UILineBreakModeWordWrap];
    
    CGFloat width = size.width + MARGIN * 4;
    _quickBackView = [[[QuickBackForCheckinView alloc] initWithFrame:CGRectMake(self.view.frame.size.width,
                                                                                380.0f,
                                                                                width,
                                                                                size.height + MARGIN * 2)
                                                     checkinDelegate:self
                                                       directionType:LEFT_DIR_TY
                                                            topColor:COLOR_HSB(360.0f, 100.0f, 78.0f, 1.0f)
                                                         bottomColor:COLOR_HSB(359.0f, 77.0f, 47.0f, 1.0f)] autorelease];
    [_quickBackView setTitle:title];
    
    _quickBackView.alpha = 0.0f;
    
    [self.view addSubview:_quickBackView];
    
}

- (void)showQuichBackViewWithAnimationIfNeeded {
    
    if (![self shouldShowQuickTips]) {
        return;
    }
    
    // if tips view be displayed already, then not need to show it with animation again
    if (_quickBackViewShowed) {
        return;
    }
    
    [UIView animateWithDuration:0.5f
                     animations:^{
                         
                         _quickBackView.alpha = 1.0f;
                         
                         _quickBackView.frame = CGRectMake(self.view.frame.size.width - _quickBackView.frame.size.width,
                                                           _quickBackView.frame.origin.y,
                                                           _quickBackView.frame.size.width,
                                                           _quickBackView.frame.size.height);
                     }];
    
    _quickBackViewShowed = YES;
}

#pragma mark - lifecycle methods

- (id)initWithMOC:(NSManagedObjectContext *)MOC
checkinResultDelegate:(id<EventCheckinDelegate>)checkinResultDelegate
      event:(Event *)event
checkinResultType:(CheckinResultType)checkinResultType
         entrance:(UIViewController *)entrance
         listType:(EventLiveActionType)listType {
    
    self = [super initWithMOC:MOC showCloseButton:NO needRefreshHeaderView:YES needRefreshFooterView:YES];
    
    if (self) {
        
        self.event = event;
        
        _eventId = event.eventId.longLongValue;
        
        /*
         if (self.event.checkinResultType.intValue == CHECKIN_NEED_CONFIRM_TY) {
         _waitingForAdminApprove = YES;
         }
         */
        
        self.checkinResultDelegate = checkinResultDelegate;
        
        _checkinResultType = checkinResultType;
        
        self.checkinEntrance = entrance;
        
        _listType = listType;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(selectedFeedBeDeleted)
                                                     name:FEED_DELETED_NOTIFY
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    
    self.alumni = nil;
    
    self.event = nil;
    
    self.checkinEntrance = nil;
    
    self.checkinResultDelegate = nil;
    
    [[AppManager instance].imageCache clearAllCachedImages];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:FEED_DELETED_NOTIFY
                                                  object:nil];
    
    [super dealloc];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initTableContainer {
    
    _tableContainer = [[UIView alloc] initWithFrame:CGRectMake(0,0,
                                                               self.view.frame.size.width,
                                                               self.view.frame.size.height)];
    _tableContainer.backgroundColor = TRANSPARENT_COLOR;
    [self.view addSubview:_tableContainer];
    
    // remove table view from self.vew
    [_tableView removeFromSuperview];
    
    // move table view to new container
    _tableView.frame = CGRectMake(0, 0, _tableContainer.frame.size.width, _tableContainer.frame.size.height);
    [_tableContainer addSubview:_tableView];
}

- (void)arrangeRightBarButtonForDiscussionList {
    
    UIToolbar *toolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 100, TOOLBAR_HEIGHT)] autorelease];
    toolbar.barStyle = -1;
    toolbar.tintColor = NAVIGATION_BAR_COLOR;
    
    UIBarButtonItem *sendBarButton = BAR_BUTTON(LocaleStringForKey(NSPostTitle, nil), UIBarButtonItemStyleBordered, self, @selector(doPost:));
    
    UIBarButtonItem *space = BAR_SYS_BUTTON(UIBarButtonSystemItemFlexibleSpace, nil, nil);
    
    NSString *title = nil;
    switch (_listType) {
        case EVENT_APPEAR_ALUMNUS_TY:
            title = LocaleStringForKey(NSDiscussTitle, nil);
            break;
            
        case EVENT_DISCUSS_TY:
            title = LocaleStringForKey(NSAppearAlumniTitle, nil);
            break;
            
        default:
            break;
    }
    
    UIBarButtonItem *switchBarButton = BAR_BUTTON(title, UIBarButtonItemStyleBordered, self, @selector(switchList:));
    
    [toolbar setItems:[NSArray arrayWithObjects:sendBarButton, space, switchBarButton, nil]];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:toolbar] autorelease];
}

- (void)arrangeRightBarButtonForAlumniList {
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:LocaleStringForKey(NSDiscussTitle,nil)
                                                                               style:UIBarButtonItemStyleBordered
                                                                              target:self
                                                                              action:@selector(switchList:)] autorelease];
}

- (void)initNavigationItemButtons {
    
    switch (_listType) {
        case EVENT_APPEAR_ALUMNUS_TY:
            [self arrangeRightBarButtonForAlumniList];
            break;
            
        case EVENT_DISCUSS_TY:
            [self arrangeRightBarButtonForDiscussionList];
            break;
            
        default:
            break;
    }
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    if (_listType == EVENT_DISCUSS_TY) {
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    
    [self initNavigationItemButtons];
    
    [self initTableContainer];
    
    [self addQuickBackViewIfNeeded];
}

- (void)handleViewDidAppearForAlumniList {
    if (!_autoLoaded) {
      //[self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
      [self loadAlumus:TRIGGERED_BY_AUTOLOAD
                forNew:YES];
    }
    
}

- (void)handleViewDidAppearForDiscussion {
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
                //[self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
              [self loadDiscussionPosts:TRIGGERED_BY_AUTOLOAD forNew:YES];
            }
            
        } else {
            _selectedFeedBeDeleted = NO;
        }
        
    } else {
        _returnFromComposer = NO;
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    switch (_listType) {
        case EVENT_APPEAR_ALUMNUS_TY:
            break;
            
        case EVENT_DISCUSS_TY:
        {
            // if the selected post be deleted, then should not update the cell, because the post has been removed from MOC
            if (!_selectedFeedBeDeleted) {
                [self updateLastSelectedCell];
            } else {
                [self deleteLastSelectedCell];
            }
            break;
        }
            
        default:
            break;
    }
    
    switch (_listType) {
        case EVENT_APPEAR_ALUMNUS_TY:
            [self handleViewDidAppearForAlumniList];
            break;
            
        case EVENT_DISCUSS_TY:
            [self handleViewDidAppearForDiscussion];
            break;
            
        default:
            break;
    }
}

#pragma mark - composer post
- (void)doPost:(id)sender {
    
    ComposerViewController *composerVC = [[[ComposerViewController alloc] initForEventDiscussWithMOC:_MOC
                                                                                            delegate:self
                                                                                             eventId:[NSString stringWithFormat:@"%lld", _eventId]] autorelease];
    composerVC.title = LocaleStringForKey(NSNewFeedTitle, nil);
    
    WXWNavigationController *composerNC = [[[WXWNavigationController alloc] initWithRootViewController:composerVC] autorelease];
    composerNC.modalPresentationStyle = UIModalPresentationPageSheet;
    
    [self presentModalViewController:composerNC animated:YES];
    
    _returnFromComposer = YES;
}

#pragma mark - post delete handle
- (void)selectedFeedBeDeleted {
    _selectedFeedBeDeleted = YES;
}

#pragma mark - switch alumni list and discussion list

- (void)clearTable {
    self.fetchedRC = nil;
    [_tableView reloadData];
}

- (void)switchList:(id)sender {
    
    [UIView beginAnimations:nil
                    context:nil];
    [UIView setAnimationDuration:1.0f];
    UIViewAnimationTransition transition;
    
    [self clearTable];
    
    switch (_listType) {
        case EVENT_DISCUSS_TY:
        {
            transition = UIViewAnimationTransitionFlipFromLeft;
            
            _listType = EVENT_APPEAR_ALUMNUS_TY;
          [self loadAlumus:TRIGGERED_BY_AUTOLOAD forNew:YES];
          //[self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
            
            self.title = LocaleStringForKey(NSCheckedinAlumnusListTitle, nil);
            
            
            break;
        }
            
        case EVENT_APPEAR_ALUMNUS_TY:
        {
            transition = UIViewAnimationTransitionFlipFromRight;
            
            _listType = EVENT_DISCUSS_TY;
          [self loadDiscussionPosts:TRIGGERED_BY_AUTOLOAD forNew:YES];
          //[self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
            
            self.title = LocaleStringForKey(NSEventDiscussionTitle, nil);
            
            
            break;
        }
            
        default:
            break;
    }
    
    [UIView setAnimationTransition:transition
                           forView:_tableContainer
                             cache:YES];
    [UIView commitAnimations];
    
    switch (_listType) {
        case EVENT_DISCUSS_TY:
            [self arrangeRightBarButtonForDiscussionList];
            break;
            
        case EVENT_APPEAR_ALUMNUS_TY:
            [self arrangeRightBarButtonForAlumniList];
            break;
            
        default:
            break;
    }
    
}

#pragma mark - load data
- (void)setPredicate {
    
    self.descriptors = [NSMutableArray array];
    
    self.predicate = nil;
    
    switch (_listType) {
        case EVENT_APPEAR_ALUMNUS_TY:
        {
            self.entityName = @"EventCheckinAlumni";
            self.predicate = [NSPredicate predicateWithFormat:@"(eventId == %lld)", _eventId];
            NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"orderId" ascending:YES] autorelease];
            [self.descriptors addObject:sortDescriptor];
            break;
        }
            
        case EVENT_DISCUSS_TY:
        {
            self.entityName = @"Post";
            NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"postId" ascending:NO] autorelease];
            [self.descriptors addObject:sortDescriptor];
            break;
        }
            
        default:
            break;
    }
}

/*
- (void)loadListData:(LoadTriggerType)triggerType forNew:(BOOL)forNew {
    
    [super loadListData:triggerType forNew:forNew];
    switch (_listType) {
        case EVENT_APPEAR_ALUMNUS_TY:
            [self loadAlumus:TRIGGERED_BY_SCROLL forNew:YES];
            break;
            
        case EVENT_DISCUSS_TY:
            [self loadDiscussionPosts:TRIGGERED_BY_SCROLL forNew:YES];
            break;
            
        default:
            break;
    }
}
*/

- (void)loadAlumus:(LoadTriggerType)triggerType
            forNew:(BOOL)forNew {
    
    _currentType = CHECKIN_USER_TY;
    
    NSInteger startIndex = 0;
    if (!forNew) {
        startIndex = ++_currentStartIndex;
    }
    
    NSString *param = [NSString stringWithFormat:@"<event_id>%lld</event_id><page>%d</page><page_size>%@</page_size><is_get_checkin>1</is_get_checkin>", _eventId, startIndex, ITEM_LOAD_COUNT];
    
    NSString *url = [CommonUtils geneUrl:param itemType:CHECKIN_USER_TY];
    
    WXWAsyncConnectorFacade *connFacade = [[[WXWAsyncConnectorFacade alloc] initWithDelegate:self interactionContentType:CHECKIN_USER_TY] autorelease];
    [self.connDic setObject:connFacade forKey:url];
    
    [connFacade asyncGet:url showAlertMsg:YES];
}

- (void)loadDiscussionPosts:(LoadTriggerType)triggerType forNew:(BOOL)forNew {
    _currentType = EVENT_POST_TY;
    
    NSInteger startIndex = 0;
    if (!forNew) {
        startIndex = ++_currentStartIndex;
    }
    
    NSString *param = [NSString stringWithFormat:@"<event_id>%lld</event_id><sort_type>%d</sort_type><post_type>%d</post_type><page>%d</page><page_size>%@</page_size><is_get_checkin>1</is_get_checkin>",
                       _eventId,
                       SORT_BY_ID_TY,
                       EVENT_DISCUSS_POST_TY,
                       startIndex,
                       ITEM_LOAD_COUNT];
    
    NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
    WXWAsyncConnectorFacade *connFacade = [[[WXWAsyncConnectorFacade alloc] initWithDelegate:self
                                                                    interactionContentType:_currentType] autorelease];
    [self.connDic setObject:connFacade forKey:url];
    [connFacade fetchNews:url];
    
}

#pragma mark - ItemUploaderDelegate methods
- (void)afterUploadFinishAction:(WebItemType)actionType {

  [self loadDiscussionPosts:TRIGGERED_BY_AUTOLOAD forNew:YES];
  //[self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
}

#pragma mark - WXWConnectorDelegate methods
- (void)connectStarted:(NSString *)url contentType:(WebItemType)contentType {
    
    [WXWUIUtils showActivityView:[APP_DELEGATE foundationView]
                         text:LocaleStringForKey(NSLoadingTitle, nil)];
    
    [super connectStarted:url contentType:contentType];
}

- (void)connectCancelled:(NSString *)url contentType:(WebItemType)contentType {
    [super connectCancelled:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(WebItemType)contentType {
    
    switch (contentType) {
        case CHECKIN_USER_TY:
            if ([XMLParser parserEventStuff:result
                                   itemType:CHECKIN_USER_TY
                                event:self.event
                                        MOC:_MOC
                          connectorDelegate:self
                                        url:url]) {
                [self refreshTable];
                
                _autoLoaded = YES;
                
            } else {
                [WXWUIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSFetchAlumniFailedMsg, nil)
                                              msgType:ERROR_TY
                                   belowNavigationBar:YES];
            }
            break;
            
        case EVENT_POST_TY:
        {
            
            SAVE_MOC(_MOC);
            if ([XMLParser parserEventStuff:result
                                   itemType:EVENT_POST_TY
                                event:self.event
                                        MOC:_MOC
                          connectorDelegate:self
                                        url:url]) {
                
                [self refreshTable];
                
                _autoLoaded = YES;
                
            } else {
                [WXWUIUtils showNotificationOnTopWithMsg:[self.errorMsgDic objectForKey:url]
                                       alternativeMsg:LocaleStringForKey(NSLoadFeedFailedMsg, nil)
                                              msgType:ERROR_TY
                                   belowNavigationBar:YES];
            }
            
            break;
        }
            
        default:
            break;
    }
    
    // show the quick back tips view when list data be loaded first time
    [self showQuichBackViewWithAnimationIfNeeded];
    
    //[self adjustQuickTipsIfNeeded];
    
    [self resetUIElementsForConnectDoneOrFailed];
    
    [super connectDone:result url:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(WebItemType)contentType {
    
  NSString *msg = nil;
  
  switch (contentType) {
    case CHECKIN_USER_TY:
      msg = LocaleStringForKey(NSFetchAlumniFailedMsg, nil);
      break;
      
    case EVENT_POST_TY:
      msg = LocaleStringForKey(NSLoadFeedFailedMsg, nil);
      break;
      
    default:
      break;
  }
  
  if ([self connectionMessageIsEmpty:error]) {
    self.connectionErrorMsg = msg;
  }
  
    [super connectFailed:error url:url contentType:contentType];
}

#pragma mark - scrolling overrides
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
  
  if ([WXWUIUtils shouldLoadNewItems:scrollView
                       headerView:_headerRefreshView
                        reloading:_reloading]) {
    
    _shouldTriggerLoadLatestItems = YES;
    
    switch (_listType) {
      case EVENT_APPEAR_ALUMNUS_TY:
        [self loadAlumus:TRIGGERED_BY_SCROLL forNew:YES];
        break;
        
      case EVENT_DISCUSS_TY:
        [self loadDiscussionPosts:TRIGGERED_BY_SCROLL forNew:YES];
        break;
        
      default:
        break;
    }
  }
  
  if ([WXWUIUtils shouldLoadOlderItems:scrollView
                    tableViewHeight:_tableView.contentSize.height
                         footerView:_footerRefreshView
                          reloading:_reloading]) {
    
    _reloading = YES;
    
    switch (_listType) {
      case EVENT_APPEAR_ALUMNUS_TY:
        [self loadAlumus:TRIGGERED_BY_SCROLL forNew:NO];
        break;
        
      case EVENT_DISCUSS_TY:
        [self loadDiscussionPosts:TRIGGERED_BY_SCROLL forNew:NO];
        break;
        
      default:
        break;
    }
  }
}

#pragma mark - UITableViewDelegate and UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.fetchedRC.fetchedObjects.count + 1;
}

- (UITableViewCell *)drawAlumniCell:(NSIndexPath *)indexPath {
    
    static NSString *kCellIdentifier = @"kUserCell";
    NearbyPeopleCell *cell = (NearbyPeopleCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (nil == cell) {
        cell = [[[NearbyPeopleCell alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier:kCellIdentifier
                                 imageDisplayerDelegate:self
                                 imageClickableDelegate:self
                                                    MOC:_MOC] autorelease];
    }
    
    EventCheckinAlumni *alumni = (EventCheckinAlumni *)[_fetchedRC objectAtIndexPath:indexPath];
    
    [cell drawCell:alumni];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

- (UITableViewCell *)drawDiscussPost:(NSIndexPath *)indexPath {
    Post *post = [_fetchedRC objectAtIndexPath:indexPath];
    
    static NSString *cellIdentifier = @"PostListCell";
    
    PostListCell *cell = (PostListCell *)[_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == cell) {
        
        cell = [[[PostListCell alloc] initWithStyle:UITableViewCellStyleDefault
                                    reuseIdentifier:cellIdentifier
                             imageDisplayerDelegate:self
                             imageClickableDelegate:self
                                           showType:CLUB_SELF_VIEW
                                                MOC:_MOC] autorelease];
    }
    
    [cell drawPost:post];
    
    return cell;
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
    
    switch (_listType) {
        case EVENT_APPEAR_ALUMNUS_TY:
            return [self drawAlumniCell:indexPath];
            
        case EVENT_DISCUSS_TY:
            return [self drawDiscussPost:indexPath];
            
        default:
            return nil;
    }
}

- (CGFloat)discussPostCellHeight:(NSIndexPath *)indexPath {
    if (indexPath.row == _fetchedRC.fetchedObjects.count) {
        return FEED_CELL_HEIGHT;
    } else {
        
        Post *post = [_fetchedRC objectAtIndexPath:indexPath];
        
        CGFloat height = MARGIN * 8;
        
        CGFloat x = MARGIN * 2 + POSTLIST_PHOTO_WIDTH + MARGIN * 2;
        CGFloat width = self.view.frame.size.width - x - MARGIN * 2;
        CGSize size = [[NSString stringWithFormat:@"%@: %@", post.authorName, post.content] sizeWithFont:FONT(15)
                                                                                       constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                                                                                           lineBreakMode:UILineBreakModeWordWrap];
        
        
        height += size.height;
        
        if (post.imageAttached.boolValue) {
            height += MARGIN * 2;
            height += POST_IMG_LONG_SIDE;
            height += MARGIN;
        } else {
            height += MARGIN * 2;
        }
        
        height += CELL_BASE_INFO_HEIGHT;
        height += MARGIN * 2;
        
        if (height < FEED_CELL_HEIGHT) {
            return FEED_CELL_HEIGHT;
        } else {
            return height;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (_listType) {
        case EVENT_APPEAR_ALUMNUS_TY:
            return PEOPLE_CELL_HEIGHT;
            
        case EVENT_DISCUSS_TY:
            return [self discussPostCellHeight:indexPath];
            
        default:
            return 0;
    }
}

- (void)showProfile:(NSString *)personId userType:(NSString *)userType {
    
    AlumniProfileViewController *profileVC = [[[AlumniProfileViewController alloc] initWithMOC:_MOC
                                                                                      personId:personId
                                                                                      userType:[userType intValue]] autorelease];
    profileVC.title = LocaleStringForKey(NSAlumniDetailTitle, nil);
    [self.navigationController pushViewController:profileVC animated:YES];
}

- (void)beginChat {
    
    [CommonUtils doDelete:_MOC entityName:@"Chat"];
    ChatListViewController *chatVC = [[[ChatListViewController alloc] initWithMOC:_MOC
                                                                           alumni:(AlumniDetail*)self.alumni] autorelease];
    
    [self.navigationController pushViewController:chatVC animated:YES];
    
}

- (void)selectAlumniCell:(NSIndexPath *)indexPath {
    EventCheckinAlumni *alumni = (EventCheckinAlumni *)[self.fetchedRC objectAtIndexPath:indexPath];
    
    [self showProfile:alumni.personId userType:alumni.userType];
}

- (void)selectDiscussPostCell:(NSIndexPath *)indexPath {
    
    Post *post = [_fetchedRC objectAtIndexPath:indexPath];
    
    PostDetailViewController *detailVC = [[[PostDetailViewController alloc] initWithMOC:_MOC
                                                                                 holder:_holder
                                                                       backToHomeAction:_backToHomeAction
                                                                                   post:post
                                                                               postType:EVENT_DISCUSS_POST_TY] autorelease];
    
    detailVC.title = LocaleStringForKey(NSPostDetailTitle, nil);
    
    [AppManager instance].isPostDetail = YES;
    
    [self.navigationController pushViewController:detailVC animated:YES];
    [super deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == _fetchedRC.fetchedObjects.count) {
        return;
    }
    
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    switch (_listType) {
        case EVENT_APPEAR_ALUMNUS_TY:
            [self selectAlumniCell:indexPath];
            break;
            
        case EVENT_DISCUSS_TY:
            [self selectDiscussPostCell:indexPath];
            break;
            
        default:
            break;
    }
    
    [super deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - ECClickableElementDelegate method
- (void)doChat:(Alumni*)aAlumni sender:(id)sender{
    
    self.alumni = aAlumni;
    
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

#pragma mark - ECClickableElementDelegate method
- (void)openImageUrl:(NSString *)imageUrl {
    ECHandyImageBrowser *imageBrowser = [[[ECHandyImageBrowser alloc] initWithFrame:CGRectMake(0, 0,
                                                                                               self.view.frame.size.width,
                                                                                               self.view.frame.size.height)
                                                                             imgUrl:imageUrl] autorelease];
    [self.view addSubview:imageBrowser];
    [imageBrowser setNeedsLayout];
}

- (void)openProfile:(NSString*)personId userType:(NSString*)userType {
    
    [self showProfile:personId userType:userType];
}

#pragma mark - Action Sheet
- (void)actionSheet:(UIActionSheet*)aSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	switch (buttonIndex) {
		case CHAT_SHEET_IDX:
		{
            [self beginChat];
            return;
		}
            
		case DETAIL_SHEET_IDX:
            [self showProfile:self.alumni.personId userType:self.alumni.userType];
			return;
			
        case CANCEL_SHEET_IDX:
            return;
            
		default:
			break;
	}
}

#pragma mark - EventCheckinDelegate methods
- (void)quickCheck {
    switch (_checkinResultType) {
        case CHECKIN_NEED_CONFIRM_TY:
        case CHECKIN_OK_TY:
            [self.navigationController popViewControllerAnimated:YES];
            break;
            
        case CHECKIN_NO_REG_FEE_TY:
            //case CHECKIN_NOT_SIGNUP_TY:
            [self.navigationController popToViewController:self.checkinEntrance
                                                  animated:YES];
            break;
            
        default:
            break;
    }
}

@end
