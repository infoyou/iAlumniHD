//
//  TagListView.h
//  iAlumniHD
//
//  Created by Mobguang on 12-6-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "GlobalConstants.h"

@interface TagListView : UIView <UIScrollViewDelegate> {
  @private
  
  UIImageView *_icon;
  
  UIScrollView *_tagsContainerView;
  
  NSMutableDictionary *_tagAndLabelDic;
  
  CAGradientLayer *_maskLayer;
}

- (void)drawViews:(NSArray *)tags;

@end
