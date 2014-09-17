//
//  BrandCell.h
//  iAlumniHD
//
//  Created by MobGuang on 12-8-20.
//
//

#import "BaseUITableViewCell.h"
#import "GlobalConstants.h"

@class WXWLabel;
@class Brand;

@interface BrandCell : BaseUITableViewCell {
  @private
  UIView *_avatarBackgroundView;
  UIImageView *_avatar;
  
  WXWLabel *_nameLabel;
  WXWLabel *_categoryLabel;
  WXWLabel *_companyType;
  WXWLabel *_couponInfoLabel;
  WXWLabel *_distanceLabel;
}

- (void)drawCell:(Brand *)brand;

@end
