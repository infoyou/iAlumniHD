//
//  ImagePickerViewController.m
//  iAlumniHD
//
//  Created by Adam on 12-10-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ImagePickerViewController.h"
#import "ECPhotoPickerOverlayDelegate.h"
#import "UIDevice-Hardware.h"

#define SELF_VIEW_TAG               9000
#define CAMERA_TRANSFORM            1.00f

#define BTN_WIDTH                   70.0f
#define BTN_HEIGHT                  40.0f

@interface ImagePickerViewController()
@property (nonatomic, retain) UIImage *originalImage;
@property (nonatomic, retain) UIImage *selectedImage;
@property (nonatomic, retain) UIView *displayBoard;
@property (nonatomic, retain) id<ItemUploaderDelegate> uploaderDelegate;
@property (nonatomic, retain) id<ECPhotoPickerOverlayDelegate> delegate;
@property (nonatomic, copy) NSString *itemId;
@end

@implementation ImagePickerViewController

@synthesize imagePicker = _imagePicker;
@synthesize originalImage = _originalImage;
@synthesize selectedImage = _selectedImage;
@synthesize delegate = _delegate;
@synthesize uploaderDelegate = _uploaderDelegate;
@synthesize itemId = _itemId;
@synthesize needSaveToAlbum = _needSaveToAlbum;
@synthesize _popVC;

#pragma mark - camera controller buttons

- (void)creaetFlashControllerButton:(UIButton **)button
                              frame:(CGRect)frame
                             action:(SEL)action
                              title:(NSString *)title {
    
    *button = [UIButton buttonWithType:UIButtonTypeCustom];
    (*button).frame = frame;
    (*button).backgroundColor = [UIColor colorWithWhite:0.5f alpha:0.6f];
    [(*button) addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [(*button) setTitle:title forState:UIControlStateNormal];
    (*button).titleLabel.font = BOLD_FONT(14);
    [_flashButtonBoard addSubview:(*button)];
}

- (NSString *)currentFlashModeName {
    switch (self.imagePicker.cameraFlashMode) {
        case UIImagePickerControllerCameraFlashModeOff:
            return LocaleStringForKey(NSOffTitle, nil);
            
        case UIImagePickerControllerCameraFlashModeOn:
            return LocaleStringForKey(NSOnTitle, nil);
            
        case UIImagePickerControllerCameraFlashModeAuto:
            return LocaleStringForKey(NSAutoTitle, nil);
            
        default:
            return nil;
    }
}

- (void)createFlashButton {
    _flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _flashButton.frame = CGRectMake(0, 0, BTN_WIDTH, BTN_HEIGHT);
    _flashButton.backgroundColor = TRANSPARENT_COLOR;
    [_flashButton addTarget:self
                     action:@selector(expandFlashBoard:)
           forControlEvents:UIControlEventTouchUpInside];
    [_flashButton setImage:[UIImage imageNamed:@"lightning.png"] forState:UIControlStateNormal];
    [_flashButton setTitle:[self currentFlashModeName] forState:UIControlStateNormal];
    _flashButton.titleLabel.font = BOLD_FONT(14);
    
    [_flashButtonBoard addSubview:_flashButton];
}

- (void)collapseFlashBoard {
    
    [_autoFlashButton removeFromSuperview];
    _autoFlashButton = nil;
    
    [_offFlashButton removeFromSuperview];
    _offFlashButton = nil;
    
    [_onFlashButton removeFromSuperview];
    _onFlashButton = nil;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2f];
    
    [self createFlashButton];
    _flashButtonBoard.frame = CGRectMake(MARGIN * 2, 0, BTN_WIDTH, BTN_HEIGHT);
    
    [UIView commitAnimations];
}

- (void)turnFlashOff:(id)sender {
    self.imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
    [self collapseFlashBoard];
}

- (void)turnFlashOn:(id)sender {
    self.imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
    [self collapseFlashBoard];
}

- (void)turnFlashAuto:(id)sender {
    self.imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
    [self collapseFlashBoard];
}

