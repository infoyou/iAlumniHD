//
//  PeopleWithChatCell.h
//  iAlumniHD
//
//  Created by MobGuang on 12-12-4.
//
//

#import "PeopleCell.h"
#import "GlobalConstants.h"

@class Alumni;

@interface PeopleWithChatCell : PeopleCell {
  @private
  
  UIImageView *_chatImgView;
  UIButton *_chatImgBut;

}

#pragma mark - draw cell
- (void)drawCell:(Alumni*)alumni;

@end
