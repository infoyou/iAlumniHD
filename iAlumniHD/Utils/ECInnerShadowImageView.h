//
//  ECInnerShadowImageView.h
//  iAlumniHD
//
//  Created by Mobguang on 12-7-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"

@interface ECInnerShadowImageView : UIView {
  
  UIImageView *_imageView;

@private
  
  CGPoint _centerPoint;
  
  CGFloat _radius;
}

@property (nonatomic, retain) UIImageView *imageView;

- (id)initCircleWithCenterPoint:(CGPoint)centerPoint radius:(CGFloat)radius;

@end
