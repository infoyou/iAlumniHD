//
//  ComposerViewController.m
//  iAlumniHD
//
//  Created by Adam on 12-11-12.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ComposerViewController.h"
#import "TextComposerView.h"
#import "ComposerTag.h"
#import "ComposerPlace.h"
#import "ImagePickerViewController.h"
#import "ItemPropertiesListViewController.h"
#import "PlaceListViewController.h"
#import "UIImage-Extensions.h"
#import "Place.h"
#import "Club.h"

enum {
	DIFF_ORI,
	LANDSCAPE_ORI,
	PORTRAIT_ORI,
};

#define DEVICE_IS_LANDSCAPE	[CommonUtils currentOrientationIsLandscape]
#define IMAGE_IS_LANDSCAPE	[self imageOrientationIsLandscape]

#define DISPLAY_BOARD_HEIGHT    SCREEN_HEIGHT -  NAVIGATION_BAR_HEIGHT// 436.0f
#define DISPLAY_IMAGE_HEIGHT    480.f
#define DISPLAY_IMAGE_X         40.f
#define TOOLBAR_W               200.f

#define LANDSCAPE_W_H_RATIO     1.5
#define PORTRAIT_W_H_RATIO      LIST_WIDTH / DISPLAY_BOARD_HEIGHT

#define TEXT_COMPOSER_HEIGHT		SCREEN_HEIGHT

#define ATTACHMENT_X                144.f
#define ATTACHMENT_BUTTON_Y         12.f
#define ATTACHMENT_BUTTON_W         56.f
#define ATTACHMENT_BUTTON_H         38.f
#define ATTACHMENT_BUTTON_SPACING   28.f

#define PLACE_SEARCH_RADIUS         0.5f
#define ICON_SIDE_LENGTH            32.0f

@interface ComposerViewController()
@property (nonatomic, copy) NSString *originalItemId;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, retain) UIImage *selectedPhoto;
@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, retain) ImagePickerViewController *imagePickerVC;
@property (nonatomic, retain) id<ItemUploaderDelegate> delegate;
@property (nonatomic, assign) NSString *isSelectedSms;
@property (nonatomic, copy) NSString *brandId;
@property (nonatomic, retain) UIImage *targetImage;
@property (nonatomic, retain) UIImage *originalImage;
@property (nonatomic, retain) UIImage *selectedImage;
@property (nonatomic, retain) WXWPhotoEffectSamplesView *palette;
@property (nonatomic, retain) UIView *displayBoard;
@property (nonatomic, copy) NSString *itemId;
@property (nonatomic, retain) WXWLabel *_placeLabel;
@property (nonatomic, retain) WXWImageButton *_delPlaceBut;
@property (nonatomic, retain) WXWLabel *_tagLabel;
@property (nonatomic, retain) WXWImageButton *_delTagBut;
@property (nonatomic, retain) WXWImageButton *_closePhotoBut;
@property (nonatomic, retain) Club *group;
@end

@implementation ComposerViewController

@synthesize originalItemId = _originalItemId;
@synthesize content = _content;
@synthesize isSelectedSms = _isSelectedSms;
@synthesize selectedPhoto = _selectedPhoto;
@synthesize selectedImage = _selectedImage;
@synthesize groupId = _groupId;
@synthesize palette = _palette;
@synthesize displayBoard = _displayBoard;
@synthesize targetImage = _targetImage;
@synthesize imagePickerVC = _imagePickerVC;
@synthesize delegate = _delegate;
@synthesize brandId = _brandId;
@synthesize itemId = _itemId;
@synthesize _placeLabel;
@synthesize _delPlaceBut;
@synthesize _tagLabel;
@synthesize _delTagBut;
@synthesize _closePhotoBut;

#pragma mark - user actions

- (void)sendComment {
    
    self.connFacade = [[[WXWAsyncConnectorFacade alloc] initWithDelegate:self
                                                  interactionContentType:SEND_COMMENT_TY] autorelease];
    
    [self.connFacade sendComment:self.content originalItemId:self.originalItemId photo:self.selectedPhoto];
}

- (void)sendGroup {
    self.connFacade = [[[WXWAsyncConnectorFacade alloc] initWithDelegate:self
                                                  interactionContentType:SEND_POST_TY] autorelease];
    
    if (self.content.length == 0 || nil == self.content) {
        self.content = @" ";
    }
    
    [self.connFacade sendPostForGroup:self.group
                              content:self.content
                                photo:self.selectedPhoto];
}

- (void)sendServiceItemComment {
    if (self.content.length == 0 || nil == self.content) {
        self.content = @" ";
    }
    
    self.connFacade = [[[WXWAsyncConnectorFacade alloc] initWithDelegate:self
                                                  interactionContentType:SEND_SERVICE_ITEM_COMMENT_TY] autorelease];
    [self.connFacade sendServiceItemComment:self.content
                                     itemId:self.originalItemId
                                    brandId:self.brandId];
}

- (NSArray *)fetchSelectedTags {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(selected == 1)"];
    
    NSArray *selectedTags = [CoreDataUtils fetchObjectsFromMOC:_MOC
                                                    entityName:@"ComposerTag"
                                                     predicate:predicate];
    return selectedTags;
}

- (void)doSend:(NSArray *)selectedTags {
    self.connFacade = [[[WXWAsyncConnectorFacade alloc] initWithDelegate:self
                                                  interactionContentType:SEND_POST_TY] autorelease];
    
    NSString *selectedTagIds = @"";
    NSInteger index = 0;
    for (ComposerTag *tag in selectedTags) {
        if (index > 0) {
            selectedTagIds = [NSString stringWithFormat:@"%@,%@", selectedTagIds, tag.tagId];
        } else {
            selectedTagIds = [NSString stringWithFormat:@"%@", tag.tagId];
        }
        index++;
    }
    
    if (self.content.length == 0 || nil == self.content) {
        self.content = @" ";
    }
    
    switch (_contentType) {
        case SEND_POST_TY:
            [self.connFacade sendPost:self.content
                                photo:self.selectedPhoto
                               hasSms:self.isSelectedSms];
            break;
            
        case SEND_EVENT_DISCUSS_TY:
            [self.connFacade sendEventDiscuss:self.content
                                        photo:self.selectedPhoto
                                       hasSMS:self.isSelectedSms
                                      eventId:self.groupId];
            break;
            
        case SEND_SHARE_TY:
        {
            PostType type = 0;
            NSString *groupId = @"";
            if (self.groupId.longLongValue == ALL_CATEGORY_GROUP_ID) {
                type = SHARE_POST_TY;
            } else {
                type = DISCUSS_POST_TY;
                groupId = self.groupId;
            }
            [self.connFacade sendPost:self.content
                               tagIds:selectedTagIds
                            placeName:[AppManager instance].composerPlace
                                photo:self.selectedPhoto
                             postType:type
                              groupId:groupId];
            break;
        }
            
        default:
            break;
    }
}

- (void)sendPost {
    
    if (self.content.length == 0 || nil == self.content) {
        [WXWUIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSChatEmptyWarningMsg, nil)
                                         msgType:WARNING_TY
                              belowNavigationBar:YES];
    } else {
        NSArray *selectedTags = [self fetchSelectedTags];
        [self doSend:selectedTags];
    }
    
}

- (BOOL)needTagMandatory {
    if ([CoreDataUtils objectInMOC:_MOC
                        entityName:@"ComposerTag"
                         predicate:nil]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)sendShare {
    
    NSArray *selectedTags = nil;
    
    if ([self needTagMandatory]) {
        selectedTags = [self fetchSelectedTags];
        
        if (nil == selectedTags || [selectedTags count] == 0) {
            // user must select one tag at least
            
            [self chooseTags];
            
            [WXWUIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSSelectTagNotifyMsg, nil)
                                             msgType:WARNING_TY
                                  belowNavigationBar:YES];
            return;
        }
    }
    
    if (self.content.length == 0 || nil == self.content) {
        [WXWUIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSChatEmptyWarningMsg, nil)
                                         msgType:WARNING_TY
                              belowNavigationBar:YES];
        return;
    }
    
    [self doSend:selectedTags];
}

