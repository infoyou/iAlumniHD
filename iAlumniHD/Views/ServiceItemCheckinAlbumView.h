//
//  ServiceItemCheckinAlbumView.h
//  iAlumniHD
//
//  Created by MobGuang on 12-8-17.
//
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "GlobalConstants.h"
#import "ImageDisplayerDelegate.h"
#import "ImageFetcherDelegate.h"
#import "ECClickableElementDelegate.h"

@class WXWLabel;

@interface ServiceItemCheckinAlbumView  : UIView <ImageFetcherDelegate> {
  UIActivityIndicatorView *_spinView;
  BOOL _clickable;
  
  NSInteger _displayedPeopleCount;
  
  UIImageView *_rightArrow;
  
  BOOL photoLoaded;
  
@private
  
  id<ImageDisplayerDelegate> _imageDisplayerDelegate;
  id<ECClickableElementDelegate> _clickableElementDelegate;
  
  NSMutableDictionary *_photoDic;
  
  WXWLabel *_noCheckinNotifyLabel;
  
  NSMutableArray *_imageViewList;
  
  NSArray *_currentCheckinAlumnus;
  
  WXWLabel *_checkinCountLabel;
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
hashedCheckedinItemId:(NSString *)hashedCheckedinItemId;

@end
