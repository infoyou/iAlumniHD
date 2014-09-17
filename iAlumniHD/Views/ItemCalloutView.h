//
//  ItemCalloutView.h
//  iAlumniHD
//
//  Created by Mobguang on 11-12-21.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"

@class WXWLabel;
@class ServiceItem;

@interface ItemCalloutView : UIView {
 
@private
  ServiceItem *_item;
  
  UIButton *_button;
  WXWLabel *_nameLabel;
  UIImageView *_likeIndicator;
  WXWLabel *_likeCountLabel;
  UIImageView *_commentIndicator;
  WXWLabel *_commentCountLabel;
  WXWLabel *_categoryNameLabel;
  UIImageView *_couponIndicator;
   
  id _target;
  SEL _showDetailAction;
}

- (id)initWithFrame:(CGRect)frame
               item:(ServiceItem *)item 
         sequenceNO:(NSInteger)sequeneNO 
             target:(id)target 
   showDetailAction:(SEL)showDetailAction;
@end