- (void)sendEventDiscuss {
    [self doSend:nil];
}

- (void)uploadPhotoForServiceItem {
    if (self.content.length == 0 || nil == self.content) {
        self.content = @" ";
    }
    
    self.connFacade = [[[WXWAsyncConnectorFacade alloc] initWithDelegate:self
                                                  interactionContentType:ADD_PHOTO_FOR_SERVICE_ITEM_TY] autorelease];
    [self.connFacade addPhotoForServiceItem:self.selectedPhoto
                                     itemId:self.originalItemId.longLongValue
                                    caption:self.content];
    
}

- (void)send:(id)sender {
    
    switch (_contentType) {
        case SEND_BIZ_POST_TY:
            [self sendGroup];
            break;
            
        case SEND_COMMENT_TY:
            [self sendComment];
            break;
            
        case SEND_SERVICE_ITEM_COMMENT_TY:
            [self sendServiceItemComment];
            break;
            
        case SEND_POST_TY:
            [self sendPost];
            break;
            
        case SEND_SHARE_TY:
            [self sendShare];
            break;
            
        case ADD_PHOTO_FOR_SERVICE_ITEM_TY:
            [self uploadPhotoForServiceItem];
            break;
            
        case SEND_EVENT_DISCUSS_TY:
            [self sendEventDiscuss];
            break;
            
        default:
            break;
    }
    
}

- (void)doClose {
    [self cancelConnection];
    [self cancelLocation];
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)close:(id)sender {
    
    _alertType = CLOSE_BTN;
    
    if ([_textComposer charCount] > 0 || self.selectedPhoto) {
        UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:LocaleStringForKey(NSCloseNotificationTitle, nil)
                                                        delegate:self
                                               cancelButtonTitle:nil
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:nil];
		[as addButtonWithTitle:LocaleStringForKey(NSCloseTitle, nil)];
        [as addButtonWithTitle:LocaleStringForKey(NSCancelTitle, nil)];
		[as addButtonWithTitle:LocaleStringForKey(NSCancelTitle, nil)];
        as.destructiveButtonIndex = 0;
		as.cancelButtonIndex = [as numberOfButtons] - 1;
        
        [as showFromRect:CGRectMake(-350.f, -50.f, _frame.size.width, TOOLBAR_HEIGHT)
                  inView:self.view
                animated:YES];
        
		RELEASE_OBJ(as);
        
    } else {
        
        [self doClose];
    }
}

- (void)changeSendButtonStatus {
    if ((self.content && [self.content length] > 0)) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (void)applySelectedPhoto:(UIImage *)image {
    
    //	self.selectedPhoto = image;
    //    [self addImgContent];
    
    //    /*
    [super initDisableView:self.view.bounds];
    [self showDisableView];
    
    [self handleTakenImage:image];
    [self initImageEffectToolbar];
    //    */
}

- (void)saveImageIfNecessary:(UIImage *)image
                  sourceType:(UIImagePickerControllerSourceType)sourceType {
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        
		UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
	}
}

#pragma mark - ECPhotoPickerOverlayDelegate methods

- (void)didTakePhoto:(UIImage *)photo {
    
    if (_photoSourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImageWriteToSavedPhotosAlbum(photo, nil, nil, nil);
    }
    
    [self applySelectedPhoto:photo];
}

// as a delegate we are told to finished with the camera
- (void)didFinishWithCamera {
    
    self.imagePickerVC = nil;
}

- (void)adjustUIAfterUserBrowseAlbumInImagePicker {
    
    // user browse the album in image picker, so UI layout be set as full screen, then we should recovery
    // the layout corresponding
    
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    self.navigationController.navigationBar.frame = CGRectOffset(self.navigationController.navigationBar.frame, 0.0f, 20.0f);
    self.view.frame = CGRectOffset(self.view.frame, 0.0f, 20.0f);
    
    _needMoveDown20px = YES;
}

#pragma mark - UIActionSheetDelegate method
- (void)actionSheet:(UIActionSheet *)as
clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (_alertType) {
        case CLOSE_BTN:
            if (1 == buttonIndex) {
                return;
            } else {
                [self doClose];
            }
            break;
            
        default:
            break;
    }
}

#pragma mark - ECEditorDelegate methods
- (void)textChanged:(NSString *)text {
    
    self.content = text;
    [self changeSendButtonStatus];
}

#pragma mark - del action
- (void)delTag:(id)sender {
    
    //    _tagLabel.hidden = YES;
    //    _delTagBut.hidden = YES;
}

- (void)delPlace:(id)sender {
    
    _placeLabel.hidden = YES;
    _delPlaceBut.hidden = YES;
}

- (void)delImage:(id)sender {
    
    _showPhotoView.hidden = YES;
    _delPhotoBut.hidden = YES;
    _showPhotoBGView.hidden = YES;
    
    [self modifyTagFrame];
    [self modifyPlaceFrame];
}

#pragma mark - attachment action

- (void)startAction
{
    [_textComposer hideKeyboard];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationItem.leftBarButtonItem.enabled = NO;
}

- (void)choosePlace:(id)sender {
    
    [self startAction];
    
    PlaceListViewController *placeListVC = [[[PlaceListViewController alloc] initWithMOC:_MOC composerDelegate:self] autorelease];
    
    placeListVC.title = LocaleStringForKey(NSNearbyPlaceListTitle, nil);
    
    UIPopoverController *popVC = [[[UIPopoverController alloc] initWithContentViewController:placeListVC] autorelease];
    placeListVC._popVC = popVC;
    
    [popVC presentPopoverFromRect:CGRectMake(10.f, 0.f, _frame.size.width, POP_HEIGHT)
                           inView:self.view
         permittedArrowDirections:_UIPopoverArrowDirection
                         animated:YES];
    popVC.delegate = self;
}

- (void)chooseTags {
    
    [self startAction];
    
    ItemPropertiesListViewController *itemPropertiesListVC = [[[ItemPropertiesListViewController alloc]
                                                               initWithMOC:_MOC
                                                               composerDelegate:self
                                                               propertyType:TAG_TY
                                                               moveDownUI:_needMoveDownUI
                                                               tagType:SHARE_TY] autorelease];
    
    itemPropertiesListVC.title = LocaleStringForKey(NSTagTitle, nil);
    itemPropertiesListVC.modalDelegate = self;
    
    WXWNavigationController *itemNC = [[[WXWNavigationController alloc] initWithRootViewController:itemPropertiesListVC] autorelease];
    itemNC.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentModalViewController:itemNC animated:YES];
}

- (void)addImgFromCamera {
    
    if (HAS_CAMERA) {
        [self startAction];
        [self showImagePicker:UIImagePickerControllerSourceTypeCamera];
    }
}

