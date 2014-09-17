//
//  VerticalMenuViewController.m
//  iAlumniHD
//
//  Created by Adam on 12-10-3.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "VerticalMenuViewController.h"
#import "iAlumniHDAppDelegate.h"
#import "EventListViewController.h"
#import "FeedbackViewController.h"
#import "SearchAlumniViewController.h"
#import "ShakeNameCardViewController.h"
#import "UIWebViewController.h"
#import "GroupListViewController.h"
#import "AppSettingViewController.h"
#import "NewsListViewController.h"
#import "VideoListViewController.h"
#import "NearbyEntranceViewController.h"
#import "VerticalMenuCell.h"
#import "UserProfileCell.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "AppManager.h"
#import "UserProfileViewController.h"
#import "StartUpListViewController.h"
#import "ClubEntranceViewController.h"

#define CELL_IMG_IND                    @"CellImage"
#define CELL_TXT_IND                    @"CellText"

#define SECTION_HEADER_HEIGHT           30.0f

#define SEC_COUNT                       2
#define BASE_CELL_COUNT                 11
#define ALUMNI_CELL_COUNT               2
#define ITEM_CELL_HEIGHT                50.0f
#define FONT_SIZE                       18.0f

enum {
    FOLLOW_WECHART_IDX,
    SHARE_APP_BY_WECHART_IDX,
} AppType;

@interface VerticalMenuViewController()
@end

@implementation VerticalMenuViewController

#pragma mark - View lifecycle
- (id)initWithFrame:(CGRect)frame MOC:(NSManagedObjectContext *)MOC {
    
    self = [super init];
    
    if (self) {
		_frame = frame;
        _MOC = MOC;
	}
    
    return self;
}

- (void)dealloc {
    
    RELEAES_TABLE(_tableView);
    RELEASE_OBJ(_baseMenuTitles);
    RELEASE_OBJ(_sectionHeaderView);
    
    [super dealloc];
}

- (void)initMenuTitles {
    
    NSDictionary *eventDic = [NSDictionary dictionaryWithObjectsAndKeys:LocaleStringForKey(NSEventTitle, nil), CELL_TXT_IND,
                              [UIImage imageNamed:@"event.png"], CELL_IMG_IND, nil];
    NSDictionary *newsDic = [NSDictionary dictionaryWithObjectsAndKeys:LocaleStringForKey(NSNewsActivityTitle, nil), CELL_TXT_IND,
                             [UIImage imageNamed:@"news.png"], CELL_IMG_IND, nil];
    NSDictionary *startDic = [NSDictionary dictionaryWithObjectsAndKeys:LocaleStringForKey(NSStartupTitle, nil), CELL_TXT_IND,
                               [UIImage imageNamed:@"business.png"], CELL_IMG_IND, nil];
    NSDictionary *clubDic = [NSDictionary dictionaryWithObjectsAndKeys:LocaleStringForKey(NSBizCoopTitle, nil), CELL_TXT_IND,
                             [UIImage imageNamed:@"group.png"], CELL_IMG_IND, nil];
    NSDictionary *queryDic = [NSDictionary dictionaryWithObjectsAndKeys:LocaleStringForKey(NSAlumniSearchTitle, nil), CELL_TXT_IND,
                              [UIImage imageNamed:@"query.png"], CELL_IMG_IND, nil];
    NSDictionary *personSettingDic = [NSDictionary dictionaryWithObjectsAndKeys:LocaleStringForKey(NSPersonSettingTitle, nil), CELL_TXT_IND,
                                      [UIImage imageNamed:@"setting.png"], CELL_IMG_IND, nil];
    NSDictionary *nearbyDic = [NSDictionary dictionaryWithObjectsAndKeys:LocaleStringForKey(NSShakeTitle, nil), CELL_TXT_IND,
                               [UIImage imageNamed:@"nearby.png"], CELL_IMG_IND, nil];
    NSDictionary *shakeDic = [NSDictionary dictionaryWithObjectsAndKeys:LocaleStringForKey(NSShakeNameCardTitle, nil), CELL_TXT_IND,
                              [UIImage imageNamed:@"shake.png"], CELL_IMG_IND, nil];
    NSDictionary *videoDic = [NSDictionary dictionaryWithObjectsAndKeys:LocaleStringForKey(NSVideoTitle, nil), CELL_TXT_IND,
    [UIImage imageNamed:@"video.png"], CELL_IMG_IND, nil];
    NSDictionary *shareDic = [NSDictionary dictionaryWithObjectsAndKeys:LocaleStringForKey(NSShareTitle, nil), CELL_TXT_IND,
                              [UIImage imageNamed:@"homeShare.png"], CELL_IMG_IND, nil];
    NSDictionary *moreDic = [NSDictionary dictionaryWithObjectsAndKeys:LocaleStringForKey(NSMoreTitle, nil), CELL_TXT_IND,
                             [UIImage imageNamed:@"homeMore.png"], CELL_IMG_IND, nil];
    _baseMenuTitles = [[NSArray alloc] initWithObjects:eventDic, newsDic, startDic, clubDic, queryDic, personSettingDic, nearbyDic, shakeDic,  videoDic, shareDic, moreDic, nil];
}

