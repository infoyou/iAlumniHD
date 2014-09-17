//
//  LikePeopleAlbumView.h
//  iAlumniHD
//
//  Created by Adam on 12-11-2.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseUIView.h"
#import "ImageDisplayerDelegate.h"
#import "ImageFetcherDelegate.h"
#import "ECClickableElementDelegate.h"


@interface LikePeopleAlbumView : BaseUIView <ImageFetcherDelegate> {
  
  NSInteger _displayedPeopleCount;
  
  UIView *_topShadow;
  
  UIImageView *_rightArrow;
  
  BOOL photoLoaded;
  
@private
  
  id<ImageDisplayerDelegate> _imageDisplayerDelegate;
  id<ECClickableElementDelegate> _clickableElementDelegate;
  
  NSMutableDictionary *_photoDic;
  
}

@property (nonatomic, readonly, getter = isPhotoLoaded) BOOL photoLoaded;

- (id)initWithFrame:(CGRect)frame
imageDisplayerDelegate:(id<ImageDisplayerDelegate>)imageDisplayerDelegate 
clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate;

- (void)drawAlbum:(NSManagedObjectContext *)MOC;
@end
