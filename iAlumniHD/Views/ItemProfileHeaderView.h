//
//  ItemProfileHeaderView.h
//  iAlumniHD
//
//  Created by Mobguang on 11-12-6.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageFetcherDelegate.h"
#import "ImageDisplayerDelegate.h"
#import "ECClickableElementDelegate.h"

@class Member;
@class WXWLabel;
@class WXWGradientButton;

@interface ItemProfileHeaderView : UIView <ImageFetcherDelegate> {
  Member *_member;
  
  id<ECClickableElementDelegate> _clickableElementDelegate;
  id<ImageDisplayerDelegate> _imageDisplayerDelegate;
  
  UIView *_authorPicBackgroundView;
  UIButton *_authorPicButton;
  
  WXWLabel *_userNameLabel;
  WXWLabel *_countryLabel;
  WXWLabel *_bioLabel;
  
  UIView *_buttonsBackgroundView;
  WXWGradientButton *_pointButton;
  UIView *_pointButtonBackgroundView;
  WXWGradientButton *_feedsButton;
  UIView *_feedsButtonBackgroundView;
  WXWGradientButton *_commentsButton;
  UIView *_comentsButtonBackgroundView;
  WXWGradientButton *_favoriteButton;
  UIView *_favoriteButtonBackgroundView;
  
  UIImage *_userPhoto;
  
}

//@property (nonatomic, retain) Member *member;
@property (nonatomic, retain) UIImage *userPhoto;

- (id)initWithFrame:(CGRect)frame
imageDisplayerDelegate:(id<ImageDisplayerDelegate>)imageDisplayerDelegate
clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate;

- (void)initProfileBaseInfo;

- (void)drawProfile:(Member *)member;

- (void)updateButtonCounts;

@end
