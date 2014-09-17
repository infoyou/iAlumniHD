//
//  StoreListViewController.h
//  iAlumniHD
//
//  Created by Adam on 13-3-14.
//
//

#import "BaseListViewController.h"
#import <MapKit/MapKit.h>
#import "GlobalConstants.h"
#import "FilterListDelegate.h"

@class Brand;
@class NearbyMapView;
@class ItemCalloutView;
@class NearbyItemAnnotationView;

@interface StoreListViewController : BaseListViewController <MKMapViewDelegate, FilterListDelegate> {
  @private
  Brand *_brand;
  
  NSNumber *_itemTotleCount;
  
  long long _brandId;
  
  UIView *_tableAndMapContainer;  // be used to flip between list and map
  
  // map view
  NearbyMapView *_mapView;
  NSInteger _startIndex;
  NSInteger _endIndex;
  BOOL _currentShowList;
  BOOL _loadMoreTriggeredForMap;
  NSInteger _currentPhaseIndex;
  BOOL _keepCalloutView;
  BOOL _clearCalloutViewForIOS4x;
  BOOL _switchTypeInMapView;
  ItemCalloutView *_calloutView;
  NearbyItemAnnotationView *_userLastSelectedAnnotationView;
  
  // location
  BOOL _currentLocationIsLatest;
}

- (id)initNearbyStoreWithMOC:(NSManagedObjectContext *)MOC
            locationRefreshed:(BOOL)locationRefreshed;

- (id)initBranchVenuesWithMOC:(NSManagedObjectContext *)MOC
                        brand:(Brand *)brand
            locationRefreshed:(BOOL)locationRefreshed;

@end
