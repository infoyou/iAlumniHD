//
//  VideoListViewController.m
//  iAlumniHD
//
//  Created by Adam on 13-1-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "VideoListViewController.h"
#import "Video.h"
#import "VideoViewController.h"
#import "CommonUtils.h"
#import "WXWAsyncConnectorFacade.h"
#import "WXWUIUtils.h"
#import "XMLParser.h"
#import "VideoListCell.h"
#import "VideoToolView.h"
#import "VideoDetailViewController.h"

#define FONT_SIZE       12.0f
#define TITLE_W         200.f
#define TITLE_Y         10.0f
#define DATE_H          20.f
#define MARK_IMG_H      16.f
#define THUMB_SIDE_LENGTH 80.0f

enum {
    VIDEO_TYPE = 0,
    VIDEO_OTHER,
} VideoFliterType;

enum {
    OPEN_VIDEO_IDX,
    SHARE_WECHAT_IDX,
} VideoActionSheet;

@interface VideoListViewController()
@property (nonatomic, retain) VideoToolView *videoToolView;
@property (nonatomic, retain) NSMutableArray *tableCellShowValArray;
@property (nonatomic, retain) NSMutableArray *tableCellSaveValArray;
@property (nonatomic, retain) Video *video;
@property (nonatomic, retain) UIImage *thumbnail;
@property (nonatomic, retain) NSString *requestParam;
@end

@implementation VideoListViewController

- (id)initWithMOC:(NSManagedObjectContext *)MOC
{
    self = [super initWithMOC:MOC holder:nil backToHomeAction:nil needRefreshHeaderView:NO needRefreshFooterView:YES tableStyle:UITableViewStyleGrouped needGoHome:NO];
    
    if (self) {
        // Custom initialization
        _currentStartIndex = 0;
        
        if([AppManager instance].showIndex != VIDEO_MENU_TY) {
            [super clearPickerSelIndex2Init:2];
            [AppManager instance].videoTypeVal = @"-1";
            [AppManager instance].videoSortVal = @"-1";
            [AppManager instance].videoTypeIndex = 0;
            [AppManager instance].videoSortIndex = 0;
            
            isReloadView = NO;
        } else {
            isReloadView = YES;
            
            self.tableCellShowValArray = nil;
            self.tableCellSaveValArray = nil;
        }
    }
    
    return self;
}

- (void)dealloc
{
    self.requestParam = nil;
    self.videoToolView = nil;

    self.tableCellShowValArray = nil;
    self.tableCellSaveValArray = nil;

    self.video = nil;
    self.thumbnail = nil;
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)loadListData:(LoadTriggerType)triggerType forNew:(BOOL)forNew
{
    [super loadListData:triggerType forNew:forNew];
    
    _currentType = VIDEO_TY;
    NSInteger index = 0;
    if (!forNew) {
        index = ++_currentStartIndex;
    }
    
    self.requestParam = [NSString stringWithFormat:@"<page_size>30</page_size><page>%d</page><video_type>%@</video_type><order_value>%@</order_value>", index, self.tableCellSaveValArray[0], self.tableCellSaveValArray[1]];
    
    NSString *url = [CommonUtils geneUrl:self.requestParam itemType:_currentType];
    NSLog(@"%@", url);
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                              contentType:_currentType];
    [connFacade fetchGets:url];
}

