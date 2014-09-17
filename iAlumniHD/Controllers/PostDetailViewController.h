//
//  PostDetailViewController.h
//  iAlumniHD
//
//  Created by Adam on 12-10-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseListViewController.h"
#import "ItemUploaderDelegate.h"
#import "ECClickableElementDelegate.h"
#import "WXWConnectionTriggerHolderDelegate.h"
#import "ECPhotoPickerOverlayDelegate.h"

@class Post;
@class ItemListSectionView;
@class NoticeableCommentComposerView;
@class ImagePickerViewController;

@interface PostDetailViewController : BaseListViewController <ItemUploaderDelegate, ECClickableElementDelegate, UIActionSheetDelegate, WXWConnectionTriggerHolderDelegate, UIImagePickerControllerDelegate, ECPhotoPickerOverlayDelegate,
    UIGestureRecognizerDelegate, WXApiDelegate> {
    
@private
    Post *_post;
    
    PostType _postType;
    
    ItemListSectionView *_sectionView;
    
    NoticeableCommentComposerView *_commentComposerView;
    
    CGFloat _noCommentComposerTableHeight;
    
    long long _beDeletedCommentId;
    
    BOOL _loadingComments;
    
    NSString *_lastSectionTitle;
    
    CGFloat _textContentHeight;
    BOOL _textContentLoaded;
    
    BOOL _scrollDirectoinType;
    BOOL    isDown;
    CGFloat _scrollPreviousValue;
    
    // as view will be modified if user select photo from album, 
    // we need a var to store the height of view visible area
    CGFloat _visibleViewHeight;
    
    // image stuff
    NSInteger _actionSheetOwnerType;
    
    UIImage *_selectedPhoto;
    
    UIImagePickerControllerSourceType _photoSourceType;
    
    ImagePickerViewController *_photoPickerVC;
    
    BOOL _needMoveDown20px;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder
 backToHomeAction:(SEL)backToHomeAction 
             post:(Post *)post
         postType:(PostType)postType;

- (void)openProfile:(NSString*)personId userType:(NSString*)userType;
- (void)showImagePicker;
- (void)addOrRemovePhoto;

@end
