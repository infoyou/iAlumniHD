//
//  StartUpListViewController.m
//  iAlumniHD
//
//  Created by Adam on 11-10-4.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "StartUpListViewController.h"
#import "StartUpListCell.h"
#import "Event.h"
#import "StartUpDetailViewController.h"
#import "EventCity.h"

@interface StartUpListViewController()
@property (nonatomic, copy) NSString *cityId;
@property (nonatomic, copy) NSString *hostTypeValue;
@property (nonatomic, copy) NSString *hostSubTypeValue;
@end

@implementation StartUpListViewController

- (void)clearEvents {
    DELETE_OBJS_FROM_MOC(_MOC, @"Event", nil);
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
{
    
    self = [super initWithMOC:MOC
                       holder:nil
             backToHomeAction:nil
        needRefreshHeaderView:NO
        needRefreshFooterView:YES
                   tableStyle:UITableViewStylePlain
                   needGoHome:YES];
    
    _currentStartIndex = 0;
    
    [self clearEvents];
    
    [self clearFliter];
    [self clearPickerSelIndex2Init:1];
    
    return self;
}

- (void)dealloc {
    
    [NSFetchedResultsController deleteCacheWithName:nil];
    [self clearFliter];
    [self clearEvents];
    self.cityId = @"";
    [super dealloc];
}

- (void)loadListData:(LoadTriggerType)triggerType forNew:(BOOL)forNew {
    
    [super loadListData:triggerType forNew:forNew];
    
    _currentType = EVENTLIST_TY;
    
    NSInteger index = 0;
    if (!forNew) {
        index = ++_currentStartIndex;
    }
    
    NSMutableString *requestParam = [NSMutableString stringWithFormat:@"<host_type_value>%@</host_type_value><host_sub_type_value>%@</host_sub_type_value><city_id>%@</city_id><page_size>20</page_size><page>%d</page><longitude>%f</longitude><latitude>%f</latitude><screen_type>%d</screen_type>", self.hostTypeValue, self.hostSubTypeValue, self.cityId, index, [AppManager instance].longitude, [AppManager instance].latitude, STARTUP_EVENT_TY];
    
    NSString *url = [CommonUtils geneUrl:requestParam itemType:_currentType];
    
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                              contentType:_currentType];
    [connFacade fetchGets:url];
}

- (void)clearFliter {
    // Clear Fliter
    [[AppManager instance].supClubFilterList removeAllObjects];
    [AppManager instance].supClubFilterList = nil;
    [[AppManager instance].clubFilterList removeAllObjects];
    [AppManager instance].clubFilterList = nil;
    [AppManager instance].clubFliterLoaded = NO;
}

#pragma mark - core data

- (void)setPredicate {
    self.entityName = @"Event";
    self.descriptors = [NSMutableArray array];
    self.predicate = [NSPredicate predicateWithFormat:@"screenType == %d", STARTUP_EVENT_TY];
    
    NSSortDescriptor *dateDesc = [[[NSSortDescriptor alloc] initWithKey:@"showOrder" ascending:YES] autorelease];
    [self.descriptors addObject:dateDesc];
    
}

#pragma mark - View lifecycle

- (void)setTableViewProperties {
    
    _tableView.separatorStyle = NO;
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"lightBackground.png"]];
}

- (void)hideView {
    _originalTableViewFrame = _tableView.frame;
    _tableView.alpha = 0.0f;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = CELL_COLOR;
    
//    [self setNaviBarButtonItem:LocaleStringForKey(NSAllTitle, nil)];
    
    [self setTableViewProperties];
    
    [self hideView];
}

