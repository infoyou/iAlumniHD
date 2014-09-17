//
//  ClubEntranceViewController.m
//  iAlumniHD
//
//  Created by Adam on 13-3-7.
//
//

#import "ClubEntranceViewController.h"
#import "BizGroupIndicatorBar.h"
#import "AppManager.h"
#import "CommonUtils.h"
#import "XMLParser.h"
#import "WXWUIUtils.h"
#import "PublicDiscussionGroupsViewController.h"
#import "Club.h"
#import "ShareViewController.h"
#import "BizPostListViewController.h"
#import "JoinedGroup.h"
#import "GroupDiscussionViewController.h"
#import "GroupListViewController.h"
#import "UIPageControl+CustomizeDot.h"
#import "PlainTabView.h"
#import "ClubGroupCell.h"
#import "PublicDiscussionGroupCell.h"
#import "WXWLabel.h"

#define SELECTION_BAR_HEIGHT   30.0f
#define PROMPT_OFFSET          120.0f

#define PAGE_COUNT             2

#define ITEM_HEIGHT     144.f
#define GRID_CELL_HEIGHT  ITEM_HEIGHT + MARGIN * 2
#define ROW_ITEM_COUNT    2

#define SECTION_VIEW_HEIGHT 20.0f

#define DISCUSS_GP_CELL_HEIGHT 95.0f

enum {
    CLUB_GP_TY,
    PUBLIC_DISCUSS_GP_TY,
}GroupCategoryType;

enum {
    DISCUSS_GROUP_SECTION_COUNT = 1,
    CLUB_GROUP_SECTION_COUNT = 2,
};

enum {
    JOINED_SEC,
    POPULAR_SEC,
};

@interface ClubEntranceViewController ()
@property (nonatomic, retain) NSFetchedResultsController *joinedGroupFetchedRC;
@property (nonatomic, retain) NSFetchedResultsController *popularGroupFetchedRC;
@end

@implementation ClubEntranceViewController

#pragma mark - user actions
- (void)enterGroup:(ClubViewType)showType group:(Club *)group {
    
    [AppManager instance].clubName = [NSString stringWithFormat:@"%@", group.clubName];
    [AppManager instance].clubId = [NSString stringWithFormat:@"%@", group.clubId];
    [AppManager instance].clubType = [NSString stringWithFormat:@"%@", group.clubType];
    [AppManager instance].hostSupTypeValue = group.hostSupTypeValue;
    [AppManager instance].hostTypeValue = group.hostTypeValue;
    [AppManager instance].isNeedReLoadClubDetail = YES;
    
    [AppManager instance].allowSendSMS = NO;
    
    GroupDiscussionViewController *postListVC = [[[GroupDiscussionViewController alloc] initWithMOC:_MOC
                                                                                              group:group
                                                                                             holder:nil
                                                                                   backToHomeAction:nil
                                                                                             parent:self
                                                                                refreshParentAction:@selector(setTriggerReloadListFlag)
                                                                                           listType:ALL_ITEM_LIST_TY
                                                                                           showType:showType] autorelease];
    if (showType == CLUB_POST_VIEW) {
        postListVC.title = group.clubName;
    } else {
        postListVC.title = LocaleStringForKey(NSGroupTrendsTitle, nil);
    }
    
    postListVC.deSelectCellDelegate = self;
    [self setRefreshVC:self];
    
    WXWNavigationController *detailNC = [[[WXWNavigationController alloc] initWithRootViewController:postListVC] autorelease];
    
    [APP_DELEGATE addViewInSlider:detailNC
               invokeByController:self
                   stackStartView:NO];
}


- (void)enterAllScopeGroup:(NSString *)title {
    ShareViewController *shareListVC = [[[ShareViewController alloc] initWithMOC:_MOC
                                                                          holder:nil
                                                                backToHomeAction:nil
                                                                        listType:ALL_ITEM_LIST_TY] autorelease];
    shareListVC.title = title;
    
    shareListVC.deSelectCellDelegate = self;
    [self setRefreshVC:self];

    WXWNavigationController *detailNC = [[[WXWNavigationController alloc] initWithRootViewController:shareListVC] autorelease];
    
    [APP_DELEGATE addViewInSlider:detailNC
               invokeByController:self
                   stackStartView:NO];
}

