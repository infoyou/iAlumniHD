//
//  CPShadowView.m
//  iAlumniHD
//
//  Created by Adam on 12-10-4.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "CPShadowView.h"

@implementation CPShadowView

- (id)init {
  self = [super init];
  if (self) {
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
	}
	return self;
}

- (void)dealloc {
  [super dealloc];
}

- (void)layoutSubviews {
	CGFloat coloredBoxMargin = 40;
  CGFloat coloredBoxHeight = self.frame.size.height;
  _coloredBoxRect = CGRectMake(coloredBoxMargin, 
                               0, 
                               40, 
                               coloredBoxHeight);
}

- (void)drawRect:(CGRect)rect {
  
	CGColorRef lightColor =  [UIColor colorWithRed:105.0f/255.0f green:179.0f/255.0f blue:216.0f/255.0f alpha:0.8].CGColor;
  
  CGColorRef shadowColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.4].CGColor;   
  
	CGContextRef context = UIGraphicsGetCurrentContext();
	// Draw shadow
  CGContextSaveGState(context);
  CGContextSetShadowWithColor(context, CGSizeMake(5, 0), 10, shadowColor);
	CGContextSetFillColorWithColor(context, lightColor);
  CGContextFillRect(context, _coloredBoxRect);
	CGContextRestoreGState(context);
}

@end
