//
//  WXWGradientButton.h
//  iAlumniHD
//
//  Created by Adam on 12-11-8.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"

@interface WXWGradientButton : UIButton {
@private
  ButtonColorType _colorType;
  BOOL _hideBorder;
}

- (id)initWithFrame:(CGRect)frame
             target:(id)target
             action:(SEL)action
          colorType:(ButtonColorType)colorType 
              title:(NSString *)title 
              image:(UIImage *)image 
         titleColor:(UIColor *)titleColor
   titleShadowColor:(UIColor *)titleShadowColor
          titleFont:(UIFont *)titleFont 
        roundedType:(ButtonRoundedType)roundedType
    imageEdgeInsert:(UIEdgeInsets)imageEdgeInsert 
    titleEdgeInsert:(UIEdgeInsets)titleEdgeInsert;

- (id)initWithFrame:(CGRect)frame
             target:(id)target
             action:(SEL)action
          colorType:(ButtonColorType)colorType 
              title:(NSString *)title 
              image:(UIImage *)image 
         titleColor:(UIColor *)titleColor
   titleShadowColor:(UIColor *)titleShadowColor
          titleFont:(UIFont *)titleFont 
        roundedType:(ButtonRoundedType)roundedType
    imageEdgeInsert:(UIEdgeInsets)imageEdgeInsert 
    titleEdgeInsert:(UIEdgeInsets)titleEdgeInsert
         hideBorder:(BOOL)hideBorder;

#pragma mark - change color type 
- (void)changeToColor:(ButtonColorType)coloType;


@end