- (void)addImgFromPhotoLibrary {
    
    [self startAction];
    [self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)showImagePicker:(UIImagePickerControllerSourceType)type {
    
    _photoSourceType = type;
    
    self.imagePickerVC = [[[ImagePickerViewController alloc] initWithSourceType:_photoSourceType
                                                                       delegate:self
                                                               uploaderDelegate:self.delegate
                                                                      takerType:POST_COMPOSER_TY
                                                                            MOC:_MOC] autorelease];
    
    [self.imagePickerVC arrangeViews];
    
    UIPopoverController *popVC = [[[UIPopoverController alloc] initWithContentViewController:self.imagePickerVC.imagePicker] autorelease];
    popVC.delegate = self;
    self.imagePickerVC._popVC = popVC;
    
    [popVC presentPopoverFromRect:CGRectMake(10.f, 0.f, _frame.size.width, _frame.size.height)
                           inView:self.view
         permittedArrowDirections:_UIPopoverArrowDirection
                         animated:YES];
}

#pragma mark - WXWConnectorDelegate methods
- (void)connectStarted:(NSString *)url contentType:(WebItemType)contentType {
    
    switch (contentType) {
        case LOAD_NEARBY_PLACE_LIST_TY:
            _loadingPlaces = YES;
            break;
            
        case SEND_COMMENT_TY:
        case SEND_POST_TY:
        case SEND_EVENT_DISCUSS_TY:
        case SEND_QUESTION_TY:
        case ADD_PHOTO_FOR_SERVICE_ITEM_TY:
        case SEND_SERVICE_ITEM_COMMENT_TY:
        case ADD_PHOTO_FOR_SERVICE_PROVIDER_TY:
        case SEND_SERVICE_PROVIDER_COMMENT_TY:
        {
            [WXWUIUtils showActivityView:[APP_DELEGATE foundationView]
                                    text:LocaleStringForKey(NSSendingTitle, nil)];
            
            [self doClose];
            break;
        }
            
        default:
            break;
    }
    [super connectStarted:url contentType:contentType];
}

- (void)connectCancelled:(NSString *)url contentType:(WebItemType)contentType {
    
    [super connectCancelled:url contentType:contentType];
}

- (NSString *)successMsg {
    return LocaleStringForKey(NSSendFeedDoneMsg, nil);
}

- (NSString *)errorMsg {
    if ([AppManager instance].feedGroupId.longLongValue == self.groupId.longLongValue) {
        // send feed
        return LocaleStringForKey(NSSendFeedFailedMsg, nil);
    } else if ([AppManager instance].qaGroupId.longLongValue == self.groupId.longLongValue) {
        // send question
        return LocaleStringForKey(NSSendQuestionFailedMsg, nil);
    }
    return nil;
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(WebItemType)contentType {
    
    switch (contentType) {
            
        case LOAD_NEARBY_PLACE_LIST_TY:
        {
            if ([XMLParser parserSyncResponseXml:result
                                            type:LOAD_NEARBY_PLACE_LIST_SRC
                                             MOC:_MOC]) {
                
                //                [_textComposer showPlaceButton:YES];
                _placesLoaded = YES;
                
            } else {
                
                _placesLoaded = NO;
                [WXWUIUtils showNotificationWithMsg:LocaleStringForKey(NSActionFaildMsg, nil)
                                            msgType:ERROR_TY
                                         holderView:[APP_DELEGATE foundationView]];
            }
            
            _loadingPlaces = NO;
            break;
        }
            
        case SEND_COMMENT_TY:
        case SEND_SERVICE_ITEM_COMMENT_TY:
        {
            if ([XMLParser parserResponseXml:result
                                        type:SEND_COMMENT_TY
                                         MOC:nil
                           connectorDelegate:self
                                         url:url]) {
                
                if (self.delegate) {
                    [self.delegate afterUploadFinishAction:contentType];
                }
                
                [WXWUIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSSendCommentDoneMsg, nil)
                                                 msgType:SUCCESS_TY
                                      belowNavigationBar:YES];
                [self doParentRefresh];
            } else {
                [WXWUIUtils showNotificationOnTopWithMsg:[self.errorMsgDic objectForKey:url]
                                          alternativeMsg:LocaleStringForKey(NSSendCommentFailedMsg, nil)
                                                 msgType:ERROR_TY
                                      belowNavigationBar:YES];
            }
            break;
        }
            
        case SEND_POST_TY:
        case SEND_EVENT_DISCUSS_TY:
        {
            if ([XMLParser parserResponseXml:result
                                        type:contentType
                                         MOC:nil
                           connectorDelegate:self
                                         url:url]) {
                
                if (self.delegate) {
                    [self.delegate afterUploadFinishAction:contentType];
                }
                
                [WXWUIUtils showNotificationOnTopWithMsg:[self successMsg]
                                                 msgType:SUCCESS_TY
                                      belowNavigationBar:YES];
                [self doParentRefresh];
            } else {
                [WXWUIUtils showNotificationOnTopWithMsg:[self.errorMsgDic objectForKey:url]
                                          alternativeMsg:[self errorMsg]
                                                 msgType:ERROR_TY
                                      belowNavigationBar:YES];
            }
            break;
            
            [[UIApplication sharedApplication] keyWindow];
        }
            
        case ADD_PHOTO_FOR_SERVICE_ITEM_TY:
        {
            
            if ([XMLParser parserResponseXml:result
                                        type:ADD_PHOTO_FOR_SERVICE_ITEM_TY
                                         MOC:_MOC
                           connectorDelegate:self
                                         url:url]) {
                
                if (self.delegate) {
                    [self.delegate afterUploadFinishAction:ADD_PHOTO_FOR_SERVICE_ITEM_TY];
                }
                
                [WXWUIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSAddPhotoDoneTitle, nil)
                                                 msgType:SUCCESS_TY
                                      belowNavigationBar:YES];
                [self doParentRefresh];
            } else {
                [WXWUIUtils showNotificationOnTopWithMsg:[self.errorMsgDic objectForKey:url]
                                          alternativeMsg:LocaleStringForKey(NSAddPhotoFailedTitle, nil)
                                                 msgType:ERROR_TY
                                      belowNavigationBar:YES];
            }
            
            break;
        }
        default:
            break;
    }
    
    [super connectDone:result url:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error url:(NSString *)url contentType:(WebItemType)contentType {
    
    NSString *msg = nil;
    
    switch (contentType) {
        case LOAD_NEARBY_PLACE_LIST_TY:
        {
            _placesLoaded = NO;
            _loadingPlaces = NO;
            break;
        }
            
        case SEND_COMMENT_TY:
        {
            msg = LocaleStringForKey(NSSendCommentFailedMsg, nil);
            break;
        }
            
        case SEND_POST_TY:
        case SEND_EVENT_DISCUSS_TY:
        {
            msg = [self errorMsg];
            break;
        }
        default:
            break;
    }
    
    if ([self connectionMessageIsEmpty:error]) {
        self.connectionErrorMsg = msg;
    }
    
    [super connectFailed:error url:url contentType:contentType];
}

#pragma mark - LocationFetcherDelegate methods

- (void)locationManagerDidReceiveLocation:(LocationManager *)manager location:(CLLocation *)location {
    
    [super locationManagerDidReceiveLocation:manager location:location];
}

#pragma mark - prepare for share

- (void)clearOldPlacesData {
    // delete 'Place' and 'ComposerPlace' instance from MOC firstly
    DELETE_OBJS_FROM_MOC(_MOC, @"ComposerTag", nil);
    DELETE_OBJS_FROM_MOC(_MOC, @"Place", nil);
}

- (void)loadPlaces
{
    _currentType = LOAD_NEARBY_PLACE_LIST_TY;
    
    NSString *param = [NSString stringWithFormat:@"<latitude>%f</latitude><longitude>%f</longitude>",
                       [AppManager instance].latitude,
                       [AppManager instance].longitude];
    
    NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
    
    WXWAsyncConnectorFacade *connector = [self setupAsyncConnectorForUrl:url
                                                             contentType:_currentType];
    
    [connector asyncGet:url showAlertMsg:YES];
}

- (void)registerKeyboardNotifications {
    if ([CommonUtils currentOSVersion] >= IOS5) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardHeightChanged:)
                                                     name:UIKeyboardWillChangeFrameNotification
                                                   object:nil];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
}

