//
//  WXWGradientView.m
//  iAlumniHD
//
//  Created by Adam on 12-11-15.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "WXWGradientView.h"

@implementation WXWGradientView

- (void)drawWithTopColor:(UIColor *)topColor
             bottomColor:(UIColor *)bottomColor {
  
  CAGradientLayer *gradientLayer = (CAGradientLayer *)self.layer;
  gradientLayer.colors = [NSArray arrayWithObjects:(id)topColor.CGColor,
                          (id)bottomColor.CGColor,
                          nil];
  
  NSArray *location = [[NSArray alloc] initWithObjects:[NSNumber numberWithFloat:0.50f], [NSNumber numberWithFloat:1.0f], nil];
  gradientLayer.locations = location;
  RELEASE_OBJ(location);
}

- (id)initWithFrame:(CGRect)frame startColor:(UIColor *)startColor endColor:(UIColor *)endColor
{
    return [self initWithFrame:frame topColor:startColor bottomColor:endColor];
}

- (id)initWithFrame:(CGRect)frame topColor:(UIColor *)topColor bottomColor:(UIColor *)bottomColor
{
  self = [super initWithFrame:frame];
  if (self) {

    [self drawWithTopColor:topColor bottomColor:bottomColor];
    
    self.backgroundColor = TRANSPARENT_COLOR;
  }
  return self;
}

+ (Class)layerClass
{
	return [CAGradientLayer class];
}

@end
