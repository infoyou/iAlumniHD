//
//  NearbySearchBar.h
//  iAlumniHD
//
//  Created by Mobguang on 11-12-17.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "WXWGradientView.h"
#import "GlobalConstants.h"
#import "FilterListDelegate.h"

@class WXWLabel;
@class ECSearchBar;

@interface NearbySearchBar : WXWGradientView {
  @private
  WXWLabel *_searchResultLabel;
  UIToolbar *_searchToolbar;

  id<FilterListDelegate> _filterListDelegate;
  
}

@property (nonatomic, retain) WXWLabel *searchResultLabel;

- (id)initWithFrame:(CGRect)frame 
           topColor:(UIColor *)topColor 
        bottomColor:(UIColor *)bottomColor 
 filterListDelegate:(id<FilterListDelegate>)filterListDelegate;

- (void)needHideToolbar:(BOOL)hide;

@end