- (void)initTags {
    if ([CoreDataUtils objectInMOC:_MOC entityName:@"Tag" predicate:nil]) {
        [CoreDataUtils createComposerTagsForGroupId:self.groupId
                                                MOC:_MOC];
    }
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
         delegate:(id<ItemUploaderDelegate>)delegate {
    
    self = [super initWithMOC:MOC frame:CGRectMake(0, 0, UI_MODAL_PAGE_SHEET_WIDTH, SCREEN_HEIGHT)];
    
    if (self) {
        self.delegate = delegate;
        _imagePickerSourceType = UIImagePickerControllerSourceTypeCamera;
    }
    return self;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
         delegate:(id<ItemUploaderDelegate>)delegate
   originalItemId:(NSString *)originalItemId {
    
    self = [self initWithMOC:MOC delegate:delegate];
    if (self) {
        self.originalItemId = originalItemId;
        _contentType = SEND_COMMENT_TY;
    }
    return self;
}

- (id)initServiceItemCommentComposerWithMOC:(NSManagedObjectContext *)MOC
                                   delegate:(id<ItemUploaderDelegate>)delegate
                             originalItemId:(NSString *)originalItemId
                                    brandId:(NSString *)brandId {
    
    self = [self initWithMOC:MOC delegate:delegate originalItemId:originalItemId];
    if (self) {
        _composerShowType = COMPOSER_NONE;
        _hidePhotoFetcher = YES;
        
        self.brandId = brandId;
        
        _contentType = SEND_SERVICE_ITEM_COMMENT_TY;
    }
    return self;
}

- (id)initServiceProviderCommentComposerWithMOC:(NSManagedObjectContext *)MOC
                                       delegate:(id<ItemUploaderDelegate>)delegate
                                 originalItemId:(NSString *)originalItemId {
    
    self = [self initWithMOC:MOC delegate:delegate originalItemId:originalItemId];
    
    if (self) {
        _hidePhotoFetcher = YES;
        _contentType = SEND_SERVICE_PROVIDER_COMMENT_TY;
    }
    return self;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
         delegate:(id<ItemUploaderDelegate>)delegate
          groupId:(NSString *)groupId {
    
    self = [self initWithMOC:MOC delegate:delegate];
    
    if (self) {
        self.groupId = groupId;
        self.isSelectedSms = @"0";
        _contentType = SEND_POST_TY;
        
    }
    return self;
}

- (id)initForBizPostWithMOC:(NSManagedObjectContext *)MOC
                      group:(Club *)group
                   delegate:(id<ItemUploaderDelegate>)delegate {
    
    self = [self initWithMOC:MOC delegate:delegate];
    
    if (self) {
        _composerShowType = COMPOSER_SHOW_IMG;
        _contentType = SEND_BIZ_POST_TY;
        
        [self prepareData];
        self.group = group;
    }
    return self;
}

- (id)initForEventDiscussWithMOC:(NSManagedObjectContext *)MOC
                        delegate:(id<ItemUploaderDelegate>)delegate
                         eventId:(NSString *)eventId {
    
    self = [self initWithMOC:MOC
                    delegate:delegate
                     groupId:eventId];
    
    if (self) {
        _composerShowType = COMPOSER_SHOW_IMG;
        _contentType = SEND_EVENT_DISCUSS_TY;
        [self prepareData];
    }
    
    return self;
}

- (id)initForCommentWithMOC:(NSManagedObjectContext *)MOC
                   delegate:(id<ItemUploaderDelegate>)delegate
                     postId:(NSString *)postId
{
    _composerShowType = COMPOSER_SHOW_IMG;
    return [self initWithMOC:MOC delegate:delegate originalItemId:postId];
}

- (id)initForShareWithMOC:(NSManagedObjectContext *)MOC
                 delegate:(id<ItemUploaderDelegate>)delegate
                  groupId:(NSString *)groupId {
    
    self = [self initWithMOC:MOC delegate:delegate];
    
    if (self) {
        self.groupId = groupId;
        _composerShowType = COMPOSER_SHOW_ALL;
        _contentType = SEND_SHARE_TY;
        
        
        [self prepareData];
        
    }
    return self;
    
}

- (void)prepareData
{
    [self clearOldPlacesData];
    if (_composerShowType == COMPOSER_SHOW_IMG) {
        return;
    }
    
    [self initTags];
    
    if (![IPAD_SIMULATOR isEqualToString:[CommonUtils deviceModel]]) {
        [AppManager instance].latitude = 0.0;
        [AppManager instance].longitude = 0.0;
        
        [self getCurrentLocationInfoIfNecessary];
    } else {
        [AppManager instance].latitude = [SIMULATION_LATITUDE doubleValue];
        [AppManager instance].longitude = [SIMULATION_LONGITUDE doubleValue];
        [self loadPlaces];
    }
}

- (void)initNavigationBar {
    
    self.navigationItem.leftBarButtonItem = BAR_BUTTON(LocaleStringForKey(NSCloseTitle, nil), UIBarButtonItemStyleBordered, self, @selector(close:));
    
    self.navigationItem.rightBarButtonItem = BAR_BUTTON(LocaleStringForKey(NSSendTitle, nil), UIBarButtonItemStyleBordered, self, @selector(send:));
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)initTextComposer {
    
    CGFloat y = 0.0f;
    if (_needMoveDownUI) {
        y += NAVIGATION_BAR_HEIGHT;
    }
    
    _textComposer = [[TextComposerView alloc] initWithFrame:CGRectMake(0, y, self.view.frame.size.width, TEXT_COMPOSER_HEIGHT)
                                                   topColor:COLOR(249, 249, 249)
                                                bottomColor:COLOR(200, 200, 200)
                                           composerDelegate:self];
    
    [self.view addSubview:_textComposer];
    
    [self addAttachmentView:CGRectMake(ATTACHMENT_X, 235.f, _frame.size.width - ATTACHMENT_X*2, 64)];
}

#pragma mark - add attachement view
- (void)addAttachmentView:(CGRect)frame
{
    
    _attachmentBGView = [[UIView alloc] initWithFrame:frame];
    _attachmentBGView.backgroundColor = TRANSPARENT_COLOR;
    [self.view addSubview:_attachmentBGView];
    
    UIImageView *_attachmentBGImageView = [[[UIImageView alloc] init] autorelease];
    _attachmentBGImageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    _attachmentBGImageView.image = [UIImage imageNamed:@"composer_bar.png"];
    [_attachmentBGView addSubview:_attachmentBGImageView];
    
    // location
    WXWImageButton *locationBut = [[[WXWImageButton alloc]
                                   initImageButtonWithFrame:CGRectZero
                                   target:self
                                   action:@selector(choosePlace:)
                                   title:nil
                                   image:nil
                                   backImgName:@"composer_location.png"
                                   selBackImgName:@"composer_location_selected.png"
                                   titleFont:nil
                                   titleColor:nil
                                   titleShadowColor:TRANSPARENT_COLOR
                                   roundedType:HAS_ROUNDED
                                   imageEdgeInsert:ZERO_EDGE
                                   titleEdgeInsert:ZERO_EDGE] autorelease];
    
    // tag
    WXWImageButton *tagBut = [[[WXWImageButton alloc]
                              initImageButtonWithFrame:CGRectZero
                              target:self
                              action:@selector(chooseTags)
                              title:nil
                              image:nil
                              backImgName:@"composer_tag.png"
                              selBackImgName:@"composer_tag_selected.png"
                              titleFont:nil
                              titleColor:nil
                              titleShadowColor:TRANSPARENT_COLOR
                              roundedType:HAS_ROUNDED
                              imageEdgeInsert:ZERO_EDGE
                              titleEdgeInsert:ZERO_EDGE] autorelease];
    
    // img
    WXWImageButton *imgBut = [[[WXWImageButton alloc]
                              initImageButtonWithFrame:CGRectZero
                              target:self
                              action:@selector(addImgFromPhotoLibrary)
                              title:nil
                              image:nil
                              backImgName:@"composer_img.png"
                              selBackImgName:@"composer_img_selected.png"
                              titleFont:nil
                              titleColor:nil
                              titleShadowColor:TRANSPARENT_COLOR
                              roundedType:HAS_ROUNDED
                              imageEdgeInsert:ZERO_EDGE
                              titleEdgeInsert:ZERO_EDGE] autorelease];
    
    // camera
    WXWImageButton *cameraBut = [[[WXWImageButton alloc]
                                 initImageButtonWithFrame:CGRectZero
                                 target:self
                                 action:@selector(addImgFromCamera)
                                 title:nil
                                 image:nil
                                 backImgName:@"composer_camera.png"
                                 selBackImgName:@"composer_camera_selected.png"
                                 titleFont:nil
                                 titleColor:nil
                                 titleShadowColor:TRANSPARENT_COLOR
                                 roundedType:HAS_ROUNDED
                                 imageEdgeInsert:ZERO_EDGE
                                 titleEdgeInsert:ZERO_EDGE] autorelease];
    
    switch (_composerShowType) {
            
        case COMPOSER_NONE:
        {
            [_attachmentBGView setHidden:YES];
        }
            break;
            
        case COMPOSER_SHOW_ALL:
        {
            int location_But_X = frame.size.width/2 - ATTACHMENT_BUTTON_SPACING-ATTACHMENT_BUTTON_SPACING/2 - ATTACHMENT_BUTTON_W * 2;
            
            // location
            locationBut.frame = CGRectMake(location_But_X, ATTACHMENT_BUTTON_Y, ATTACHMENT_BUTTON_W, ATTACHMENT_BUTTON_H);
            [_attachmentBGView addSubview:locationBut];
            
            // tag
            int tag_But_X = frame.size.width/2 - ATTACHMENT_BUTTON_SPACING/2 - ATTACHMENT_BUTTON_W;
            tagBut.frame = CGRectMake(tag_But_X, ATTACHMENT_BUTTON_Y, ATTACHMENT_BUTTON_W, ATTACHMENT_BUTTON_H);
            
            [_attachmentBGView addSubview:tagBut];
            
            // img
            int img_But_X = frame.size.width/2 + ATTACHMENT_BUTTON_SPACING/2;
            imgBut.frame = CGRectMake(img_But_X, ATTACHMENT_BUTTON_Y, ATTACHMENT_BUTTON_W, ATTACHMENT_BUTTON_H);
            
            [_attachmentBGView addSubview:imgBut];
            
            // camera
            int camera_But_X = frame.size.width/2 + ATTACHMENT_BUTTON_SPACING/2+ATTACHMENT_BUTTON_W+ATTACHMENT_BUTTON_SPACING;
            cameraBut.frame = CGRectMake(camera_But_X, ATTACHMENT_BUTTON_Y, ATTACHMENT_BUTTON_W, ATTACHMENT_BUTTON_H);
            
            [_attachmentBGView addSubview:cameraBut];
            
        }
            break;
            
        case COMPOSER_SHOW_LOCATION_IMG:
        {
            int location_But_X = frame.size.width/2 - ATTACHMENT_BUTTON_W/2 - ATTACHMENT_BUTTON_SPACING - ATTACHMENT_BUTTON_W;
            
            // location
            locationBut.frame = CGRectMake(location_But_X, ATTACHMENT_BUTTON_Y, ATTACHMENT_BUTTON_W, ATTACHMENT_BUTTON_H);
            [_attachmentBGView addSubview:locationBut];
            
            // img
            int img_But_X = frame.size.width/2 - ATTACHMENT_BUTTON_W/2;
            imgBut.frame = CGRectMake(img_But_X, ATTACHMENT_BUTTON_Y, ATTACHMENT_BUTTON_W, ATTACHMENT_BUTTON_H);
            
            [_attachmentBGView addSubview:imgBut];
            
            // camera
            int camera_But_X = frame.size.width/2 + ATTACHMENT_BUTTON_W/2+ATTACHMENT_BUTTON_SPACING;
            cameraBut.frame = CGRectMake(camera_But_X, ATTACHMENT_BUTTON_Y, ATTACHMENT_BUTTON_W, ATTACHMENT_BUTTON_H);
            
            [_attachmentBGView addSubview:cameraBut];
        }
            break;
            
        case COMPOSER_SHOW_IMG:
        {
            // img
            int img_But_X = frame.size.width/2 - ATTACHMENT_BUTTON_SPACING/2 - ATTACHMENT_BUTTON_W;
            imgBut.frame = CGRectMake(img_But_X, ATTACHMENT_BUTTON_Y, ATTACHMENT_BUTTON_W, ATTACHMENT_BUTTON_H);
            [_attachmentBGView addSubview:imgBut];
            
            // camera
            int camera_But_X = frame.size.width/2 + ATTACHMENT_BUTTON_SPACING/2;
            cameraBut.frame = CGRectMake(camera_But_X, ATTACHMENT_BUTTON_Y, ATTACHMENT_BUTTON_W, ATTACHMENT_BUTTON_H);
            [_attachmentBGView addSubview:cameraBut];
            
        }
            break;
    }
    
}

#pragma mark - ComposerDelegate method
- (void)endAction
{
    
    [_textComposer showKeyboard];
    self.navigationItem.leftBarButtonItem.enabled = YES;
    [self changeSendButtonStatus];
}

- (void)addImgContent {
    
    CGRect showPhotoFrame = CGRectMake(400, 198, 150, 87.5f);
    
    if (_composerShowType == COMPOSER_SHOW_IMG) {
        showPhotoFrame = CGRectMake(300, 198, 150, 87.5f);
    }
    
    if (_showPhotoBGView == nil) {
        _showPhotoBGView = [[[UIView alloc] init] autorelease];
        _showPhotoBGView.backgroundColor = [UIColor whiteColor];
        
        _showPhotoBGView.frame = CGRectMake(showPhotoFrame.origin.x-5, showPhotoFrame.origin.y-5, showPhotoFrame.size.width+10, showPhotoFrame.size.height+10);
        
        UIBezierPath *shadowPath = [UIBezierPath bezierPath];
        CGFloat curlFactor = 10.0f;
        CGFloat shadowDepth = 8.0f;
        [shadowPath moveToPoint:CGPointMake(0, 0)];
        [shadowPath addLineToPoint:CGPointMake(_showPhotoBGView.frame.size.width, 0)];
        [shadowPath addLineToPoint:CGPointMake(_showPhotoBGView.frame.size.width,
                                               _showPhotoBGView.frame.size.height + shadowDepth)];
        [shadowPath addCurveToPoint:CGPointMake(0.0f, _showPhotoBGView.frame.size.height + shadowDepth)
                      controlPoint1:CGPointMake(_showPhotoBGView.frame.size.width - curlFactor,
                                                _showPhotoBGView.frame.size.height + shadowDepth - curlFactor)
                      controlPoint2:CGPointMake(curlFactor,
                                                _showPhotoBGView.frame.size.height + shadowDepth - curlFactor)];
        
        _showPhotoBGView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
        _showPhotoBGView.layer.shadowOpacity = 0.7f;
        _showPhotoBGView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        _showPhotoBGView.layer.shadowRadius = 2.0f;
        _showPhotoBGView.layer.masksToBounds = NO;
        
        _showPhotoBGView.layer.shadowPath = shadowPath.CGPath;
        [self.view addSubview:_showPhotoBGView];
    } else {
        _showPhotoBGView.hidden = NO;
    }
    
    if (_showPhotoView == nil) {
        _showPhotoView = [[UIImageView alloc] init];
        _showPhotoView.frame = showPhotoFrame;
        [self.view addSubview:_showPhotoView];
    } else {
        _showPhotoView.hidden = NO;
    }
    
    _showPhotoView.image = self.selectedPhoto;
    
    if (_delPhotoBut == nil) {
        CGRect delPhotoFrame = CGRectMake(385, 183, 30, 30);
        
        if (_composerShowType == COMPOSER_SHOW_IMG) {
            delPhotoFrame = CGRectMake(285, 183, 30, 30);
        }
        
        _delPhotoBut = [[[WXWImageButton alloc]
                         initImageButtonWithFrame:delPhotoFrame
                         target:self
                         action:@selector(delImage:)
                         title:nil
                         image:nil
                         backImgName:@"closeButton.png"
                         selBackImgName:@"closeButtonSel.png"
                         titleFont:nil
                         titleColor:nil
                         titleShadowColor:TRANSPARENT_COLOR
                         roundedType:HAS_ROUNDED
                         imageEdgeInsert:ZERO_EDGE
                         titleEdgeInsert:ZERO_EDGE] autorelease];
        [self.view addSubview:_delPhotoBut];
    } else {
        _delPhotoBut.hidden = NO;
    }
    
    [self modifyTagFrame];
    [self modifyPlaceFrame];
    [self endAction];
}

- (void)addPlaceText {
    
    if (_placeLabel == nil) {
        _placeLabel = [[WXWLabel alloc] initWithFrame:CGRectZero
                                            textColor:[UIColor grayColor]
                                          shadowColor:TRANSPARENT_COLOR];
        
        
        _placeLabel.font = TIMESNEWROM_BOLD_ITALIC(15);
        _placeLabel.lineBreakMode = UILineBreakModeTailTruncation;
        
        [self.view addSubview:_placeLabel];
    } else {
        _placeLabel.hidden = NO;
    }
    
    [self modifyPlaceFrame];
    
    // location
    if (_delPlaceBut == nil) {
        
        CGRect delPlaceFrame = CGRectMake(MARGIN*5, 192, 30, 30);
        _delPlaceBut = [[WXWImageButton alloc]
                        initImageButtonWithFrame:delPlaceFrame
                        target:self
                        action:@selector(delPlace:)
                        title:nil
                        image:nil
                        backImgName:@"closeButton.png"
                        selBackImgName:@"closeButtonSel.png"
                        titleFont:nil
                        titleColor:nil
                        titleShadowColor:TRANSPARENT_COLOR
                        roundedType:HAS_ROUNDED
                        imageEdgeInsert:ZERO_EDGE
                        titleEdgeInsert:ZERO_EDGE];
        [self.view addSubview:_delPlaceBut];
    } else {
        _delPlaceBut.hidden = NO;
    }
    
    [self endAction];
}

- (void)modifyPlaceFrame {
    
    if (_placeLabel == nil)
        return;
    
    _placeLabel.text = [NSString stringWithFormat:@"%@: %@", LocaleStringForKey(NSUserPlaceTitle, nil), [AppManager instance].composerPlace];
    CGSize fontSize = [@"位置" sizeWithFont:_placeLabel.font
                        constrainedToSize:CGSizeMake(_frame.size.width-2*MARGIN, CGFLOAT_MAX)
                            lineBreakMode:UILineBreakModeWordWrap];
    
    if (_delPhotoBut && !_delPhotoBut.hidden) {
        _placeLabel.frame = CGRectMake(MARGIN*12, 198.f, 300.f, fontSize.height);
    } else {
        _placeLabel.frame = CGRectMake(MARGIN*12, 198.f, _frame.size.width - MARGIN*24, fontSize.height);
    }
    
}

- (void)addTagText {
    
    if (_tagLabel == nil) {
        _tagLabel = [[WXWLabel alloc] initWithFrame:CGRectZero
                                          textColor:[UIColor grayColor]
                                        shadowColor:TRANSPARENT_COLOR];
        
        
        _tagLabel.font = TIMESNEWROM_BOLD_ITALIC(15);
        _tagLabel.lineBreakMode = UILineBreakModeTailTruncation;
        
        [self.view addSubview:_tagLabel];
    } else {
        _tagLabel.hidden = NO;
    }
    
    [self loadTag];
    
    [self modifyTagFrame];
    
    // tag
    if (_delTagBut == nil) {
        
        CGRect delPlaceFrame = CGRectMake(MARGIN*6, 224, 16, 16);
        _delTagBut = [[WXWImageButton alloc]
                      initImageButtonWithFrame:delPlaceFrame
                      target:self
                      action:@selector(delTag:)
                      title:nil
                      image:nil
                      backImgName:@"tag.png"
                      selBackImgName:@"tag.png"
                      titleFont:nil
                      titleColor:nil
                      titleShadowColor:TRANSPARENT_COLOR
                      roundedType:HAS_ROUNDED
                      imageEdgeInsert:ZERO_EDGE
                      titleEdgeInsert:ZERO_EDGE];
        [self.view addSubview:_delTagBut];
    } else {
        _delTagBut.hidden = NO;
    }
    
    if ([_tagLabel.text length] == 0) {
        _delTagBut.hidden = YES;
    }
    
    [self dismissModalViewControllerAnimated:YES];
    [self endAction];
}

- (void)loadTag {
    // display selected tags info
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(selected == 1)"];
    NSArray *selectedTags = [CoreDataUtils fetchObjectsFromMOC:_MOC
                                                    entityName:@"ComposerTag"
                                                     predicate:predicate];
    
    NSMutableString *tagMsg = [NSMutableString string];
    int tagSize = [selectedTags count];
    
    if (tagSize > 0) {
        
        NSInteger index = 0;
        for (ComposerTag *tag in selectedTags) {
            [tagMsg appendString:tag.tagName];
            
            if (index != tagSize-1) {
                [tagMsg appendString:@","];
            }
            
            index++;
        }
    }
    
    _tagLabel.userInteractionEnabled = YES;
    _tagLabel.text = tagMsg;
}

- (void)modifyTagFrame {
    
    if (_tagLabel == nil)
        return;
    
    CGSize fontSize = [@"标签" sizeWithFont:_tagLabel.font
                        constrainedToSize:CGSizeMake(_frame.size.width-2*MARGIN, CGFLOAT_MAX)
                            lineBreakMode:UILineBreakModeWordWrap];
    
    if (_delPhotoBut && !_delPhotoBut.hidden) {
        _tagLabel.frame = CGRectMake(MARGIN*12, 224.f, 300.f, fontSize.height);
    } else {
        _tagLabel.frame = CGRectMake(MARGIN*12, 224.f, _frame.size.width - MARGIN*24, fontSize.height);
    }
    
}

- (void)initSelfViewProperties {
    
    self.view.backgroundColor = TRANSPARENT_COLOR;
}

#pragma mark - lifecycle methods
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initSelfViewProperties];
    
    [self initNavigationBar];
    
    [self initTextComposer];
    
    [_textComposer showKeyboard];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)dealloc {
    
    self.targetImage = nil;
    
    RELEASE_OBJ(_showPhotoView);
    RELEASE_OBJ(_textComposer);
    
    RELEASE_OBJ(_placeLabel);
    RELEASE_OBJ(_delPlaceBut);
    RELEASE_OBJ(_tagLabel);
    RELEASE_OBJ(_delTagBut);
    
    RELEASE_OBJ(_originalItemId);
    RELEASE_OBJ(_groupId);
    
    self.isSelectedSms = nil;
    self.content = nil;
    self.selectedPhoto = nil;
    self.imagePickerVC = nil;
    self.delegate = nil;
    self.brandId = nil;
    RELEASE_OBJ(_closePhotoBut);
    
    [super dealloc];
}

- (void)chooseSMS:(BOOL)isSelectedSms
{
    if (isSelectedSms) {
        self.isSelectedSms = @"1";
    } else {
        self.isSelectedSms = @"0";
    }
}

#pragma mark - location result
- (void)locationResult:(int)type{
    NSLog(@"shake type is %d", type);
    
    [WXWUIUtils closeActivityView];
    
    switch (type) {
        case 0:
        {
            [self loadPlaces];
        }
            break;
            
        case 1:
        {
            
            [WXWUIUtils showNotificationWithMsg:LocaleStringForKey(NSLocatingFailedMsg, nil)
                                        msgType:ERROR_TY
                                     holderView:[APP_DELEGATE foundationView]];
            debugLog(LocaleStringForKey(NSLocatingFailedMsg, nil));
        }
            break;
            
        default:
            break;
    }
    
}

#pragma mark - image picker tool bar

- (void)initImageEffectToolbar {
    
    _toolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake((self.view.bounds.size.width-TOOLBAR_W)/2, self.frame.size.height - 2*NAVIGATION_BAR_HEIGHT - 2*STATUS_BAR_HEIGHT - EFFECT_PHOTO_SAMPLE_VIEW_HEIGHT, TOOLBAR_W, TOOLBAR_HEIGHT)] autorelease];
    _toolbar.barStyle = UIBarStyleBlack;
    
    [self addImageEffectButtons];
    
    [self.displayBoard addSubview:_toolbar];
}

