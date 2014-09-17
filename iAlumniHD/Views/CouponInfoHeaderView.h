//
//  CouponInfoHeaderView.h
//  iAlumniHD
//
//  Created by Mobguang on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"
#import "ImageFetcherDelegate.h"
#import "ImageDisplayerDelegate.h"
#import "ECClickableElementDelegate.h"


@class CouponItem;
@class WXWLabel;
@class CouponImageView;

@interface CouponInfoHeaderView : UIView {
  @private
  CouponItem *_item;
  
  id<ECClickableElementDelegate> _clickableElementDelegate;
  
  CouponImageView *_imageView;
  WXWLabel *_nameLabel;
  WXWLabel *_validityTitleLabel;
  WXWLabel *_validityValueLabel;
}

- (id)initWithFrame:(CGRect)frame 
               item:(CouponItem *)item
imageDisplayerDelegate:(id<ImageDisplayerDelegate>)imageDisplayerDelegate 
clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate;

@end
