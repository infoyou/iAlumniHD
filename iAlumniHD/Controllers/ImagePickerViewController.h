//
//  ImagePickerViewController.h
//  iAlumniHD
//
//  Created by Adam on 12-10-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"

@protocol ECPhotoPickerOverlayDelegate;
@protocol ItemUploaderDelegate;

@interface ImagePickerViewController : RootViewController <UINavigationControllerDelegate,  UIImagePickerControllerDelegate, UIActionSheetDelegate> {
    
    UIImagePickerController *_imagePicker;
    UIPopoverController *_popVC;
    
@private
    
    id<ECPhotoPickerOverlayDelegate> _delegate;
    
    id<ItemUploaderDelegate> _uploaderDelegate;
    
    UIImagePickerControllerSourceType _sourceType;
    
    UIButton *_onFlashButton;
    UIButton *_offFlashButton;
    UIButton *_autoFlashButton;
    UIButton *_flashButton;
    UIView *_flashButtonBoard;
    
    UIImage *_originalImage;
    UIImage *_selectedImage;

    PhotoTakerType _takerType;
    
    NSString *_itemId;
    
    BOOL _userSelectPhotoFromAlbum;
    BOOL _needMoveDownComposerSubViews;
    
    BOOL _needSaveToAlbum;
}

@property (nonatomic, retain) UIImagePickerController *imagePicker;
@property (nonatomic, retain) UIPopoverController *_popVC;
@property (nonatomic, assign) BOOL needSaveToAlbum;

- (id)initWithSourceType:(UIImagePickerControllerSourceType)sourceType
                delegate:(id<ECPhotoPickerOverlayDelegate>)delegate
        uploaderDelegate:(id<ItemUploaderDelegate>)uploaderDelegate
               takerType:(PhotoTakerType)takerType
                     MOC:(NSManagedObjectContext *)MOC;

- (id)initForServiceUploadPhoto:(NSString *)itemId
                     SourceType:(UIImagePickerControllerSourceType)sourceType
                       delegate:(id<ECPhotoPickerOverlayDelegate>)delegate
               uploaderDelegate:(id<ItemUploaderDelegate>)uploaderDelegate
                      takerType:(PhotoTakerType)takerType
                            MOC:(NSManagedObjectContext *)MOC;
- (void)arrangeViews;

@end
