//
//  HandyCommentComposerView.h
//  iAlumniHD
//
//  Created by Mobguang on 12-3-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"
#import "ECClickableElementDelegate.h"

@class WXWLabel;
@class News;
@class WXWGradientButton;
@class ECInnerShadowTextView;

@interface HandyCommentComposerView : UIView <UITextViewDelegate> {
  
  BOOL _enlarged;
  
  @private
  
  WXWLabel *_title;
  
  NSInteger _count;
  
  ECInnerShadowTextView *_commentTextView;
  
  WXWGradientButton *_sendButton;
  
  id<ECClickableElementDelegate> _clickableElementDelegate;
  
  WebItemType _contentType;

  NSString *_composerTitle;
}

@property (nonatomic, assign) BOOL enlarged;

- (id)initWithFrame:(CGRect)frame 
              count:(NSInteger)count
        contentType:(WebItemType)contentType
clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate;

- (void)adjustLayout:(BOOL)enlarge;
- (void)updateCommentCount:(NSInteger)count;

@end
