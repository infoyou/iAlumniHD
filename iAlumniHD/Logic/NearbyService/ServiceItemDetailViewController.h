//
//  ServiceItemDetailViewController.h
//  iAlumniHD
//
//  Created by Mobguang on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseListViewController.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "ImageDisplayerDelegate.h"
#import "ECClickableElementDelegate.h"
#import "ItemUploaderDelegate.h"
#import "ECPhotoPickerDelegate.h"
#import "ECPhotoPickerOverlayDelegate.h"

@class ServiceItem;
@class ServiceItemHeaderView;
@class ImagePickerViewController;
@class ServiceItemToolbar;
@class Brand;

@interface ServiceItemDetailViewController : BaseListViewController <ECClickableElementDelegate, ItemUploaderDelegate, ECPhotoPickerDelegate, UIActionSheetDelegate, ECPhotoPickerOverlayDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate> {
 
  @private
  ServiceItemHeaderView *_headerView;
  
  ServiceItemToolbar *_moreActionToolbar;
  
  ServiceItem *_item;
  
  Brand *_brand;
  
  ImagePickerViewController *_pickerOverlayVC;
  
  NSMutableDictionary *_sectionInfoDic;
  
  CGFloat _avatar_y;
  
  NSInteger _actionOwnerType;
  
  BOOL _needUpdateCommentCount;
  
  NSIndexPath *_commentIndexPath;
  
  BOOL _toolbarAdjusted;
  
  NSString *_hashedServiceItemId;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder 
 backToHomeAction:(SEL)backToHomeAction 
      serviceItem:(ServiceItem *)serviceItem;

@end
