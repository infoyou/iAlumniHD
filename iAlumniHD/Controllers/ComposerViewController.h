//
//  ComposerViewController.h
//  iAlumniHD
//
//  Created by Adam on 12-11-12.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "ECPhotoPickerOverlayDelegate.h"
#import "WXWPhotoEffectSamplesView.h"
#import "ItemUploaderDelegate.h"
#import "ECEditorDelegate.h"
#import "ComposerDelegate.h"
#import "WXWTextView.h"
#import "WXWLabel.h"

@class TextComposerView;
@class ImagePickerViewController;
@class Club;

@interface ComposerViewController : RootViewController <UIActionSheetDelegate, ECEditorDelegate, ECPhotoPickerOverlayDelegate, ComposerDelegate> {
    
@private
    TextComposerView *_textComposer;
    
    UIImagePickerControllerSourceType _photoSourceType;
    UIImage *_selectedPhoto;
    
    NSString *_originalItemId;
    
    NSString *_brandId;
    
    NSString *_groupId;
    
    WebItemType _contentType;
    
    NSString *_content;
    NSString *_isSelectedSms;
    
    id<ItemUploaderDelegate> _delegate;
        
    BOOL _needMoveDownUI;
    
    BOOL _needMoveDown20px;
    
    BOOL _hidePhotoFetcher;
    
    UIImagePickerControllerSourceType _imagePickerSourceType;
    
    ImagePickerViewController *_imagePickerVC;
    
    BOOL _loadingPlaces;
    BOOL _placesLoaded;
    
    // attachment
    UIView *_attachmentBGView;
    
    // place
    WXWLabel *_placeLabel;
    WXWImageButton *_delPlaceBut;
    
    // tag
    WXWLabel *_tagLabel;
    WXWImageButton *_delTagBut;
    
    // show photo
    UIImageView *_showPhotoView;
    WXWImageButton *_delPhotoBut;
    UIView *_showPhotoBGView;
    
    // toolbar   
    UIToolbar *_toolbar;
    
    CGFloat imgWidth;
    CGFloat imgHeight;
    
    int rotateStep;
    CGFloat rotateWidth;
    
    UIImage *_targetImage;
    
    UIImageView *_displayedImageView;
    int displayW;
    int displayH;
    UIImage *_originalImage;
    UIImage *_selectedImage;
    WXWImageButton *_closePhotoBut;
    WXWPhotoEffectSamplesView *_palette;
    
    UIView *_displayBoard;
    
    UIImagePickerControllerSourceType _sourceType;
        
    NSString *_itemId;

    int _composerShowType;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
         delegate:(id<ItemUploaderDelegate>)delegate;

- (id)initWithMOC:(NSManagedObjectContext *)MOC
         delegate:(id<ItemUploaderDelegate>)delegate
   originalItemId:(NSString *)originalItemId;

- (id)initServiceItemCommentComposerWithMOC:(NSManagedObjectContext *)MOC
                                   delegate:(id<ItemUploaderDelegate>)delegate
                             originalItemId:(NSString *)originalItemId
                                    brandId:(NSString *)brandId;

- (id)initServiceProviderCommentComposerWithMOC:(NSManagedObjectContext *)MOC
                                       delegate:(id<ItemUploaderDelegate>)delegate
                                 originalItemId:(NSString *)originalItemId;

- (id)initWithMOC:(NSManagedObjectContext *)MOC
         delegate:(id<ItemUploaderDelegate>)delegate
          groupId:(NSString *)groupId;

- (id)initForEventDiscussWithMOC:(NSManagedObjectContext *)MOC
                        delegate:(id<ItemUploaderDelegate>)delegate
                         eventId:(NSString *)eventId;

- (id)initForShareWithMOC:(NSManagedObjectContext *)MOC
                 delegate:(id<ItemUploaderDelegate>)delegate
                  groupId:(NSString *)groupId;

- (id)initForCommentWithMOC:(NSManagedObjectContext *)MOC
                   delegate:(id<ItemUploaderDelegate>)delegate
                    postId:(NSString *)postId;

- (id)initForBizPostWithMOC:(NSManagedObjectContext *)MOC
                      group:(Club *)group
                   delegate:(id<ItemUploaderDelegate>)delegate;

@end
