//
//  BaseUITableViewCell.h
//  iAlumniHD
//
//  Created by Adam on 12-10-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <QuartzCore/QuartzCore.h>
#import "WXWAsyncConnectorFacade.h"
#import "WXWConnectionTriggerHolderDelegate.h"
#import "ECClickableElementDelegate.h"
#import "ImageDisplayerDelegate.h"
#import "ImageFetcherDelegate.h"
#import "iAlumniHDAppDelegate.h"
#import "WXWConnectorDelegate.h"
#import "GlobalConstants.h"
#import "TextConstants.h"
#import "CoreDataUtils.h"
#import "CommonUtils.h"
#import "AppManager.h"
#import "ImageCache.h"

#import "XMLParser.h"
#import "WXWUIUtils.h"
#import "WXWLabel.h"

#pragma mark - notification names
#define WEB_CONTENT_LOADED_NOTIFY       @"WEB_CONTENT_LOADED_NOTIFY"
#define WEB_CONTENT_HEIGHT_KEY          @"WEB_CONTENT_HEIGHT_KEY"
#define IMAGE_LOADED_NOTIFY             @"IMAGE_LOADED_NOTIFY"
#define NEWS_IMAGE_INFO_KEY             @"NEWS_IMAGE_INFO_KEY"
#define NEWS_IMAGE_ORIENTATION_KEY      @"NEWS_IMAGE_ORIENTATION_KEY"
#define IMAGE_HEIGHT_KEY                @"IMAGE_HEIGHT_KEY"
#define TEXT_CONTENT_HEIGHT_KEY         @"TEXT_CONTENT_HEIGHT_KEY"
#define TEXT_CONTENT_LOADED_NOTIFY      @"TEXT_CONTENT_LOADED_NOTIFY"
#define CLEAR_HANDY_IMAGE_BROWSER_NOTIF @"CLEAR_HANDY_IMAGE_BROWSER_NOTIF"
#define FEED_DELETED_NOTIFY             @"FEED_DELETED_NOTIFY"
#define QUESTION_DELETED_NOTIFY         @"QUESTION_DELETED_NOTIFY"
#define UPDATE_NEWS_LIST_NOTIFY         @"UPDATE_NEWS_LIST_NOTIFY"
#define TRACE_REVIEWING_NEWS_NOTIFY     @"TRACE_REVIEWING_NEWS_NOTIFY"
#define REVIEWING_NEWS_KEY              @"REVIEWING_NEWS_KEY"

#define DISPLAY_LIKE_ALBUM_NOTIFY       @"DISPLAY_LIKE_ALBUM_NOTIFY"
#define HIDE_LIKE_ALBUM_NOTIFY          @"HIDE_LIKE_ALBUM_NOTIFY"

#define EMBEDDED_COMMENT_LOADED_NOTIFY  @"EMBEDDED_COMMENT_LOADED_NOTIFY"
#define EMBEDDED_COMMENT_LOADED_INDEXPATH_KEY @"EMBEDDED_COMMENT_LOADED_INDEXPATH_KEY"


#define PROFILE_TITLE_COLOR             COLOR(123, 124, 126)  
#define PROFILE_VALUE_COLOR             COLOR(135, 26, 24)
#define CELL_BASE_INFO_HEIGHT           16.0f

#define MAX_DISPLAYED_COMMENT_COUNT 3

#define TOOL_TITLE_HEIGHT           40.0f
//#define DARK_TEXT_COLOR  COLOR(44, 45, 51)
#define USER_PROF_BUTTONS_BACKGROUND_HEIGHT   90.0f
#define AUTHOR_AREA_HEIGHT      55.0f
//#define INIT_ZOOM_LEVEL			0.008
#define PHOTO_SIDE_LENGTH               40.0f
#define IMG_EDGE    UIEdgeInsetsMake(-12.0f, 7.0, 0.0, 0.0)
#define TITLE_EDGE  UIEdgeInsetsMake(19.0, -15.0, 0.0, 0.0)
#define CELL_BORDER_COLOR               COLOR(224, 224, 224)
#define CELL_BASE_INFO_HEIGHT           16.0f
#define PHOTO_SIDE_LENGTH               40.0f
#define IMAGE_SIDE_LENGTH               70.0f

#pragma mark - comment
#define COMMENT_AUTHOR_HEIGHT               20.0f
#define COMMENT_WITH_IMG_CELL_MIN_HEIGHT    106.0f
#define COMMENT_WITHOUT_IMG_CELL_MIN_HEIGHT 60.0f

@interface BaseUITableViewCell : UITableViewCell <WXWConnectorDelegate, ImageFetcherDelegate>
{
    WebItemType _currentType;
    NSMutableArray *_imageUrls;
    NSManagedObjectContext *_MOC;
    NSMutableDictionary *_errorMsgDic;
    id<ImageDisplayerDelegate> _imageDisplayerDelegate;
    id<WXWConnectionTriggerHolderDelegate> _connectionTriggerHolderDelegate;
    
    @private
    NSMutableArray *_labelsContainer;
}

@property (nonatomic, retain) NSMutableDictionary *errorMsgDic;
@property (nonatomic, retain) NSMutableArray *imageUrls;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

- (id)initWithStyle:(UITableViewCellStyle)style 
    reuseIdentifier:(NSString *)reuseIdentifier
imageDisplayerDelegate:(id<ImageDisplayerDelegate>)imageDisplayerDelegate
                MOC:(NSManagedObjectContext *)MOC;

- (id)initWithStyle:(UITableViewCellStyle)style 
    reuseIdentifier:(NSString *)reuseIdentifier
imageDisplayerDelegate:(id<ImageDisplayerDelegate>)imageDisplayerDelegate 
connectionTriggerHolderDelegate:(id<WXWConnectionTriggerHolderDelegate>)connectionTriggerHolderDelegate
                MOC:(NSManagedObjectContext *)MOC;

- (void)requestConnection:(NSString *)url  
               connFacade:(WXWAsyncConnectorFacade *)connFacade 
         connectionAction:(SEL)connectionAction;

- (void)setCellStyle:(CGFloat)cellHeight;

- (CATransition *)imageTransition;
- (BOOL)currentUrlMatchCell:(NSString *)url;
- (void)fetchImage:(NSMutableArray *)imageUrls forceNew:(BOOL)forceNew;

- (void)removeLabelShadowForHighlight:(UILabel **)label;

- (void)addLabelShadowForHighlight:(UILabel **)label;

- (void)hideLabelShadow;

- (void)showLabelShadow;

- (WXWLabel *)initLabel:(CGRect)frame
             textColor:(UIColor *)textColor
           shadowColor:(UIColor *)shadowColor;

#pragma mark - network consumer methods
- (WXWAsyncConnectorFacade *)setupAsyncConnectorForUrl:(NSString *)url
                                          contentType:(WebItemType)contentType;
#pragma mark - draw out bottom shadow
- (void)drawOutBottomShadow:(CGFloat)height;

@end
