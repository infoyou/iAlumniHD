//
//  CheckinResultHeaderView.h
//  iAlumniHD
//
//  Created by MobGuang on 12-8-28.
//
//

#import <UIKit/UIKit.h>
#import "ImageFetcherDelegate.h"
#import "GlobalConstants.h"
#import "ImageDisplayerDelegate.h"

@class WXWLabel;
@class Event;
@class RegisterationFeeView;

@interface CheckinResultHeaderView : UIView <ImageFetcherDelegate> {

  @private
  
  id<ImageDisplayerDelegate> _imageDisplayerDelegate;
  
  RegisterationFeeView *_resultBoardView;
  
  NSString *_backendMsg;
  
  UIView *_authorPicBackgroundView;
  UIImageView *_authorPic;
  
  WXWLabel *_nameLabel;
  WXWLabel *_classLabel;
  WXWLabel *_signUpStatusLabel;
  
  UIView *_resultBackgroundView;
  WXWLabel *_resultLabel;
}

- (id)initWithFrame:(CGRect)frame
imageDisplayerDelegate:(id<ImageDisplayerDelegate>)imageDisplayerDelegate
         backendMsg:(NSString *)backendMsg;

- (void)drawView:(CGFloat)resultBoardHeight event:(Event *)event;

@end