- (void)openBizDiscussionGroup:(Club *)group {
    if (group.clubId.intValue == ALL_SCOPE_GP_ID) {
        [self enterAllScopeGroup:group.clubName];
    } else {
        BizPostListViewController *bizPostListVC = [[[BizPostListViewController alloc] initWithMOC:_MOC
                                                                                             group:group] autorelease];
        bizPostListVC.title = group.clubName;
        
        bizPostListVC.deSelectCellDelegate = self;
        
        WXWNavigationController *detailNC = [[[WXWNavigationController alloc] initWithRootViewController:bizPostListVC] autorelease];
        
        [APP_DELEGATE addViewInSlider:detailNC
                   invokeByController:self
                       stackStartView:NO];
    }
}

- (void)openAllGroups {
    
//    [super close:nil];
    
    GroupListViewController *allGroupsVC = [[[GroupListViewController alloc] initForAllGroupsWithMOC:_MOC] autorelease];
    
    allGroupsVC.title = LocaleStringForKey(NSGroupsTitle, nil);
    allGroupsVC.deSelectCellDelegate = self;
    [self setRefreshVC:self];
    
    [self.navigationController pushViewController:allGroupsVC animated:YES];
}

- (void)openClubGroup:(Club *)group {

    if (nil == group) {
        // open all groups
        [self openAllGroups];
    } else {
        // open specified group
        if (group.clubId.intValue == ALL_SCOPE_GP_ID) {
            [self enterAllScopeGroup:group.clubName];
        } else {
            [self enterGroup:CLUB_SELF_VIEW group:group];
        }
    }
    
    [_tableView reloadData];
}

- (void)openLeftClubGroup:(Club *)leftGroup  {
    
    _selectedGroupId = leftGroup.clubId.longLongValue;
    
    [self openClubGroup:leftGroup];
}

- (void)openRightClubGroup:(Club *)rightGroup {
    
    _selectedGroupId = rightGroup.clubId.longLongValue;
    
    [self openClubGroup:rightGroup];
}

#pragma mark - load and display data

- (void)loadAndDisplayPublicGroups {
    self.entityName = @"Club";
    
    self.descriptors = [NSMutableArray array];
    NSSortDescriptor *dateDesc = [[[NSSortDescriptor alloc] initWithKey:@"showOrder"
                                                              ascending:YES] autorelease];
    [self.descriptors addObject:dateDesc];
    
    self.predicate = [NSPredicate predicateWithFormat:@"(usageType == %d)", BIZ_DISCUSS_USAGE_GP_TY];
    
    self.fetchedRC = [self performFetchByFetchedRC:self.fetchedRC];
    
    [_tableView reloadData];
}

- (void)loadAndDisplayClubGroups {
    self.descriptors = [NSMutableArray array];
    NSSortDescriptor *dateDesc = [[[NSSortDescriptor alloc] initWithKey:@"showOrder"
                                                              ascending:YES] autorelease];
    [self.descriptors addObject:dateDesc];
    
    self.entityName = @"JoinedGroup";
    self.predicate = [NSPredicate predicateWithFormat:@"(alumniId == %@) AND (usageType == %d)", [AppManager instance].personId, BIZ_JOINED_USAGE_GP_TY];
    self.joinedGroupFetchedRC = [self performFetchByFetchedRC:self.joinedGroupFetchedRC];
    
    self.entityName = @"Club";
    self.predicate = [NSPredicate predicateWithFormat:@"(usageType == %d)", BIZ_POPULAR_USAGE_GP_TY];
    self.popularGroupFetchedRC = [self performFetchByFetchedRC:self.popularGroupFetchedRC];
    
    [_tableView reloadData];
}

- (void)loadAndDisplayGroups {
    switch (_groupCategory) {
        case CLUB_GP_TY:
            [self loadAndDisplayClubGroups];
            break;
            
        case PUBLIC_DISCUSS_GP_TY:
            [self loadAndDisplayPublicGroups];
            break;
            
        default:
            break;
    }
}

#pragma mark - load data
- (void)loadGroups {
    
    _currentType = LOAD_BIZ_GROUPS_TY;
    
    NSString *url = [CommonUtils geneUrl:NULL_PARAM_VALUE itemType:_currentType];
    
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                              contentType:_currentType];
    [connFacade asyncGet:url showAlertMsg:YES];
}

- (void)setTriggerReloadListFlag {
    _needRefresh = YES;
}

#pragma mark - lifecycle methods

