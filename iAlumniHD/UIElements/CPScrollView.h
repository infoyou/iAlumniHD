//
//  CPScrollView.h
//  iAlumniHD
//
//  Created by Adam on 12-10-10.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXWGradientView.h"

@interface CPScrollView : UIScrollView {
  
@private
  UIColor *_startColor;
  UIColor *_endColor;
  
}

- (id)initWithFrame:(CGRect)frame startColor:(UIColor *)startColor endColor:(UIColor *)endColor;

@end
