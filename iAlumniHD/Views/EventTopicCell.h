//
//  EventTopicCell.h
//  iAlumniHD
//
//  Created by MobGuang on 12-9-10.
//
//

#import "BaseUITableViewCell.h"
#import "GlobalConstants.h"

@class WXWGradientView;
@class WXWLabel;
@class EventTopic;

@interface EventTopicCell : BaseUITableViewCell {
  
  @private
  WXWGradientView *_badgeBackgroundView;
  
  WXWLabel *_contentLabel;
  WXWLabel *_sequenceNumberLabel;
  WXWLabel *_statusLabel;
  WXWLabel *_votedLabel;
}

- (void)drawCell:(EventTopic *)topic;

@end
