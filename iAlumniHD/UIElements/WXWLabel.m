//
//  WXWLabel.m
//  iAlumniHD
//
//  Created by Adam on 12-11-8.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "WXWLabel.h"
#import "GlobalConstants.h"

@implementation WXWLabel

@synthesize noShadow;

- (id)initWithFrame:(CGRect)frame textColor:(UIColor *)textColor shadowColor:(UIColor *)shadowColor {
  self = [super initWithFrame:frame];
  if (self) {
    self.textColor = textColor;
    if (shadowColor == TRANSPARENT_COLOR) {
      noShadow = YES;
    } else {
      noShadow = NO;
    }
    self.shadowColor = shadowColor;
    self.shadowOffset = CGSizeMake(0.0f, 1.0f);
    self.highlightedTextColor = [UIColor whiteColor];
    self.backgroundColor = TRANSPARENT_COLOR;
  }
  return self;
}

- (id)initWithFrame:(CGRect)frame textColor:(UIColor *)textColor shadowColor:(UIColor *)shadowColor highlightedTextColor:(UIColor *)highlightedTextColor
{
    self = [super initWithFrame:frame];
    if (self) {
        self.textColor = textColor;
        if (shadowColor == TRANSPARENT_COLOR) {
            noShadow = YES;
        } else {
            noShadow = NO;
        }
        self.shadowColor = shadowColor;
        self.shadowOffset = CGSizeMake(0.0f, 1.0f);
        self.highlightedTextColor = highlightedTextColor;
        self.backgroundColor = TRANSPARENT_COLOR;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
          textColor:(UIColor *)textColor
        shadowColor:(UIColor *)shadowColor
               font:(UIFont *)font {
    
    self = [self initWithFrame:frame
                     textColor:textColor
                   shadowColor:shadowColor];
    if (self) {
        self.font = font;
    }
    
    return self;
}

- (void)dealloc {
  
  [super dealloc];
}

@end
