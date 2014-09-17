//
//  EventIntroCell.h
//  iAlumniHD
//
//  Created by MobGuang on 12-9-7.
//
//

#import "BaseUITableViewCell.h"
#import "GlobalConstants.h"

@class WXWLabel;

@interface EventIntroCell : BaseUITableViewCell {
  @private
  WXWLabel *_titleLabel;
  
  WXWLabel *_contentLabel;
  
  SeparatorType _separatorType;
  
  CGFloat _cellHeight;
}

- (void)drawCell:(NSString *)title
         content:(NSString *)content
       maxHeight:(CGFloat)maxHeight
   separatorType:(SeparatorType)separatorType;

@end
