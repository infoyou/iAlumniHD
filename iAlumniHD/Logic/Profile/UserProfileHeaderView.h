//
//  UserProfileHeaderView.h
//  iAlumniHD
//
//  Created by MobGuang on 12-9-24.
//
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"
#import "ImageDisplayerDelegate.h"
#import "ImageFetcherDelegate.h"
#import "ECClickableElementDelegate.h"

@class WXWLabel;

@interface UserProfileHeaderView : UIView <ImageFetcherDelegate> {
  @private
  
  id<ImageDisplayerDelegate> _imageDisplayerDelegate;
  
  id<ECClickableElementDelegate> _clickableElementDelegate;
  
  UIButton *_avatarButton;
  UIButton *_changeAvatarButton;
  UIView *_avatarBackgroundView;
  
  WXWLabel *_nameLabel;
  WXWLabel *_classLabel;
}

- (id)initWithFrame:(CGRect)frame
imageDisplayerDelegate:(id<ImageDisplayerDelegate>)imageDisplayerDelegate
clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate;

#pragma mark - update avatar
- (void)updateAvatar:(UIImage *)avatar;

@end