- (void)initTableView {
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
//    [_tableView setBackgroundColor:TRANSPARENT_COLOR];
    _tableView.separatorColor = COLOR(77, 77, 77);
    _tableView.tableFooterView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)] autorelease];
    _tableView.scrollEnabled = NO;
    _tableView.backgroundColor = COLOR(102, 102, 102);
    [self.view addSubview:_tableView];
    
    [self drawProfileCell];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.frame = _frame;
    
    [self initMenuTitles];
    
    [self initTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIDeviceOrientationLandscapeRight || interfaceOrientation == UIDeviceOrientationLandscapeLeft);
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotate {
    return YES;
}
#endif

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return BASE_CELL_COUNT;
}

- (void)drawProfileCell {
    
    static NSString *kProfileCellIdentifier = @"ProfileCell";
    UserProfileCell *profileCell = (UserProfileCell *)[_tableView dequeueReusableCellWithIdentifier:kProfileCellIdentifier];
    
    if (nil == profileCell) {
        profileCell = [[[UserProfileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kProfileCellIdentifier] autorelease];
    }
    
    [profileCell drawProfile:[AppManager instance].username imgUrl:[AppManager instance].userImgUrl];
    profileCell.selectionStyle = UITableViewCellSelectionStyleNone;
    profileCell.backgroundColor = COLOR(102, 102, 102);
    _tableView.tableHeaderView = profileCell;
}

- (VerticalMenuCell *)drawItemCell:(NSIndexPath *)indexPath {
    
    static NSString *kCellIdentifier = @"ItemCell";
    VerticalMenuCell *cell = (VerticalMenuCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (nil == cell) {
        cell = [[[VerticalMenuCell alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier:kCellIdentifier
                                                  width:self.view.frame.size.width] autorelease];
    }
    
    NSDictionary *dic = nil;
    dic = [_baseMenuTitles objectAtIndex:(indexPath.row)];
    
    cell.textLabel.text = [dic objectForKey:CELL_TXT_IND];
    cell.imageView.image = [dic objectForKey:CELL_IMG_IND];
    cell.backgroundColor = COLOR(102, 102, 102);
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self drawItemCell:indexPath];
}

- (void)selectRow:(HomeMenuType)type {
    
    switch (type) {
            
        case EVENT_MENU_TY:
        {
            [self gotoEvent:DEFAULT_ID_VALUE eventType:0];
            return;
        }
            
        case NEWS_MENU_TY:
        {
            [self gotoNews];
            return;
        }
            
        case STARTUP_MENU_TY:
        {
            [self gotoStartUp:DEFAULT_ID_VALUE];
            return;
        }
            
        case CLUB_MENU_TY:
        {
            [self gotoClub];
            return;
        }
            
        case ALUMNI_MENU_TY:
        {
            [self gotoQuery];
            return;
        }
            
        case NEARBY_MENU_TY:
        {
            [self gotoNearby:DEFAULT_ID_VALUE];
            return;
        }
            
        case SHAKE_MENU_TY:
        {
            [self gotoShake];
            return;
        }
            
        case PROFILE_MENU_TY:
        {
            [self gotoProfile];
            return;
        }
            
        case VIDEO_MENU_TY:
        {
            [self gotoVideo:DEFAULT_ID_VALUE];
            return;
        }
            
        case SHARE_MENU_TY:
        {
            if ([WXApi isWXAppInstalled]){
                UIActionSheet *as = [[[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:nil
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:nil] autorelease];
                [as addButtonWithTitle:LocaleStringForKey(NSFollowWechatPublicNoTitle, nil)];
                [as addButtonWithTitle:LocaleStringForKey(NSShareToWechatTitle, nil)];
                [as addButtonWithTitle:LocaleStringForKey(NSCancelTitle, nil)];
                [as addButtonWithTitle:LocaleStringForKey(NSCancelTitle, nil)];
                as.cancelButtonIndex = as.numberOfButtons - 1;
                [as showInView:self.view];
                return;
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                message:LocaleStringForKey(NSNoWeChatMsg, nil)
                                                               delegate:self
                                                      cancelButtonTitle:LocaleStringForKey(NSDonotInstallTitle, nil)
                                                      otherButtonTitles:LocaleStringForKey(NSInstallTitle, nil), nil];
                [alert show];
                [alert release];
            }
            return;
        }
            
        case MORE_MENU_TY:
        {
            [self gotoMore];
            return;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSIndexPath *selectedIndexPath = [_tableView indexPathForSelectedRow];
    if (selectedIndexPath) {
        [_tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
    }
    
    if ([AppManager instance].sharedItemType == DEFAULT_ID_VALUE) {
        [self selectRow:indexPath.row];
    }
    
    [_tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = 0.0f;
    
    switch (indexPath.row) {
        default:
            height = ITEM_CELL_HEIGHT;
            break;
    }
    
    return height;
}

#pragma mark - go default view
- (void)selectedCell:(NSInteger)showIndex {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:showIndex inSection:0];
    [self tableView:_tableView didSelectRowAtIndexPath:indexPath];
}

#pragma mark - go business view
- (void)gotoEvent:(long long)eventId eventType:(int)eventType
{
    
    EventListViewController *eventListVC = [[[EventListViewController alloc] initWithMOC:_MOC tabIndex:eventType] autorelease];
    eventListVC.title = LocaleStringForKey(NSEventDescTitle, nil);
    WXWNavigationController *mNC = [[[WXWNavigationController alloc] initWithRootViewController:eventListVC shadowType:SHADOW_RIGHT] autorelease];
    
    [APP_DELEGATE addViewInSlider:mNC
               invokeByController:self
                   stackStartView:YES];
    
    [APP_DELEGATE setMenuTitle:LocaleStringForKey(NSEventDescTitle, nil)];
}

- (void)gotoQuery
{

    [AppManager instance].isAdminCheckIn = NO;
    
    [CommonUtils deleteAllObjects:_MOC];
    SearchAlumniViewController *queryVC = [[[SearchAlumniViewController alloc] initWithMOC:_MOC] autorelease];
    
    WXWNavigationController *mNC = [[[WXWNavigationController alloc] initWithRootViewController:queryVC shadowType:SHADOW_RIGHT] autorelease];
    
    [APP_DELEGATE addViewInSlider:mNC
               invokeByController:self
                   stackStartView:YES];
    
    [APP_DELEGATE setMenuTitle:LocaleStringForKey(NSAlumniSearchTitle, nil)];
}

- (void)gotoNews
{
    
    NewsListViewController *newsListVC = [[[NewsListViewController alloc] initWithMOC:_MOC
                                                                               holder:self
                                                                     backToHomeAction:@selector(backToHomepage:)] autorelease];
    newsListVC.title = LocaleStringForKey(NSNewsActivityTitle, nil);
    
    WXWNavigationController *mNC = [[[WXWNavigationController alloc] initWithRootViewController:newsListVC shadowType:SHADOW_RIGHT] autorelease];
    
    [APP_DELEGATE addViewInSlider:mNC
               invokeByController:self
                   stackStartView:YES];
    
    [APP_DELEGATE setMenuTitle:LocaleStringForKey(NSNewsActivityTitle, nil)];
}

- (void)gotoClub
{
    
    ClubEntranceViewController *groupListVC = [[[ClubEntranceViewController alloc] initWithMOC:_MOC parentVC:self] autorelease];
    groupListVC.title = LocaleStringForKey(NSBizCoopTitle, nil);
    WXWNavigationController *mNC = [[[WXWNavigationController alloc] initWithRootViewController:groupListVC shadowType:SHADOW_RIGHT] autorelease];
    
    [APP_DELEGATE addViewInSlider:mNC
               invokeByController:self
                   stackStartView:YES];
    
    [APP_DELEGATE setMenuTitle:LocaleStringForKey(NSBizCoopTitle, nil)];
}

- (void)gotoStartUp:(long long)eventId
{
    StartUpListViewController *eventListVC = [[[StartUpListViewController alloc] initWithMOC:_MOC] autorelease];
    eventListVC.title = LocaleStringForKey(NSStartupTitle, nil);
    WXWNavigationController *mNC = [[[WXWNavigationController alloc] initWithRootViewController:eventListVC shadowType:SHADOW_RIGHT] autorelease];
    
    [APP_DELEGATE addViewInSlider:mNC
               invokeByController:self
                   stackStartView:YES];
    
    [APP_DELEGATE setMenuTitle:LocaleStringForKey(NSStartupTitle, nil)];
}

- (void)gotoSurvey
{
    CGRect mFrame = CGRectMake(0, 0, SCREEN_WIDTH - VERTICAL_MENU_WIDTH, SCREEN_HEIGHT);
    
    NSString *url = [NSString stringWithFormat:@"%@%@&user_id=%@&locale=%@&plat=%@&version=%@&sessionId=%@&person_id=%@", [AppManager instance].hostUrl, SURVEY_URL,[AppManager instance].userId,[AppManager instance].currentLanguageDesc, PLATFORM, VERSION, [AppManager instance].sessionId,[AppManager instance].personId];
    
    UIWebViewController *webVC = [[[UIWebViewController alloc] initWithUrl:url frame:mFrame isNeedClose:NO] autorelease];
    
    [APP_DELEGATE addViewInSlider:webVC
               invokeByController:self
                   stackStartView:YES];
    
    [APP_DELEGATE setMenuTitle:LocaleStringForKey(NSSurveyTitle, nil)];
}

- (void)gotoVideo:(long long)videoId
{
    VideoListViewController *videoListVC = [[[VideoListViewController alloc] initWithMOC:_MOC] autorelease];
    videoListVC.title = LocaleStringForKey(NSVideoTitle, nil);
    
    WXWNavigationController *mNC = [[[WXWNavigationController alloc] initWithRootViewController:videoListVC shadowType:SHADOW_RIGHT] autorelease];
    
    [APP_DELEGATE addViewInSlider:mNC
               invokeByController:self
                   stackStartView:YES];
    
    [APP_DELEGATE setMenuTitle:LocaleStringForKey(NSVideoTitle, nil)];
}

- (void)gotoNearby:(long long)brandId
{
    [AppManager instance].isAdminCheckIn = NO;
    
    NearbyEntranceViewController *nearbyVC = [[[NearbyEntranceViewController alloc] initWithMOC:_MOC brandId:brandId] autorelease];
    
    nearbyVC.title = LocaleStringForKey(NSNearbyTitle, nil);
    
    WXWNavigationController *mNC = [[[WXWNavigationController alloc] initWithRootViewController:nearbyVC shadowType:SHADOW_RIGHT] autorelease];
    if ([CommonUtils currentOSVersion] < IOS5) {
        [nearbyVC viewDidAppear:YES];
    }
    
    [APP_DELEGATE addViewInSlider:mNC
               invokeByController:self
                   stackStartView:YES];
    
    [APP_DELEGATE setMenuTitle:LocaleStringForKey(NSNearbyTitle, nil)];
}

- (void)gotoShake
{
    ShakeNameCardViewController *shakeNameCard = [[[ShakeNameCardViewController alloc] initWithMOC:_MOC] autorelease];
    shakeNameCard.title = LocaleStringForKey(NSShakeNameCardTitle, nil);
    
    if ([CommonUtils currentOSVersion] < IOS5) {
        [shakeNameCard viewDidAppear:YES];
    }
    
    [APP_DELEGATE addViewInSlider:shakeNameCard
               invokeByController:self
                   stackStartView:YES];
    
    [APP_DELEGATE setMenuTitle:LocaleStringForKey(NSShakeNameCardTitle, nil)];
}

- (void)gotoProfile
{
    UserProfileViewController *profileVC = [[[UserProfileViewController alloc] initWithMOC:_MOC] autorelease];
    
    profileVC.title = LocaleStringForKey(NSPersonSettingTitle, nil);
    WXWNavigationController *mNC = [[[WXWNavigationController alloc] initWithRootViewController:profileVC shadowType:SHADOW_RIGHT] autorelease];
    
    [APP_DELEGATE addViewInSlider:mNC
               invokeByController:self
                   stackStartView:YES];
    
    [APP_DELEGATE setMenuTitle:LocaleStringForKey(NSPersonSettingTitle, nil)];
}

- (void)gotoMore {
    
    AppSettingViewController *settingVC = [[[AppSettingViewController alloc]
                                            initWithMOC:_MOC
                                            holder:self
                                            backToHomeAction:nil] autorelease];
    settingVC.title = LocaleStringForKey(NSMoreTitle, nil);
    
    WXWNavigationController *mNC = [[[WXWNavigationController alloc] initWithRootViewController:settingVC shadowType:SHADOW_RIGHT] autorelease];
    
    [APP_DELEGATE addViewInSlider:mNC
               invokeByController:self
                   stackStartView:YES];
    
    [APP_DELEGATE setMenuTitle:LocaleStringForKey(NSMoreTitle, nil)];
}

#pragma mark - WXApiDelegate methods
-(void) onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[SendMessageToWXResp class]]) {
        switch (resp.errCode) {
            case WECHAT_OK_CODE:
                [WXWUIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSAppShareByWeChatDoneMsg, nil)
                                              msgType:SUCCESS_TY
                                   belowNavigationBar:YES];
                break;
                
            case WECHAT_BACK_CODE:
                break;
                
            default:
                [WXWUIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSAppShareByWeChatFailedMsg, nil)
                                              msgType:ERROR_TY
                                   belowNavigationBar:YES];
                break;
        }
    }
    
    APP_DELEGATE.wxApiDelegate = nil;
}

