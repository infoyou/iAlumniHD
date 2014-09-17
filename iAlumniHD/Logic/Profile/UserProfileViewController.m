//
//  UserProfileViewController.m
//  iAlumniHD
//
//  Created by MobGuang on 12-9-24.
//
//

#import "UserProfileViewController.h"
#import "UserProfileHeaderView.h"
#import "UserListViewController.h"
#import "UIWebViewController.h"
#import "PhotoFetcherView.h"
#import "XMLParser.h"
#import "ECHandyAvatarBrowser.h"
#import "AlumniListViewController.h"
#import "WithTitleImageCell.h"
#import "NameCardSearchViewController.h"
#import "AttractiveAlumniListViewController.h"
#import "KnownAlumniListViewController.h"
#import "VerticalMenuViewController.h"

#define PHOTO_MARGIN      3.0f
#define SECTION_GAP       30.0f

enum {
    DM_SEC,
    ALUMNI_NETWORK_SEC,
    INFO_SEC,
};

enum {
    DM_SEC_CELL,
};

enum {
    ALUMNI_NETWORK_SEC_TITLE_CELL,
    ALUMNI_NETWORK_SEC_WANT_TO_KNOW_CELL,
    //ALUMNI_NETWORK_SEC_RECOMMEND_CELL,
    ALUMNI_NETWORK_SEC_KNOW_CELL,
    //ALUMNI_NETWORK_SEC_SEARCH_CELL,
};

enum {
    INFO_SEC_TITLE_CELL,
    INFO_SEC_3RD_SNS_CELL,
    INFO_SEC_PROF_CELL,
    INFO_SEC_CONTACT_CELL,
    INFO_SEC_COMPANY_CELL,
};

#define DM_SEC_COUNT        1
#define ALUMNI_NETWORK_SEC_COUNT 3
#define INFO_SEC_COUNT      5
#define SECTION_COUNT       3

#define DEFAULT_HEIGHT  44.0f

@interface UserProfileViewController ()
@property (nonatomic, retain) ImagePickerViewController *photoPickerVC;
@property (nonatomic, retain) id<ItemUploaderDelegate> delegate;
@property (nonatomic, retain) UIImage *selectedPhoto;
@end

@implementation UserProfileViewController

@synthesize photoPickerVC = _photoPickerVC;
@synthesize selectedPhoto = _selectedPhoto;

#pragma mark - load data
- (void)loadConnectedAlumnusCount {
    NSString *url = [CommonUtils geneUrl:@"" itemType:LOAD_CONNECTED_ALUMNUS_COUNT_TY];
    
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                             contentType:LOAD_CONNECTED_ALUMNUS_COUNT_TY];
    [connFacade asyncGet:url showAlertMsg:YES];
}

#pragma mark - lifecycle methods
- (id)initWithMOC:(NSManagedObjectContext *)MOC
{
    
    self = [super initWithMOC:MOC
                       holder:nil
             backToHomeAction:nil
        needRefreshHeaderView:NO
        needRefreshFooterView:NO
                   tableStyle:UITableViewStyleGrouped
                   needGoHome:NO];
    
    if (self) {
        
    }
    
    return self;
}

- (void)dealloc {
    
    RELEASE_OBJ(_headerView);
    
    self.selectedPhoto = nil;
    
    self.photoPickerVC = nil;
    
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self reSizeTable];
    
    self.view.backgroundColor = CELL_COLOR;
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self loadConnectedAlumnusCount];
    
    [self updateLastSelectedCell];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - handle empty list
- (BOOL)listIsEmpty {
    return NO;
}

#pragma mark - UITableViewDelegate and UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return SECTION_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case DM_SEC:
            return DM_SEC_COUNT;
            
        case ALUMNI_NETWORK_SEC:
            return ALUMNI_NETWORK_SEC_COUNT;
            
        case INFO_SEC:
            return INFO_SEC_COUNT;
            
        default:
            return 0;
    }
}

