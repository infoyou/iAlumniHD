//
//  NameCardSearchViewController.h
//  iAlumniHD
//
//  Created by MobGuang on 12-11-23.
//
//

#import "BaseListViewController.h"
#import "ECClickableElementDelegate.h"

@class NameCardSearchToolView;

@interface NameCardSearchViewController : BaseListViewController <ECClickableElementDelegate, UISearchBarDelegate, UIActionSheetDelegate> {
  @private
  
  NameCardSearchToolView *_searchToolView;
  
  BOOL _searched;

}

- (id)initWithMOC:(NSManagedObjectContext *)MOC;

@end
