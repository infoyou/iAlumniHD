//
//  ECHandyAvatarBrowser.h
//  iAlumniHD
//
//  Created by Mobguang on 11-12-14.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"
#import "ImageFetcherDelegate.h"
#import "ImageDisplayerDelegate.h"


@interface ECHandyAvatarBrowser : UIView <ImageFetcherDelegate> {
  @private
  id<ImageDisplayerDelegate> _imageDisplayerDelegate;
  
  UIImageView *_imageView;
  UIView *_canvasView;

  CGRect _imageStartFrame;

  BOOL _toBeRemoved;

}

- (id)initWithFrame:(CGRect)frame 
             imgUrl:(NSString *)imgUrl
    imageStartFrame:(CGRect)imageStartFrame
imageDisplayerDelegate:(id<ImageDisplayerDelegate>)imageDisplayerDelegate;

@end
