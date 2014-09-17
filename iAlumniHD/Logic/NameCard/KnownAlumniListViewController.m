//
//  KnownAlumniListViewController.m
//  iAlumniHD
//
//  Created by MobGuang on 12-12-6.
//
//

#import "KnownAlumniListViewController.h"
#import "KnownAlumni.h"
#import "AlumniProfileViewController.h"

@interface KnownAlumniListViewController ()

@end

@implementation KnownAlumniListViewController

#pragma mark - load data
- (void)loadListData:(LoadTriggerType)triggerType
             forNew:(BOOL)forNew {
  
  [super loadListData:triggerType forNew:forNew];
  
  _currentType = LOAD_KNOWN_ALUMNUS_TY;
  
  NSInteger startIndex = 0;
  if (!forNew) {
    startIndex = ++_currentStartIndex;
  }
  
  NSString *param = [NSString stringWithFormat:@"<page>%d</page><page_size>100</page_size>", startIndex];
  
  NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
  
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                           contentType:_currentType];
  [connFacade asyncGet:url showAlertMsg:YES];
}

- (void)setPredicate {
  self.entityName = @"KnownAlumni";
  
  self.descriptors = [NSMutableArray array];
  NSSortDescriptor *namePinyinDesc = [[[NSSortDescriptor alloc] initWithKey:@"firstNamePinyinChar"
                                                                  ascending:YES] autorelease];
  [self.descriptors addObject:namePinyinDesc];
  
  self.sectionNameKeyPath = @"firstNamePinyinChar";
}

#pragma mark - lifecycle methods
- (void)dealloc {
  
  [super dealloc];
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - override methods
- (void)showProfile:(Alumni *)alumni {
  AlumniProfileViewController *profileVC = [[[AlumniProfileViewController alloc] initHideLocationWithMOC:_MOC
                                                                                                  alumni:alumni
                                                                                                userType:ALUMNI_USER_TY] autorelease];
  profileVC.title = LocaleStringForKey(NSAlumniDetailTitle, nil);
  [self.navigationController pushViewController:profileVC animated:YES];
}


#pragma mark - WXWConnectorDelegate methods
- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(WebItemType)contentType
{
  if ([XMLParser parserResponseXml:result
                              type:contentType
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
