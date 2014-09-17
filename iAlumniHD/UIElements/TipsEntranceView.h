//
//  TipsEntranceView.h
//  iAlumniHD
//
//  Created by Mobguang on 12-3-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WXWGradientView.h"
#import "GlobalConstants.h"
#import "FilterListDelegate.h"

@class WXWLabel;

@interface TipsEntranceView : WXWGradientView {
@private
  id<FilterListDelegate> _filterListDelegate;
  
  WXWLabel *_tipsTitleLabel;
  
  WXWLabel *_firstTipsTitleLabel;
  
  UIToolbar *_tipsToolbar;
}

@property (nonatomic, retain) WXWLabel *firstTipsTitleLabel;
@property (nonatomic, retain) WXWLabel *tipsTitleLabel;

- (id)initWithFrame:(CGRect)frame 
           topColor:(UIColor *)topColor
        bottomColor:(UIColor *)bottomColor
 filterListDelegate:(id<FilterListDelegate>)filterListDelegate;

- (void)setTipsTitleLabelText:(NSString *)title;

@end
