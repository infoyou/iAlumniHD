//
//  WXWNumberBadge.m
//  wxwlib
//
//  Created by MobGuang on 13-1-23.
//  Copyright (c) 2013年 MobGuang. All rights reserved.
//

#import "WXWNumberBadge.h"
#import <QuartzCore/QuartzCore.h>
#import "WXWLabel.h"

@implementation WXWNumberBadge

#pragma mark - lifecycle methods

- (void)addShadow {
  UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:CGRectOffset(self.bounds, 1.0f, 1.0f)];
  
  self.layer.shadowColor = [UIColor darkGrayColor].CGColor;
  self.layer.shadowOpacity = 0.9f;
  self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
  self.layer.shadowRadius = 2.0f;
  self.layer.masksToBounds = NO;
  self.layer.shadowPath = shadowPath.CGPath;
}

- (id)initWithFrame:(CGRect)frame
           topColor:(UIColor *)topColor
        bottomColor:(UIColor *)bottomColor
               font:(UIFont *)font
{
  self = [super initWithFrame:frame
                     topColor:topColor
                  bottomColor:bottomColor];
  if (self) {
    
    self.layer.cornerRadius = 4.0f;

    _numberLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                          textColor:[UIColor whiteColor]
                                        shadowColor:TRANSPARENT_COLOR] autorelease];
    _numberLabel.font = font;
    _numberLabel.textAlignment = UITextAlignmentCenter;
    _numberLabel.numberOfLines = 1;
    [self addSubview:_numberLabel];
  }
  return self;
}

- (void)dealloc {
  
  [super dealloc];
}

#pragma mark - set title
- (void)setNumberWithTitle:(NSString *)title {
  _numberLabel.text = title;
  
  CGSize size = [_numberLabel.text sizeWithFont:_numberLabel.font
                              constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                  lineBreakMode:UILineBreakModeWordWrap];
  
  CGFloat width = size.width + 6;
  if (width < MARGIN * 4) {
    width = MARGIN * 4;
  }
  
  self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,
                          width, self.frame.size.height);
  
  _numberLabel.frame = CGRectMake((self.frame.size.width - size.width)/2.0f,
                                  (self.frame.size.height - size.height)/2.0f + 1.0f,
                                  size.width, size.height);
  
  [self addShadow];
}

@end
