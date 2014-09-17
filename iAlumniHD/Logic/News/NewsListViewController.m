//
//  NewsListViewController.m
//  iAlumniHD
//
//  Created by Adam on 12-11-23.
//
//

#import "NewsListViewController.h"
#import "NewsListSectionView.h"
#import "UIWebViewController.h"
#import "NewsListCell.h"
#import "News.h"

#define SECTION_VIEW_HEIGHT     16.0f

@interface NewsListViewController ()

@end

@implementation NewsListViewController

#pragma mark - set predicate
- (void)setPredicate {
    
    self.entityName = @"News";
    self.sectionNameKeyPath = @"elapsedDayCount";
    
    self.descriptors = [NSMutableArray array];
    
    NSSortDescriptor *elapsedDayDesc = [[[NSSortDescriptor alloc] initWithKey:@"elapsedDayCount" ascending:YES] autorelease];
    [self.descriptors addObject:elapsedDayDesc];
    
    NSSortDescriptor *timestampDesc = [[[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO] autorelease];
    [self.descriptors addObject:timestampDesc];

}

#pragma mark - load news
- (void)loadListData:(LoadTriggerType)triggerType forNew:(BOOL)forNew {
    
    [super loadListData:triggerType forNew:forNew];
    
    _currentType = LOAD_NEWS_REPORT_TY;
    
    NSInteger index = 0;
    if (!forNew) {
        index = ++_currentStartIndex;
    }
    
    NSString *param = [NSString stringWithFormat:@"<page>%d</page><page_size>%@</page_size><news_type>%d</news_type>", index, ITEM_LOAD_COUNT, FOR_HOMEPAGE_NEWS_TY];
    
    NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
    
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                              contentType:_currentType];
    [connFacade asyncGet:url showAlertMsg:YES];
}

#pragma mark - lifecycle methods
- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder
 backToHomeAction:(SEL)backToHomeAction {
    
    self = [super initWithMOC:MOC
                       holder:holder
             backToHomeAction:backToHomeAction
        needRefreshHeaderView:YES
        needRefreshFooterView:YES
                   needGoHome:YES];
    
    if (self) {
        DELETE_OBJS_FROM_MOC(_MOC, @"News", nil);
    }
    
    return self;
}

- (void)dealloc {
      
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    if (!_autoLoaded) {
        [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_fetchedRC.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionInfo = [_fetchedRC sections][section];
    if (section == [_fetchedRC.sections count] - 1) {
        return [sectionInfo numberOfObjects] + 1;
    } else {
        return [sectionInfo numberOfObjects];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == [_fetchedRC.sections count] - 1) {
        id<NSFetchedResultsSectionInfo> sectionInfo = [_fetchedRC sections][indexPath.section];
        
        if (indexPath.row == [sectionInfo numberOfObjects]) {
            static NSString *kFooterCellIdentifier = @"footerCell";
            UITableViewCell *footerCell = [_tableView dequeueReusableCellWithIdentifier:kFooterCellIdentifier];
            if (nil == footerCell) {
                footerCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                     reuseIdentifier:kFooterCellIdentifier] autorelease];
                
                if (_footerRefreshView) {
                    [_footerRefreshView removeFromSuperview];
                }
                [footerCell.contentView addSubview:_footerRefreshView];
                footerCell.accessoryType = UITableViewCellAccessoryNone;
                footerCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            return footerCell;
        }
    }
    
    News *news = [_fetchedRC objectAtIndexPath:indexPath];
    
    static NSString *cellIdentifier = @"newsCell";
    
    NewsListCell *cell = (NewsListCell *)[_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == cell) {
        cell = [[[NewsListCell alloc] initWithStyle:UITableViewCellStyleDefault
                                   reuseIdentifier:cellIdentifier
                            imageDisplayerDelegate:self
                                               MOC:_MOC] autorelease];
    }
    
    [cell drawNews:news];
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NEWS_CEL_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)table
sectionForSectionIndexTitle:(NSString *)title
               atIndex:(NSInteger)index {
    return [_fetchedRC sectionForSectionIndexTitle:title atIndex:index];
}

- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section {
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [_fetchedRC sections][section];
    
    NSArray *newsList = [sectionInfo objects];
    NSString *name = nil;
    if (newsList.count > 0) {
        News *news = (News *)newsList.lastObject;
        name = news.dateSeparator;
    }
    
    return [[[NewsListSectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, SECTION_VIEW_HEIGHT)
                                                 title:name] autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return SECTION_VIEW_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == [_fetchedRC.sections count] - 1) {
        id<NSFetchedResultsSectionInfo> sectionInfo = [_fetchedRC sections][indexPath.section];
        if (indexPath.row == [sectionInfo numberOfObjects]) {
            return;
        }
    }
    
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    News *news = [_fetchedRC objectAtIndexPath:indexPath];
    
    CGRect mFrame = CGRectMake(0, 0, UI_MODAL_FORM_SHEET_WIDTH, self.view.frame.size.height);
    
    UIWebViewController *webVC = [[[UIWebViewController alloc]
                                   initWithUrl:news.url
                                   frame:mFrame
                                   isNeedClose:YES] autorelease];
    
	webVC.deSelectCellDelegate = self;
    self.selectedIndexPath = indexPath;
    
    WXWNavigationController *detailNC = [[[WXWNavigationController alloc] initWithRootViewController:webVC] autorelease];
    
    [APP_DELEGATE addViewInSlider:detailNC
               invokeByController:self
                   stackStartView:NO];
}

#pragma mark - WXWConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(WebItemType)contentType {
    
    [WXWUIUtils showActivityView:[APP_DELEGATE foundationView]
                         text:LocaleStringForKey(NSLoadingTitle, nil)];
    [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(WebItemType)contentType {
        
        if ([XMLParser parserResponseXml:result
                                    type:contentType
                                     MOC:self.MOC
                       connectorDelegate:self
                                     url:url]) {
        [self refreshTable];
        if (!_autoLoaded) {
            _autoLoaded = YES;
        }
    } else {
        [WXWUIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSActionFaildMsg, nil)
                                         msgType:ERROR_TY
                              belowNavigationBar:YES];
    }
    
    [super connectDone:result url:url contentType:contentType];
}

- (void)connectCancelled:(NSString *)url
             contentType:(WebItemType)contentType {
    [super connectCancelled:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(WebItemType)contentType {
        
  if ([self connectionMessageIsEmpty:error]) {
    self.connectionErrorMsg = LocaleStringForKey(NSActionFaildMsg, nil);
  }
    
    [super connectFailed:error url:url contentType:contentType];
}

@end
