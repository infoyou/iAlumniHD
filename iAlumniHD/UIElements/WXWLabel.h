//
//  WXWLabel.h
//  iAlumniHD
//
//  Created by Adam on 12-11-8.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WXWLabel : UILabel {
  BOOL noShadow;
}

@property (nonatomic, readonly, getter = isNoShadow) BOOL noShadow;

- (id)initWithFrame:(CGRect)frame textColor:(UIColor *)textColor shadowColor:(UIColor *)shadowColor;

- (id)initWithFrame:(CGRect)frame
          textColor:(UIColor *)textColor
        shadowColor:(UIColor *)shadowColor
               font:(UIFont *)font;

- (id)initWithFrame:(CGRect)frame textColor:(UIColor *)textColor shadowColor:(UIColor *)shadowColor highlightedTextColor:(UIColor *)highlightedTextColor;

@end
