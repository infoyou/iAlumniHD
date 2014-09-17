//
//  ServiceItemLikerAlbumView.h
//  iAlumniHD
//
//  Created by Mobguang on 12-3-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LikePeopleAlbumView.h"
#import <CoreData/CoreData.h>
#import "GlobalConstants.h"
#import "ImageDisplayerDelegate.h"
#import "ImageFetcherDelegate.h"
#import "ECClickableElementDelegate.h"

@class WXWLabel;

@interface ServiceItemLikerAlbumView : UIView <ImageFetcherDelegate> {
  UIActivityIndicatorView *_spinView;
  BOOL _clickable;
  
  NSInteger _displayedPeopleCount;
  
  UIImageView *_rightArrow;
  
  BOOL photoLoaded;
  
@private
  
  id<ImageDisplayerDelegate> _imageDisplayerDelegate;
  id<ECClickableElementDelegate> _clickableElementDelegate;
  
  NSMutableDictionary *_photoDic;
  
  WXWLabel *_noLikerNotifyLabel;
  
  NSMutableArray *_imageViewList;
  
  NSArray *_currentLikers;
  
  WXWLabel *_likeCountLabel;
}

@property (nonatomic, readonly, getter = isPhotoLoaded) BOOL photoLoaded;
@property (nonatomic, retain) UIActivityIndicatorView *spinView;
@property (nonatomic, assign) BOOL clickable;

- (void)hideRightArrow;
- (void)startSpinView;
- (void)stopSpinView;

- (id)initWithFrame:(CGRect)frame
imageDisplayerDelegate:(id<ImageDisplayerDelegate>)imageDisplayerDelegate 
clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate;

- (void)drawAlbum:(NSManagedObjectContext *)MOC 
hashedLikedItemId:(NSString *)hashedLikedItemId;

@end
