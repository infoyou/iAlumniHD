//
//  WXWGradientView.h
//  iAlumniHD
//
//  Created by Adam on 12-11-15.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseUIView.h"

@interface WXWGradientView : BaseUIView {
  
}

- (id)initWithFrame:(CGRect)frame topColor:(UIColor *)topColor bottomColor:(UIColor *)bottomColor;

- (id)initWithFrame:(CGRect)frame startColor:(UIColor *)startColor endColor:(UIColor *)endColor;

- (void)drawWithTopColor:(UIColor *)topColor
             bottomColor:(UIColor *)bottomColor;
@end
