//
//  ServiceProviderViewController.h
//  iAlumniHD
//
//  Created by Mobguang on 11-12-21.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "BaseListViewController.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "ImageDisplayerDelegate.h"
#import "ECClickableElementDelegate.h"
#import "ItemUploaderDelegate.h"
#import "ECPhotoPickerDelegate.h"
#import "ECPhotoPickerOverlayDelegate.h"

@class ServiceProviderProfileHeaderView;
//@class ServiceItem;
@class ImagePickerViewController;
@class ServiceProvider;

@interface ServiceProviderViewController : BaseListViewController <ECClickableElementDelegate, ImageDisplayerDelegate, ItemUploaderDelegate, ECPhotoPickerDelegate, UIActionSheetDelegate, UIAlertViewDelegate, ECPhotoPickerOverlayDelegate, MFMailComposeViewControllerDelegate> {
  
  @private
  ServiceProviderProfileHeaderView *_headerView;
  
  //  ServiceItem *_item;
  
  ServiceProvider *_sp;
  
  long long _spId;
  
  ImagePickerViewController *_pickerOverlayVC;
  
  NSInteger _startIndex;
  
  NSInteger _sectionCount;
  
  NSString *_hashedLikedItemId;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder 
 backToHomeAction:(SEL)backToHomeAction 
             spId:(long long)spId;

@end
