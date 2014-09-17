//
//  NearbyAnnotation.h
//  iAlumniHD
//
//  Created by Mobguang on 11-12-20.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "WXWMapAnnotation.h"
#import "GlobalConstants.h"

@class ServiceItem;

@interface NearbyAnnotation : WXWMapAnnotation {

  ServiceItem *_item;
  
  NSInteger _sequenceNumber;
}

@property (nonatomic, retain) ServiceItem *item;

@property (nonatomic, assign) NSInteger sequenceNumber;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
             serviceItem:(ServiceItem *)serviceItem 
          sequenceNumber:(NSInteger)sequenceNumber;

@end