- (void)clearData {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(usageType == %d) OR (usageType == %d) OR (usageType == %d)", BIZ_DISCUSS_USAGE_GP_TY, BIZ_JOINED_USAGE_GP_TY, BIZ_POPULAR_USAGE_GP_TY];
    DELETE_OBJS_FROM_MOC(_MOC, @"Club", predicate);
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
         parentVC:(UIViewController *)parentVC {
    
    self = [super initWithMOC:MOC
                       holder:nil
             backToHomeAction:nil
        needRefreshHeaderView:NO
        needRefreshFooterView:NO
                   needGoHome:NO];
    
    if (self) {
        _viewHeight = self.frame.size.height;
        
        _parentVC = parentVC;
        
        [self clearData];
        
        _groupCategory = CLUB_GP_TY;
        
        _noNeedDisplayEmptyMsg = YES;
    }
    return self;
}

- (void)dealloc {
    
    self.joinedGroupFetchedRC = nil;
    self.popularGroupFetchedRC = nil;
    
    [super dealloc];
}

- (void)addSelectionIndicator {
    _selectionIndicator = [[[BizGroupIndicatorBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, SELECTION_BAR_HEIGHT)] autorelease];
    
    [self.view addSubview:_selectionIndicator];
}

- (void)triggerPromptIfNeeded {
    if (![AppManager instance].eventPagePrompt) {
        
        [self performSelector:@selector(promptUser) withObject:nil afterDelay:0.5f];
        
        [AppManager instance].eventPagePrompt = YES;
    }
}

- (void)initTabSwitchView {
    
    int offsetY = 0;
    
    if ([CommonUtils is7System]) {
        offsetY = 44;
    }
    
    _tabSwitchView = [[[PlainTabView alloc] initWithFrame:CGRectMake(0, offsetY, self.view.frame.size.width, HEADER_HEIGHT) buttonTitles:@[LocaleStringForKey(NSClubAndBranchGroup, nil), LocaleStringForKey(NSPublicDiscussGroupTitle, nil)] tapSwitchDelegate:self selTabIndex:0] autorelease];
    
    [self.view addSubview:_tabSwitchView];
}

- (void)setTableViewProperties {
    
    _tableView.frame = CGRectMake(0, _tableView.frame.origin.y + 44, _tableView.frame.size.width, _tableView.frame.size.height - 44);
    
    _tableView.separatorStyle = NO;
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"lightBackground.png"]];
}

- (void)hideView {
    _tableView.alpha = 0.0f;
    _tabSwitchView.alpha = 0.0f;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initTabSwitchView];
    
    [self reSizeTable];
    
    [self setTableViewProperties];
    
    [self hideView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!_autoLoaded || _needRefresh) {
        [self loadGroups];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(WebItemType)contentType {
    
    [WXWUIUtils showActivityView:[APP_DELEGATE foundationView]
                            text:LocaleStringForKey(NSLoadingTitle, nil)];
    
    [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(WebItemType)contentType {
    
    switch (contentType) {
        case LOAD_BIZ_GROUPS_TY:
        {
            DELETE_OBJS_FROM_MOC(_MOC, @"JoinedGroup", nil);
            DELETE_OBJS_FROM_MOC(_MOC, @"Club", nil);
            
            if ([XMLParser parserResponseXml:result
                                        type:contentType
                                         MOC:_MOC
                           connectorDelegate:self
                                         url:url]) {
                if (!_autoLoaded) {
                    _autoLoaded = YES;
                    
                    [_tabSwitchView selectButtonWithIndex:_groupCategory];
                    
                    [UIView animateWithDuration:FADE_IN_DURATION
                                     animations:^{
                                         
                                         _tableView.alpha = 1.0f;
                                         _tabSwitchView.alpha = 1.0f;
                                         
                                     }];
                }
                
                [self loadAndDisplayGroups];
                
            } else {
                [WXWUIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSLoadGroupFailedMsg, nil)
                                                 msgType:ERROR_TY
                                      belowNavigationBar:YES];
            }
            
            _tableView.hidden = NO;
            
            _needRefresh = NO;
            
            break;
        }
            
        default:
            break;
    }
    
    [WXWUIUtils closeActivityView];
    
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
    
    _needRefresh = NO;
    
    if ([self connectionMessageIsEmpty:error]) {
        [WXWUIUtils showNotificationOnTopWithMsg:self.errorMsgDic[url]
                                  alternativeMsg:LocaleStringForKey(NSLoadGroupFailedMsg, nil)
                                         msgType:ERROR_TY
                              belowNavigationBar:YES];
    }
    
    _tableView.hidden = NO;
    
    [WXWUIUtils closeActivityView];
    
    [super connectFailed:error url:url contentType:contentType];
}

#pragma mark - section view
- (UIView *)sectionView:(NSString *)title {
    
    WXWLabel *titleLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                  textColor:COLOR(50, 50, 50)
                                                shadowColor:TRANSPARENT_COLOR] autorelease];
    titleLabel.text = title;
    titleLabel.font = BOLD_FONT(13);
    
    CGSize size = [title sizeWithFont:titleLabel.font
                    constrainedToSize:CGSizeMake(self.view.frame.size.width - MARGIN * 2, SECTION_VIEW_HEIGHT)
                        lineBreakMode:UILineBreakModeWordWrap];
    titleLabel.frame = CGRectMake(MARGIN * 2, (SECTION_VIEW_HEIGHT - size.height)/2.0f,
                                  size.width, size.height);
    
    UIView *sectionView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0,
                                                                    self.view.frame.size.width,
                                                                    SECTION_VIEW_HEIGHT)] autorelease];
    sectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"lightBackground.png"]];
    
    [sectionView addSubview:titleLabel];
    return sectionView;
}

