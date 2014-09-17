//
//  CouponPriceCell.h
//  iAlumniHD
//
//  Created by Mobguang on 12-5-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseUITableViewCell.h"
#import "GlobalConstants.h"

@class CouponItem;
@class WXWLabel;

@interface CouponPriceCell : BaseUITableViewCell {
  @private
  
  WXWLabel *_priceInfoTitleLabel;
  WXWLabel *_priceInfoValueLabe;
  WXWLabel *_prpTitleLabel;
  WXWLabel *_prpValueLabel;
}

- (void)drawCell:(CouponItem *)couponItem;

@end
