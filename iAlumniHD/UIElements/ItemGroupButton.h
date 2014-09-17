//
//  ItemGroupButton.h
//  iAlumniHD
//
//  Created by Adam on 12-11-16.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "WXWGradientButton.h"
#import "GlobalConstants.h"
#import "ImageFetcherDelegate.h"
#import "ImageDisplayerDelegate.h"

@class ItemGroup;

@interface ItemGroupButton : UIButton <ImageFetcherDelegate> {

  ItemGroup *_itemGroup;
    
@private
  id<ImageDisplayerDelegate> _imageDisplayerDelegate;
  
  ButtonColorType _colorType;
  BOOL _hideBorder;
  
  NSString *_titleText;
}

@property (nonatomic, retain) ItemGroup *itemGroup;

- (id)initWithFrame:(CGRect)frame 
             target:(id)target
             action:(SEL)action 
          colorType:(ButtonColorType)colorType
              title:(NSString *)title 
         titleColor:(UIColor *)titleColor
   titleShadowColor:(UIColor *)titleShadowColor
          titleFont:(UIFont *)titleFont 
    imageEdgeInsert:(UIEdgeInsets)imageEdgeInsert
    titleEdgeInsert:(UIEdgeInsets)titleEdgeInsert
          itemGroup:(ItemGroup *)itemGroup
imageDisplayerDelegate:(id<ImageDisplayerDelegate>)imageDisplayerDelegate;

@end
