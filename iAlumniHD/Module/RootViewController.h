//
//  RootViewController.h
//  iAlumniHD
//
//  Created by Adam on 12-10-12.
//
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/ABPersonViewController.h>
#import <AddressBookUI/ABUnknownPersonViewController.h>
#import <MapKit/MKReverseGeocoder.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreData/CoreData.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CGColor.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "MessageUI/MessageUI.h"
#import "WXWConnectionTriggerHolderDelegate.h"
#import "LocationFetcherDelegate.h"
#import "ImageDisplayerDelegate.h"
#import "WXWConnectorDelegate.h"
#import "iAlumniHDAppDelegate.h"
#import "GlobalConstants.h"
#import "LocationManager.h"
#import "DebugLogOutput.h"
#import "TextConstants.h"
#import "CoreDataUtils.h"
#import "CommonUtils.h"
#import "EncryptUtil.h"
#import "ImageCache.h"
#import "AppManager.h"
#import "XMLParser.h"
#import "WXWUIUtils.h"

#import "WXWAsyncConnectorFacade.h"
#import "WXWConnector.h"

#import "WXWGradientButton.h"
#import "WXWImageButton.h"

#import "WXWNavigationController.h"
#import "HorizontalScrollViewController.h"

#import "MobClick.h"
#import "WXApi.h"

@class WXWAsyncConnectorFacade;
@class WXWConnector;

@protocol ModalViewControllerDelegate <NSObject>
@optional
-(void)modalViewControllerDidFinish;
@end

@protocol DeSelectCellDelegate <NSObject>
@optional
- (void)deSelectCell;
@end

@interface RootViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, WXWConnectorDelegate, ImageDisplayerDelegate, LocationFetcherDelegate, WXWConnectionTriggerHolderDelegate, UIPopoverControllerDelegate, ModalViewControllerDelegate, DeSelectCellDelegate, UINavigationControllerDelegate> {
    
    CGRect _frame;
    WebItemType _currentType;
    BOOL _needGoHome;
    int _alertType;
    
    UITableView *_tableView;
    
    NSManagedObjectContext *_MOC;
    NSFetchedResultsController *_fetchedRC;
    NSPredicate *_predicate;
    NSString *_entityName;
    NSMutableArray *_descriptors;
    
    UIPickerView *_PickerView;
    NSMutableArray *_DropDownValArray;
    NSMutableArray *_PickData;
    UIView *_PopView;
    UIView *_PopBGView;
    
    UIPopoverController *_popViewController;
    UIPopoverArrowDirection _UIPopoverArrowDirection;
    BOOL    _isPop;
    
    int iFliterIndex;
    int pickSel0Index;
    int pickSel1Index;
    int _pickSize;
    BOOL isPickSelChange;
    
    NSString *_sectionNameKeyPath;
    UIActivityIndicatorView *_activityView;
    UIView *_activityBackgroundView;
    UILabel *_loadingLabel;
    
    id _holder;
    SEL _backToHomeAction;
    
    WXWAsyncConnectorFacade *_connFacade;
    NSString *_connectionErrorMsg;
    
    NSMutableDictionary *_connDic;
    
    NSMutableDictionary *_errorMsgDic;
    
    NSMutableDictionary *_imageUrlDic;
    
    // sub class responsible for setting this message, then closeAsyncLoadingView will check its value
    // to determine whether show this message
    NSString *_connectionResultMessage;
    
    LocationManager *_locationManager;
    
    UIView *disableViewOverlay;
    
    // Modal View
    id <ModalViewControllerDelegate>  _modalDelegate;
    
    // deselect cell
    NSIndexPath *_selectedIndexPath;
    id <DeSelectCellDelegate>  _deSelectCellDelegate;
    id <UINavigationControllerDelegate> _ncDelegate;
    
    // swipe back to parent view controller
    BOOL _allowSwipeBackToParentVC;
    
@private
    // async loading
    UIView *_asyncLoadingBackgroundView;
    UILabel *_asyncLoadingLabel;
    UIImageView *_operaFacebookImageView;
    BOOL _reverseFromRightToLeft;
    BOOL _stopAsyncLoading;
    BOOL _blockCurrentView;
    BOOL _userCancelledLocate;
    
    // tiny notification
    UIView *_tinyNotifyBackgroundView;
    UILabel *_tinyNotifyLabel;
    
    // animate view
    UIViewController *modalDisplayedVC;
    
    // location
    BOOL _showLocationErrorMsg;
    
}

