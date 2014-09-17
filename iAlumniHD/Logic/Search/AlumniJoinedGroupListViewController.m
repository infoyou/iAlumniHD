//
//  AlumniJoinedGroupListViewController.m
//  iAlumniHD
//
//  Created by MobGuang on 12-12-6.
//
//

#import "AlumniJoinedGroupListViewController.h"
#import "TabSwitchView.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "JoinedGroup.h"
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

@interface AlumniJoinedGroupListViewController ()
@property (nonatomic, copy) NSString *alumniPersonId;
@property (nonatomic, copy) NSString *userType;
@end

@implementation AlumniJoinedGroupListViewController

#pragma mark - user actions

- (void)setTriggerReloadListFlag {
    _needReloadGroups = YES;
}

- (void)enterGroup:(ClubViewType)showType group:(Club *)group {
    
    [AppManager instance].allowSendSMS = NO;
    
    GroupDiscussionViewController *postListVC = [[[GroupDiscussionViewController alloc] initWithMOC:_MOC
                                                                                              group:group
                                                                                             parent:self
                                                                                refreshParentAction:@selector(setTriggerReloadListFlag)
                                                                                           listType:ALL_ITEM_LIST_TY
                                                                                           showType:showType] autorelease];
    if (showType == CLUB_ALL_POST_SHOW) {
        postListVC.title = LocaleStringForKey(NSClubPostTitle, nil);
    } else {
        postListVC.title = LocaleStringForKey(NSGroupTrendsTitle, nil);
    }
    
    [self.navigationController pushViewController:postListVC animated:YES];
}

- (void)enterAllScopeGroup:(NSString *)title {
    ShareViewController *shareListVC = [[[ShareViewController alloc] initWithMOC:_MOC
                                                                          holder:nil
                                                                backToHomeAction:nil
                                                                        listType:ALL_ITEM_LIST_TY] autorelease];
    shareListVC.title = title;
    
    [self.navigationController pushViewController:shareListVC animated:YES];
}

#pragma mark - load club
- (void)setPredicate {
    self.entityName = @"JoinedGroup";
    
    self.descriptors = [NSMutableArray array];
    NSSortDescriptor *dateDesc = [[[NSSortDescriptor alloc] initWithKey:@"showOrder"
                                                              ascending:YES] autorelease];
    [self.descriptors addObject:dateDesc];
    
    self.predicate = [NSPredicate predicateWithFormat:@"(alumniId == %@)", self.alumniPersonId];
}

- (void)loadListData:(LoadTriggerType)triggerType forNew:(BOOL)forNew {
    
  [super loadListData:triggerType forNew:forNew];
  
    _showNewLoadedItemCount = NO;
    
    NSInteger index = 0;
    if (!forNew) {
        index = ++_currentStartIndex;
    }
    
    NSString *requestParam = [NSString stringWithFormat:@"<keyword></keyword><sort_type>2</sort_type><only_mine>%d</only_mine><host_type_value></host_type_value><host_sub_type_value></host_sub_type_value><page_size>%@</page_size><page>%d</page><target_user_id>%@</target_user_id><target_user_type>%@</target_user_type>", _myGroupFlag, ITEM_LOAD_COUNT, index, self.alumniPersonId, self.userType];
    
    NSString *url = [CommonUtils geneUrl:requestParam itemType:LOAD_JOINED_GROUPS_TY];
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url contentType:LOAD_JOINED_GROUPS_TY];
    
    [connFacade asyncGet:url showAlertMsg:YES];
}

#pragma mark - lifecycle methods

- (void)clearData {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(alumniId == %@)", self.alumniPersonId];
    
    DELETE_OBJS_FROM_MOC(_MOC, @"JoinedGroup", predicate);
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
   alumniPersonId:(NSString *)alumniPersonId
         userType:(NSString *)userType {
    
    self = [super initWithMOC:MOC
                       holder:nil
             backToHomeAction:nil
        needRefreshHeaderView:NO
        needRefreshFooterView:YES
                   needGoHome:NO];
    
    if (self) {
        _currentStartIndex = 0;
        
        _myGroupFlag = MY_GP_SCOPE;
        
        self.alumniPersonId = alumniPersonId;
        
        self.userType = userType;
        
        [self clearData];
    }
    
    return self;
}

- (void)dealloc {
    
  //[self clearData];
    
    self.alumniPersonId = nil;
    self.userType = nil;
    
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
    self.view.backgroundColor = CELL_COLOR;
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_autoLoaded) {
        [self updateLastSelectedCell];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!_autoLoaded || _needReloadGroups) {
        
        [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
        case LOAD_JOINED_GROUPS_TY:
        {
            
            if ([XMLParser parserJoinedGroupForAlumniId:self.alumniPersonId.longLongValue
                                                xmlData:result
                                                    MOC:_MOC
                                      connectorDelegate:self
                                                    url:url]) {
                
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
    
    switch (contentType) {
        case LOAD_JOINED_GROUPS_TY:
        {
          if ([self connectionMessageIsEmpty:error]) {
            self.connectionErrorMsg = LocaleStringForKey(NSLoadGroupFailedMsg, nil);
          }

            break;
        }
            
        default:
            break;
    }
    
    [super connectFailed:error url:url contentType:contentType];
}


#pragma mark - UITableViewDelegate and UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fetchedRC.fetchedObjects.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.fetchedRC.fetchedObjects.count) {
        return [self drawFooterCell];
	}
    
    // group Cell
    static NSString *kCellIdentifier = @"ClubListCell";
    
    JoinedGroup *group = [self.fetchedRC objectAtIndexPath:indexPath];
    
    GroupInfoCell *cell = (GroupInfoCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (nil == cell) {
        cell = [[[GroupInfoCell alloc] initWithStyle:UITableViewCellStyleDefault
                                     reuseIdentifier:kCellIdentifier] autorelease];
    }
    
    [cell drawCell:group];
    
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
    
    JoinedGroup *group = [self.fetchedRC objectAtIndexPath:indexPath];
    
    if (group.clubId.intValue == ALL_SCOPE_GP_ID) {
        
        [self enterAllScopeGroup:group.clubName];
    } else {
        [AppManager instance].clubName = [NSString stringWithFormat:@"%@", group.clubName];
        [AppManager instance].clubId = [NSString stringWithFormat:@"%@", group.clubId];
        [AppManager instance].clubType = [NSString stringWithFormat:@"%@", group.clubType];
        [AppManager instance].hostSupTypeValue = group.hostSupTypeValue;
        [AppManager instance].hostTypeValue = group.hostTypeValue;
        
        [AppManager instance].isNeedReLoadClubDetail = YES;
        
        group.badgeNum = @"";
        SAVE_MOC(_MOC);
        
        [self enterGroup:CLUB_SELF_VIEW group:group];
    }
    
    [super deselectRowAtIndexPath:indexPath animated:YES];
}


@end
