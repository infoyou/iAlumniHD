//
//  WXWNumberBadge.h
//  wxwlib
//
//  Created by MobGuang on 13-1-23.
//  Copyright (c) 2013年 MobGuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXWGradientView.h"

@class WXWLabel;

@interface WXWNumberBadge : WXWGradientView {
  @private
  WXWLabel *_numberLabel;
}

- (id)initWithFrame:(CGRect)frame
           topColor:(UIColor *)topColor
        bottomColor:(UIColor *)bottomColor
               font:(UIFont *)font;

#pragma mark - set title
- (void)setNumberWithTitle:(NSString *)title;

@end
