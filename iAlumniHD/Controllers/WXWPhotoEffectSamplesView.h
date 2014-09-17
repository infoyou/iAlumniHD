//
//  WXWPhotoEffectSamplesView.h
//  iAlumniHD
//
//  Created by Adam on 12-10-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"

@interface WXWPhotoEffectSamplesView : UIView {
@private
  id _target;
  SEL _action;
  
  UIScrollView *_samplesContainer;
  
  NSMutableDictionary *_effectedPhotos;
  
  NSMutableArray *_buttons;
}

- (id)initWithFrame:(CGRect)frame
      originalImage:(UIImage *)originalImage 
             target:(id)target 
             action:(SEL)action;

@end