#pragma mark - core data
- (void)setPredicate {
    
    self.predicate = [NSPredicate predicateWithFormat:@"(videoId > 0)"];
    self.entityName = @"Video";
    self.descriptors = [NSMutableArray array];
    
    NSSortDescriptor *dateDesc = [[[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES] autorelease];
    [self.descriptors addObject:dateDesc];
}

#pragma mark - View lifecycle

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */

- (void)viewWillAppear:(BOOL)animated {
    
	[super deselectCell];
    
	if (!_autoLoaded) {
        if (![AppManager instance].isLoadVedioFilterOk) {
            [self getVideoFliter];
        } else {
            [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
            //            [self checkListWhetherEmpty];
        }
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    int offsetY = 0;
    
    if ([CommonUtils is7System]) {
        offsetY = 44;
    }
    
    self.videoToolView = [[[VideoToolView alloc] initForVideo:CGRectMake(0, offsetY, self.view.frame.size.width, HEADER_HEIGHT)
                                               topColor:COLOR(236, 232, 226)
                                            bottomColor:COLOR(223, 220, 212)
                                               delegate:self
                                       userListDelegate:self] autorelease];
    [self.view addSubview:self.videoToolView];
    
    [self reSizeTable];
    
    if ([CommonUtils is7System]) {
        _tableView.frame = CGRectMake(0, self.videoToolView.frame.origin.y, _tableView.frame.size.width, _tableView.frame.size.height - self.videoToolView.frame.origin.y);
    } else {
        _tableView.frame = CGRectMake(0, self.videoToolView.frame.origin.y + 44, _tableView.frame.size.width, _tableView.frame.size.height - self.videoToolView.frame.origin.y - 44);
    
    }
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"lightBackground.png"]];
    
    self.tableCellShowValArray = [NSMutableArray array];
    self.tableCellSaveValArray = [NSMutableArray array];
    
    if(isReloadView) {
        
        if ([AppManager instance].videoTypeVal) {
            
            [self.tableCellShowValArray insertObject:[AppManager instance].videoTypeVal atIndex:VIDEO_TYPE];
            [self.tableCellSaveValArray insertObject:[NSString stringWithFormat:@"%d",[AppManager instance].videoTypeIndex] atIndex:VIDEO_TYPE];
        } else {
            [self.tableCellShowValArray insertObject:[NSString stringWithFormat:@"%d",iOriginalSelIndexVal] atIndex:VIDEO_TYPE];
            [self.tableCellSaveValArray insertObject:@"" atIndex:VIDEO_TYPE];
        }
        
        if ([AppManager instance].videoSortVal) {
            
            [self.tableCellShowValArray insertObject:[NSString stringWithFormat:@"%d",iOriginalSelIndexVal] atIndex:VIDEO_OTHER];
            [self.tableCellSaveValArray insertObject:[NSString stringWithFormat:@"%d",[AppManager instance].videoSortIndex] atIndex:VIDEO_OTHER];
        } else {
            [self.tableCellShowValArray insertObject:[NSString stringWithFormat:@"%d",iOriginalSelIndexVal] atIndex:VIDEO_OTHER];
            [self.tableCellSaveValArray insertObject:@"" atIndex:VIDEO_OTHER];
        }
    } else {
        for (NSUInteger i=0; i<2; i++) {
            [self.tableCellShowValArray insertObject:[NSString stringWithFormat:@"%d",iOriginalSelIndexVal] atIndex:i];
            [self.tableCellSaveValArray insertObject:@"" atIndex:i];
        }
    }

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableViewDelegate, UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedRC sections][section];
	return [sectionInfo numberOfObjects] + 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Foot Cell
    if (indexPath.row == self.fetchedRC.fetchedObjects.count) {
        return [self drawFooterCell];
    }
    
    // Event Cell
    static NSString *CellIdentifier = @"VideoCell";
    VideoListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
//        cell = [[[VideoListCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell = [[[VideoListCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                 reuseIdentifier:CellIdentifier
                                          imageDisplayerDelegate:self
                                                             MOC:_MOC] autorelease];
    }
    
    NSArray *subviews = [[NSArray alloc] initWithArray:cell.contentView.subviews];
    for (UIView *subview in subviews) {
        [subview removeFromSuperview];
    }
    [subviews release];
    
    Video *video = [self.fetchedRC objectAtIndexPath:indexPath];
    
    [cell drawVideo:video];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == _fetchedRC.fetchedObjects.count) {
        return;
    }
    
    [AppManager instance].lastSelectedIndexPath = indexPath;
    
    
    [self selectVideoDetail:indexPath];
    
    /*
    UIActionSheet *as = [[[UIActionSheet alloc] initWithTitle:nil
                                                     delegate:self
                                            cancelButtonTitle:nil
                                       destructiveButtonTitle:nil
                                            otherButtonTitles:nil] autorelease];
    [as addButtonWithTitle:LocaleStringForKey(NSOpenVideoTitle, nil)];
    [as addButtonWithTitle:LocaleStringForKey(NSShareToWechatTitle, nil)];
    [as addButtonWithTitle:LocaleStringForKey(NSCancelTitle, nil)];
    [as addButtonWithTitle:LocaleStringForKey(NSCancelTitle, nil)];
    as.cancelButtonIndex = as.numberOfButtons - 1;
    
    [as showInView:self.navigationController.view];
    */
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == _fetchedRC.fetchedObjects.count) {
        return VIDEO_LIST_CELL_HEIGHT;
    } else {
        
        Video *video = [_fetchedRC objectAtIndexPath:indexPath];
        if (!video) {
            return VIDEO_LIST_CELL_HEIGHT;
        } else {

            CGSize constrainedSize = CGSizeMake(TITLE_W, CGFLOAT_MAX);
            CGSize titleSize = [video.videoName sizeWithFont:Arial_FONT(FONT_SIZE)
                                     constrainedToSize:constrainedSize
                                         lineBreakMode:UILineBreakModeWordWrap];
            
            float cellHeight = titleSize.height + TITLE_Y*2 + DATE_H + MARK_IMG_H;
            if (cellHeight < VIDEO_LIST_CELL_HEIGHT) {
                return VIDEO_LIST_CELL_HEIGHT;
            } else {
                return cellHeight;
            }
        }
    }
}