@property (nonatomic, assign) CGRect frame;
@property (nonatomic, retain) NSManagedObjectContext *MOC;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) WXWAsyncConnectorFacade *connFacade;
@property (nonatomic, retain) NSString *connectionErrorMsg;
@property (nonatomic, retain) NSMutableDictionary *connDic;
@property (nonatomic, retain) NSMutableDictionary *errorMsgDic;
@property (nonatomic, retain) NSMutableDictionary *imageUrlDic;
@property (nonatomic, retain) NSFetchedResultsController *fetchedRC;
@property (nonatomic, copy) NSString *entityName;
@property (nonatomic, copy) NSString *sectionNameKeyPath;
@property (nonatomic, retain) NSMutableArray *descriptors;
@property (nonatomic, retain) NSPredicate *predicate;
@property (nonatomic, copy) NSString *connectionResultMessage;
@property (nonatomic, retain) UIView *disableViewOverlay;

@property (nonatomic, assign) id <ModalViewControllerDelegate> modalDelegate;
@property (nonatomic, retain) NSIndexPath *selectedIndexPath;
@property (nonatomic, assign) id <DeSelectCellDelegate> deSelectCellDelegate;
@property (nonatomic, assign) id <UINavigationControllerDelegate> ncDelegate;

// Picker View
@property (nonatomic,retain) UIPickerView   *_PickerView;
@property (nonatomic,retain) NSMutableArray *DropDownValArray;
@property (nonatomic,retain) NSMutableArray *PickData;
@property (nonatomic,retain) UIView *_PopView;
@property (nonatomic,retain) UIView *_PopBGView;

// animate view
@property (nonatomic, retain) UIViewController *modalDisplayedVC;

#pragma mark - Table
- (void)initTableView;
- (void)deselectCell;

#pragma mark - init view
- (void)addCloseBar;

- (id)initWithMOC:(NSManagedObjectContext *)MOC;
- (id)initWithMOC:(NSManagedObjectContext *)MOC frame:(CGRect)frame;
- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder
 backToHomeAction:(SEL)backToHomeAction
       needGoHome:(BOOL)needGoHome;

#pragma mark - network consumer methods
- (WXWAsyncConnectorFacade *)setupAsyncConnectorForUrl:(NSString *)url
                                          contentType:(WebItemType)contentType;

#pragma mark - check connection error message
- (BOOL)connectionMessageIsEmpty:(NSError *)error;

#pragma mark - back to homepage
- (void)backToHomepage:(id)sender;

#pragma mark - cancel connection/location when navigation back to parent layer
- (void)cancelConnection;
- (void)cancelLocation;

#pragma mark - location fetch
- (void)forceGetLocation;
- (void)getCurrentLocationInfoIfNecessary;
- (void)forceGetLocationNeedShowErrorMsg:(BOOL)showErrorMsg;

#pragma mark - async loading animation
- (void)showAsyncLoadingView:(NSString *)message blockCurrentView:(BOOL)blockCurrentView;
- (void)changeAsyncLoadingMessage:(NSString *)message;
- (void)closeAsyncLoadingView;

#pragma mark - show tiny notification
- (void)showTinyNotification:(NSString *)message;

#pragma mark - cancel connection and image loading
- (void)cancelConnectionAndImageLoading;

#pragma mark - Clear Picker Select Index
- (void)clearPickerSelIndex2Init:(int)size;

#pragma mark - picker
- (void)pickerSelectRow:(NSInteger)row;
- (void)setDropDownValueArray;
- (void)setPopView;
- (void)onPopCancle;
- (void)onPopSelectedOk;
- (int)pickerList0Index;

#pragma mark - core data
- (NSFetchedResultsController *)prepareFetchRC;

#pragma mark - DisableView option
- (void)initDisableView:(CGRect)frame;
- (void)showDisableView;
- (void)removeDisableView;

#pragma mark - manage modal view controller
- (void)presentModalQuickViewController:(RootViewController *)vc;
- (void)presentModalQuickView:(UIView *)vc;
- (void)dismissModalQuickView;

#pragma mark - core data
- (void)setFetchCondition;
- (NSFetchedResultsController *)prepareFetchRC;

#pragma mark - cancel connection/location when navigation back to parent layer
- (void)cancelConnection;
- (void)cancelLocation;

#pragma mark - location fetch
- (void)forceGetLocation;
- (void)getCurrentLocationInfoIfNecessary;

#pragma mark - ImageDisplayerDelegate method
- (void)registerImageUrl:(NSString *)url;

#pragma mark - close action
- (void)close:(id)sender;
- (void)closeModal:(id)sender;

#pragma mark - table option
- (void)hideTable;
- (void)showTable;

#pragma mark - refresh
- (void)doParentRefresh;
- (void)doParentRefreshView;
- (void)setRefreshVC:(RootViewController *)rootVC;

#pragma mark - set bar item buttons
- (void)setRightButtonTitle:(NSString *)title;
- (void)setLeftButtonTitle:(NSString *)title;
- (void)addRightBarButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action;
- (void)addLeftBarButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action;

#pragma mark - add right bar button
- (void)addRightBarButton:(SEL)action;

- (void)reSizeTable;

@end
