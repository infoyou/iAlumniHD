//
//  ServiceItemHeaderView.h
//  iAlumniHD
//
//  Created by Mobguang on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "GlobalConstants.h"
#import "WXWConnectorDelegate.h"
#import "ECClickableElementDelegate.h"
#import "ImageDisplayerDelegate.h"
#import "ImageFetcherDelegate.h"
#import "WXWConnectionTriggerHolderDelegate.h"

@class ServiceItem;
@class WXWLabel;
@class WXWGradientButton;
@class ServiceItemLikerAlbumView;
@class ServiceItemAlbumView;
@class ItemTitleAvatarView;
@class ServiceItemCheckinAlbumView;

@interface ServiceItemHeaderView : UIView <ImageFetcherDelegate, WXWConnectorDelegate> {
  @private
  NSManagedObjectContext *_MOC;
  
  ServiceItem *_item;
  
  id<ECClickableElementDelegate> _clickableElementDelegate;
  id<ImageDisplayerDelegate> _imageDisplayerDelegate;
  id<WXWConnectionTriggerHolderDelegate> _connectionTriggerHolderDelegate;
  
  ItemTitleAvatarView *_titleAvatarView;
  CGFloat _titleAvatarViewHeight;
  
  UIView *_itemPicBackgroundView;
  UIButton *_itemPicButton;
    
  WXWLabel *_priceTitleLabel;
  WXWLabel *_priceValueLabel;
  
  WXWLabel *_tagsTitleLabel;
  WXWLabel *_tagsValueLabel;
  
  UIButton *_likeButton;
  WXWLabel *_likeCountLabel;
  
  UIButton *_checkinButton;
  
  CGFloat _likeAreaYCoordinate;
  
  UIActivityIndicatorView *_likeSpinView;
  UIActivityIndicatorView *_favoriteSpinView;  
  
  ServiceItemLikerAlbumView *_likerAlbumView;
  
  ServiceItemCheckinAlbumView *_checkinAlbumView;
  
  ServiceItemAlbumView *_itemAlbumView;
  
  UIImage *_itemPhoto;
  
  WXWLabel *_sourceLabel;
  
  // error message
  NSMutableDictionary *_errorMsgDic;

  BOOL _originalNoPhoto;
  
  BOOL _connectionCancelled;
  
  NSString *_hashedServiceItemId;
}

@property (nonatomic, retain) UIView *itemPicBackgroundView;

- (id)initWithFrame:(CGRect)frame 
               item:(ServiceItem *)item
hashedServiceItemId:(NSString *)hashedServiceItemId
                MOC:(NSManagedObjectContext *)MOC 
imageDisplayerDelegate:(id<ImageDisplayerDelegate>)imageDisplayerDelegate
clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate
connectionTriggerHolderDelegate:(id<WXWConnectionTriggerHolderDelegate>)connectionTriggerHolderDelegate;

#pragma mark - album frame convertion
- (CGRect)convertedAddPhotoButtonRect;

#pragma mark - update photo wall after user add photo
- (void)updatePhotoWall;

#pragma mark - adjust scroll speed
- (void)adjustScrollSpeedWithOffset:(CGPoint)offset;
@end