- (void)expandFlashBoard:(id)sender {
    
    if (_flashButton) {
        [_flashButton removeFromSuperview];
        _flashButton = nil;
    }
    
    [self creaetFlashControllerButton:&_autoFlashButton
                                frame:CGRectMake(0, 0, BTN_WIDTH - 1, BTN_HEIGHT)
                               action:@selector(turnFlashAuto:)
                                title:LocaleStringForKey(NSAutoTitle, nil)];
    [_autoFlashButton setImage:[UIImage imageNamed:@"lightning.png"] forState:UIControlStateNormal];
    
    [self creaetFlashControllerButton:&_onFlashButton
                                frame:CGRectMake(_autoFlashButton.frame.size.width + 1, 0, 60.0f - 1, BTN_HEIGHT)
                               action:@selector(turnFlashOn:)
                                title:LocaleStringForKey(NSOnTitle, nil)];
    [self creaetFlashControllerButton:&_offFlashButton
                                frame:CGRectMake(_onFlashButton.frame.size.width + _onFlashButton.frame.origin.x + 1, 0, 60.0f, BTN_HEIGHT)
                               action:@selector(turnFlashOff:)
                                title:LocaleStringForKey(NSOffTitle, nil)];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2f];
    
    _flashButtonBoard.frame = CGRectMake(MARGIN * 2, 0, 190.0f, BTN_HEIGHT);
    
    [UIView commitAnimations];
}

- (void)initFlashButtonBoard:(BOOL)animated {
    
    if (nil == _flashButtonBoard) {
        
        _flashButtonBoard = [[UIView alloc] initWithFrame:CGRectMake(MARGIN * 2, 0, BTN_WIDTH, BTN_HEIGHT)];
        _flashButtonBoard.layer.cornerRadius = 20.0f;
        _flashButtonBoard.layer.masksToBounds = YES;
        _flashButtonBoard.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.6f];
        [self.view addSubview:_flashButtonBoard];
        
        if (nil == _flashButton) {
            [self createFlashButton];
        }
    }
    
    if (animated) {
        _flashButtonBoard.alpha = 0.0f;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2f];
        _flashButtonBoard.alpha = 1.0;
        [UIView commitAnimations];
    }
}

- (void)removeFlashButtonBoard {
    
    _flashButton = nil;
    
    [_flashButtonBoard removeFromSuperview];
    RELEASE_OBJ(_flashButtonBoard);
}

- (void)hideFlashButtonBoard {
    if (_flashButtonBoard) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(removeFlashButtonBoard)];
        _flashButtonBoard.alpha = 0.0f;
        [UIView commitAnimations];
    }
}

- (void)switchFrontRear:(id)sender {
    if (self.imagePicker.cameraDevice == UIImagePickerControllerCameraDeviceRear) {
        self.imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    } else {
        self.imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }
    
    if ([UIImagePickerController isFlashAvailableForCameraDevice:self.imagePicker.cameraDevice]) {
        
        [self initFlashButtonBoard:YES];
    } else {
        [self hideFlashButtonBoard];
    }
}

#pragma mark - user actions

- (void)browseAlbum:(id)sender {
    
    self.needSaveToAlbum = NO;
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    // strange, why use clicks the album in photo picker, all views will be move up 20, so reset the position,
    // when user close the photo picker after he/she browse album in photo picker
    if ([CommonUtils currentOSVersion] >= IOS5) {
        _needMoveDownComposerSubViews = YES;
    } else {
        [UIApplication sharedApplication].statusBarHidden = NO;
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
    }
}

- (void)takePhoto:(id)sender {
    
    self.needSaveToAlbum = YES;
    
    [self.imagePicker takePicture];
}

- (void)doClose {
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
    
    [self.imagePicker dismissModalViewControllerAnimated:YES];
    
    if (self.delegate) {
        
        if (_needMoveDownComposerSubViews) {
            [self.delegate adjustUIAfterUserBrowseAlbumInImagePicker];
        }
        
        [self.delegate didFinishWithCamera];
    }
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)as clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (as.cancelButtonIndex == buttonIndex) {
        return;
    } else {
        [self doClose];
    }
}

#pragma mark - lifecycle methods

- (void)addRearFrontSwitchButton {
    UIButton *switchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    switchBtn.frame = CGRectMake(self.view.bounds.size.width - BTN_WIDTH - MARGIN * 2, 0, BTN_WIDTH, BTN_HEIGHT);
    switchBtn.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.6f];
    [switchBtn addTarget:self
                  action:@selector(switchFrontRear:)
        forControlEvents:UIControlEventTouchUpInside];
    [switchBtn setImage:[UIImage imageNamed:@"switchFrontRear.png"] forState:UIControlStateNormal];
    
    switchBtn.layer.cornerRadius = 20.0f;
    switchBtn.layer.masksToBounds = YES;
    
    [self.view addSubview:switchBtn];
}

