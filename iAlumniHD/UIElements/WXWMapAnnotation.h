//
//  WXWMapAnnotation.h
//  iAlumniHD
//
//  Created by Adam on 12-11-1.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "GlobalConstants.h"

@interface WXWMapAnnotation : NSObject <MKAnnotation> {
  CLLocationCoordinate2D	_coordinate;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

-(id) initWithCoordinate:(CLLocationCoordinate2D)coordinate;


@end
