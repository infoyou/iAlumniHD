//
//  LocationManager.m
//  iAlumniHD
//
//  Created by Adam on 12-1-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LocationManager.h"
#import "TextConstants.h"
#import "DebugLogOutput.h"
#import "CommonUtils.h"
#import "AppManager.h"
#import "UIUtils.h"
#import "iAlumniHDAppDelegate.h"

#define GPS_TIMEOUT_TIME        30.0
#define GPS_ACCURACY_THRESHOLD  50.0

@interface LocationManager()
@property(nonatomic, retain) CLLocationManager *locationManager;
@property(nonatomic, retain) CLLocation *location;
@property(nonatomic, retain) id<LocationFetcherDelegate> delegate;
@end

@implementation LocationManager

@synthesize locationManager = _locationManager;
@synthesize location = _location;
@synthesize delegate = _delegate;

#pragma mark - lifecycle methods

- (id)initWithDelegate:(id<LocationFetcherDelegate>)delegate showAlertMsg:(BOOL)showAlertMsg {
  self = [super init];
  if (self) {
    
    NSLog(@"---init loc---");
    
    self.delegate = delegate;
    
    _location = nil;
    
    self.locationManager = [[[CLLocationManager alloc] init] autorelease];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    _showAlertMsg = showAlertMsg;
  }
  return self;
}

- (void)dealloc {
  
  NSLog(@"---dealloc loc---");
  
  self.locationManager.delegate = nil;
  self.locationManager = nil;
  self.location = nil;
  self.delegate = nil;
  
  [super dealloc];
}

#pragma mark - location fetch methods

- (void)getCurrentLocation {
  [self.locationManager startUpdatingLocation];
  
  [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
  
  _timer = [NSTimer scheduledTimerWithTimeInterval:GPS_TIMEOUT_TIME 
                                            target:self 
                                          selector:@selector(locationManagerDidTimeout:userInfo:) 
                                          userInfo:nil 
                                           repeats:NO];
  
}

#pragma mark - cancel location
- (void)cancelLocation {
  
  [self.locationManager stopUpdatingLocation];
  [self.locationManager stopUpdatingHeading];
  //self.locationManager.delegate = nil;
  
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
  
  [self.delegate locationManagerCancelled:self];
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
  
  // indicate that whether latitude and longitude have been loacated
	// if they are be gotten, then no need to get the location again
	if (_hasLocationGotten) {
		return;
	}
  
  if (self.delegate) {
    [self.delegate locationManagerDidUpdateLocation:self location:newLocation];
    
    [AppManager instance].locationFetched = YES;
  }
  
  self.location = newLocation;
  
  [_timer invalidate];
  _timer = nil;
  [manager stopUpdatingLocation];
  
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
  
  _hasLocationGotten = YES;
  
  [self.delegate locationManagerDidReceiveLocation:self location:newLocation];
}

- (void)locationManagerDidTimeout:(NSTimer*)aTimer userInfo:(id)userInfo {
  _timer = nil;
  
  [self.locationManager stopUpdatingLocation];
  
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
  
  if (self.location) {
    NSDate* eventDate = self.location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
		
    if ([self.location horizontalAccuracy] < 10000 && abs(howRecent) < GPS_TIMEOUT_TIME + 5.0) {
      [self.delegate locationManagerDidReceiveLocation:self location:self.location];
      self.location = nil;
      
      return;
    }
    
    self.location = nil;
  }
  
  if (![AppManager instance].hasLogoff && ![AppManager instance].locationFetched) {
    if (_showAlertMsg) {
      [UIUtils showNotificationWithMsg:LocaleStringForKey(NSLocationTimeOutMsg, nil)
                               msgType:ERROR_TY
                            holderView:[APP_DELEGATE foundationView]];
    }
  }
  
  [self.delegate locationManagerDidFail:self];
  
  debugLog(@"Location Service Error caused by timeout");
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
  [self.locationManager stopUpdatingLocation];
  
  if (error.code == kCLErrorDenied && [error.domain isEqualToString:kCLErrorDomain]) {
    // the error message will be displayed only for locate current place first time
    // the auto location error no need to display to user again and again
    if (![AppManager instance].locationFetched) {
        [UIUtils showNotificationWithMsg:LocaleStringForKey(NSLocationSevDisabledMsg, nil)
                                 msgType:INFO_TY
                              holderView:[APP_DELEGATE foundationView]];

		} else if (error.code == kCLErrorLocationUnknown) {
      // ignore this error and continue
      return;
    }
    
    [_timer invalidate];
    _timer = nil;
    
    self.location = nil;
    
    [self.delegate locationManagerDidFail:self];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
  }
}

@end

