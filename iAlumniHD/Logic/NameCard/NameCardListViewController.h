//
//  NameCardListViewController.h
//  iAlumniHD
//
//  Created by Adam on 12-12-12.
//
//

#import "BaseListViewController.h"
#import "ECClickableElementDelegate.h"

@class ECStandardButton;

@interface NameCardListViewController : BaseListViewController <ECClickableElementDelegate> {
  @private
  ECStandardButton *_exchangeButton;
  
  BOOL _firstSearching;
  BOOL _secondSearching;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC;

@end
