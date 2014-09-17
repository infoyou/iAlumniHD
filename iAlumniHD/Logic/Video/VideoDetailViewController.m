//
//  VideoDetailViewController.m
//  iAlumniHD
//
//  Created by Adam on 13-3-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "VideoDetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "HandyCommentComposerView.h"
#import "News.h"
#import "WXWTextView.h"
#import "CommentVideoCell.h"
#import "WXWUIUtils.h"
#import "HttpUtils.h"
#import "TextConstants.h"
#import "XMLParser.h"
#import "CommentVideo.h"
#import "ECImageBrowseViewController.h"
#import "WXWNavigationController.h"
#import "CoreDataUtils.h"
#import "AlumniProfileViewController.h"
#import "Video.h"
#import "VideoViewController.h"

@interface VideoDetailViewController()
@property (nonatomic, retain) Video *video;
@property (nonatomic, retain) UIImage *thumbnail;
@end

#define TOP_H       80.f
#define BUTTON_X    20.f
#define BUTTON_Y    20.f
#define BUTTON_W    149.f
#define BUTTON_H    45.f
#define FONT_SIZE   16.f
#define THUMB_SIDE_LENGTH 80.0f

@implementation VideoDetailViewController

#pragma mark - load comment
- (void)loadListData:(LoadTriggerType)triggerType forNew:(BOOL)forNew {
    
    [super loadListData:triggerType forNew:forNew];
    
    NSString *url = nil;
            
    NSInteger startIndex = 0;
    if (!forNew) {
        startIndex = ++_currentStartIndex;
    }
    
    _currentType = LOAD_VIDEO_COMMENT_TY;
    NSString *param = [NSString stringWithFormat:@"<video_id>%@</video_id><page>%d</page><page_size>%@</page_size>",
                       self.video.videoId,
                       startIndex,
                       ITEM_LOAD_COUNT];
    url = [CommonUtils geneUrl:param itemType:_currentType];
        
    WXWAsyncConnectorFacade *connector = [self setupAsyncConnectorForUrl:url
                                                              contentType:_currentType];
    
    [connector asyncGet:url showAlertMsg:YES];
}

#pragma mark - lifecycle methods
- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder
 backToHomeAction:(SEL)backToHomeAction
           itemId:(long long)itemId
            video:(Video *)video {
    
    self = [super initWithMOC:MOC
                       holder:holder
             backToHomeAction:backToHomeAction
        needRefreshHeaderView:NO
        needRefreshFooterView:YES
                   needGoHome:NO];
    if (self) {
        
        _itemId = itemId;
        self.video = video;
        
        _currentStartIndex = 0;
    }
    return self;
}

- (void)dealloc {
    
    self.video = nil;
    _oneTapRecoginzer.delegate = nil;
    
    [super dealloc];
}

