//
//  UserProfileViewController.h
//  iAlumniHD
//
//  Created by MobGuang on 12-9-24.
//
//

#import "BaseListViewController.h"
#import "GlobalConstants.h"
#import "ImageDisplayerDelegate.h"
#import "ECPhotoPickerOverlayDelegate.h"
#import "ItemUploaderDelegate.h"
#import "ECPhotoPickerDelegate.h"
#import "ECClickableElementDelegate.h"
#import "ImagePickerViewController.h"

@class ImagePickerViewController;
@class PhotoFetcherView;
@class UserProfileHeaderView;
@class PhotoFetcherView;

@interface UserProfileViewController : BaseListViewController <ImageDisplayerDelegate, UIActionSheetDelegate, ECPhotoPickerOverlayDelegate, ItemUploaderDelegate, ECClickableElementDelegate> {
  @private
  
  // table header view
  UserProfileHeaderView *_headerView;
  
  UIImagePickerControllerSourceType _photoSourceType;
  UIImage *_selectedPhoto;

  ImagePickerViewController *_photoPickerVC;
  
  PhotoTakerType _photoTakerType;
  
  PhotoFetcherView *_photoFetcherView;

}

- (id)initWithMOC:(NSManagedObjectContext *)MOC;

@end