#pragma mark - UITableViewDelegate and UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    switch (_groupCategory) {
        case PUBLIC_DISCUSS_GP_TY:
            return DISCUSS_GROUP_SECTION_COUNT;
            
        case CLUB_GP_TY:
            return CLUB_GROUP_SECTION_COUNT;
            
        default:
            return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (_groupCategory) {
        case PUBLIC_DISCUSS_GP_TY:
            return self.fetchedRC.fetchedObjects.count;
            
        case CLUB_GP_TY:
        {
            switch (section) {
                case JOINED_SEC:
                    return (self.joinedGroupFetchedRC.fetchedObjects.count + ROW_ITEM_COUNT - 1) / ROW_ITEM_COUNT;
                    
                case POPULAR_SEC:
                {
                    NSInteger rowCount = (self.popularGroupFetchedRC.fetchedObjects.count + ROW_ITEM_COUNT - 1) / ROW_ITEM_COUNT;
                    
                    _popularGroupCellCount = rowCount + 1;
                    return _popularGroupCellCount;
                }
                    
                default:
                    return 0;
            }
        }
            
        default:
            return 0;
    }
}

- (UITableViewCell *)drawCell:(NSIndexPath *)indexPath
                    fetchedRC:(NSFetchedResultsController *)fetchedRC
               cellIdentifier:(NSString *)cellIdentifier
{
    
    ClubGroupCell *cell = (ClubGroupCell *)[_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == cell) {
        cell = [[[ClubGroupCell alloc] initWithStyle:UITableViewCellStyleDefault
                                     reuseIdentifier:cellIdentifier] autorelease];
    }
    
    NSInteger leftIndex = indexPath.row * 2;
    NSInteger rightIndex = indexPath.row * 2 + 1;
    
    if (leftIndex < fetchedRC.fetchedObjects.count) {
        Club *leftGroup = [fetchedRC.fetchedObjects objectAtIndex:leftIndex];
        
        if (leftGroup) {
            [cell drawLeftItem:indexPath.row
                         group:leftGroup
               selectedGroupId:_selectedGroupId
                      entrance:self
                        action:@selector(openLeftClubGroup:)];
        } else {
            [cell hideLeftItem];
        }
    } else {
        [cell hideLeftItem];
    }
    
    if (rightIndex < fetchedRC.fetchedObjects.count) {
        Club *rightGroup = [fetchedRC.fetchedObjects objectAtIndex:rightIndex];
        
        if (rightGroup) {
            [cell drawRightItem:indexPath.row
                          group:rightGroup
                selectedGroupId:_selectedGroupId
                       entrance:self
                         action:@selector(openRightClubGroup:)];
        } else {
            [cell hideRightItem];
        }
    } else {
        [cell hideRightItem];
    }
    
    return cell;
}

