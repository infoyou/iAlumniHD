//
//  ECInnerShadowTextView.h
//  iAlumniHD
//
//  Created by Adam on 12-10-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WXWTextView.h"
#import "GlobalConstants.h"

@interface ECInnerShadowTextView : WXWTextView {
  @private
  UIImageView *_addCommentImageView;
  
}

- (void)hideAddCommentIcon;

- (void)showAddCommentIcon;

@end
