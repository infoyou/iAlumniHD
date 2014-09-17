//
//  AlumniCouponTitleCell.h
//  iAlumniHD
//
//  Created by MobGuang on 12-8-22.
//
//

#import "BaseUITableViewCell.h"
#import "GlobalConstants.h"

@class WXWLabel;

@interface AlumniCouponTitleCell : BaseUITableViewCell {
  @private
  
  WXWLabel *_title;
  
  WXWLabel *_subTitleLabel;
}

- (void)drawCell:(NSString *)text
        subTitle:(NSString *)subTitle
            font:(UIFont *)font
       textColor:(UIColor *)textColor
   textAlignment:(UITextAlignment)textAlignment
      cellHeight:(CGFloat)cellHeight
showBottomShadow:(BOOL)showBottomShadow;

@end
