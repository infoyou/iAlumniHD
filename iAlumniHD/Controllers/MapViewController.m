//
//  MapViewController.m
//  iAlumniHD
//
//  Created by Adam on 12-11-2.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "WXWMapAnnotation.h"

@interface MapViewController()
@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, copy) NSString *title;
@end

@implementation MapViewController

#pragma mark - lifecycle methods
- (id)initWithTitle:(NSString*)title
           latitude:(double)latitude
          longitude:(double)longitude
     allowLaunchMap:(BOOL)allowLaunchMap {
    
    self = [super initWithMOC:nil frame:CGRectMake(0, 0, UI_MODAL_FORM_SHEET_WIDTH, 760.f)];
    
    if (self) {
        _latitude = latitude;
        _longitude = longitude;
        _allowLaunchMap = allowLaunchMap;
        self.title = title;
    }
    return self;
}

- (void)viewDidLoad {
    
	[super viewDidLoad];
    
    [self addRightBarButton:@selector(closeModal:)];
    
    if (_allowLaunchMap) {
        self.navigationItem.leftBarButtonItem = BAR_BUTTON(LocaleStringForKey(NSRouteTitle, nil), UIBarButtonItemStyleBordered, self, @selector(lanuchGoogleMap:));
    }
    
    if (self.title && self.title.length > 0) {
        self.navigationItem.title = self.title;
    } else {
        self.navigationItem.title = LocaleStringForKey(NSUserPlaceTitle, nil);
    }
    
    [self drawMapView];
    
    [self drawUserLocation];
}

- (void)dealloc {
    
    self.title = nil;
    
    self.mapView.delegate = nil;
    self.mapView = nil;
    
    [super dealloc];
}

#pragma mark - draw map
- (void)drawMapView {
    self.mapView = [[[MKMapView alloc] initWithFrame:CGRectMake(0, 0, UI_MODAL_FORM_SHEET_WIDTH, 760.f)] autorelease];
    self.mapView.delegate = self;
	self.mapView.autoresizesSubviews = YES;
	self.mapView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	[self.view addSubview:self.mapView];
}

#pragma mark - draw location
- (void)drawUserLocation {
	
	// draw map
	CLLocation* currentLocation = [[[CLLocation alloc] initWithLatitude:_latitude
                                                              longitude:_longitude] autorelease];
    [self.mapView setCenterCoordinate:currentLocation.coordinate
                            zoomLevel:INIT_ZOOM_LEVEL
                             animated:YES];
    
	WXWMapAnnotation *annotation = [[[WXWMapAnnotation alloc] initWithCoordinate:currentLocation.coordinate] autorelease];
	[self.mapView addAnnotation:annotation];
}

#pragma mark - user action

- (void)lanuchGoogleMap:(id)sender {
    [super closeModal:nil];
    
    NSString* url = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=Current%%20Location&daddr=%f,%f", _latitude, _longitude];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

#pragma mark - mapView delegate functions

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	MKAnnotationView* annotationView = nil;
	
	// determine the type of annotation, and produce the correct type of annotation view for it.
	WXWMapAnnotation* csAnnotation = (WXWMapAnnotation*)annotation;
	
	NSString* identifier = @"Pin";
	MKPinAnnotationView* pin = (MKPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
	
	if(nil == pin) {
		pin = [[[MKPinAnnotationView alloc] initWithAnnotation:csAnnotation reuseIdentifier:identifier] autorelease];
		pin.animatesDrop = YES;
	}
    
	pin.pinColor = MKPinAnnotationColorRed;
    
	annotationView = pin;
	
	return annotationView;
}

@end
