//
//  PublicDiscussionGroupCell.h
//  iAlumniHD
//
//  Created by MobGuang on 13-1-28.
//
//

#import "WXWImageConsumerCell.h"

@class WXWLabel;
@class Club;

@interface PublicDiscussionGroupCell : WXWImageConsumerCell {
  @private
  UIView *_thumbnailBackgroundView;
  
  UIView *_contentBackgroundView;
  
  UIImageView *_thumbnial;
  
  WXWLabel *_groupNameLabel;
  WXWLabel *_authorLabel;
  WXWLabel *_contentLabel;
  WXWLabel *_dateTimeLabel;
}

#pragma mark - draw cell
- (void)drawCellWithGroup:(Club *)group index:(NSInteger)index;

@end
