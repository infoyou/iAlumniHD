//
//  SignedUpAlumnusViewController.h
//  iAlumniHD
//
//  Created by MobGuang on 12-9-8.
//
//

#import "BaseListViewController.h"
#import "ECClickableElementDelegate.h"

@class Event;
@class Alumni;

@interface SignedUpAlumnusViewController : BaseListViewController <ECClickableElementDelegate, UIActionSheetDelegate> {
    
  @private
  Event *_eventDetail;
  
  Alumni *_alumni;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
      event:(Event *)event;

@end
