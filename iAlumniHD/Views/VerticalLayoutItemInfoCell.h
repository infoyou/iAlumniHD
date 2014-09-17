//
//  VerticalLayoutItemInfoCell.h
//  iAlumniHD
//
//  Created by Mobguang on 12-3-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"
#import "BaseUITableViewCell.h"

@class WXWLabel;

@interface VerticalLayoutItemInfoCell : BaseUITableViewCell {
@private
  WXWLabel *_titleLabel;
  WXWLabel *_subTitleLabel;
  WXWLabel *_contentLabel;

  SeparatorType _separatorType;
  CGFloat _cellHeight;
}

- (void)drawNoShadowInfoCell:(NSString *)title 
                    subTitle:(NSString *)subTitle
                     content:(NSString *)content
                   clickable:(BOOL)clickable;

- (void)drawDashSeparatorNoShadowInfoCell:(NSString *)title
                                 subTitle:(NSString *)subTitle
                                  content:(NSString *)content
                                clickable:(BOOL)clickable
                               cellHeight:(CGFloat)cellHeight;

- (void)drawShadowInfoCell:(NSString *)title 
                  subTitle:(NSString *)subTitle
                   content:(NSString *)content
                cellHeight:(CGFloat)cellHeight
                 clickable:(BOOL)clickable;

- (void)drawShadowInfoCell:(NSString *)title 
                  subTitle:(NSString *)subTitle
                   content:(NSString *)content
  contentConstrainedHeight:(CGFloat)contentConstrainedHeight
                cellheight:(CGFloat)cellheight
             lineBreakMode:(UILineBreakMode)lineBreakMode
                 clickable:(BOOL)clickable;

@end
