//
//  BrandBaseInfoView.h
//  iAlumniHD
//
//  Created by MobGuang on 12-8-21.
//
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"
#import "ECClickableElementDelegate.h"
#import "ImageFetcherDelegate.h"
#import "ImageDisplayerDelegate.h"

@class Brand;

@interface BrandBaseInfoView : UIView <ImageFetcherDelegate> {
  @private
  
  id<ImageDisplayerDelegate> _imageDisplayerDelegate;
  
  id<ECClickableElementDelegate> _clickableElementDelegate;
  
  UIButton *_itemPicButton;
  
  NSString *_avatarUrl;
}

- (id)initWithFrame:(CGRect)frame
              brand:(Brand *)brand
clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate
ImageDisplayerDelegate:(id<ImageDisplayerDelegate>)ImageDisplayerDelegate;

@end