- (void)addImageEffectButtons
{
    
    UIButton *leftRotateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftRotateBtn.frame = CGRectMake(0, 0, ICON_SIDE_LENGTH, ICON_SIDE_LENGTH);
    leftRotateBtn.backgroundColor = TRANSPARENT_COLOR;
    [leftRotateBtn addTarget:self action:@selector(doLeftRotate:) forControlEvents:UIControlEventTouchUpInside];
    [leftRotateBtn setImage:[UIImage imageNamed:@"leftRotation.png"] forState:UIControlStateNormal];
    leftRotateBtn.showsTouchWhenHighlighted = YES;
    UIBarButtonItem *leftRotateBtnItem = [[[UIBarButtonItem alloc] initWithCustomView:leftRotateBtn] autorelease];
    
    UIBarButtonItem *spaceBtn = BAR_SYS_BUTTON(UIBarButtonSystemItemFlexibleSpace, nil, nil);
    
    UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmBtn.frame = CGRectMake(0, 0, ICON_SIDE_LENGTH, ICON_SIDE_LENGTH);
    confirmBtn.backgroundColor = TRANSPARENT_COLOR;
    [confirmBtn addTarget:self
                   action:@selector(confirmPhoto:)
         forControlEvents:UIControlEventTouchUpInside];
    [confirmBtn setImage:[UIImage imageNamed:@"agree.png"] forState:UIControlStateNormal];
    
    confirmBtn.showsTouchWhenHighlighted = YES;
    UIBarButtonItem *confirmBarBtn = [[[UIBarButtonItem alloc] initWithCustomView:confirmBtn] autorelease];
    
    UIButton *rightRotateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightRotateBtn.frame = CGRectMake(0, 0, ICON_SIDE_LENGTH, ICON_SIDE_LENGTH);
    rightRotateBtn.backgroundColor = TRANSPARENT_COLOR;
    [rightRotateBtn addTarget:self action:@selector(doRightRotate:) forControlEvents:UIControlEventTouchUpInside];
    [rightRotateBtn setImage:[UIImage imageNamed:@"rightRotation.png"] forState:UIControlStateNormal];
    rightRotateBtn.showsTouchWhenHighlighted = YES;
    
    UIBarButtonItem *rightRotateBtnItem = [[[UIBarButtonItem alloc] initWithCustomView:rightRotateBtn] autorelease];
    
    [_toolbar setItems:[NSArray arrayWithObjects:leftRotateBtnItem, spaceBtn, confirmBarBtn, spaceBtn, rightRotateBtnItem, nil]
              animated:YES];
}

