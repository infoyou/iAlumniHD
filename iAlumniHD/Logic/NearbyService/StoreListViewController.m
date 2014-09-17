//
//  StoreListViewController.m
//  iAlumniHD
//
//  Created by Adam on 13-3-14.
//
//

#import "StoreListViewController.h"
#import "Brand.h"
#import "NearbyMapView.h"
#import "MKMapView+ZoomLevel.h"
#import "ServiceItem.h"
#import "NearbyAnnotation.h"
#import "ItemCalloutView.h"
#import "NearbyItemAnnotationView.h"
#import "ServiceItemCell.h"
#import "ServiceItemDetailViewController.h"
#import "AppManager.h"
#import "CommonUtils.h"
#import "XMLParser.h"
#import "WXWUIUtils.h"

#define DISPLAYED_ITEMS_COUNT 20

#define CALLOUT_VIEW_WIDTH            240.0f
#define CALLOUT_VIEW_HEIGHT           80.0f

#define ITEM_CELL_HEIGHT              80.0f

#define DISTANCE_FACTOR       550
#define MAX_ZOOM_LEVEL        8
#define MIN_ZOON_LEVEL        2

@interface StoreListViewController ()
@property (nonatomic, retain) Brand *brand;
@end

@implementation StoreListViewController

@synthesize brand = _brand;

#pragma mark - load data
- (void)loadListData:(LoadTriggerType)triggerType
              forNew:(BOOL)forNew {
    
    [super loadListData:triggerType forNew:forNew];
    
    NSInteger startIndex = 0;
    
    if (!forNew) {
        startIndex = ++_currentPhaseIndex;
    }
    
    NSMutableString *param = [NSMutableString stringWithFormat:@"<favorite_by></favorite_by><distance></distance><latitude>%@</latitude><longitude>%@</longitude><sort_type>%d</sort_type><page>%d</page><page_size>%@</page_size>",
                              LOCDATA_TO_STRING([AppManager instance].latitude),
                              LOCDATA_TO_STRING([AppManager instance].longitude),
                              SI_SORT_BY_DISTANCE_TY,
                              startIndex,
                              ITEM_LOAD_COUNT];
    if (_brandId > 0ll) {
        [param appendFormat:@"<channel_id>%lld</channel_id>", _brandId];
    }
    
    NSString *url = [CommonUtils geneUrl:param itemType:LOAD_SERVICE_ITEM_TY];
    
    WXWAsyncConnectorFacade *connFacade = [[[WXWAsyncConnectorFacade alloc] initWithDelegate:self
                                                                      interactionContentType:LOAD_SERVICE_ITEM_TY] autorelease];
    (self.connDic)[url] = connFacade;
    [connFacade fetchNearbyItems:url];
}

- (void)setPredicate {
    self.entityName = @"ServiceItem";
    
    self.descriptors = [NSMutableArray array];
    NSSortDescriptor *descriptor1 = [[[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES] autorelease];
    [self.descriptors addObject:descriptor1];
    
    NSSortDescriptor *descriptor2 = [[[NSSortDescriptor alloc] initWithKey:@"itemId" ascending:YES] autorelease];
    [self.descriptors addObject:descriptor2];
}

#pragma mark - refresh nearby location info
- (void)refreshBranchList:(NSNotification *)notification {
    
    [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
}

#pragma mark - lifecycle methods

- (void)registerNotifications {
    
    // user entered nearby service, then he/she click 'Home' button for iPhone, then app deactivec,
    // if user actives the app again, the location info should be refreshed
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshBranchList:)
                                                 name:REFRESH_NEARBY_NOTIFY
                                               object:nil];
    
}

- (void)setInitProperties:(BOOL)locationRefreshed {
    _currentLocationIsLatest = locationRefreshed;
    _currentShowList = YES;
    
    [self registerNotifications];
}