#pragma mark - UIActionSheetDelegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case FOLLOW_WECHART_IDX:
        {
            if ([WXApi isWXAppInstalled]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:WECHAT_PUBLIC_NO_URL]];
            }
            break;
        }
            
        case SHARE_APP_BY_WECHART_IDX:
        {
            if ([WXApi isWXAppInstalled]) {
                APP_DELEGATE.wxApiDelegate = self;
                
                NSString *url = [NSString stringWithFormat:CONFIGURABLE_DOWNLOAD_URL,
                                 [AppManager instance].hostUrl,
                                 [AppManager instance].currentLanguageDesc,
                                 [AppManager instance].releaseChannelType];
                
                [CommonUtils shareByWeChat:WXSceneSession
                                     title:LocaleStringForKey(NSAppRecommendTitle, nil)
                               description:[AppManager instance].recommend
                                       url:url];
            }
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - UIAlertViewDelegate method
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:WECHAT_ITUNES_URL]];
    }
}

#pragma mark - open shared
- (void)openSharedEventById:(long long)eventId eventType:(int)eventType
{
    if (eventType != STARTUP_EVENT_TY) {
        [self selectedCell:EVENT_MENU_TY];
        [self gotoEvent:eventId eventType:(eventType-1)];
    } else {
        [self selectedCell:STARTUP_MENU_TY];
        [self gotoStartUp:eventId];
    }
    [self closeSharedParam];
}

- (void)setAutoSelectEventTabFlagWithId:(long long)eventId eventType:(int)eventType
{
}

- (void)openSharedBrandWithId:(long long)brandId
{
    [self selectedCell:NEARBY_MENU_TY];
    [self gotoNearby:brandId];
    [self closeSharedParam];
}

- (void)openSharedVideoWithId:(long long)videoId
{
    [self selectedCell:VIDEO_MENU_TY];
    [self gotoVideo:videoId];
    [self closeSharedParam];
}

- (void)closeSharedParam
{
    [AppManager instance].sharedItemType = DEFAULT_ID_VALUE;
}

@end
