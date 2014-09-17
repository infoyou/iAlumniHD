//
//  UserProfileHeaderView.m
//  iAlumni
//
//  Created by MobGuang on 12-9-24.
//
//

#import "UserProfileHeaderView.h"
#import <QuartzCore/QuartzCore.h>
#import "AppManager.h"
#import "ImageCache.h"
#import "CommonUtils.h"
#import "ECLabel.h"
#import "UIImageButton.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "ECPlainButton.h"

#define PHOTO_MARGIN        3.0f

#define CAMERA_SIDE_LENGTH  24.0f

#define BUTTON_WIDTH        100.0f
#define BUTTON_HEIGHT       30.0f

@implementation UserProfileHeaderView

#pragma mark - show big picture
- (void)showBigPicture:(id)sender {
  
  if (_clickableElementDelegate && [AppManager instance].userImgUrl) {
    [_clickableElementDelegate showBigPhoto:[AppManager instance].userImgUrl];
  }
}

#pragma mark - lifecycle methods
- (void)initViews {
  _avatarBackgroundView = [[[UIView alloc] initWithFrame:CGRectMake(MARGIN * 6,
                                                                    MARGIN * 2,
                                                                    USERDETAIL_PHOTO_WIDTH + PHOTO_MARGIN * 2,
                                                                    USERDETAIL_PHOTO_HEIGHT + PHOTO_MARGIN * 2)] autorelease];
  _avatarBackgroundView.backgroundColor = [UIColor whiteColor];
  UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(1, 1,
                                                                         _avatarBackgroundView.frame.size.width - 2,
                                                                         _avatarBackgroundView.frame.size.height - 1)];
  _avatarBackgroundView.layer.shadowPath = shadowPath.CGPath;
  _avatarBackgroundView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
  _avatarBackgroundView.layer.shadowOpacity = 0.9f;
  _avatarBackgroundView.layer.shadowRadius = 1.0f;
  _avatarBackgroundView.layer.shadowOffset = CGSizeMake(0, 0);
  _avatarBackgroundView.layer.masksToBounds = NO;
  [self addSubview:_avatarBackgroundView];
  
  _avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
  _avatarButton.backgroundColor = [UIColor whiteColor];
  _avatarButton.frame = CGRectMake(PHOTO_MARGIN,
                                   PHOTO_MARGIN,
                                   USERDETAIL_PHOTO_WIDTH,
                                   USERDETAIL_PHOTO_HEIGHT);
  [_avatarButton addTarget:self action:@selector(showBigPicture:) forControlEvents:UIControlEventTouchUpInside];
  [_avatarBackgroundView addSubview:_avatarButton];
  
  _nameLabel = [[[ECLabel alloc] initWithFrame:CGRectZero
                                     textColor:DARK_TEXT_COLOR
                                   shadowColor:[UIColor whiteColor]] autorelease];
  _nameLabel.font = BOLD_FONT(18);
  _nameLabel.text = [AppManager instance].username;
  CGSize size = [_nameLabel.text sizeWithFont:_nameLabel.font
                            constrainedToSize:CGSizeMake(self.frame.size.width - MARGIN * 6 - USERDETAIL_PHOTO_WIDTH, CGFLOAT_MAX)
                                lineBreakMode:UILineBreakModeWordWrap];
  _nameLabel.frame = CGRectMake(_avatarBackgroundView.frame.origin.x +
                                _avatarBackgroundView.frame.size.width + MARGIN * 2,
                                MARGIN * 2, size.width, size.height);
  [self addSubview:_nameLabel];
  
  _classLabel = [[[ECLabel alloc] initWithFrame:CGRectZero
                                      textColor:BASE_INFO_COLOR
                                    shadowColor:[UIColor whiteColor]] autorelease];
  _classLabel.font = BOLD_FONT(13);
  _classLabel.text = [AppManager instance].className;
  size = [_classLabel.text sizeWithFont:_classLabel.font
                      constrainedToSize:CGSizeMake(self.frame.size.width - MARGIN * 6 - USERDETAIL_PHOTO_WIDTH, CGFLOAT_MAX)
                          lineBreakMode:UILineBreakModeWordWrap];
  _classLabel.frame = CGRectMake(_nameLabel.frame.origin.x,
                                 _nameLabel.frame.origin.y + _nameLabel.frame.size.height + MARGIN,
                                 size.width, size.height);
  [self addSubview:_classLabel];
  
  _changeAvatarButton = [[[ECPlainButton alloc] initPlainButtonWithFrame:CGRectMake(_avatarBackgroundView.frame.origin.x + _avatarBackgroundView.frame.size.width + MARGIN * 2, _avatarBackgroundView.frame.origin.y + _avatarBackgroundView.frame.size.height - BUTTON_HEIGHT, BUTTON_WIDTH, BUTTON_HEIGHT)
                                                                  target:_target
                                                                  action:_action
                                                                   title:LocaleStringForKey(NSProfileModifyImgTitle, nil)
                                                                   image:nil
                                                                     hue:83.0f
                                                              saturation:74.0f
                                                              brightness:71.0f
                                                             borderColor:COLOR(98, 159, 21)
                                                               titleFont:BOLD_FONT(13)
                                                              titleColor:[UIColor whiteColor]
                                                        titleShadowColor:[UIColor clearColor]
                                                             roundedType:HAS_ROUNDED
                                                         imageEdgeInsert:ZERO_EDGE
                                                         titleEdgeInsert:ZERO_EDGE] autorelease];
  [self addSubview:_changeAvatarButton];
}

- (id)initWithFrame:(CGRect)frame
imageDisplayerDelegate:(id<ImageDisplayerDelegate>)imageDisplayerDelegate
clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate
             target:(id)target
             action:(SEL)action {
  self = [super initWithFrame:frame];
  if (self) {
    
    _target = target;
    
    _action = action;
    
    self.backgroundColor = CELL_COLOR;
    
    _imageDisplayerDelegate = imageDisplayerDelegate;
    
    _clickableElementDelegate = clickableElementDelegate;
    
    [self initViews];
    
    if (_imageDisplayerDelegate) {
      [_imageDisplayerDelegate registerImageUrl:[AppManager instance].userImgUrl];
    }
    
    [[[AppManager instance] imageCache] fetchImage:[AppManager instance].userImgUrl
                                            caller:self
                                          forceNew:NO];
  }
  return self;
}

- (void)dealloc {
  
  [super dealloc];
}

#pragma mark - update avatar
- (void)updateAvatar:(UIImage *)avatar {
  CATransition *imageFadein = [CATransition animation];
  imageFadein.duration = FADE_IN_DURATION;
  imageFadein.type = kCATransitionFade;
  
  [_avatarButton.layer addAnimation:imageFadein forKey:nil];
  
  [_avatarButton setImage:[CommonUtils cutPartImage:avatar
                                              width:USERDETAIL_PHOTO_WIDTH
                                             height:USERDETAIL_PHOTO_HEIGHT]
                 forState:UIControlStateNormal];
}



#pragma mark - ImageFetcherDelegate methods
- (void)imageFetchStarted:(NSString *)url {
  
}

- (void)imageFetchDone:(UIImage *)image url:(NSString *)url {
  
  [self updateAvatar:image];
}

- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url {
  
  [_avatarButton setImage:[CommonUtils cutPartImage:image
                                              width:USERDETAIL_PHOTO_WIDTH
                                             height:USERDETAIL_PHOTO_HEIGHT]
                 forState:UIControlStateNormal];
}

- (void)imageFetchFailed:(NSError *)error url:(NSString *)url {
  
}


@end