- (id)initNearbyStoreWithMOC:(NSManagedObjectContext *)MOC
            locationRefreshed:(BOOL)locationRefreshed {
    
    self = [super initWithMOC:MOC
                       holder:nil
             backToHomeAction:nil
        needRefreshHeaderView:YES
        needRefreshFooterView:YES
                   needGoHome:NO];
    if (self) {
        
        _brandId = 0ll;
        
        [self setInitProperties:locationRefreshed];
        
        _allowSwipeBackToParentVC = NO;
    }
    return self;
}

- (id)initBranchVenuesWithMOC:(NSManagedObjectContext *)MOC
                        brand:(Brand *)brand
            locationRefreshed:(BOOL)locationRefreshed {
    self = [self initWithMOC:MOC
                      holder:nil
            backToHomeAction:nil
       needRefreshHeaderView:YES
       needRefreshFooterView:YES
                  needGoHome:NO];
    
    if (self) {
        self.brand = brand;
        
        _brandId = brand.brandId.longLongValue;
        
        [self setInitProperties:locationRefreshed];
        
        _allowSwipeBackToParentVC = NO;
    }
    return self;
}

- (void)dealloc {
    
    self.brand = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:REFRESH_NEARBY_NOTIFY
                                                  object:nil];
    [super dealloc];
}

- (void)initTableAndMapContainer {
    
    // becauser the table view has been initialized and added to self.view in super viewDidLoad method,
    // then we need to move table view from self.view to current container;
    _tableAndMapContainer = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                     0,
                                                                     self.view.frame.size.width,
                                                                     self.view.frame.size.height)];
    _tableAndMapContainer.backgroundColor = TRANSPARENT_COLOR;
    [self.view addSubview:_tableAndMapContainer];
    
    // remove table view from self.vew
    [_tableView removeFromSuperview];
    
    // move table view to new container
    [_tableAndMapContainer addSubview:_tableView];
}

- (void)initNavigationItemButton {
    [self addRightBarButtonWithTitle:LocaleStringForKey(NSMapTitle, nil)
                              target:self
                              action:@selector(switchMapAndList:)];
    
    self.navigationItem.rightBarButtonItem.enabled = _currentLocationIsLatest;
}

