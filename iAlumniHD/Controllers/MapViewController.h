//
//  MapViewController.h
//  iAlumniHD
//
//  Created by Adam on 12-11-2.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import <MapKit/MapKit.h>
#import "MKMapView+ZoomLevel.h"

@interface MapViewController : RootViewController <MKMapViewDelegate, UIAlertViewDelegate> {
    
  @private
  
  double _latitude;
  double _longitude;
  
  BOOL _allowLaunchMap;
}

- (id)initWithTitle:(NSString*)title
           latitude:(double)latitude
          longitude:(double)longitude
     allowLaunchMap:(BOOL)allowLaunchMap;

@end
