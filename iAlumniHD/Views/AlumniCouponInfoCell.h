//
//  AlumniCouponInfoCell.h
//  iAlumniHD
//
//  Created by MobGuang on 12-8-22.
//
//

#import "BaseUITableViewCell.h"
#import "GlobalConstants.h"

@class WXWLabel;


@interface AlumniCouponInfoCell : BaseUITableViewCell {
  @private
  
  WXWLabel *_title;
}

- (void)drawCell:(NSString *)couponInfo;

@end
