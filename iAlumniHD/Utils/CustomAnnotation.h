//
//  CustomAnnotation.h
//  iAlumniHD
//
//  Created by Adam on 12-11-20.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface CustomAnnotation : NSObject<MKAnnotation>
{
	CLLocationCoordinate2D coordinate;
	NSString *subtitle;
	NSString *title;
}

@property(nonatomic,readonly)CLLocationCoordinate2D coordinate;
@property(nonatomic,copy) NSString *subtitle;
@property(nonatomic,copy) NSString *title;


-(id)initWithCoords:(CLLocationCoordinate2D)coords;

@end
