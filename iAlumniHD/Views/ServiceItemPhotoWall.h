//
//  ServiceItemPhotoWall.h
//  iAlumniHD
//
//  Created by Mobguang on 12-4-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"
#import "WXWConnectorDelegate.h"
#import "ImageDisplayerDelegate.h"
#import "ECClickableElementDelegate.h"
#import "WXWConnectionTriggerHolderDelegate.h"
#import "ImageFetcherDelegate.h"

@class ServiceItem;

@interface ServiceItemPhotoWall : UIView <WXWConnectorDelegate, ImageFetcherDelegate> {
  @private
  ServiceItem *_item;
  
  id<ImageDisplayerDelegate> _imageDisplayerDelegate;
  id<ECClickableElementDelegate> _clickableElementDelegate;
  id<WXWConnectionTriggerHolderDelegate> _connectionTriggerHolderDelegate;

  NSMutableDictionary *_errorMsgDic;
  
  UIActivityIndicatorView *_spinView;
  
  NSManagedObjectContext *_MOC;
  
  NSMutableDictionary *_photoDic;
  
  NSArray *_currentPhotos;
  
  CGRect _coloredBoxRect;
  
  BOOL _photoLoaded;
  
  NSString *_currentOldestImageUrl;
  
  BOOL _connectionCancelled;
}

- (id)initWithFrame:(CGRect)frame
                MOC:(NSManagedObjectContext *)MOC
               item:(ServiceItem *)item
imageDisplayerDelegate:(id<ImageDisplayerDelegate>)imageDisplayerDelegate 
clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate
connectionTriggerHolderDelegate:(id<WXWConnectionTriggerHolderDelegate>)connectionTriggerHolderDelegate;

- (void)appendPhoto;

- (void)addArrow;

@end
