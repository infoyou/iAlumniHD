//
//  RecommendedItemLikeAreaView.h
//  iAlumniHD
//
//  Created by Mobguang on 12-4-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"
#import "ECClickableElementDelegate.h"
#import "ImageDisplayerDelegate.h"
#import "WXWConnectionTriggerHolderDelegate.h"
#import "WXWConnectorDelegate.h"

@class ServiceItemLikerAlbumView;
@class WXWLabel;
@class RecommendedItem;

@interface RecommendedItemLikeAreaView : UIView <WXWConnectorDelegate> {
  
  ServiceItemLikerAlbumView *_likerAlbumView;
  UIActivityIndicatorView *_likeSpinView;
  UIButton *_likeButton;
  WXWLabel *_likeCountLabel;
  
  @private
  
  id<ECClickableElementDelegate> _clickableElementDelegate;
  id<ImageDisplayerDelegate> _imageDisplayerDelegate;
  id<WXWConnectionTriggerHolderDelegate> _connectionTriggerHolderDelegate;
  
  BOOL _connectionCancelled;
  
  CGFloat _likeAreaYCoordinate;
  RecommendedItem *_item;
  
  NSManagedObjectContext *_MOC;
  
  NSString *_hashedLikedItemId;
}

- (id)initWithFrame:(CGRect)frame 
                MOC:(NSManagedObjectContext *)MOC
               item:(RecommendedItem *)item
  hashedLikedItemId:(NSString *)hashedLikedItemId
imageDisplayerDelegate:(id<ImageDisplayerDelegate>)imageDisplayerDelegate
clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate
connectionTriggerHolderDelegate:(id<WXWConnectionTriggerHolderDelegate>)connectionTriggerHolderDelegate;

@end
