//
//  CustomAnnotation.m
//  iAlumniHD
//
//  Created by Adam on 12-11-20.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "CustomAnnotation.h"

@implementation CustomAnnotation

@synthesize coordinate,subtitle,title;

-(id)initWithCoords:(CLLocationCoordinate2D)coords{
	self = [super init];
    
	coordinate = coords;
    
	return self;
}

-(void)dealloc
{
	[title release];
	[subtitle release];
	[super dealloc];
}

@end