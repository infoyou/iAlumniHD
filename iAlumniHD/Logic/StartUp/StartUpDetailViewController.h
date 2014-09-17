//
//  StartUpDetailViewController.h
//  iAlumniHD
//
//  Created by Adam on 13-1-25.
//
//

#import "BaseListViewController.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import "EventActionDelegate.h"
#import "GlobalConstants.h"
#import "WXApi.h"
#import "UPOMP_iPad.h"

@class Event;
@class StartUpDetailHeadView;
@class StartUpDetailActionView;
@class WXWImageButton;
@class WXWLabel;

@interface StartUpDetailViewController : BaseListViewController <UIActionSheetDelegate, EventActionDelegate, EKEventEditViewDelegate, MFMessageComposeViewControllerDelegate, WXApiDelegate, UPOMP_iPad_Delegate, UIAlertViewDelegate> {
  
@private
  Event *_event;
  
    CGFloat _actionButtonOriginalY;
    
  UIView *_sectionHeaderView;
  WXWImageButton *_eventActionButton;
  
  WXWLabel *_descTitleLabel;
  
  NSInteger _actionSheetOwnerType;
  
  EKEventStore *_eventStore;
  EKEvent *_dailyEvent;
  EKCalendar *_defaultCalendar;
  BOOL _needRefreshAfterBack;
  
  BOOL _needClearFakeClubInstance;
  
  StartUpDetailHeadView *_headView;
  
  BOOL _eventLoaded;
  StartUpDetailActionView *_bottomToolbar;
  
  UPOMP_iPad *_paymentView;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC event:(Event *)event;

@end

