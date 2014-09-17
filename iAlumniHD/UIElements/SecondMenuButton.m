//
//  SecondMenuButton.m
//  iAlumniHD
//
//  Created by Adam on 12-10-9.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "SecondMenuButton.h"
#import <QuartzCore/QuartzCore.h>
#import "WXWUIUtils.h"

@implementation SecondMenuButton

- (id)initWithTarget:(id)target action:(SEL)action title:(NSString *)title
{
  self = [super init];
  if (self) {
    self.frame = CGRectMake(0, 0, SECOND_MENU_BTN_WIDTH, SECOND_MENU_BTN_HEIGHT);
    
    [self addTarget:target 
             action:action 
   forControlEvents:UIControlEventTouchUpInside];
    
    [self setTitle:title forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setTitleShadowColor:[UIColor blackColor] 
                     forState:UIControlStateNormal];
    self.titleLabel.shadowOffset = CGSizeMake(0.0f, 0.8f);
    self.titleLabel.font = BOLD_FONT(18);
    
    self.backgroundColor = TRANSPARENT_COLOR;
    self.layer.masksToBounds = NO;
  }
  
  return self;
}

- (void)dealloc {
  
  [super dealloc];
}

- (void)drawRect:(CGRect)rect {

  CGContextRef context = UIGraphicsGetCurrentContext();
  
  if (self.selected) {
    self.layer.cornerRadius = 6.0f;
    self.layer.borderWidth = 1.0f;
    self.layer.masksToBounds = YES;
    
    CGRect outerRect = CGRectInset(self.bounds, 1.0f, 1.0f);            
    CGMutablePathRef outerPath = [WXWUIUtils createRoundedRectForRect:outerRect radius:0.0f];
    
    // Draw shadow
    if (self.state != UIControlStateHighlighted) {
      CGContextSaveGState(context);
      CGContextSetFillColorWithColor(context, DARK_GRAY_BTN_TOP_COLOR.CGColor);
      CGContextSetShadowWithColor(context, CGSizeMake(0, 2), 3.0, COLOR_ALPHA(51, 51, 52, 0.5).CGColor);
      CGContextAddPath(context, outerPath);
      CGContextFillPath(context);
      CGContextRestoreGState(context);
    }
    
    CGContextSaveGState(context);
    CGContextAddPath(context, outerPath);
    CGContextClip(context);
    [WXWUIUtils drawGlossAndGradient:context 
                             rect:outerRect
                       startColor:DARK_GRAY_BTN_TOP_COLOR.CGColor
                         endColor:DARK_GRAY_BTN_BOTTOM_COLOR.CGColor];
    
    CGContextRestoreGState(context);
    
    CFRelease(outerPath);
  } else {
    self.layer.cornerRadius = 0.0f;
    self.layer.borderWidth = 0.0f;
    self.layer.masksToBounds = NO;
     
    CGContextClearRect(context, self.bounds);
  }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  [super touchesEnded:touches withEvent:event];
  self.selected = YES;
}

@end