- (void)handleTakenImage:(UIImage *)image {
    
    self.originalImage = [CommonUtils scaleAndRotateImage:image
                                               sourceType:_sourceType];
    
    self.selectedImage = self.originalImage;
    self.targetImage = self.originalImage;
    
    imgWidth = self.originalImage.size.width;
    imgHeight = self.originalImage.size.height;
    
    CGImageRef imgRef = self.targetImage.CGImage;
    imgWidth = CGImageGetWidth(imgRef);
    imgHeight = CGImageGetHeight(imgRef);
    
    rotateWidth = [[UIScreen mainScreen] bounds].size.width;
    rotateStep = 3;
    
    [self showTargetImage];
    
    [self showPalette];
}

- (void)showPalette {
    
    self.palette = [[[WXWPhotoEffectSamplesView alloc] initWithFrame:CGRectZero
                                                       originalImage:self.originalImage                                                             target:self
                                                              action:@selector(applyEffectedImage:)] autorelease];
    
    self.palette.alpha = 0.0f;
    [self.displayBoard addSubview:self.palette];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2f];
    
    self.palette.alpha = 1.0f;
    self.palette.frame = CGRectMake(0, self.frame.size.height - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT - EFFECT_PHOTO_SAMPLE_VIEW_HEIGHT, self.view.bounds.size.width, EFFECT_PHOTO_SAMPLE_VIEW_HEIGHT);
    
    [UIView commitAnimations];
}

