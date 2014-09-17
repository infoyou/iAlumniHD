//
//  MessageCell.h
//  iAlumniHD
//
//  Created by Adam on 12-11-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseUITableViewCell.h"
#import "GlobalConstants.h"

@class MessageButton;
@class WXWLabel;
@class Messages;

@interface MessageCell : BaseUITableViewCell {
  @private
  MessageButton *_awardButton;
  WXWLabel *_messageLabel;
}

- (void)drawCell:(Messages *)message target:(id)target action:(SEL)action;

@end
