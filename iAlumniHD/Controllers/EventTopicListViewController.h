//
//  EventTopicListViewController.h
//  iAlumniHD
//
//  Created by MobGuang on 12-9-10.
//
//

#import "BaseListViewController.h"

@class EventTopic;

@interface EventTopicListViewController : BaseListViewController {
  
  @private
  
  long long _eventId;
  
  EventTopic *_currentSelectedTopic;
  
  UIView *_bottomToolbar;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC eventId:(long long)eventId;

@end
