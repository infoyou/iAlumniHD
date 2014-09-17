//
//  GroupMemberListViewController.m
//  iAlumniHD
//
//  Created by MobGuang on 12-12-6.
//
//

#import "GroupMemberListViewController.h"
#import "Alumni.h"
#import "Club.h"

@interface GroupMemberListViewController ()
@property (nonatomic, retain) Club *group;
@end

@implementation GroupMemberListViewController

#pragma mark - load data
- (void)loadListData:(LoadTriggerType)triggerType
             forNew:(BOOL)forNew {
  
  [super loadListData:triggerType forNew:forNew];
  
  _currentType = CLUB_MANAGE_USER_TY;
  
  NSInteger index = 0;
  if (!forNew) {
    index = ++_currentStartIndex;
  }
  
  NSString *param = [NSString stringWithFormat:@"<host_id>%@</host_id><host_type></host_type><host_type_value>%@</host_type_value><host_sub_type_value>%@</host_sub_type_value><host_name>%@</host_name><page>%d</page><page_size>100</page_size>", self.group.clubId, self.group.hostSupTypeValue, self.group.hostTypeValue, self.group.clubName, index];
  
  NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
  
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url contentType:_currentType];
  [connFacade asyncGet:url showAlertMsg:YES];
}

- (void)setPredicate {
  self.entityName = @"Alumni";
  
  self.descriptors = [NSMutableArray array];
  NSSortDescriptor *namePinyinDesc = [[[NSSortDescriptor alloc] initWithKey:@"firstNamePinyinChar"
                                                                  ascending:YES] autorelease];
  [self.descriptors addObject:namePinyinDesc];
  
  self.sectionNameKeyPath = @"firstNamePinyinChar";

  self.predicate = [NSPredicate predicateWithFormat:@"(groupId == %@)", self.group.clubId];
}


#pragma mark - lifecycle methods

- (void)clearData {
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(groupId == %@)", self.group.clubId];
  
  DELETE_OBJS_FROM_MOC(_MOC, @"Alumni", predicate);
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC group:(Club *)group {
  self = [super initWithMOC:MOC];
  if (self) {
    self.group = group;
    
    [self clearData];
  }
  return self;
}

- (void)dealloc {
   
  self.group = nil;
  
  [super dealloc];
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

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(WebItemType)contentType
{
  
  if ([XMLParser parseMemberForGroupId:self.group.clubId.longLongValue
                               xmlData:result
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {
    _autoLoaded = YES;
    
    [self refreshTable];
  } else {
    [WXWUIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSFetchAlumniFailedMsg, nil)
                                  msgType:ERROR_TY
                       belowNavigationBar:YES];
    
  }
  
  [super connectDone:result url:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(WebItemType)contentType {
  
  if ([self connectionMessageIsEmpty:error]) {
    self.connectionErrorMsg = LocaleStringForKey(NSFetchAlumnusFailedMsg, nil);
  }
  
  [super connectFailed:error
                   url:url
           contentType:contentType];
}

@end
