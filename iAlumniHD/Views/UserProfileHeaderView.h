//
//  UserProfileHeaderView.h
//  iAlumni
//
//  Created by MobGuang on 12-9-24.
//
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"
#import "ImageDisplayerDelegate.h"
#import "ImageFetcherDelegate.h"
#import "ECClickableElementDelegate.h"

@class ECLabel;

@interface UserProfileHeaderView : UIView <ImageFetcherDelegate> {
  @private
  
  id<ImageDisplayerDelegate> _imageDisplayerDelegate;
  
  id<ECClickableElementDelegate> _clickableElementDelegate;
  
  id _target;
  SEL _action;
  
  UIButton *_avatarButton;
  UIButton *_changeAvatarButton;
  UIView *_avatarBackgroundView;
  
  ECLabel *_nameLabel;
  ECLabel *_classLabel;
}

- (id)initWithFrame:(CGRect)frame
imageDisplayerDelegate:(id<ImageDisplayerDelegate>)imageDisplayerDelegate
clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate
             target:(id)target
             action:(SEL)action;

#pragma mark - update avatar
- (void)updateAvatar:(UIImage *)avatar;

@end
