//
//  GroupListViewController.h
//  iAlumniHD
//
//  Created by MobGuang on 12-10-5.
//
//

#import "BaseListViewController.h"
#import "GlobalConstants.h"
#import "TapSwitchDelegate.h"

@class PlainTabView;

@interface GroupListViewController : BaseListViewController <TapSwitchDelegate> {
  @private
  
  PlainTabView *_tabSwitchView;
    ClubShowType _showType;
    
  NSInteger _myGroupFlag;
  
  NSInteger _startTabIndex;
  
  BOOL _needReloadGroups;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC;

- (id)initForAllGroupsWithMOC:(NSManagedObjectContext *)MOC;

@end