- (id)initWithSourceType:(UIImagePickerControllerSourceType)sourceType
                delegate:(id<ECPhotoPickerOverlayDelegate>)delegate
        uploaderDelegate:(id<ItemUploaderDelegate>)uploaderDelegate
               takerType:(PhotoTakerType)takerType
                     MOC:(NSManagedObjectContext *)MOC
{
    self = [super initWithMOC:MOC];
    
    if (self) {
        _sourceType = sourceType;
        self.delegate = delegate;
        self.uploaderDelegate = uploaderDelegate;
        _takerType = takerType;
    }
    return self;
}

- (id)initForServiceUploadPhoto:(NSString *)itemId
                     SourceType:(UIImagePickerControllerSourceType)sourceType
                       delegate:(id<ECPhotoPickerOverlayDelegate>)delegate
               uploaderDelegate:(id<ItemUploaderDelegate>)uploaderDelegate
                      takerType:(PhotoTakerType)takerType
                            MOC:(NSManagedObjectContext *)MOC {
    
    self = [self initWithSourceType:sourceType
                           delegate:delegate
                   uploaderDelegate:uploaderDelegate
                          takerType:takerType
                                MOC:MOC];
    if (self) {
        self.itemId = itemId;
    }
    return self;
}

- (void)arrangeViews {

    self.view.backgroundColor = TRANSPARENT_COLOR;
    
    self.view.tag = SELF_VIEW_TAG;
    
    BOOL hasFrontCamera = NO;
    BOOL hasFlash = NO;
    
    if ([IPHONE_4_NAMESTRING isEqualToString:[CommonUtils deviceModel]] ||
        [IPHONE_4S_NAMESTRING isEqualToString:[CommonUtils deviceModel]] ||
        [IPHONE_5_NAMESTRING isEqualToString:[CommonUtils deviceModel]]) {
        
        hasFrontCamera = YES;
        hasFlash = YES;
        
    } else if ([IPOD_4G_NAMESTRING isEqualToString:[CommonUtils deviceModel]]) {
        hasFrontCamera = YES;
    }
    
    if (hasFrontCamera) {
        [self addRearFrontSwitchButton];
    }
    
    if (hasFlash) {
        [self initFlashButtonBoard:NO];
    }
    
    [self initPhotoPicker];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    
    self.imagePicker = nil;
    self.originalImage = nil;
    self.selectedImage = nil;
    
    self.displayBoard = nil;
    self.uploaderDelegate = nil;
    self.delegate = nil;
    
    _popVC = nil;
    
    RELEASE_OBJ(_flashButtonBoard);
    
    [super dealloc];
}

- (void)initPhotoPicker {
    
    self.imagePicker = [[[UIImagePickerController alloc] init] autorelease];
    self.imagePicker.delegate = self;
    self.imagePicker.sourceType = _sourceType;
//    self.imagePicker.allowsEditing = YES;
    
    switch (_sourceType) {
        case UIImagePickerControllerSourceTypeCamera:
        {
            self.imagePicker.showsCameraControls = YES;
            
            CGAffineTransform cameraTransform = CGAffineTransformMakeScale(1.0f, CAMERA_TRANSFORM);
            self.imagePicker.cameraViewTransform = cameraTransform;
            
//            if (0 == self.imagePicker.cameraOverlayView.subviews.count) {
//                [self.imagePicker.cameraOverlayView addSubview:self.view];
//            }
            break;
        }
            
        case UIImagePickerControllerSourceTypePhotoLibrary:
        {
            break;
        }
        default:
            break;
    }
}

#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker 
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    [self.delegate didTakePhoto:[CommonUtils rotateImage:image]];
    
    if (_popVC) {
        [_popVC dismissPopoverAnimated:NO];
    }

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    if (_sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        
        [self.imagePicker dismissModalViewControllerAnimated:YES];
    } else {
        
        // user opens album from camera controllers, then user cancel the album pick action, 
        // the image picker source type should be recoveried as UIImagePickerControllerSourceTypeCamera
        self.imagePicker.sourceType = _sourceType;
    }
    
    _userSelectPhotoFromAlbum = NO;
}

@end
