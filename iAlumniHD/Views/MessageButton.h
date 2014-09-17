//
//  MessageButton.h
//  iAlumniHD
//
//  Created by Adam on 12-11-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WXWGradientButton.h"

@class Messages;

@interface MessageButton : WXWGradientButton {

  Messages *_message;
}

@property (nonatomic, retain) Messages *message;

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

@end
