//
//  NameCardListViewController.h
//  iAlumniHD
//
//  Created by MobGuang on 12-12-4.
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