- (UITableViewCell *)drawDMSectionCell:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"dmCell";
    
    return [self configureWithTitleImageCell:cellIdentifier
                                       title:LocaleStringForKey(NSShakeChatListTitle, nil)
                                  badgeCount:[AppManager instance].msgNumber.intValue
                                     content:nil
                                       image:[UIImage imageNamed:@"dm.png"]
                                   indexPath:indexPath
                                   clickable:YES
                                  dropShadow:NO
                                cornerRadius:GROUPED_CELL_CORNER_RADIUS];
    
}

- (UITableViewCell *)drawNameCardSection:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = nil;
    
    switch (indexPath.row) {
        case ALUMNI_NETWORK_SEC_TITLE_CELL:
        {
            cellIdentifier = @"nameCardHeaderCell";
            return [self configureHeaderCell:cellIdentifier
                                       title:LocaleStringForKey(NSPeopleNetworkTitle, nil)
                                  badgeCount:0
                                     content:nil
                                   indexPath:indexPath
                                  dropShadow:NO
                                cornerRadius:GROUPED_CELL_CORNER_RADIUS];
        }
            
        case ALUMNI_NETWORK_SEC_WANT_TO_KNOW_CELL:
        {
            cellIdentifier = @"favoriteCell";
            
            return [self configureWithTitleImageCell:cellIdentifier
                                               title:LocaleStringForKey(NSWantToKnowAlumniTitle, nil)
                                          badgeCount:[AppManager instance].wantToKnowAlumnusCount.intValue
                                             content:nil
                                               image:[UIImage imageNamed:@"wantKnowAlumni.png"]
                                           indexPath:indexPath
                                           clickable:YES
                                          dropShadow:NO
                                        cornerRadius:GROUPED_CELL_CORNER_RADIUS];
            
        }
            /*
             case ALUMNI_NETWORK_SEC_RECOMMEND_CELL:
             {
             cellIdentifier = @"recommendCell";
             return [self configureWithTitleImageCell:cellIdentifier
             title:LocaleStringForKey(NSRecommendAlumnusTitle, nil)
             badgeCount:0
             content:nil
             image:[UIImage imageNamed:@"recommendedAlumni.png"]
             indexPath:indexPath
             clickable:YES
             dropShadow:YES
             cornerRadius:GROUPED_CELL_CORNER_RADIUS];
             }
             */
        case ALUMNI_NETWORK_SEC_KNOW_CELL:
        {
            cellIdentifier = @"knowCell";
            
            return [self configureWithTitleImageCell:cellIdentifier
                                               title:LocaleStringForKey(NSKnownAlumnusTitle, nil)
                                          badgeCount:[AppManager instance].knownAlumnusCount.intValue
                                             content:nil
                                               image:[UIImage imageNamed:@"knownAlumni.png"]
                                           indexPath:indexPath
                                           clickable:YES
                                          dropShadow:NO
                                        cornerRadius:GROUPED_CELL_CORNER_RADIUS];
        }
            /*
             case ALUMNI_NETWORK_SEC_SEARCH_CELL:
             {
             cellIdentifier = @"searchCell";
             
             return [self configureWithTitleImageCell:cellIdentifier
             title:LocaleStringForKey(NSSearchNameCardTitle, nil)
             badgeCount:0
             content:nil
             image:[UIImage imageNamed:@"recommendedAlumni.png"]
             indexPath:indexPath
             clickable:YES
             dropShadow:YES
             cornerRadius:GROUPED_CELL_CORNER_RADIUS];
             }
             */
        default:
            return nil;
    }
}

