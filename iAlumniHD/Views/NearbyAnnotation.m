//
//  NearbyAnnotation.m
//  iAlumniHD
//
//  Created by Mobguang on 11-12-20.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "NearbyAnnotation.h"
#import "ServiceItem.h"


@implementation NearbyAnnotation

@synthesize item = _item;
@synthesize sequenceNumber = _sequenceNumber;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
             serviceItem:(ServiceItem *)serviceItem 
          sequenceNumber:(NSInteger)sequenceNumber {
  self = [super initWithCoordinate:coordinate];
  if (self) {
    self.item = serviceItem;
    self.sequenceNumber = sequenceNumber;
  }
  return self;
}

- (void)dealloc {
  
  self.item = nil;
  
  [super dealloc];
}

- (NSString *)title {
  return self.item.itemName;
}

- (NSString *)subtitle {
  return self.item.categoryName;
}

@end