- (void)checkLocationRefreshStatus {
    if (!_currentLocationIsLatest) {
        
        [self showAsyncLoadingView:LocaleStringForKey(NSLocatingMsg, nil) blockCurrentView:YES];
        [self forceGetLocation];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = CELL_COLOR;
    
    [self initTableAndMapContainer];
    
    [self initMapView];
    
    [self initNavigationItemButton];
    
    [self checkLocationRefreshStatus];

}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!_autoLoaded && _currentLocationIsLatest) {
        [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - switch between map and list

- (void)adjustMapZoomLevel {
    
    [_mapView zoomToFitMapAnnotations];
}

- (void)initMapView {
    _mapView = [[NearbyMapView alloc] initWithFrame:CGRectMake(0, 0,
                                                               self.view.frame.size.width,
                                                               _tableView.frame.size.height)
                                 filterListDelegate:self
                                             target:self
                                  hideCalloutAction:@selector(hideAnnotationView)
                                     needFilterSort:NO];
    _mapView.autoresizesSubviews = YES;
    _mapView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    _mapView.showsUserLocation = YES;
    
    [self adjustMapZoomLevel];
    
    _mapView.delegate = self;
    
    _startIndex = 1;
    _endIndex = 1;
}

- (void)removeAllNonUserLocationAnnotation {
    NSMutableArray *anns = [NSMutableArray array];
    for (id<MKAnnotation> annotation in _mapView.annotations) {
        if (![annotation isKindOfClass:[MKUserLocation class]]) {
            [anns addObject:annotation];
        }
    }
    
    [_mapView removeAnnotations:anns];
}

- (void)setStartAndEndIndex {
    
    if (_fetchedRC.fetchedObjects.count == 0) {
        _startIndex = 0;
        _endIndex = 0;
        return;
    }
    
    _startIndex = _currentPhaseIndex * DISPLAYED_ITEMS_COUNT + 1;
    NSInteger end = _currentPhaseIndex * DISPLAYED_ITEMS_COUNT + DISPLAYED_ITEMS_COUNT;
    if (_itemTotleCount.intValue < end) {
        // item total count less than 20
        //_startIndex = 1;
        _endIndex = _itemTotleCount.intValue;
    } else {
        _endIndex = end;
    }
    
    // if _loadMoreTriggeredForMap is YES, which means the load more is in progress now,
    // then no need to trigger load again
    if (_endIndex > _fetchedRC.fetchedObjects.count) {
        
        _loadMoreTriggeredForMap = YES;
        
        _currentStartIndex = _fetchedRC.fetchedObjects.count;
        
        // current loaded item is not enough to displayed, then trigger load more
        [self loadListData:TRIGGERED_BY_SORT forNew:NO];
    }
}

- (void)arrangeAnnotationsForMapView {
    
    [self setStartAndEndIndex];
    
    // if load more triggered for map, the re-draw for map will be called in connectDone:url:conentType: method
    if (!_loadMoreTriggeredForMap) {
        
        [self removeAllNonUserLocationAnnotation];
        
        if (_startIndex > 0 && _endIndex > 0) {
            for (NSInteger index = (_startIndex - 1); index < _endIndex; index++) {
                ServiceItem *item = (ServiceItem *)(_fetchedRC.fetchedObjects)[index];
                if (item.latlagAttached.boolValue) {
                    CLLocationCoordinate2D coordinate = {item.latitude.doubleValue, item.longitude.doubleValue};
                    NearbyAnnotation *annotation = [[[NearbyAnnotation alloc] initWithCoordinate:coordinate
                                                                                     serviceItem:item
                                                                                  sequenceNumber:index + 1] autorelease];
                    [_mapView addAnnotation:annotation];
                }
            }
        }
        
        [_mapView setSPTitleWithStartNumber:_startIndex
                                  endNumber:_endIndex
                                  itemTotal:_itemTotleCount.intValue];
        
        [self adjustMapZoomLevel];
    }
}

- (void)clearCalloutView {
    [_calloutView removeFromSuperview];
    RELEASE_OBJ(_calloutView);
}

- (void)switchMapAndList:(id)sender {
    
    [UIView beginAnimations:nil
                    context:nil];
    [UIView setAnimationDuration:1.0f];
    UIViewAnimationTransition transition;
    
    if (_currentShowList) {
        // switch from list to map
        
        // as user could click 'Show Nexst' button to trigger load more items in map view,
        // then the param need the latest start index, we should set the load start index when
        // the list switch to map
        _currentStartIndex = _fetchedRC.fetchedObjects.count;
        
        [self setRightButtonTitle:LocaleStringForKey(NSListTitle, nil)];
        transition = UIViewAnimationTransitionFlipFromLeft;
        
        [self adjustMapZoomLevel];
        
        [_tableView removeFromSuperview];
        [_tableAndMapContainer addSubview:_mapView];
        
        [self arrangeAnnotationsForMapView];
        
    } else {
        
        // switch from map to list
        [self setRightButtonTitle:LocaleStringForKey(NSMapTitle, nil)];
        transition = UIViewAnimationTransitionFlipFromRight;
        
        // clear current displayed call out view
        if (_calloutView) {
            [self clearCalloutView];
        }
        
        [_mapView removeFromSuperview];
        [_tableAndMapContainer addSubview:_tableView];
    }
    [UIView setAnimationTransition:transition
                           forView:_tableAndMapContainer
                             cache:YES];
    [UIView commitAnimations];
    
    _currentShowList = !_currentShowList;
}

#pragma mark mapView delegate functions

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    NearbyItemAnnotationView *itemAnnotationView = (NearbyItemAnnotationView *)view;
    NearbyAnnotation *annotation = (NearbyAnnotation *)itemAnnotationView.annotation;
    
    _userLastSelectedAnnotationView = itemAnnotationView;
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return;
    }
    
    ((NearbyItemAnnotationView *)view).image = [UIImage imageNamed:@"itemRedPin.png"];
    [((NearbyItemAnnotationView *)view) setPinTextColor:[UIColor whiteColor]];
    
    [_mapView setCenterCoordinate:annotation.coordinate animated:YES];
    
    if (nil == _calloutView) {
        _calloutView = [[ItemCalloutView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - CALLOUT_VIEW_WIDTH)/2,
                                                                         _mapView.frame.origin.y + 40.0f + MARGIN * 2,
                                                                         CALLOUT_VIEW_WIDTH, CALLOUT_VIEW_HEIGHT)
                                                         item:annotation.item
                                                   sequenceNO:annotation.sequenceNumber
                                                       target:self showDetailAction:@selector(showItem:)];
    }
    
    [_mapView addSubview:_calloutView];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    
    NearbyItemAnnotationView *itemAnnotationView = (NearbyItemAnnotationView *)view;
    NearbyAnnotation *annotation = (NearbyAnnotation *)itemAnnotationView.annotation;
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return;
    }
    
    if (!_keepCalloutView) {
        
        ((NearbyItemAnnotationView *)view).image = [UIImage imageNamed:@"itemOrangePin.png"];
        
        // there is a difference between IOS 5.x and IOS 4.x for the process flow,
        // flow of IOS 4.x: pointInside-->mapView: didSelectAnnotationView:-->
        // mapView: didDeselectAnnotationView:
        // foow of IOS 5.x: pointInside-->mapView: didDeselectAnnotationView:-->
        // mapView: didSelectAnnotationView:
        // so we need handle them separately
        if ([CommonUtils currentOSVersion] >= IOS5) {
            if (_calloutView) {
                [self clearCalloutView];
            }
        } else {
            if (_clearCalloutViewForIOS4x && _calloutView) {
                [self clearCalloutView];
                
                _clearCalloutViewForIOS4x = NO;
            }
        }
        
    } else {
        _keepCalloutView = NO;
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id <MKAnnotation>)annotation {
    
	if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
	// determine the type of annotation, and produce the correct type of annotation view for it.
	NearbyAnnotation* csAnnotation = (NearbyAnnotation*)annotation;
	
	static NSString* identifier = @"Pin";
    
	NearbyItemAnnotationView* pin = (NearbyItemAnnotationView*)[_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
	
	if(nil == pin) {
		pin = [[[NearbyItemAnnotationView alloc] initWithAnnotation:csAnnotation
                                                    reuseIdentifier:identifier] autorelease];
    } else {
        pin.annotation = csAnnotation;
    }
    
    [pin setSequenceNumber:csAnnotation.sequenceNumber];
    
    return pin;
}

#pragma mark - UITableViewDataSource, UITableViewDelegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _fetchedRC.fetchedObjects.count + 1;
}