- (UITableViewCell *)drawInfoSectionCell:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = nil;
    
    switch (indexPath.row) {
        case INFO_SEC_TITLE_CELL:
        {
            cellIdentifier = @"baseInfoHeaderCell";
            return [self configureHeaderCell:cellIdentifier
                                       title:LocaleStringForKey(NSBaseInfoTitle, nil)
                                  badgeCount:0
                                     content:nil
                                   indexPath:indexPath
                                  dropShadow:NO
                                cornerRadius:GROUPED_CELL_CORNER_RADIUS];
        }
            
        case INFO_SEC_PROF_CELL:
        {
            cellIdentifier = @"profileCell";
            
            return [self configureWithTitleImageCell:cellIdentifier
                                               title:LocaleStringForKey(NSProfileBaseTitle, nil)
                                          badgeCount:0
                                             content:nil
                                               image:[UIImage imageNamed:@"personalInfo.png"]
                                           indexPath:indexPath
                                           clickable:YES
                                          dropShadow:NO
                                        cornerRadius:GROUPED_CELL_CORNER_RADIUS];
        }
            
        case INFO_SEC_CONTACT_CELL:
        {
            cellIdentifier = @"contactCell";
            
            return [self configureWithTitleImageCell:cellIdentifier
                                               title:LocaleStringForKey(NSProfileHomeTitle, nil)
                                          badgeCount:0
                                             content:LocaleStringForKey(NSProfileHomeNoteMsg, nil)
                                               image:[UIImage imageNamed:@"addressContact.png"]
                                           indexPath:indexPath
                                           clickable:YES
                                          dropShadow:NO
                                        cornerRadius:GROUPED_CELL_CORNER_RADIUS];
            
        }
            
        case INFO_SEC_COMPANY_CELL:
        {
            cellIdentifier = @"companyCell";
            
            return [self configureWithTitleImageCell:cellIdentifier
                                               title:LocaleStringForKey(NSProfileCompanyTitle, nil)
                                          badgeCount:0
                                             content:nil
                                               image:[UIImage imageNamed:@"companyContact.png"]
                                           indexPath:indexPath
                                           clickable:YES
                                          dropShadow:NO
                                        cornerRadius:GROUPED_CELL_CORNER_RADIUS];
        }
            
        case INFO_SEC_3RD_SNS_CELL:
        {
            cellIdentifier = @"thirdPartySNSCell";
            
            return [self configureWithTitleImageCell:cellIdentifier
                                               title:LocaleStringForKey(NSProfileAccountTitle, nil)
                                          badgeCount:0
                                             content:nil
                                               image:[UIImage imageNamed:@"weibo.png"]
                                           indexPath:indexPath
                                           clickable:YES
                                          dropShadow:NO
                                        cornerRadius:GROUPED_CELL_CORNER_RADIUS];
        }
            
        default:
            return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case DM_SEC:
            return [self drawDMSectionCell:indexPath];
            
        case ALUMNI_NETWORK_SEC:
            return [self drawNameCardSection:indexPath];
            
        case INFO_SEC:
            return [self drawInfoSectionCell:indexPath];
            
        default:
            return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case DM_SEC:
        {
            switch (indexPath.row) {
                case DM_SEC_CELL:
                {
                    return [self calculateCommonCellHeightWithTitle:LocaleStringForKey(NSShakeChatListTitle, nil)
                                                            content:nil
                                                          indexPath:indexPath
                                                          clickable:YES];
                }
                default:
                    return 0;
            }
        }
            
        case ALUMNI_NETWORK_SEC:
        {
            switch (indexPath.row) {
                    
                case ALUMNI_NETWORK_SEC_TITLE_CELL:
                    return [self calculateHeaderCellHeightWithTitle:LocaleStringForKey(NSPeopleNetworkTitle, nil)
                                                            content:nil
                                                          indexPath:indexPath];
                    
                case ALUMNI_NETWORK_SEC_WANT_TO_KNOW_CELL:
                    
                    return [self calculateCommonCellHeightWithTitle:LocaleStringForKey(NSWantToKnowAlumniTitle, nil)
                                                            content:nil
                                                          indexPath:indexPath
                                                          clickable:YES];
                    /*
                     case ALUMNI_NETWORK_SEC_RECOMMEND_CELL:
                     
                     return [self calculateCommonCellHeightWithTitle:LocaleStringForKey(NSRecommendAlumnusTitle, nil)
                     content:nil
                     indexPath:indexPath
                     clickable:YES];
                     */
                case ALUMNI_NETWORK_SEC_KNOW_CELL:
                    
                    return [self calculateCommonCellHeightWithTitle:LocaleStringForKey(NSKnownAlumnusTitle, nil)
                                                            content:nil
                                                          indexPath:indexPath
                                                          clickable:YES];
                    /*
                     case ALUMNI_NETWORK_SEC_SEARCH_CELL:
                     return [self calculateCommonCellHeightWithTitle:LocaleStringForKey(NSSearchNameCardTitle, nil)
                     content:nil
                     indexPath:indexPath
                     clickable:YES];
                     */
                    
                default:
                    return 0;
            }
        }
            
        case INFO_SEC:
        {
            switch (indexPath.row) {
                case INFO_SEC_TITLE_CELL:
                    return [self calculateHeaderCellHeightWithTitle:LocaleStringForKey(NSBaseInfoTitle, nil)
                                                            content:nil
                                                          indexPath:indexPath];
                    
                case INFO_SEC_PROF_CELL:
                    return [self calculateCommonCellHeightWithTitle:LocaleStringForKey(NSProfileBaseTitle, nil)
                                                            content:nil
                                                          indexPath:indexPath
                                                          clickable:YES];
                    
                case INFO_SEC_CONTACT_CELL:
                    return [self calculateCommonCellHeightWithTitle:LocaleStringForKey(NSProfileHomeTitle, nil)
                                                            content:LocaleStringForKey(NSProfileHomeNoteMsg, nil)
                                                          indexPath:indexPath
                                                          clickable:YES];
                    
                case INFO_SEC_COMPANY_CELL:
                    return [self calculateCommonCellHeightWithTitle:LocaleStringForKey(NSProfileCompanyTitle, nil)
                                                            content:nil
                                                          indexPath:indexPath
                                                          clickable:YES];
                    
                case INFO_SEC_3RD_SNS_CELL:
                    return [self calculateCommonCellHeightWithTitle:LocaleStringForKey(NSProfileAccountTitle, nil)
                                                            content:nil
                                                          indexPath:indexPath
                                                          clickable:YES];
                    
                default:
                    return 0;
            }
        }
        default:
            return 0;
    }
}

