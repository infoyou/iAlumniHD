//
//  BaseListViewController.h
//  iAlumniHD
//
//  Created by Adam on 12-10-4.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "PullRefreshTableHeaderView.h"
#import "PullRefreshTableFooterView.h"
#import "UIWebViewController.h"

@class VerticalLayoutItemInfoCell;
@class ConfigurableTextCell;

@interface BaseListViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource>
{
    PullRefreshTableFooterView *_footerRefreshView;
    PullRefreshTableHeaderView *_headerRefreshView;
    
    BOOL _needRefreshHeaderView;
    BOOL _needRefreshFooterView;
    BOOL _userBeginDrag;
    
    BOOL _userFirstUseThisList;
    
    NSInteger _currentStartIndex;
    
    BOOL _showNewLoadedItemCount;
    
    BOOL _shouldTriggerLoadLatestItems;
    BOOL _shouldTriggerLoadOlderItems;
    
    BOOL _noNeedDisplayEmptyMsg;
    
    BOOL _loadForNewItem;
    LoadTriggerType _currentLoadTriggerType;
    BOOL _autoLoaded;
    BOOL _reloading;
    NSTimer *timer;
    
@private
    UITableViewStyle _tableStyle;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
  showCloseButton:(BOOL)showCloseButton
needRefreshHeaderView:(BOOL)needRefreshHeaderView
needRefreshFooterView:(BOOL)needRefreshFooterView;

- (id)initWithMOC:(NSManagedObjectContext *)MOC
  showCloseButton:(BOOL)showCloseButton
needRefreshHeaderView:(BOOL)needRefreshHeaderView
needRefreshFooterView:(BOOL)needRefreshFooterView
       tableStyle:(UITableViewStyle)tableStyle;

- (id)initNoNeedLoadBackendDataWithMOC:(NSManagedObjectContext *)MOC
                                holder:(id)holder
                      backToHomeAction:(SEL)backToHomeAction
                 needRefreshHeaderView:(BOOL)needRefreshHeaderView
                 needRefreshFooterView:(BOOL)needRefreshFooterView
                            tableStyle:(UITableViewStyle)tableStyle
                            needGoHome:(BOOL)needGoHome;

- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder
 backToHomeAction:(SEL)backToHomeAction
needRefreshHeaderView:(BOOL)needRefreshHeaderView
needRefreshFooterView:(BOOL)needRefreshFooterView
       needGoHome:(BOOL)needGoHome;

- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder
 backToHomeAction:(SEL)backToHomeAction
needRefreshHeaderView:(BOOL)needRefreshHeaderView
needRefreshFooterView:(BOOL)needRefreshFooterView
       tableStyle:(UITableViewStyle)tableStyle
       needGoHome:(BOOL)needGoHome;

- (void)initTableView;

- (void)refreshTable;
- (void)refreshTable:(NSFetchedResultsController **)fetchedRC
          entityName:(NSString *)entityName
  sectionNameKeyPath:(NSString *)sectionNameKeyPath
     sortDescriptors:(NSMutableArray *)sortDescriptors
           predicate:(NSPredicate *)predicate;

- (NSFetchedResultsController *)performFetchByFetchedRC:(NSFetchedResultsController *)fetchedRC;

#pragma mark - load data from backend server
- (void)loadListData:(LoadTriggerType)triggerType forNew:(BOOL)forNew;

#pragma mark - draw grouped cell
- (VerticalLayoutItemInfoCell *)drawNoShadowVerticalInfoCell:(NSString *)title
                                                    subTitle:(NSString *)subTitle
                                                     content:(NSString *)content
                                              cellIdentifier:(NSString *)cellIdentifier
                                                   clickable:(BOOL)clickable;

- (VerticalLayoutItemInfoCell *)drawShadowVerticalInfoCell:(NSString *)title
                                                  subTitle:(NSString *)subTitle
                                                   content:(NSString *)content
                                            cellIdentifier:(NSString *)cellIdentifier
                                                    height:(CGFloat)height
                                                 clickable:(BOOL)clickable;

#pragma mark - draw configurable text cell

- (CGFloat)calculateCommonCellHeightWithTitle:(NSString *)title
                                      content:(NSString *)content
                                    indexPath:(NSIndexPath *)indexPath
                                    clickable:(BOOL)clickable;

- (CGFloat)calculateHeaderCellHeightWithTitle:(NSString *)title
                                      content:(NSString *)content
                                    indexPath:(NSIndexPath *)indexPath;

- (UITableViewCell *)configureCommonCell:(NSString *)cellIdentifier
                                   title:(NSString *)title
                              badgeCount:(NSInteger)badgeCount
                                 content:(NSString *)content
                               indexPath:(NSIndexPath *)indexPath
                               clickable:(BOOL)clickable
                              dropShadow:(BOOL)dropShadow
                            cornerRadius:(CGFloat)cornerRadius;

- (UITableViewCell *)configureCommonGroupedCell:(NSString *)cellIdentifier
                                          title:(NSString *)title
                                     badgeCount:(NSInteger)badgeCount
                                        content:(NSString *)content
                                      indexPath:(NSIndexPath *)indexPath
                                      clickable:(BOOL)clickable
                                     dropShadow:(BOOL)dropShadow
                                   cornerRadius:(CGFloat)cornerRadius;

- (ConfigurableTextCell *)configurePlainCell:(NSString *)cellIdentifier
                                       title:(NSString *)title
                                  badgeCount:(NSInteger)badgeCount
                                     content:(NSString *)content
                                   indexPath:(NSIndexPath *)indexPath
                                   clickable:(BOOL)clickable
                              selectionStyle:(UITableViewCellSelectionStyle)selectionStyle;

- (UITableViewCell *)configureHeaderCell:(NSString *)cellIdentifier
                                   title:(NSString *)title
                              badgeCount:(NSInteger)badgeCount
                                 content:(NSString *)content
                               indexPath:(NSIndexPath *)indexPath
                              dropShadow:(BOOL)dropShadow
                            cornerRadius:(CGFloat)cornerRadius;

- (UITableViewCell *)configureWithTitleImageCell:(NSString *)cellIdentifier
                                           title:(NSString *)title
                                      badgeCount:(NSInteger)badgeCount
                                         content:(NSString *)content
                                           image:(UIImage *)image
                                       indexPath:(NSIndexPath *)indexPath
                                       clickable:(BOOL)clickable
                                      dropShadow:(BOOL)dropShadow
                                    cornerRadius:(CGFloat)cornerRadius;

#pragma mark - table view utility methods
- (BOOL)currentCellIsFooter:(NSIndexPath *)indexPath;

#pragma mark - handle empty list
- (BOOL)listIsEmpty;
- (void)checkListWhetherEmpty;

#pragma mark - load latest or old items
- (BOOL)shouldLoadLatestItems:(UIScrollView *)scrollView;
- (BOOL)shouldLoadOlderItems:(UIScrollView *)scrollView;
- (void)resetUIElementsForConnectDoneOrFailed;

#pragma mark - clear last selected indexPath
- (void)clearLastSelectedIndexPath;

#pragma mark - update last selected cell
- (void)updateLastSelectedCell;

#pragma mark - delete last selected cell
- (void)deleteLastSelectedCell;

#pragma mark - deselect row cell
- (void)deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;

- (NSFetchedResultsController *)prepareFetchRC;

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark - draw footer cell
- (UITableViewCell *)drawFooterCell;

- (void)resetFooterRefreshViewStatus;
- (void)removeEmptyMessageIfNeeded;

#pragma mark - web view
- (void)goWebView:(NSString *)url title:(NSString*)title;

#pragma mark - go map view
- (void)goMapView:(NSString*)title
         latitude:(double)latitude
        longitude:(double)longitude
   allowLaunchMap:(BOOL)allowLaunchMap;

- (void)defaultSelTableCell;
@end
