//
//  ECHandyImageBrowser.h
//  iAlumniHD
//
//  Created by Adam on 12-11-28.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageFetcherDelegate.h"


@interface ECHandyImageBrowser : UIView <ImageFetcherDelegate> {
@private
  NSString *_imageUrl;
  
  UIImageView *_imageView;
  UIView *_canvasView;
}

- (id)initWithFrame:(CGRect)frame
             imgUrl:(NSString *)imgUrl;

@end
