//
//  GroupInfoCell.h
//  iAlumniHD
//
//  Created by MobGuang on 12-10-5.
//
//

#import "WXWTextBoardCell.h"
#import "GlobalConstants.h"

@class CoreTextView;
@class WXWLabel;
@class Club;

@interface GroupInfoCell : WXWTextBoardCell {
  @private
  WXWLabel *_groupNameLabel;
  CoreTextView *_postContentView;
  CoreTextView *_baseInfoView;
  
  WXWLabel *_dateTimeLabel;
  
  UIImageView *_badgeImageView;
  WXWLabel *_badgeNumLabel;
  
  Club *_club;
}

- (void)drawCell:(Club *)club;

@end
