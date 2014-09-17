//
//  LocationFetcherDelegate.h
//  iAlumniHD
//
//  Created by Adam on 12-1-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class LocationManager;

@protocol LocationFetcherDelegate <NSObject>

@optional
- (void)locationManagerDidUpdateLocation:(LocationManager *)manager location:(CLLocation*)location;
- (void)locationManagerDidReceiveLocation:(LocationManager *)manager location:(CLLocation*)location;
- (void)locationManagerDidFail:(LocationManager *)manager;
- (void)locationManagerCancelled:(LocationManager *)manager;



@end
