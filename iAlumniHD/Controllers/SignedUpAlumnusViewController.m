//
//  SignedUpAlumnusViewController.m
//  iAlumniHD
//
//  Created by MobGuang on 12-9-8.
//
//

#import "SignedUpAlumnusViewController.h"
#import "AlumniProfileViewController.h"
#import "ChatListViewController.h"
#import "EventSignedUpAlumni.h"
#import "NearbyPeopleCell.h"
#import "AlumniFounder.h"
#import "Event.h"
#import "Member.h"
#import "Liker.h"

@interface SignedUpAlumnusViewController ()
@property (nonatomic, retain) Event *event;
@property (nonatomic, retain) Alumni *alumni;
@end

@implementation SignedUpAlumnusViewController

@synthesize event = _eventDetail;
@synthesize alumni = _alumni;

#pragma mark - load alumnus
- (void)setPredicate {
  self.entityName = @"EventSignedUpAlumni";
  
  self.descriptors = [NSMutableArray array];
  
  self.predicate = [NSPredicate predicateWithFormat:@"(eventId == %@)", self.event.eventId];
  NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"orderId"
                                                                  ascending:YES] autorelease];
  [self.descriptors addObject:sortDescriptor];
}

- (void)loadListData:(LoadTriggerType)triggerType
              forNew:(BOOL)forNew {
  
  [super loadListData:triggerType forNew:forNew];
  
  NSInteger startIndex = 0;
  if (!forNew) {
    startIndex = ++_currentStartIndex;
  }
  
  NSString *param = [NSString stringWithFormat:@"<event_id>%@</event_id><page>%d</page><page_size>%@</page_size><is_get_checkin>1</is_get_checkin>",
                     self.event.eventId, startIndex, ITEM_LOAD_COUNT];
  
  NSString *url = [CommonUtils geneUrl:param itemType:SIGNUP_USER_TY];
  
  WXWAsyncConnectorFacade *connFacade = [[[WXWAsyncConnectorFacade alloc] initWithDelegate:self interactionContentType:SIGNUP_USER_TY] autorelease];
  [self.connDic setObject:connFacade forKey:url];
  
  [connFacade asyncGet:url showAlertMsg:YES];
}

#pragma mark - lifecycle methods
- (id)initWithMOC:(NSManagedObjectContext *)MOC
      event:(Event *)event {
  
  self = [super initWithMOC:MOC showCloseButton:NO needRefreshHeaderView:YES needRefreshFooterView:YES];
  
  if (self) {
    self.event = event;
  }
  
  return self;
}

- (void)dealloc {
  
  self.event = nil;
  self.alumni = nil;
  
  [super dealloc];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  if (!_autoLoaded) {
    [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
  }
}

- (void)viewDidLoad {
  
  [super viewDidLoad];
}

- (void)viewDidUnload {
  
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
  
  [super didReceiveMemoryWarning];
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
    case SIGNUP_USER_TY:
      if ([XMLParser parserEventStuff:result
                             itemType:SIGNUP_USER_TY
                          event:self.event
                                  MOC:_MOC
                    connectorDelegate:self
                                  url:url]) {
        
        [self refreshTable];
      } else {
        [WXWUIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSFetchAlumniFailedMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
      }
      break;
      
    default:
      break;
  }
  
  [super connectDone:result url:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error url:(NSString *)url contentType:(WebItemType)contentType {
  
  NSString *msg = nil;
  
  switch (contentType) {
    case SIGNUP_USER_TY:
      msg = LocaleStringForKey(NSFetchAlumniFailedMsg, nil);
      break;
      
    default:
      break;
  }
  
  if ([self connectionMessageIsEmpty:error]) {
    self.connectionErrorMsg = msg;
  }
  
  [super connectFailed:error url:url contentType:contentType];
}

#pragma mark - UITableViewDelegate and UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.fetchedRC.fetchedObjects.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (indexPath.row == _fetchedRC.fetchedObjects.count) {
    return [self drawFooterCell];
  }
  
  static NSString *kCellIdentifier = @"kUserCell";
  NearbyPeopleCell *cell = (NearbyPeopleCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  if (nil == cell) {
    cell = [[[NearbyPeopleCell alloc] initWithStyle:UITableViewCellStyleDefault
                                    reuseIdentifier:kCellIdentifier
                             imageDisplayerDelegate:self
                             imageClickableDelegate:self
                                                MOC:_MOC] autorelease];
  }
  
  EventSignedUpAlumni *alumni = (EventSignedUpAlumni *)[_fetchedRC objectAtIndexPath:indexPath];
  
  [cell drawCell:alumni];
  cell.accessoryType = UITableViewCellAccessoryNone;
  
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return PEOPLE_CELL_HEIGHT;
}

- (void)showProfile:(NSString *)personId userType:(NSString *)userType
{
  
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if ([self currentCellIsFooter:indexPath]) {
    return;
  }
  
  EventSignedUpAlumni *alumni = (EventSignedUpAlumni *)[self.fetchedRC objectAtIndexPath:indexPath];
  
  [self showProfile:alumni.personId userType:alumni.userType];
  
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


@end