- (void)applyEffectedImage:(UIImage *)effectedImage {
    
    NSLog(@"effectedImage width: %f", effectedImage.size.width);
    NSLog(@"effectedImage height: %f", effectedImage.size.height);
    
    self.selectedImage = effectedImage;
    self.targetImage = effectedImage;
    _displayedImageView.image = effectedImage;
    
    [self doRotate:nil];
}

- (void)showTargetImage {
    
    CGFloat width = 0.0f;
    CGFloat height = 0.0f;
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    
    NSInteger currentSameOrientation = [self currentSameOrientation];
    
    BOOL isBigImage = NO;
    if (currentSameOrientation == DIFF_ORI) {
        isBigImage = [self imageIsBigWithDifferentOrientation:self.originalImage.size.width height:self.originalImage.size.height];
    } else {
        isBigImage = [self imageIsBigWithSameOrientation:currentSameOrientation width:self.originalImage.size.width height:self.originalImage.size.height];
    }
    
    switch (currentSameOrientation) {
        case LANDSCAPE_ORI:
        {
            // both device and image are landscape orientation
            if (isBigImage) {
                if (self.originalImage.size.width/self.originalImage.size.height > LANDSCAPE_W_H_RATIO) {
                    // means the width is the base, height should be calculated according to the ratio
                    width = self.view.bounds.size.width;
                    height = (self.originalImage.size.height/self.originalImage.size.width)*width;
                    x = 0;
                    y = (DISPLAY_BOARD_HEIGHT - height) / 2;
                } else if (self.originalImage.size.width/self.originalImage.size.height < LANDSCAPE_W_H_RATIO) {
                    // means the height is the base, width should be calculated according to the ratio
                    height = DISPLAY_IMAGE_HEIGHT;
                    width = (self.originalImage.size.width/self.originalImage.size.height)*height;
                    y = DISPLAY_IMAGE_X;
                    x = (self.view.bounds.size.width - width)/2;
                } else {
                    // image width/height is same as current device width/height, then the displayed width and height
                    // could be the same as the width and height of device
                    x = 0;
                    y = 0;
                    width = self.view.bounds.size.width;
                    height = DISPLAY_BOARD_HEIGHT;
                }
                
            } else {
                // image size is smaller than the screen size, so the actual displayed x and y could be
                // calculated according to the actual width and height of image and screen size
                height = self.originalImage.size.height;
                width = self.originalImage.size.width;
                x = (self.view.bounds.size.width - width)/2;
                y = (DISPLAY_BOARD_HEIGHT - height)/2;
            }
            
            break;
        }
            
        case PORTRAIT_ORI:
        {
            // both device and image are portrait
            if (isBigImage) {
                if (self.originalImage.size.width/self.originalImage.size.height > PORTRAIT_W_H_RATIO) {
                    height = DISPLAY_BOARD_HEIGHT;
                    width = (DISPLAY_BOARD_HEIGHT * self.originalImage.size.width)/self.originalImage.size.height;
                    x = 0;
                    y = 0;
                } else if (self.originalImage.size.width/self.originalImage.size.height < PORTRAIT_W_H_RATIO) {
                    height = DISPLAY_BOARD_HEIGHT;
                    width = (self.originalImage.size.width/self.originalImage.size.height)*height;
                    y = 0;
                    x = (self.view.bounds.size.width - width)/2;
                } else {
                    x = 0;
                    y = 0;
                    width = self.view.bounds.size.width;
                    height = DISPLAY_BOARD_HEIGHT;
                }
                
            } else {
                height = self.originalImage.size.height;
                width = self.originalImage.size.width;
                x = (self.view.bounds.size.width - width)/2;
                y = (DISPLAY_BOARD_HEIGHT - height)/2;
            }
            
            break;
        }
            
        case DIFF_ORI:
        {
            if (isBigImage) {
                if (DEVICE_IS_LANDSCAPE) {
                    // image is portrait
                    height = DISPLAY_IMAGE_HEIGHT;
                    width = (self.originalImage.size.width/self.originalImage.size.height)*height;
                    x = (self.view.bounds.size.width - width)/2;
                    y = DISPLAY_IMAGE_X;
                } else {
                    // image is landscape
                    width = self.view.bounds.size.width;
                    height = (self.originalImage.size.height/self.originalImage.size.width)*width;
                    x = 0;
                    y = (DISPLAY_BOARD_HEIGHT - height)/2;
                }
            } else {
                
                height = self.originalImage.size.height;
                width = self.originalImage.size.width;
                if (DEVICE_IS_LANDSCAPE) {
                    x = (self.view.bounds.size.width - width)/2;
                    y = (DISPLAY_BOARD_HEIGHT - height)/2;
                } else {
                    x = (self.view.bounds.size.width - width)/2;
                    y = (DISPLAY_BOARD_HEIGHT - height)/2;
                }
            }
            break;
        }
            
        default:
            break;
    }
    
    self.displayBoard = [[[UIView alloc] init] autorelease];
    self.displayBoard.frame = CGRectMake(0, 0, self.view.bounds.size.width, DISPLAY_BOARD_HEIGHT);
    self.displayBoard.backgroundColor = TRANSPARENT_COLOR;
    
    CGRect displayedImageFrame = CGRectMake(x, y, width, height);
    displayW = width;
    displayH = height;
    
    _displayedImageView = [[[UIImageView alloc] initWithFrame:displayedImageFrame] autorelease];
    _displayedImageView.image = self.originalImage;
    
    _closePhotoBut = [[WXWImageButton alloc]
                      initImageButtonWithFrame:CGRectMake(x-15, y-15, 30, 30)
                      target:self
                      action:@selector(closePhoto:)
                      title:nil
                      image:nil
                      backImgName:@"closeButton.png"
                      selBackImgName:@"closeButtonSel.png"
                      titleFont:nil
                      titleColor:nil
                      titleShadowColor:TRANSPARENT_COLOR
                      roundedType:HAS_ROUNDED
                      imageEdgeInsert:ZERO_EDGE
                      titleEdgeInsert:ZERO_EDGE];
    
    [self.displayBoard addSubview:_displayedImageView];
    [self.displayBoard addSubview:_closePhotoBut];
    [self.view addSubview:self.displayBoard];
}

