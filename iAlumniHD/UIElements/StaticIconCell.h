//
//  StaticIconCell.h
//  iAlumniHD
//
//  Created by MobGuang on 12-9-7.
//
//

#import "BaseUITableViewCell.h"
#import "GlobalConstants.h"

@class WXWLabel;

@interface StaticIconCell : BaseUITableViewCell {
  @private
  UIImageView *_icon;
  
  WXWLabel *_title;
  
  CGFloat _cellHeight;
  
  SeparatorType _separatorType;
}

- (void)drawCell:(NSString *)iconName
           title:(NSString *)title
   separatorType:(SeparatorType)separatorType
      cellHeight:(CGFloat)cellHeight;

@end
