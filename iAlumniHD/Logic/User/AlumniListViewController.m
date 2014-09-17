//
//  AlumniListViewController.m
//  iAlumniHD
//
//  Created by MobGuang on 12-11-22.
//
//

#import "AlumniListViewController.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "WXWAsyncConnectorFacade.h"
#import "Alumni.h"
#import "PeopleWithChatCell.h"
#import "AppManager.h"
#import "ListSectionView.h"
#import "WXWUIUtils.h"
#import "AlumniProfileViewController.h"
#import "ChatListViewController.h"

#define NAME_LIMITED_WIDTH    144.0f

#define PHOTO_MARGIN          3.0f
#define PHOTO_WIDTH           56.0f

#define SECTION_VIEW_HEIGHT   16.0f

@interface AlumniListViewController ()
@property (nonatomic, retain) Alumni *alumni;
@end

@implementation AlumniListViewController

#pragma mark - load data
- (void)loadListData:(LoadTriggerType)triggerType
              forNew:(BOOL)forNew {
  [super loadListData:triggerType forNew:forNew];
  
  // implemented by sub class
}

- (void)setPredicate {
  self.entityName = @"Alumni";
  
  self.descriptors = [NSMutableArray array];
  NSSortDescriptor *namePinyinDesc = [[[NSSortDescriptor alloc] initWithKey:@"firstNamePinyinChar"
                                                                  ascending:YES] autorelease];
  [self.descriptors addObject:namePinyinDesc];
  
  self.sectionNameKeyPath = @"firstNamePinyinChar";
}

#pragma mark - lifecycle methods
- (id)initWithMOC:(NSManagedObjectContext *)MOC
{
  self = [super initWithMOC:MOC
                     holder:nil
           backToHomeAction:nil
      needRefreshHeaderView:NO
      needRefreshFooterView:YES
                 needGoHome:NO];
  if (self) {
    
    _needSectionIndexTitles = NO;
  }
  return self;
}

- (id)initResettedWithMOC:(NSManagedObjectContext *)MOC {
  self = [self initWithMOC:MOC];
  if (self) {
    DELETE_OBJS_FROM_MOC(_MOC, @"Alumni", nil);
  }
  return self;
}

- (void)dealloc {
  
  [super dealloc];
}

