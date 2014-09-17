//
//  CPScrollView.m
//  iAlumniHD
//
//  Created by Adam on 12-10-10.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "CPScrollView.h"
#import "WXWUIUtils.h"

@interface CPScrollView()
@property (nonatomic, retain) UIColor *startColor;
@property (nonatomic, retain) UIColor *endColor;
@end

@implementation CPScrollView

@synthesize startColor = _startColor;
@synthesize endColor = _endColor;

- (id)initWithFrame:(CGRect)frame startColor:(UIColor *)startColor endColor:(UIColor *)endColor
{
  self = [super initWithFrame:frame];
  if (self) {
    self.startColor = startColor;
    self.endColor = endColor;
  }
  return self;
}

- (void)drawRect:(CGRect)rect
{
  CGContextRef context = UIGraphicsGetCurrentContext();
  [WXWUIUtils drawGlossAndGradient:context 
                           rect:rect 
                     startColor:self.startColor.CGColor
                       endColor:self.endColor.CGColor];
}

- (void)dealloc {
  
  self.startColor = nil;
  self.endColor = nil;
  
  [super dealloc];
}

@end