- (UITableViewCell *)drawItemCell:(NSIndexPath *)indexPath item:(ServiceItem *)item {
    
    static NSString *cellIdentifier = @"serviceItemCell";
    ServiceItemCell *cell = (ServiceItemCell *)[_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (nil == cell) {
        cell = [[[ServiceItemCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:cellIdentifier
                                imageDisplayerDelegate:self
                                                   MOC:_MOC] autorelease];
    }
    
    [cell drawItem:item index:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == _fetchedRC.fetchedObjects.count) {
        return [self drawFooterCell];
    }
    
    ServiceItem *item = (ServiceItem *)[_fetchedRC objectAtIndexPath:indexPath];
    
    return [self drawItemCell:indexPath item:item];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ITEM_CELL_HEIGHT;
}

- (void)showStoreDetail:(NSIndexPath *)indexPath {
    ServiceItem *item = (ServiceItem *)[_fetchedRC objectAtIndexPath:indexPath];
    
    [self showItem:item];
}

- (void)showItem:(ServiceItem *)item {
    ServiceItemDetailViewController *profileVC = [[[ServiceItemDetailViewController alloc] initWithMOC:_MOC
                                                                                                holder:nil
                                                                                      backToHomeAction:nil
                                                                                           serviceItem:item] autorelease];
    
    [self.navigationController pushViewController:profileVC animated:YES];
    
}

- (void)hideAnnotationView {
    
    if (_calloutView) {
        
        _userLastSelectedAnnotationView.image = [UIImage imageNamed:@"itemOrangePin.png"];
        
        [_calloutView removeFromSuperview];
        RELEASE_OBJ(_calloutView);
        
        _userLastSelectedAnnotationView = nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == _fetchedRC.fetchedObjects.count) {
        return;
    }
    
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];

    [self showStoreDetail:indexPath];
    
    [super deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - ECConnectorDelegate methoes
- (void)connectStarted:(NSString *)url contentType:(WebItemType)contentType {
    
    [self showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil) blockCurrentView:YES];
    
    [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result
                url:(NSString *)url
        contentType:(WebItemType)contentType {
    
    if ([XMLParser parserLoadedServiceItemForBrandId:_brandId
                                             xmlData:result
                                                 MOC:_MOC
                                   connectorDelegate:self
                                                 url:url
                                           itemCount:&_itemTotleCount]) {
        
        _autoLoaded = YES;
        
        [self refreshTable];
        
        /*
         ServiceItem *lastItem = (ServiceItem *)_fetchedRC.fetchedObjects.lastObject;
         _currentOldestTimeline = lastItem.lastCommentTimestamp.doubleValue;
         _currentOldestItemId = lastItem.itemId.longLongValue;
         */
        
        if (!_currentShowList) {
            // current show map view
            
            if (_loadMoreTriggeredForMap) {
                // reset this flag, then the map will be redraw in arrangeAnnotationsForMapView method
                _loadMoreTriggeredForMap = NO;
                
            } else if (_switchTypeInMapView) {
                // reset the phase index after new type item list loaded
                _currentPhaseIndex = 0;
                _switchTypeInMapView = NO;
            }
            
            [self arrangeAnnotationsForMapView];
            
        } else {
            // current show list
            // reset the phase index after new type item list loaded
            _currentPhaseIndex = 0;
        }
        
    } else {
        
        [WXWUIUtils showNotificationOnTopWithMsg:(self.errorMsgDic)[url]
                                  alternativeMsg:LocaleStringForKey(NSLoadNearbyFailedMsg, nil)
                                         msgType:ERROR_TY
                              belowNavigationBar:YES];
    }
    
    // should be called at end of method to clear connFacade instance
    [super connectDone:result url:url contentType:contentType];
}

- (void)connectCancelled:(NSString *)url
             contentType:(WebItemType)contentType {
    
    // should be called at end of method to clear connFacade instance
    [super connectCancelled:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error url:(NSString *)url contentType:(WebItemType)contentType {
    
    NSString *msg = nil;
    if (error) {
        msg = [error localizedDescription];
    } else {
        msg = LocaleStringForKey(NSLoadNearbyFailedMsg, nil);
        
        // reset this flag, then the map will be redraw in arrangeAnnotationsForMapView method
        _loadMoreTriggeredForMap = NO;
    }
    
    if ([self connectionMessageIsEmpty:error]) {
        self.connectionErrorMsg = msg;
    }
    
    // should be called at end of method to clear connFacade instance
    [super connectFailed:error url:url contentType:contentType];
}

#pragma mark - ECLocationFetcherDelegate methods

- (void)locationManagerDidReceiveLocation:(LocationManager *)manager
                                 location:(CLLocation *)location {
    
    [super locationManagerDidReceiveLocation:manager
                                    location:location];
    
    // user enter nearby service first time and location data info be fetched successfully
    [self changeAsyncLoadingMessage:LocaleStringForKey(NSLoadingTitle, nil)];
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
    
    _currentLocationIsLatest = YES;
}

- (void)locationManagerDidFail:(LocationManager *)manager {
    [super locationManagerDidFail:manager];
    
    [self changeAsyncLoadingMessage:LocaleStringForKey(NSLoadingTitle, nil)];
    
    [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
}

- (void)locationManagerCancelled:(LocationManager *)manager {
    [super locationManagerCancelled:manager];
}

@end
