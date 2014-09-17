//
//  PublicDiscussionGroupsViewController.h
//  iAlumniHD
//
//  Created by MobGuang on 13-1-28.
//
//

#import "BaseListViewController.h"

@interface PublicDiscussionGroupsViewController : BaseListViewController {
  @private
  id _parentVC;
  
  SEL _action;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
         parentVC:(id)parentVC
           action:(SEL)action
            frame:(CGRect)frame;

- (void)loadGroups;
@end
