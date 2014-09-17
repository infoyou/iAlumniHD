//
//  CouponImageView.h
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

@interface CouponImageView : UIView <ImageFetcherDelegate> {
  @private
  id<ImageDisplayerDelegate> _imageDisplayerDelegate;
  id<ECClickableElementDelegate> _clickableElementDelegate;
  
  UIButton *_imageButton;
  UIImageView *_loadingImageView;
  
  NSString *_imageUrl;
}

- (id)initWithFrame:(CGRect)frame 
           imageUrl:(NSString *)imageUrl 
imageDisplayerDelegate:(id<ImageDisplayerDelegate>)imageDisplayerDelegate 
clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate;

@end
