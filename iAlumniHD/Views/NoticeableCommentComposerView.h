//
//  NoticeableCommentComposerView.h
//  iAlumniHD
//
//  Created by Adam on 12-10-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WXWGradientView.h"
#import "GlobalConstants.h"
#import "ItemUploaderDelegate.h"
#import "ECClickableElementDelegate.h"

@class ECInnerShadowTextView;
@class WXWGradientButton;

@interface NoticeableCommentComposerView : WXWGradientView <UITextViewDelegate> {
  
  BOOL _expanded;  
  BOOL _showed;
  
  @private
  id<ItemUploaderDelegate> _itemUploaderDelegate;
  id<ECClickableElementDelegate> _clickableElementDelegate;
  
  WriteItemType _itemType;
  
  ECInnerShadowTextView *_textView;
  
  CGFloat _navigationBarHeight;
  
  UIButton *_photoButton;
  
  UIView *_photoButtonBackgroundView;
  
  WXWGradientButton *_sendButton;
  
  WXWGradientButton *_closeButton;
  
  UIColor *_topSeparatorLine;
  
  CGFloat _collapsed_y;
  
  NSString *_placeholder;
}

@property (nonatomic, assign) BOOL expanded;
@property (nonatomic, assign) BOOL showed;

- (id)initWithFrame:(CGRect)frame 
           topColor:(UIColor *)topColor
        bottomColor:(UIColor *)bottomColor
   topSeparatorLine:(UIColor *)topSeparatorLine
           itemType:(WriteItemType)itemType
itemUploaderDelegate:(id<ItemUploaderDelegate>)itemUploaderDelegate
clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate;

#pragma mark - compose status 
- (void)setSendButton:(BOOL)hasImage;

- (void)applySelectedPhoto:(UIImage *)photo;

@end