- (UIView *)sectionHeaderView {
    
    if (nil == _headerView) {
        _headerView = [[UserProfileHeaderView alloc] initWithFrame:CGRectMake(0, 0,
                                                                              self.view.frame.size.width,
                                                                              USERDETAIL_PHOTO_HEIGHT + PHOTO_MARGIN * 2 + MARGIN * 4)
                                            imageDisplayerDelegate:self
                                          clickableElementDelegate:self];
        _headerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    
    return _headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    switch (section) {
        case DM_SEC:
            return [self sectionHeaderView];
            
        default:
            return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    switch (section) {
        case DM_SEC:
            return USERDETAIL_PHOTO_HEIGHT + PHOTO_MARGIN * 2 + MARGIN * 4;
            
        default:
            return 0;
    }
}

- (void)showDMs {
    [CommonUtils doDelete:_MOC entityName:@"Alumni"];
    
    UserListViewController *userListVC = [[[UserListViewController alloc] initWithType:CHAT_USER_LIST_TY needGoToHome:NO MOC:_MOC group:nil] autorelease];
    userListVC.pageIndex = 0;
    userListVC.requestParam = [NSString stringWithFormat:@"<page>0</page><page_size>30</page_size>"];
    userListVC.title = LocaleStringForKey(NSShakeChatListTitle, nil);
    
    WXWNavigationController *mNC = [[[WXWNavigationController alloc] initWithRootViewController:userListVC shadowType:SHADOW_LEFT] autorelease];
    
    [APP_DELEGATE addViewInSlider:mNC
               invokeByController:self
                   stackStartView:NO];
    
    [AppManager instance].msgNumber = @"0";
}

- (void)showBasicInfos:(NSIndexPath *)indexPath {
    
    NSString *url = @"";
    
    switch (indexPath.row) {
        case INFO_SEC_TITLE_CELL:
            return;
            
        case INFO_SEC_PROF_CELL:
        {
            url = PROFILE_BASE_URL;
            break;
        }
            
        case INFO_SEC_CONTACT_CELL:
        {
            url = PROFILE_HOME_URL;
            break;
        }
            
        case INFO_SEC_COMPANY_CELL:
        {
            url = PROFILE_COMPANY_URL;
            break;
        }
            
        case INFO_SEC_3RD_SNS_CELL:
        {
            url = PROFILE_ACCOUNT_URL;
            break;
        }
            
        default:
            break;
    }
    
    NSString *targetUrl = [NSString stringWithFormat:@"%@%@&user_id=%@&locale=%@&plat=%@&version=%@&sessionId=%@&person_id=%@", [AppManager instance].hostUrl, url, [AppManager instance].userId, [AppManager instance].currentLanguageDesc, PLATFORM, VERSION,[AppManager instance].sessionId, [AppManager instance].personId];
    
    CGRect mFrame = CGRectMake(0, 0, UI_MODAL_FORM_SHEET_WIDTH, self.view.frame.size.height);
    
    UIWebViewController *webVC = [[[UIWebViewController alloc]
                                   initWithUrl:targetUrl
                                   frame:mFrame
                                   isNeedClose:YES] autorelease];
    
	webVC.deSelectCellDelegate = self;
    self.selectedIndexPath = indexPath;
    
    WXWNavigationController *detailNC = [[[WXWNavigationController alloc] initWithRootViewController:webVC] autorelease];
    
    [APP_DELEGATE addViewInSlider:detailNC
               invokeByController:self
                   stackStartView:NO];

}

- (void)selectNameCardSec:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case ALUMNI_NETWORK_SEC_WANT_TO_KNOW_CELL:
        {
            
            AttractiveAlumniListViewController *alumniListVC = [[[AttractiveAlumniListViewController alloc] initResettedWithMOC:_MOC] autorelease];
            alumniListVC.title = LocaleStringForKey(NSWantToKnowAlumniTitle, nil);
            WXWNavigationController *mNC = [[[WXWNavigationController alloc] initWithRootViewController:alumniListVC] autorelease];
            
            [APP_DELEGATE addViewInSlider:mNC
                       invokeByController:self
                           stackStartView:NO];
            break;
        }
            /*
             case ALUMNI_NETWORK_SEC_RECOMMEND_CELL:
             {
             AlumniListViewController *alumniListVC = [[[AlumniListViewController alloc] initResettedWithMOC:_MOC] autorelease];
             alumniListVC.title = LocaleStringForKey(NSRecommendAlumnusTitle, nil);
             [self.navigationController pushViewController:alumniListVC animated:YES];
             break;
             }
             */
        case ALUMNI_NETWORK_SEC_KNOW_CELL:
        {
            /*
             AlumniListViewController *alumniListVC = [[[AlumniListViewController alloc] initResettedWithMOC:_MOC] autorelease];
             alumniListVC.title = LocaleStringForKey(NSKnownAlumnusTitle, nil);
             [self.navigationController pushViewController:alumniListVC animated:YES];
             break;
             */
            
            KnownAlumniListViewController *alumniListVC = [[[KnownAlumniListViewController alloc] initWithMOC:_MOC] autorelease];
            alumniListVC.title = LocaleStringForKey(NSKnownAlumnusTitle, nil);
            WXWNavigationController *mNC = [[[WXWNavigationController alloc] initWithRootViewController:alumniListVC] autorelease];
            
            [APP_DELEGATE addViewInSlider:mNC
                       invokeByController:self
                           stackStartView:NO];
        }
            /*
             case ALUMNI_NETWORK_SEC_SEARCH_CELL:
             {
             NameCardSearchViewController *nameCardSearchVC = [[[NameCardSearchViewController alloc] initWithMOC:_MOC] autorelease];
             nameCardSearchVC.title = LocaleStringForKey(NSSearchNameCardTitle, nil);
             [self.navigationController pushViewController:nameCardSearchVC animated:YES];
             break;
             }
             */
        default:
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    switch (indexPath.section) {
        case DM_SEC:
            [self showDMs];
            break;
            
        case ALUMNI_NETWORK_SEC:
            [self selectNameCardSec:indexPath];
            break;
            
        case INFO_SEC:
            [self showBasicInfos:indexPath];
            break;
            
        default:
            break;
    }
    
    [super deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - change photo

- (void)showImagePicker:(UIImagePickerControllerSourceType)sourceType {
    
    _photoSourceType = sourceType;
    
    self.photoPickerVC = [[[ImagePickerViewController alloc] initWithSourceType:_photoSourceType
                                                                       delegate:self
                                                               uploaderDelegate:self
                                                                      takerType:USER_AVATAR_TY
                                                                            MOC:_MOC] autorelease];
    
    [self.photoPickerVC arrangeViews];
    
    UIPopoverController *popVC = [[UIPopoverController alloc] initWithContentViewController:self.photoPickerVC.imagePicker];
    popVC.delegate = self;
    self.photoPickerVC._popVC = popVC;
    
    [popVC presentPopoverFromRect:CGRectMake(10.f, 0.f, _frame.size.width, _frame.size.height)
                           inView:self.view
         permittedArrowDirections:_UIPopoverArrowDirection
                         animated:YES];
}

- (void)changeAvatar {
    
    UIActionSheet *as = [[[UIActionSheet alloc] initWithTitle:nil
                                                     delegate:self
                                            cancelButtonTitle:nil
                                       destructiveButtonTitle:nil
                                            otherButtonTitles:nil] autorelease];
    
    if (HAS_CAMERA) {
        [as addButtonWithTitle:LocaleStringForKey(NSTakePhotoTitle, nil)];
        [as addButtonWithTitle:LocaleStringForKey(NSChooseExistingPhotoTitle, nil)];
    } else {
        [as addButtonWithTitle:LocaleStringForKey(NSChooseExistingPhotoTitle, nil)];
    }
    
    [as addButtonWithTitle:LocaleStringForKey(NSCancelTitle, nil)];
    as.cancelButtonIndex = [as numberOfButtons] - 1;
    [as showInView:self.navigationController.view];
    
}

- (void)initPhotoFetcherView {
    BOOL userInteractionEnabled = YES;
    if (_photoTakerType == HANDY_PHOTO_TAKER_TY/* || _photoTakerType == SERVICE_ITEM_AVATAR_TY*/) {
        userInteractionEnabled = NO;
    }
    
    _photoFetcherView = [[PhotoFetcherView alloc] initWithFrame:CGRectMake(MARGIN * 2, MARGIN, USERDETAIL_PHOTO_WIDTH, USERDETAIL_PHOTO_HEIGHT)
                                                         target:self
                                          photoManagementAction:@selector(addOrRemovePhoto)
                                         userInteractionEnabled:userInteractionEnabled];
    [self.view addSubview:_photoFetcherView];
}

#pragma mark - WXWConnectorDelegate methods

- (void)connectStarted:(NSString *)url contentType:(WebItemType)contentType {
    
    switch (contentType) {
        case MODIFY_USER_ICON_TY:
            
            break;
            
        case LOAD_CONNECTED_ALUMNUS_COUNT_TY:
            
            break;
            
        default:
            break;
    }
    
    [WXWUIUtils showActivityView:[APP_DELEGATE foundationView]
                         text:LocaleStringForKey(NSLoadingTitle, nil)];
    [super connectStarted:url contentType:contentType];
}

- (void)connectCancelled:(NSString *)url
             contentType:(WebItemType)contentType {
    
    [super connectCancelled:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(WebItemType)contentType {
    
    
    switch (contentType) {
        case MODIFY_USER_ICON_TY:
        {
            if ([XMLParser parserResponseXml:result
                                        type:contentType
                                         MOC:nil
                           connectorDelegate:self
                                         url:url]) {
                
                [_headerView updateAvatar:self.selectedPhoto];
                
                [WXWUIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSUpdatePhotoDoneMsg, nil)
                                              msgType:SUCCESS_TY
                                   belowNavigationBar:YES];
                
            } else {
                [WXWUIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSUpdatePhotoFailedMsg, nil)
                                              msgType:ERROR_TY
                                   belowNavigationBar:YES];
            }
            
            break;
        }
            
        case LOAD_CONNECTED_ALUMNUS_COUNT_TY:
        {
            if ([XMLParser parserResponseXml:result
                                        type:contentType
                                         MOC:_MOC
                           connectorDelegate:self
                                         url:url]) {
                
                _autoLoaded = YES;
                
                [_tableView beginUpdates];
                [_tableView reloadSections:[NSIndexSet indexSetWithIndex:ALUMNI_NETWORK_SEC]
                          withRowAnimation:UITableViewRowAnimationNone];
                [_tableView endUpdates];
            }
            break;
        }
            
        default:
            break;
    }
    
    [super connectDone:result url:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(WebItemType)contentType {
    
  NSString *msg = nil;
  switch (contentType) {
    case MODIFY_USER_ICON_TY:
    {
      msg = LocaleStringForKey(NSUpdatePhotoFailedMsg, nil);
      break;
    }
      
    case LOAD_CONNECTED_ALUMNUS_COUNT_TY:
    {
      
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

#pragma mark - ECPhotoPickerOverlayDelegate methods

- (void)applyPhotoSelectedStatus:(UIImage *)image {
    
	self.selectedPhoto = image;
    
    // upload new avatar
    self.connFacade = [[[WXWAsyncConnectorFacade alloc] initWithDelegate:self
                                                 interactionContentType:MODIFY_USER_ICON_TY] autorelease];
    
    [self.connFacade modifyUserIcon:self.selectedPhoto];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)saveImageIfNecessary:(UIImage *)image
                  sourceType:(UIImagePickerControllerSourceType)sourceType {
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        
		UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
	}
}

- (void)handleFinishPickImage:(UIImage *)image
                   sourceType:(UIImagePickerControllerSourceType)sourceType {
    UIImage *handledImage = [CommonUtils scaleAndRotateImage:image sourceType:sourceType];
	
    [self saveImageIfNecessary:handledImage sourceType:sourceType];
	
	[self applyPhotoSelectedStatus:handledImage];
}

- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo {
	
    [self handleFinishPickImage:image
                     sourceType:picker.sourceType];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

#pragma mark - ECPhotoPickerDelegate method
- (void)selectPhoto:(UIImage *)selectedImage {
    if (_photoSourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImageWriteToSavedPhotosAlbum(selectedImage, nil, nil, nil);
    }
    
    [self applyPhotoSelectedStatus:selectedImage];
}

#pragma mark - ECPhotoPickerOverlayDelegate
- (void)didTakePhoto:(UIImage *)photo {
    [self selectPhoto:photo];
}

- (void)didFinishWithCamera {
    self.photoPickerVC = nil;
}

- (void)adjustUIAfterUserBrowseAlbumInImagePicker {
    // user browse the album in image picker, so UI layout be set as full screen, then we should recovery
    // the layout corresponding
    [UIApplication sharedApplication].statusBarHidden = NO;
    self.navigationController.navigationBar.frame = CGRectOffset(self.navigationController.navigationBar.frame, 0.0f, 20.0f);
    self.view.frame = CGRectOffset(self.view.frame, 0.0f, 20.0f);
}

#pragma mark - ItemUploaderDelegate method
- (void)afterUploadFinishAction:(WebItemType)actionType {
    NSLog(@"afterUploadFinishAction");
}

#pragma mark - action sheet delegate method
- (void)actionSheet:(UIActionSheet *)as clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (HAS_CAMERA) {
        switch (buttonIndex) {
            case PHOTO_ACTION_SHEET_IDX:
                [self showImagePicker:UIImagePickerControllerSourceTypeCamera];
                break;
                
            case LIBRARY_ACTION_SHEET_IDX:
                [self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
                break;
                
            case CANCEL_PHOTO_SHEET_IDX:
                return;
                
            default:
                break;
        }
    } else {
        switch (buttonIndex) {
            case 0:
                [self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
                break;
                
            case 1:
                return;
                
            default:
                break;
        }
    }
}

#pragma mark - ECClickableElementDelegate methods
- (void)showBigPhoto:(NSString *)url {
    
    CGRect smallAvatarFrame = CGRectMake(MARGIN * 2 + PHOTO_MARGIN, MARGIN * 2 + PHOTO_MARGIN,
                                         USERDETAIL_PHOTO_WIDTH, USERDETAIL_PHOTO_HEIGHT);
    
    ECHandyAvatarBrowser *avatarBrowser = [[[ECHandyAvatarBrowser alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
                                                                                imgUrl:url
                                                                       imageStartFrame:smallAvatarFrame
                                                                imageDisplayerDelegate:self] autorelease];
    [self.view addSubview:avatarBrowser];
}

- (void)changeMenuAvatar
{
    // 更改home的照片
    [(VerticalMenuViewController *)[APP_DELEGATE foundationViewController] drawProfileCell];
}

@end