- (void)viewDidLoad {
  [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  if (!_autoLoaded) {
    [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
  }
}

- (void)viewDidUnload {
  [super viewDidUnload];
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

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(WebItemType)contentType
{
  [WXWUIUtils closeActivityView];
  
  switch (contentType) {
      
    case CLUB_MANAGE_USER_TY://LOAD_FAVORITE_ALUMNI_TY:
    {
      if ([XMLParser parserSyncResponseXml:result type:FETCH_EVENT_ALUMNI_SRC MOC:_MOC]) {
        _autoLoaded = YES;
        
        [self refreshTable];
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
  
  [super connectDone:result url:url contentType:contentType];
}

- (void)connectCancelled:(NSString *)url
             contentType:(WebItemType)contentType {
  [super connectCancelled:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(WebItemType)contentType {
  
  if (contentType == CLUB_MANAGE_USER_TY/*LOAD_FAVORITE_ALUMNI_TY*/) {
    if ([self connectionMessageIsEmpty:error]) {
      self.connectionErrorMsg = LocaleStringForKey(NSFetchAlumnusFailedMsg, nil);
    }
    
  }
  
  [super connectFailed:error
                   url:url
           contentType:contentType];
}

#pragma mark - user actions

- (void)showProfileWithLocation:(BOOL)needLocation {
  
  if (needLocation) {
    
  } else {
    
  }
  
}

- (void)showProfile:(Alumni *)alumni {
  
  AlumniProfileViewController *profileVC = [[[AlumniProfileViewController alloc] initWithMOC:_MOC
                                                                                      alumni:alumni
                                                                                    userType:ALUMNI_USER_TY] autorelease];
  profileVC.title = LocaleStringForKey(NSAlumniDetailTitle, nil);
  [self.navigationController pushViewController:profileVC animated:YES];
}

- (void)beginChat {
  
  [CommonUtils doDelete:_MOC entityName:@"Chat"];
  ChatListViewController *chartVC = [[ChatListViewController alloc] initWithMOC:_MOC
                                                                         alumni:(AlumniDetail*)self.alumni];
  [self.navigationController pushViewController:chartVC animated:YES];
  RELEASE_OBJ(chartVC);
}


#pragma mark - UITableViewDelegate and UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  NSLog(@"count: %d", self.fetchedRC.sections.count);
  
  return self.fetchedRC.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedRC.sections objectAtIndex:section];
  
  if (section == self.fetchedRC.sections.count - 1) {
    return sectionInfo.numberOfObjects + 1;
  } else {
    return sectionInfo.numberOfObjects;
  }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
  
  if (_needSectionIndexTitles) {
    return self.fetchedRC.sectionIndexTitles;
  } else {
    return nil;
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return SECTION_VIEW_HEIGHT;
}

- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section {
  
  id <NSFetchedResultsSectionInfo> sectionInfo = [_fetchedRC sections][section];
  
  NSArray *alumniList = [sectionInfo objects];
  NSString *firstChar = nil;
  if (alumniList.count > 0) {
    Alumni *alumni = (Alumni *)alumniList.lastObject;
    firstChar = alumni.firstNamePinyinChar;
  }
  
  return [[[ListSectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, SECTION_VIEW_HEIGHT)
                                           title:firstChar] autorelease];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if ([self currentCellIsFooter:indexPath]) {
    return [self drawFooterCell];
  }
  
  static NSString *kCellIdentifier = @"kUserCell";
  PeopleWithChatCell *cell = (PeopleWithChatCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  if (nil == cell) {
    cell = [[[PeopleWithChatCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:kCellIdentifier
                               imageDisplayerDelegate:self
                               imageClickableDelegate:self
                                                  MOC:_MOC] autorelease];
  }
  
  Alumni *alumni = (Alumni *)[self.fetchedRC objectAtIndexPath:indexPath];
  
  [cell drawCell:alumni];
  
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if ([self currentCellIsFooter:indexPath]) {
    return PEOPLE_CELL_HEIGHT;
  }
  
  Alumni *alumni = (Alumni *)[self.fetchedRC objectAtIndexPath:indexPath];
  
  CGSize constraint = CGSizeMake(NAME_LIMITED_WIDTH, 20);
  CGSize size = [alumni.name sizeWithFont:Arial_FONT(14)
                        constrainedToSize:constraint
                            lineBreakMode:UILineBreakModeTailTruncation];
  
  CGFloat height = MARGIN + size.height + MARGIN;
  
  size = [alumni.companyName sizeWithFont:FONT(13)
                        constrainedToSize:CGSizeMake(280 - MARGIN -
                                                     (MARGIN + PHOTO_WIDTH + PHOTO_MARGIN * 2 +
                                                      MARGIN * 2),
                                                     CGFLOAT_MAX)
                            lineBreakMode:UILineBreakModeWordWrap];
  
  height += size.height + MARGIN;
  
  if (height < PEOPLE_CELL_HEIGHT) {
    height = PEOPLE_CELL_HEIGHT;
  }
  
  return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if ([self currentCellIsFooter:indexPath]) {
    return;
  }
  
  [super tableView:tableView didSelectRowAtIndexPath:indexPath];
  
  Alumni *alumni = (Alumni *)[self.fetchedRC objectAtIndexPath:indexPath];
  
  //[self showProfile:alumni.personId userType:[NSString stringWithFormat:@"%@", alumni.userType]];
  [self showProfile:alumni];
  
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
  [as showInView:self.navigationController.view];
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
      //[self showProfile:self.alumni.personId userType:self.alumni.userType];
      [self showProfile:self.alumni];
			return;
			
    case CANCEL_SHEET_IDX:
      return;
      
		default:
			break;
	}
}

@end
