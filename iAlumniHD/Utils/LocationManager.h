//
//  LocationManager.h
//  iAlumniHD
//
//  Created by Adam on 12-1-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MKReverseGeocoder.h>
#import "LocationFetcherDelegate.h"
#import "GlobalConstants.h"

@interface LocationManager : NSObject <CLLocationManagerDelegate> {
  
  id<LocationFetcherDelegate> _delegate;
  
  CLLocationManager	*_locationManager;
	CLLocation			*_location;
	NSTimer				*_timer;
	
	BOOL _hasLocationGotten;
  
  BOOL _showAlertMsg;  
}

- (id)initWithDelegate:(id<LocationFetcherDelegate>)delegate showAlertMsg:(BOOL)showAlertMsg;

#pragma mark - location fetch methods
- (void)getCurrentLocation;

#pragma mark - cancel location
- (void)cancelLocation;

@end
