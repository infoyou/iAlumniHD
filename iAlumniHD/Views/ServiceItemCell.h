//
//  ServiceItemCell.h
//  iAlumniHD
//
//  Created by Mobguang on 11-12-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "BaseUITableViewCell.h"
#import "GlobalConstants.h"

@class WXWLabel;
@class ServiceItem;

@interface ServiceItemCell : BaseUITableViewCell {
  @private
  
  UIImageView *_avatarView;
  
  WXWLabel *_nameLabel;
  WXWLabel *_addressLabel;
  UIImageView *_couponIndicator;
  WXWLabel *_categoryLabel;
  
  UIImageView *_likeIndicator;
  WXWLabel *_likeCountLabel;
  UIImageView *_commentIndicator;
  WXWLabel *_commentCountLabel;
  
  WXWLabel *_distanceLabel;
}

- (void)drawItem:(ServiceItem *)item index:(NSInteger)index;

@end