- (UITableViewCell *)moreGroupCell {
    static NSString *kCellIdentifier = @"moreCell";
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    if (nil == cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:kCellIdentifier] autorelease];
        
        UIView *backgroundView = [[[UIView alloc] initWithFrame:CGRectMake(MARGIN * 2,
                                                                           0,
                                                                           self.view.frame.size.width - MARGIN * 4,
                                                                           DEFAULT_CELL_HEIGHT)] autorelease];
        backgroundView.backgroundColor = COLOR(47, 47, 47);
        
        WXWLabel *titleLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                      textColor:[UIColor whiteColor]
                                                    shadowColor:TRANSPARENT_COLOR] autorelease];
        titleLabel.font = BOLD_FONT(20);
        titleLabel.text = LocaleStringForKey(NSOtherDiscussGroupTitle, nil);
        CGSize size = [titleLabel.text sizeWithFont:titleLabel.font
                                  constrainedToSize:CGSizeMake(backgroundView.frame.size.width - MARGIN * 4,
                                                               backgroundView.frame.size.height - MARGIN * 2)
                                      lineBreakMode:UILineBreakModeWordWrap];
        titleLabel.frame = CGRectMake((backgroundView.frame.size.width - size.width)/2.0f,
                                      (backgroundView.frame.size.height - size.height)/2.0f,
                                      size.width, size.height);
        [backgroundView addSubview:titleLabel];
        
        [cell.contentView addSubview:backgroundView];
        
        cell.backgroundColor = TRANSPARENT_COLOR;
        cell.contentView.backgroundColor = TRANSPARENT_COLOR;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (UITableViewCell *)publicGroupCell:(NSIndexPath *)indexPath {
    static NSString *kCellIdentifier = @"bizGroupCell";
    
    Club *club = [self.fetchedRC.fetchedObjects objectAtIndex:indexPath.row];
    
    PublicDiscussionGroupCell *cell = (PublicDiscussionGroupCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    if (nil == cell) {
        cell = [[[PublicDiscussionGroupCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                 reuseIdentifier:kCellIdentifier
                                          imageDisplayerDelegate:self
                                                             MOC:_MOC] autorelease];
    }
    
    [cell drawCellWithGroup:club index:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (_groupCategory) {
        case PUBLIC_DISCUSS_GP_TY:
            return [self publicGroupCell:indexPath];
            
        case CLUB_GP_TY:
        {
            switch (indexPath.section) {
                case JOINED_SEC:
                    
                    return [self drawCell:indexPath
                                fetchedRC:self.joinedGroupFetchedRC
                           cellIdentifier:@"joinedGroupCell"];
                    
                case POPULAR_SEC:
                {
                    if (indexPath.row < _popularGroupCellCount - 1) {
                        return [self drawCell:indexPath
                                    fetchedRC:self.popularGroupFetchedRC
                               cellIdentifier:@"popularGroupCell"];
                    } else {
                        return [self moreGroupCell];
                    }
                }
                    
                default:
                    return nil;
            }
        }
            
        default:
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (_groupCategory) {
        case PUBLIC_DISCUSS_GP_TY:
            return DISCUSS_GP_CELL_HEIGHT;
            
        case CLUB_GP_TY:
        {
            switch (_groupCategory) {
                case CLUB_GP_TY:
                {
                    if (indexPath.section == POPULAR_SEC) {
                        if (indexPath.row == _popularGroupCellCount - 1) {
                            return DEFAULT_CELL_HEIGHT;
                        }
                    }
                    
                    return GRID_CELL_HEIGHT;
                }
                    
                default:
                    return 0;
            }
        }
            
        default:
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    switch (_groupCategory) {
        case CLUB_GP_TY:
            return SECTION_VIEW_HEIGHT;
            
        default:
            return 0;
    }
}

- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section {
    
    switch (_groupCategory) {
            
        case CLUB_GP_TY:
        {
            switch (section) {
                case JOINED_SEC:
                {
                    return [self sectionView:LocaleStringForKey(NSJoinedDiscussGroupTitle, nil)];
                }
                    
                case POPULAR_SEC:
                {
                    return [self sectionView:LocaleStringForKey(NSPopularGroup, nil)];
                }
                    
                default:
                    return nil;
            }
        }
            
        default:
            return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.selectedIndexPath = indexPath;
    
    switch (_groupCategory) {
        case PUBLIC_DISCUSS_GP_TY:
        {
            Club *club = [self.fetchedRC.fetchedObjects objectAtIndex:indexPath.row];
            [self openBizDiscussionGroup:club];
            break;
        }
            
        case CLUB_GP_TY:
        {
            if (indexPath.section == POPULAR_SEC) {
                if (indexPath.row == _popularGroupCellCount - 1) {
                    [self openAllGroups];
                }
            }
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - clear list
- (void)clearList {
    
    _tableView.hidden = YES;
    
    self.fetchedRC = nil;
    self.joinedGroupFetchedRC = nil;
    self.popularGroupFetchedRC = nil;
    [_tableView reloadData];
}

#pragma mark - TapSwitchDelegate method
- (void)selectTapByIndex:(NSInteger)index {
    
    if (index == _groupCategory) {
        return;
    }
    
    _selectedGroupId = -1;
    [super close:nil];
    _currentStartIndex = 0;
    
    _groupCategory = index;
    
    // clear existing displaying data
    [self clearList];
    
    //  [self removeEmptyMessageIfNeeded];
    
    // reload specified type groups
    [self loadGroups];
}

@end
