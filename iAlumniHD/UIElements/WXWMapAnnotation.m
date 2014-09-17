//
//  WXWMapAnnotation.m
//  iAlumniHD
//
//  Created by Adam on 12-11-1.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "WXWMapAnnotation.h"

@implementation WXWMapAnnotation

@synthesize coordinate = _coordinate;

-(id) initWithCoordinate:(CLLocationCoordinate2D)coordinate {
  self = [super init];
  if (self) {
    _coordinate = coordinate;
  }
  return self;
}

- (void)dealloc {
  
  
  [super dealloc];
}
         

@end