#pragma mark - reset refresh header/footer view status
- (void)resetHeaderRefreshViewStatus {
	_reloading = NO;
	[WXWUIUtils dataSourceDidFinishLoadingNewData:_tableView
                                    headerView:_headerRefreshView];
}

- (void)resetFooterRefreshViewStatus {
	_reloading = NO;
	
	[WXWUIUtils dataSourceDidFinishLoadingOldData:_tableView
                                    footerView:_footerRefreshView];
}

- (void)resetHeaderOrFooterViewStatus {
    
    if (_loadForNewItem) {
        [self resetHeaderRefreshViewStatus];
    } else {
        [self resetFooterRefreshViewStatus];
    }
}

#pragma mark - WXWConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(WebItemType)contentType
{
    
    [WXWUIUtils showActivityView:[APP_DELEGATE foundationView] text:LocaleStringForKey(NSLoadingTitle, nil)];
    [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(WebItemType)contentType
{
    switch (contentType) {
        case VIDEO_FILTER_TY:
        {
            if ([XMLParser parserSyncResponseXml:result type:VIDEO_FILTER_SRC MOC:_MOC]) {
                
                [AppManager instance].videoTypeIndex = 0;
                [AppManager instance].videoSortIndex = 0;
                
//                [self.videoToolView setType:([AppManager instance].videoTypeList)[[AppManager instance].videoTypeIndex][RECORD_NAME]
//                                  sort:([AppManager instance].videoSortList)[[AppManager instance].videoSortIndex][RECORD_NAME]];
                
                [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
            } else {
                [WXWUIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSActionFaildMsg, nil)
                                              msgType:ERROR_TY
                                   belowNavigationBar:YES];
            }
            break;
        }
            
        case VIDEO_TY:
        {
            if ([XMLParser parserSyncResponseXml:result type:VIDEO_SRC MOC:_MOC]) {
                [self.videoToolView setType:([AppManager instance].videoTypeList)[[AppManager instance].videoTypeIndex][RECORD_NAME]
                                  sort:([AppManager instance].videoSortList)[[AppManager instance].videoSortIndex][RECORD_NAME]];
                
                [self resetUIElementsForConnectDoneOrFailed];
            } else {
                [WXWUIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSActionFaildMsg, nil)
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
    [self refreshTable];
    
    _autoLoaded = YES;
    [super connectDone:result url:url contentType:contentType];
}

- (void)connectCancelled:(NSString *)url
             contentType:(WebItemType)contentType {
    [super connectCancelled:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(WebItemType)contentType {
    
    [super connectFailed:error url:url contentType:contentType];
}

#pragma mark - scrolling override
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([WXWUIUtils shouldLoadOlderItems:scrollView
                      tableViewHeight:_tableView.contentSize.height + HEADER_HEIGHT
                           footerView:_footerRefreshView
                            reloading:_reloading]) {
        
        _reloading = YES;
        
        _shouldTriggerLoadLatestItems = YES;
        
        [self loadListData:TRIGGERED_BY_SCROLL forNew:NO];
    }
}

#pragma mark - Video
- (void)showVideoTypeList:(UIButton *)sender {
    [self setDropDownValueArray:0 sender:sender];
}

- (void)showVideoSortList:(UIButton *)sender {
    [self setDropDownValueArray:1 sender:sender];
}

#pragma mark - UIPickerViewDelegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    pickSel0Index = row;
    isPickSelChange = YES;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_PickData count];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return _frame.size.width;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _PickData[row];
}

- (void)setDropDownValueArray:(int)type sender:(UIButton *)sender
{
    [NSFetchedResultsController deleteCacheWithName:nil];
    iFliterIndex = type;
    self.descriptors = [NSMutableArray array];
    self.DropDownValArray = [[[NSMutableArray alloc] init] autorelease];
    
    switch (type) {
            
        case 0:
        {
            self.DropDownValArray = [AppManager instance].videoTypeList;
        }
            break;
            
        case 1:
        {
            self.DropDownValArray = [AppManager instance].videoSortList;
        }
            break;
    }
    
    _UIPopoverArrowDirection = UIPopoverArrowDirectionUp;
    [_popViewController setPopoverContentSize:CGSizeMake(_frame.size.width, PopViewHeight)];
    
    [super setPopView];
    
    [_popViewController presentPopoverFromRect:CGRectMake(sender.frame.origin.x, sender.frame.origin.y-10.f, sender.frame.size.width, TOOLBAR_HEIGHT)
                                        inView:self.view
                      permittedArrowDirections:UIPopoverArrowDirectionAny
                                      animated:YES];
}

-(void)onPopCancle:(id)sender {
    [super onPopCancle];
    
    [self.tableCellShowValArray removeObjectAtIndex:iFliterIndex];
    [self.tableCellShowValArray insertObject:[NSString stringWithFormat:@"%d",iOriginalSelIndexVal] atIndex:iFliterIndex];
    
    [self.tableCellSaveValArray removeObjectAtIndex:iFliterIndex];
    [self.tableCellSaveValArray insertObject:@"" atIndex:iFliterIndex];
    
    [_tableView reloadData];
}

-(void)onPopOk:(id)sender {
    
    [super close:nil];
    [super onPopSelectedOk];
    int iPickSelectIndex = [super pickerList0Index];
    
    [self setTableCellVal:iFliterIndex aShowVal:(self.DropDownValArray)[iPickSelectIndex][RECORD_NAME]
                 aSaveVal:(self.DropDownValArray)[iPickSelectIndex][RECORD_ID] isFresh:YES];
    
    [self doSelect];
}

-(void)setTableCellVal:(int)index aShowVal:(NSString*)aShowVal aSaveVal:(NSString*)aSaveVal isFresh:(BOOL)isFresh
{
    [self.tableCellShowValArray removeObjectAtIndex:index];
    [self.tableCellShowValArray insertObject:aShowVal atIndex:index];
    
    [self.tableCellSaveValArray removeObjectAtIndex:index];
    [self.tableCellSaveValArray insertObject:aSaveVal atIndex:index];
    
    switch (index) {
        case VIDEO_TYPE:
        {
            if ([@"" isEqualToString:self.tableCellSaveValArray[0]]) {
                [AppManager instance].videoTypeIndex = 0;
            } else {
                [AppManager instance].videoTypeIndex = [self.tableCellSaveValArray[0] intValue] - 1;
            }
        }
            break;
            
        case VIDEO_OTHER:
        {
            if ([@"" isEqualToString:self.tableCellSaveValArray[1]]) {
                [AppManager instance].videoSortIndex = 0;
            } else {
                [AppManager instance].videoSortIndex = [self.tableCellSaveValArray[1] intValue] - 1;
            }
        }
            break;
            
        default:
            break;
    }

    [AppManager instance].videoTypeVal = self.tableCellShowValArray[VIDEO_TYPE];
    [AppManager instance].videoSortVal = self.tableCellShowValArray[VIDEO_OTHER];
    
//    [self.videoToolView setType:self.tableCellShowValArray[VIDEO_TYPE]
//                      sort:self.tableCellShowValArray[VIDEO_OTHER]];
}

- (void)doSelect
{
    [CommonUtils doDelete:_MOC entityName:@"Video"];
    _currentStartIndex = 0;
    [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
}

- (void)getVideoFliter
{
    _currentType = VIDEO_FILTER_TY;
    
    NSString *url = [CommonUtils geneUrl:@"" itemType:_currentType];
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                              contentType:_currentType];
    [connFacade fetchGets:url];
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

#pragma mark - UIActionSheetDelegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case OPEN_VIDEO_IDX:
        {
            [self updateVideoClick:[self.video.videoId stringValue]];
            VideoViewController *videoVC = [[[VideoViewController alloc] initWithURL:self.video.videoUrl] autorelease];
            [self.navigationController pushViewController:videoVC animated:YES];
            
            break;
        }
            
        case SHARE_WECHAT_IDX:
        {
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
            
            break;
        }
            
        default:
            break;
    }
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

#pragma mark - select Video detail
- (void)selectVideoDetail:(NSIndexPath *)indexPath {
    self.video = [self.fetchedRC objectAtIndexPath:indexPath];
    
    VideoDetailViewController *detailVC = [[[VideoDetailViewController alloc]  initWithMOC:_MOC
                                                                                    holder:_holder
                                                                          backToHomeAction:_backToHomeAction
                                                                                    itemId:1
                                                                                     video:self.video] autorelease];
    detailVC.title = self.video.videoName;
    
    detailVC.deSelectCellDelegate = self;
    self.selectedIndexPath = indexPath;
    
    WXWNavigationController *detailNC = [[[WXWNavigationController alloc] initWithRootViewController:detailVC] autorelease];
    
    [APP_DELEGATE addViewInSlider:detailNC
               invokeByController:self
                   stackStartView:NO];
}

#pragma mark - handle empty list
- (BOOL)listIsEmpty {
    
    if([AppManager instance].showIndex == VIDEO_MENU_TY){
        [AppManager instance].showIndex = EVENT_MENU_TY;
        [self defaultSelTableCell];
        [self selectVideoDetail:[AppManager instance].lastSelectedIndexPath];
    }
    
    return NO;
}

@end