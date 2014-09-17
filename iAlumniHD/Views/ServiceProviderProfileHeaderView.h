//
//  ServiceProviderProfileHeaderView.h
//  iAlumniHD
//
//  Created by Mobguang on 11-12-23.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ItemProfileHeaderView.h"
#import <CoreData/CoreData.h>
#import "GlobalConstants.h"
#import "WXWConnectorDelegate.h"
#import "WXWConnectionTriggerHolderDelegate.h"
#import "ImageFetcherDelegate.h"
#import "ImageDisplayerDelegate.h"
#import "ECClickableElementDelegate.h"

@class ServiceProvider;
@class WXWLabel;
@class WXWGradientButton;

@interface ServiceProviderProfileHeaderView : UIView <ImageFetcherDelegate, WXWConnectorDelegate> {
  
  @private
  NSManagedObjectContext *_MOC;
  
  ServiceProvider *_sp;
  
  id<ECClickableElementDelegate> _clickableElementDelegate;
  id<ImageDisplayerDelegate> _imageDisplayerDelegate;
  
  UIView *_itemPicBackgroundView;
  UIButton *_itemPicButton;
  
  WXWLabel *_itemNameLabel;
  UIImageView *_gradeImageView;
  
  UIView *_buttonsBackgroundView;
  WXWGradientButton *_likesButton;
  WXWLabel *_likeCountLabel;
  UIView *_likesButtonBackgroundView;
  
  WXWGradientButton *_commentsButton;
  WXWLabel *_commentCountLabel;
  UIView *_comentsButtonBackgroundView;
  
  WXWGradientButton *_photoButton;
  WXWLabel *_photoCountLabel;
  UIView *_photoButtonBackgroundView;
  
  UIImage *_itemPhoto;
  
  UISegmentedControl *_actionGroupButtons;
  
  id<WXWConnectionTriggerHolderDelegate> _connectionTriggerHolderDelegate;
  
  // error message
  NSMutableDictionary *_errorMsgDic;
  
  // process spin view
  UIActivityIndicatorView *_spinView;
  
  BOOL _likersLoaded;
  
  NSString *_hashedLikedItemId;
}

@property (nonatomic, retain) ServiceProvider *sp;
@property (nonatomic, retain) UIImage *itemPhoto;

- (id)initWithFrame:(CGRect)frame
imageDisplayerDelegate:(id<ImageDisplayerDelegate>)imageDisplayerDelegate
clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate
connectionTriggerHolderDelegate:(id<WXWConnectionTriggerHolderDelegate>)connectionTriggerHolderDelegate
                MOC:(NSManagedObjectContext *)MOC
  hashedLikedItemId:(NSString *)hashedLikedItemId;

- (void)initProfileBaseInfo;

- (void)drawProfile:(ServiceProvider *)sp;

#pragma mark - update comment count/photo count
- (void)updateCommentCount;
- (void)updatePhotoCount;

#pragma mark - update like action button image 
- (void)updateLikeActionButtonImage;

@end