- (NSInteger)commentCount {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(videoId == %lld)", self.video.videoId.longLongValue];
    return [CoreDataUtils objectCountsFromMOC:_MOC entityName:@"CommentVideo" predicate:predicate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView.backgroundColor = CELL_COLOR;
    
    [self initTopView];
    [self initCommentComposerView];
    
    [self initOneTapRecoginzer:self.view];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!_autoLoaded) {
        [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

#pragma mark - logic view
- (void)initTopView {
    
    int offsetY = 0;
    
    if ([CommonUtils is7System]) {
        offsetY = 44;
    }
    
    UIView *topView = [[[UIView alloc] initWithFrame:CGRectMake(0, offsetY, LIST_WIDTH, TOP_H)] autorelease];
    
    CGRect playFrame = CGRectMake(BUTTON_X, BUTTON_Y, BUTTON_W, BUTTON_H);
    WXWImageButton *playBut = [[[WXWImageButton alloc] initImageButtonWithFrame:playFrame
                                                                         target:self
                                                                         action:@selector(doPlay:)
                                                                          title:LocaleStringForKey(NSOpenVideoTitle, nil)
                                                                          image:[UIImage imageNamed:@"play_button.png"]
                                                                    backImgName:@"buttonOrangeRound.png"
                                                                 selBackImgName:@"buttonOrangeRoundSelected.png"
                                                                      titleFont:FONT(FONT_SIZE)
                                                                     titleColor:[UIColor whiteColor]
                                                               titleShadowColor:TRANSPARENT_COLOR
                                                                    roundedType:NO_ROUNDED
                                                                imageEdgeInsert:UIEdgeInsetsMake(0, -35, 0, 0)
                                                                titleEdgeInsert:ZERO_EDGE] autorelease];
    
    [topView addSubview:playBut];
    
    CGRect shareFrame = CGRectMake(LIST_WIDTH-BUTTON_W-BUTTON_X, BUTTON_Y, BUTTON_W, BUTTON_H);
    WXWGradientButton *shareBut = [[[WXWGradientButton alloc] initWithFrame:shareFrame
                                                                     target:self
                                                                     action:@selector(doShare:)
                                                                  colorType:WHITE_BTN_COLOR_TY
                                                                      title:LocaleStringForKey(NSShareTitle, nil)
                                                                      image:[UIImage imageNamed:@"wechat.png"]
                                                                 titleColor:BLACK_BTN_TITLE_SHADOW_COLOR
                                                           titleShadowColor:BLACK_BTN_TITLE_COLOR
                                                                  titleFont:BOLD_FONT(FONT_SIZE)
                                                                roundedType:HAS_ROUNDED
                                                            imageEdgeInsert:UIEdgeInsetsMake(0, -35, 0, 0)
                                                            titleEdgeInsert:ZERO_EDGE] autorelease];
    [topView addSubview:shareBut];
    
    [self.view addSubview:topView];
}

- (void)initCommentComposerView {
    
    int offsetY = 0;
    
    if ([CommonUtils is7System]) {
        offsetY = 44;
    }
    
    _commentComposerView = [[[HandyCommentComposerView alloc] initWithFrame:CGRectMake(0,
                                                                                       TOP_H + offsetY,
                                                                                       self.view.frame.size.width, 76.0f)
                                                                      count:[self commentCount]
                                                                contentType:SEND_VIDEO_COMMENT_TY
                                                   clickableElementDelegate:self] autorelease];
    _commentComposerView.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    _commentComposerView.layer.shadowOpacity = 0.9f;
    _commentComposerView.layer.shadowColor = [UIColor grayColor].CGColor;
    _commentComposerView.layer.masksToBounds = NO;
    
    [self.view addSubview:_commentComposerView];
    
    _tableView.frame = CGRectMake(0, _commentComposerView.frame.origin.y + _commentComposerView.frame.size.height,
                                  self.view.frame.size.width,
                                  self.view.frame.size.height - _commentComposerView.frame.size.height);
}

- (void)initOneTapRecoginzer:(UIView *)gestureHolder {
	_oneTapRecoginzer = [[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                 action:@selector(oneTapHandle:)] autorelease];
	_oneTapRecoginzer.numberOfTapsRequired = 1;
	_oneTapRecoginzer.numberOfTouchesRequired = 1;
	[gestureHolder addGestureRecognizer:_oneTapRecoginzer];
	_oneTapRecoginzer.delegate = self;
}

#pragma mark - tap handler
- (void)tapGestureHandler {
    _tableView.frame = CGRectMake(0, _commentComposerView.frame.origin.y + _commentComposerView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - _commentComposerView.frame.size.height);
}

- (void)oneTapHandle:(UIGestureRecognizer *)gesture {
    if (_commentComposerView.enlarged) {
        [_commentComposerView adjustLayout:NO];
    }
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch {
    
    if ([touch.view isKindOfClass:[UIButton class]] || [touch.view isKindOfClass:[WXWTextView class]]) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - override methods
- (void)setPredicate {
    self.entityName = @"CommentVideo";
    self.predicate = [NSPredicate predicateWithFormat:@"(videoId == %lld)", self.video.videoId.longLongValue];
    
    self.descriptors = [NSMutableArray array];
    NSSortDescriptor *descriptor = [[[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO] autorelease];
    [self.descriptors addObject:descriptor];
}

#pragma mark - ECConnectorDelegate methods

- (void)connectStarted:(NSString *)url contentType:(WebItemType)contentType {
    [self showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil) blockCurrentView:YES];
    
    [super connectStarted:url contentType:contentType];
}

- (void)handleLoadComments:(WebItemType)contentType {
    
    // update news list
    [self refreshTable];
    
    // update comment count for composer view
    [_commentComposerView updateCommentCount:[self commentCount]];
    
}

- (void)connectDone:(NSData *)result
                url:(NSString *)url
        contentType:(WebItemType)contentType {
    
    switch (contentType) {
        case LOAD_VIDEO_COMMENT_TY:
        {
            if ([XMLParser parserResponseXml:result
                                        type:contentType
                                         MOC:_MOC
                           connectorDelegate:self
                                         url:url
                                parentItemId:_itemId]) {
                [self handleLoadComments:contentType];
                
            } else {
                [WXWUIUtils showNotificationOnTopWithMsg:(self.errorMsgDic)[url]
                                          alternativeMsg:LocaleStringForKey(NSLoadCommentFailedMsg, nil)
                                                 msgType:ERROR_TY
                                      belowNavigationBar:YES];
            }
            break;
        }
            
        case SEND_VIDEO_COMMENT_TY:
        {
            if ([XMLParser parserResponseXml:result
                                        type:contentType
                                         MOC:_MOC
                           connectorDelegate:self
                                         url:url]) {
                
                [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
                
            } else {
                [WXWUIUtils showNotificationOnTopWithMsg:(self.errorMsgDic)[url]
                                          alternativeMsg:LocaleStringForKey(NSSendCommentFailedMsg, nil)
                                                 msgType:ERROR_TY
                                      belowNavigationBar:YES];
            }
            break;
        }
            
        case VIDEO_CLICK_TY:
        {
            
            break;
        }
        
        default:
            break;
    }
    
    _autoLoaded = YES;
    
    [super connectDone:result url:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(WebItemType)contentType {
    
    NSString *msg = LocaleStringForKey(NSLoadCommentFailedMsg, nil);
    switch (contentType) {
        case LOAD_VIDEO_COMMENT_TY:
            msg = LocaleStringForKey(NSLoadReviewsFailedMsg, nil);
            break;
            
        default:
            break;
    }
    
    if ([self connectionMessageIsEmpty:error]) {
        self.connectionErrorMsg = msg;
    }
    
    _autoLoaded = YES;
    
    [super connectFailed:error url:url contentType:contentType];
}

- (void)connectCancelled:(NSString *)url contentType:(WebItemType)contentType {
    
    [super connectCancelled:url contentType:contentType];
}

#pragma mark - handle empty list
- (BOOL)listIsEmpty {
    return NO;
}

#pragma mark - UITableViewDelegate and UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _fetchedRC.fetchedObjects.count + 1;
}

- (void)checkAndSetCurrentOldestCommentIndexPath:(NSIndexPath *)indexPath {
    
    // record the oldest comment time
    
    id<NSFetchedResultsSectionInfo> sectionInfo = [_fetchedRC sections][indexPath.section];
    if (indexPath.row == [sectionInfo numberOfObjects] - 1) {
        _currentStartIndex = indexPath.row + 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == _fetchedRC.fetchedObjects.count) {
        return [self drawFooterCell];
    }
    
    CommentVideo *comment = (_fetchedRC.fetchedObjects)[indexPath.row];
    
    static NSString *kCommentCellIdentifier = @"CommentVideoCell";
    CommentVideoCell *cell = [_tableView dequeueReusableCellWithIdentifier:kCommentCellIdentifier];
    if (nil == cell) {
        cell = [[[CommentVideoCell alloc] initWithStyle:UITableViewCellStyleDefault
                                   reuseIdentifier:kCommentCellIdentifier
                            imageDisplayerDelegate:self
                            imageClickableDelegate:self
                                               MOC:_MOC] autorelease];
    }
    
    [cell drawComment:comment showLocation:NO];
    
    [self checkAndSetCurrentOldestCommentIndexPath:indexPath];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == _fetchedRC.fetchedObjects.count) {
        return COMMENT_WITHOUT_IMG_CELL_MIN_HEIGHT;
    } else {
        
        CommentVideo *comment = (CommentVideo *)(_fetchedRC.fetchedObjects)[indexPath.row];
        
        CGFloat height = MARGIN * 2;
        BOOL hasImage = [comment.imageAttached boolValue];
        
        CGSize size = [comment.authorName sizeWithFont:FONT(17)
                                     constrainedToSize:CGSizeMake(200, COMMENT_AUTHOR_HEIGHT)
                                         lineBreakMode:UILineBreakModeWordWrap];
        height += size.height;
        
        height += MARGIN;
        
        CGFloat width = 0;
        if (hasImage) {
            width = self.view.frame.size.width - MARGIN * 2 - IMAGE_SIDE_LENGTH - MARGIN - (MARGIN * 2 + PHOTO_SIDE_LENGTH + MARGIN);
        } else {
            width = self.view.frame.size.width - MARGIN * 2 - (MARGIN * 2 + PHOTO_SIDE_LENGTH + MARGIN);
        }
        
        size = [comment.content sizeWithFont:FONT(13)
                           constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                               lineBreakMode:UILineBreakModeWordWrap];
        
        if (hasImage) {
            if (size.height < IMAGE_SIDE_LENGTH) {
                height += IMAGE_SIDE_LENGTH;
            } else {
                height += size.height;
            }
        } else {
            height += size.height;
        }
        
        height += MARGIN * 2;
        
        CGFloat minHeight = 0;
        if (hasImage) {
            minHeight = COMMENT_WITH_IMG_CELL_MIN_HEIGHT;
        } else {
            minHeight = COMMENT_WITHOUT_IMG_CELL_MIN_HEIGHT;
        }
        
        if (height < minHeight) {
            return minHeight;
        } else {
            return height;
        }
    }
}

#pragma mark - ECClickableElementDelegate methods
- (void)openProfile:(NSString *)userId userType:(NSString *)userType {
    
    AlumniProfileViewController *profileVC = [[[AlumniProfileViewController alloc] initWithMOC:_MOC
                                                                                      personId:userId
                                                                                      userType:ALUMNI_USER_TY] autorelease];
    profileVC.title = LocaleStringForKey(NSAlumniDetailTitle, nil);
    [self.navigationController pushViewController:profileVC animated:YES];
    
}

- (void)openImageUrl:(NSString *)imageUrl {
    if (imageUrl && [imageUrl length] > 0) {
        ECImageBrowseViewController *imgBrowseVC = [[ECImageBrowseViewController alloc] initWithImageUrl:imageUrl];
        imgBrowseVC.title = LocaleStringForKey(NSBigPicTitle, nil);
        
        WXWNavigationController *detailNC = [[[WXWNavigationController alloc] initWithRootViewController:imgBrowseVC] autorelease];
        
        detailNC.modalPresentationStyle = UIModalPresentationPageSheet;
        [self presentModalViewController:detailNC animated:YES];
    }
}

- (void)sendComment:(NSString *)content {
    
    _currentType = SEND_VIDEO_COMMENT_TY;
    
    self.connFacade = [[[WXWAsyncConnectorFacade alloc] initWithDelegate:self
                                                  interactionContentType:_currentType] autorelease];  
    [self.connFacade sendVideoComment:content
                              videoId:[NSString stringWithFormat:@"%@", self.video.videoId]];

}

#pragma mark - logic action
- (void)doPlay:(id)sender {
    [self updateVideoClick:[self.video.videoId stringValue]];
    VideoViewController *videoVC = [[[VideoViewController alloc] initWithURL:self.video.videoUrl] autorelease];
    [self.navigationController pushViewController:videoVC animated:YES];
}

- (void)doShare:(id)sender {
    if ([WXApi isWXAppInstalled]) {
        ((iAlumniHDAppDelegate*)APP_DELEGATE).wxApiDelegate = self;
        
        if (self.video.imageUrl.length > 0) {
            self.thumbnail = [CommonUtils cutMiddlePartImage:[[AppManager instance].imageCache getImage:self.video.imageUrl]
                                                       width:THUMB_SIDE_LENGTH
                                                      height:THUMB_SIDE_LENGTH];
        }
        
        [CommonUtils shareVideo:self.video scene:WXSceneSession image:self.thumbnail];
        
    } else {
        
        ShowAlertWithTwoButton(self, nil,
                               LocaleStringForKey(NSNoWeChatMsg, nil),
                               LocaleStringForKey(NSDonotInstallTitle, nil),
                               LocaleStringForKey(NSInstallTitle, nil));
    }

}

- (void)updateVideoClick:(NSString *)videoId
{
    _currentType = VIDEO_CLICK_TY;
    
    NSString *param = [NSString stringWithFormat:@"<video_id>%@</video_id>", videoId];
    NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                              contentType:_currentType];
    [connFacade fetchGets:url];
}

#pragma mark - WXApiDelegate methods
- (void)onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[SendMessageToWXResp class]]) {
        switch (resp.errCode) {
            case WECHAT_OK_CODE:
                [WXWUIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSAppShareByWeChatDoneMsg, nil)
                                                 msgType:SUCCESS_TY
                                      belowNavigationBar:YES];
                break;
                
            case WECHAT_BACK_CODE:
                break;
                
            default:
                [WXWUIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSAppShareByWeChatFailedMsg, nil)
                                                 msgType:ERROR_TY
                                      belowNavigationBar:YES];
                break;
        }
    }
    
    ((iAlumniHDAppDelegate*)APP_DELEGATE).wxApiDelegate = nil;
}

#pragma mark - UIAlertViewDelegate method
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 1:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:WECHAT_ITUNES_URL]];
            break;
        default:
            break;
    }
}

@end