- (void)doFliter:(id)sender
{
    if (_isPop) {
        return;
    }else{
        _isPop = YES;
    }
    
    if (![AppManager instance].eventCityLoaded) {
        _currentType = EVENT_CITY_LIST_TY;
        NSString *url = [CommonUtils geneUrl:@"" itemType:_currentType];
        WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                                  contentType:_currentType];
        [connFacade fetchGets:url];
    } else {
        [super setPopView];
        [_popViewController presentPopoverFromRect:CGRectMake(-200.f, -50.f, 0, 0)
                                            inView:self.view
                          permittedArrowDirections:UIPopoverArrowDirectionAny
                                          animated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated {
	[super deselectCell];
	
	if (!_autoLoaded) {
		[self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
	}
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super deselectCell];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - set navigation button item
- (void)setNaviBarButtonItem:(NSString*)cityStr
{
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:cityStr
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:self
                                                                             action:@selector(doFliter:)] autorelease];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    
    return self.fetchedRC.fetchedObjects.count + 1;
}

- (void)updateTable:(NSArray *)indexPaths {
    [_tableView beginUpdates];
    [_tableView reloadRowsAtIndexPaths:indexPaths
                      withRowAnimation:UITableViewRowAnimationNone];
    [_tableView endUpdates];
    
}

- (StartUpListCell *)drawStartUpCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    
    // Event Cell
    NSString *kEventCellIdentifier = @"EventCell";
    StartUpListCell *cell = (StartUpListCell *)[tableView dequeueReusableCellWithIdentifier:kEventCellIdentifier];
    if (nil == cell) {
        cell = [[[StartUpListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kEventCellIdentifier] autorelease];
    }
    
    Event *event = [self.fetchedRC objectAtIndexPath:indexPath];
    [cell drawStartUp:event];
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == self.fetchedRC.fetchedObjects.count) {
        return [self drawFooterCell];
    } else {
        return [self drawStartUpCell:tableView indexPath:indexPath];
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == _fetchedRC.fetchedObjects.count) {
        return;
    }
    
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    [AppManager instance].isClub2Event = NO;
    
    Event *event = [self.fetchedRC objectAtIndexPath:indexPath];
    [AppManager instance].eventId = [event.eventId stringValue];
    StartUpDetailViewController *detailVC = [[[StartUpDetailViewController alloc] initWithMOC:_MOC
                                                                                    event:event] autorelease];
    detailVC.title = LocaleStringForKey(NSStartupProjectTitle, nil);
    
    detailVC.deSelectCellDelegate = self;
    self.selectedIndexPath = indexPath;
    
    WXWNavigationController *detailNC = [[[WXWNavigationController alloc] initWithRootViewController:detailVC] autorelease];
    
    [APP_DELEGATE addViewInSlider:detailNC
               invokeByController:self
                   stackStartView:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return EVENT_LIST_CELL_HEIGHT;
}

#pragma mark - UIPickerViewDelegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	pickSel0Index = row;
    
    isPickSelChange = YES;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [_PickData count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _PickData[row];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return LIST_WIDTH;
}

-(void)onPopCancle:(id)sender {
    
    [super onPopCancle];
    _isPop = NO;
}

-(void)onPopOk:(id)sender {
    [super onPopSelectedOk];
    int iPickSelectIndex = [super pickerList0Index];
    
    [self clearEvents];
    
    [_PopBGView removeFromSuperview];
    
    [self setNaviBarButtonItem:[[self.DropDownValArray objectAtIndex:iPickSelectIndex] objectAtIndex:RECORD_NAME]];

    self.cityId = [[self.DropDownValArray objectAtIndex:iPickSelectIndex] objectAtIndex:RECORD_ID];
    _currentStartIndex = 0;

    [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
    _isPop = NO;
}

#pragma mark - set drop Value
- (void)setDropDownValueArray {
    
    [NSFetchedResultsController deleteCacheWithName:nil];
    
    self.descriptors = [NSMutableArray array];
    self.DropDownValArray = [[[NSMutableArray alloc] init] autorelease];
    
    NSSortDescriptor *orderDesc = [[[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES] autorelease];
    [self.descriptors addObject:orderDesc];
    
    self.entityName = @"EventCity";
    
    NSError *error = nil;
    BOOL res = [[super prepareFetchRC] performFetch:&error];
    if (!res) {
        NSAssert1(0, @"Unhandled error performing fetch: %@", [error localizedDescription]);
    }
    
    NSArray *eventCitys = [CommonUtils objectsInMOC:_MOC
                                         entityName:self.entityName
                                       sortDescKeys:self.descriptors
                                          predicate:nil];
    
    int size = [eventCitys count];
    for (NSUInteger i=0; i<size; i++) {
        EventCity *mEventCity = (EventCity*)eventCitys[i];
        NSMutableArray *mArray = [[NSMutableArray alloc] init];
        [mArray insertObject:mEventCity.cityId atIndex:0];
        if ([AppManager instance].currentLanguageCode == EN_TY) {
            [mArray insertObject:mEventCity.enName atIndex:1];
        } else {
            [mArray insertObject:mEventCity.cnName atIndex:1];
        }
        [self.DropDownValArray insertObject:mArray atIndex:i];
        [mArray release];
    }
}

#pragma mark - load Event list from web
- (void)stopAutoRefreshUserList {
    [timer invalidate];
}

#pragma mark - arrange tab after events loaded

- (void)checkDataExisting {
    
    if ([CoreDataUtils objectInMOC:_MOC
                        entityName:@"Event"
                         predicate:nil]) {
        
        [UIView animateWithDuration:FADE_IN_DURATION
                         animations:^{
                             _tableView.frame = _originalTableViewFrame;
                             _tableView.alpha = 1.0f;
//                             [self defaultSelTableCell];
                         }];
        
        _tableViewDisplayed = YES;
    }
}

#pragma mark - WXWConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(WebItemType)contentType {
    [self showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil) blockCurrentView:YES];
    
    [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(WebItemType)contentType {
    
    switch (contentType) {
        case EVENTLIST_TY:
        {
            
            if ([XMLParser parserSyncResponseXml:result type:FETCH_EVENT_LIST_SRC MOC:_MOC]) {
                
                [self refreshTable];
                
                if (!_autoLoaded) {
                    _keepEventsInMOC = YES;
                    [self checkDataExisting];
                    _autoLoaded = YES;
                } else {
                    
                    if (!_tableViewDisplayed) {
                        [UIView animateWithDuration:FADE_IN_DURATION
                                         animations:^{
                                             _tableView.frame = _originalTableViewFrame;
                                             _tableView.alpha = 1.0f;
//                                             [self defaultSelTableCell];
                                         }];
                        
                        _tableViewDisplayed = YES;
                    }
                }
            } else {
                [WXWUIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSActionFaildMsg, nil)
                                              msgType:ERROR_TY
                                   belowNavigationBar:YES];
            }
            
            break;
        }
            
        case EVENT_CITY_LIST_TY:
        {
            BOOL ret = [XMLParser parserSyncResponseXml:result
                                                   type:FETCH_EVENT_CITY_SRC
                                                    MOC:_MOC];
            
            if (ret) {
                [super setPopView];
                [_popViewController presentPopoverFromRect:CGRectMake(-200.f, -50.f, _frame.size.width, TOOLBAR_HEIGHT)
                                                    inView:self.view
                                  permittedArrowDirections:UIPopoverArrowDirectionAny
                                                  animated:YES];
            } else {
                [WXWUIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSActionFaildMsg, nil)
                                              msgType:ERROR_TY
                                   belowNavigationBar:YES];
                
            }
            break;
        }
            
        default:
            break;
    }
    
    [self resetUIElementsForConnectDoneOrFailed];
    
    [super connectDone:result
                   url:url
           contentType:contentType];
    
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

@end