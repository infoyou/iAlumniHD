//
//  BizPostListViewController.h
//  iAlumniHD
//
//  Created by Adam on 12-12-14.
//
//

#import "BaseListViewController.h"
#import "GlobalConstants.h"
#import "ECClickableElementDelegate.h"
#import "ItemUploaderDelegate.h"

@class Club;

@interface BizPostListViewController : BaseListViewController <ECClickableElementDelegate, ItemUploaderDelegate> {
  @private
  BOOL _autoLoadAfterSent;
  
  CGFloat _currentContentOffset_y;
  
  BOOL _returnFromComposer;
  
  BOOL _selectedFeedBeDeleted;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC group:(Club *)group;

@end