- (NSInteger)currentSameOrientation {
    
    if (DEVICE_IS_LANDSCAPE && IMAGE_IS_LANDSCAPE) {
        return LANDSCAPE_ORI;
    }
    
    if (!DEVICE_IS_LANDSCAPE && !IMAGE_IS_LANDSCAPE) {
        return PORTRAIT_ORI;
    }
    
    return DIFF_ORI;
}

#pragma mark - handle photo taken
- (BOOL)imageIsBigWithSameOrientation:(NSInteger)orientation width:(float)width height:(float)height {
    
    switch (orientation) {
        case LANDSCAPE_ORI:
            return (width > self.view.bounds.size.width || height > DISPLAY_BOARD_HEIGHT);
            
        case PORTRAIT_ORI:
            return (width > self.view.bounds.size.width || height > DISPLAY_BOARD_HEIGHT);
            
        default:
            return NO;
    }
}

- (BOOL)imageOrientationIsLandscape {
    return self.originalImage.size.width > self.originalImage.size.height;
}

- (BOOL)imageIsBigWithDifferentOrientation:(float)width height:(float)height {
    
    if (DEVICE_IS_LANDSCAPE) {
        // means image is portrait
        if (height > DISPLAY_BOARD_HEIGHT) {
            return YES;
        } else {
            return NO;
        }
    } else {
        // means image is landscape
        if (width > self.view.bounds.size.width) {
            return YES;
        } else {
            return NO;
        }
    }
}

#pragma mark - effect action

- (void)doRotate:(id)sender
{
    CGSize targetSize;
    CGSize editSize;
    
    switch (rotateStep) {
        case 0:
        {
            int x = (self.view.frame.size.width - displayH) / 2;
            int y = (self.view.frame.size.height - displayW) / 2;
            
            _displayedImageView.frame = CGRectMake(x, y, displayH, displayW);
            
            UIImage *showImg = [self.targetImage imageRotatedByDegrees:90.0];
            targetSize = CGSizeMake(displayH, displayW);
            
            _displayedImageView.image = [showImg imageByScalingProportionallyToSize:targetSize];
            
            editSize = CGSizeMake(displayW, displayH);
            UIImage *editImg = [self.targetImage imageByScalingProportionallyToSize:editSize];
            self.selectedImage = [editImg imageRotatedByDegrees:90.0];
            
            break;
        }
            
        case 1:
        {
            int x = (self.view.frame.size.width - displayW) / 2;
            int y = (self.view.frame.size.height - displayH) / 2;
            
            _displayedImageView.frame = CGRectMake(x, y, displayW, displayH);
            
            self.selectedImage = [self.targetImage imageRotatedByDegrees:180.0];
            _displayedImageView.image = self.selectedImage;
            break;
        }
            
        case 2:
        {
            int x = (self.view.frame.size.width - displayH) / 2;
            int y = (self.view.frame.size.height - displayW) / 2;
            
            _displayedImageView.frame = CGRectMake(x, y, displayH, displayW);
            
            UIImage *showImg = [self.targetImage imageRotatedByDegrees:270.0];
            
            targetSize = CGSizeMake(displayH, displayW);
            _displayedImageView.image = [showImg imageByScalingProportionallyToSize:targetSize];
            
            editSize = CGSizeMake(displayW, displayH);
            UIImage *editImg = [self.targetImage imageByScalingProportionallyToSize:editSize];
            self.selectedImage = [editImg imageRotatedByDegrees:270.0];
            
            break;
        }
            
        case 3:
        {
            int x = (self.view.frame.size.width - displayW) / 2;
            int y = (self.view.frame.size.height - displayH) / 2;
            
            _displayedImageView.frame = CGRectMake(x, y, displayW, displayH);
            
            self.selectedImage = self.targetImage;
            _displayedImageView.image = self.targetImage;
            break;
        }
            
        default:
            break;
    }
    
    _closePhotoBut.frame = CGRectMake(_displayedImageView.frame.origin.x-15, _displayedImageView.frame.origin.y-15, 30, 30);
}

- (void)doRightRotate:(id)sender
{
    
    if (rotateStep >= 3) {
        rotateStep = 0;
    } else {
        rotateStep ++;
    }
    
    [self doRotate:sender];
}

- (void)doLeftRotate:(id)sender {
    
    if (rotateStep <= 0) {
        rotateStep = 3;
    } else {
        rotateStep --;
    }
    
    [self doRotate:sender];
}

- (void)closePhoto:(id)sender {
    
    if (self.displayBoard) {
        [self.displayBoard removeFromSuperview];
        self.displayBoard = nil;
    }
    
    self.palette = nil;
    self.originalImage = nil;
    [self endAction];
    [self removeDisableView];
}

- (void)confirmPhoto:(id)sender {
    self.selectedPhoto = self.selectedImage;
    
    [self addImgContent];
    [self closePhoto:nil];
    
}

#pragma mark - UIPopoverControllerDelegate method
- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController{
    return YES;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    [self endAction];
}

@end
