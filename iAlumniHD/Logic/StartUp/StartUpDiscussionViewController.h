//
//  StartUpDiscussionViewController.h
//  iAlumniHD
//
//  Created by Adam on 13-3-11.
//
//

#import "BaseListViewController.h"
#import "GlobalConstants.h"
#import "ECClickableElementDelegate.h"
#import "EventCheckinDelegate.h"
#import "ItemUploaderDelegate.h"

@class Alumni;
@class QuickBackForCheckinView;
@class Event;

@interface StartUpDiscussionViewController : BaseListViewController  <ECClickableElementDelegate, EventCheckinDelegate, ItemUploaderDelegate, UIActionSheetDelegate> {
@private
  
  id<EventCheckinDelegate> _checkinResultDelegate;
  
  Event *_eventDetail;
  
  Alumni *_alumni;
  
  QuickBackForCheckinView *_quickBackView;
  BOOL _quickBackViewShowed;
  
  CheckinResultType _checkinResultType;
  
  //BOOL _waitingForAdminApprove;
  
  long long _eventId;
  
  UIViewController *_checkinEntrance;
  
  EventLiveActionType _listType;
  
  UIView *_tableContainer;
  
  // discussion post list
  BOOL _selectedFeedBeDeleted;
  BOOL _returnFromComposer;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
checkinResultDelegate:(id<EventCheckinDelegate>)checkinResultDelegate
            event:(Event *)event
checkinResultType:(CheckinResultType)checkinResultType
         entrance:(UIViewController *)entrance
         listType:(EventLiveActionType)listType;

@end
