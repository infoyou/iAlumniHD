//
//  ECEmbedMapView.h
//  iAlumniHD
//
//  Created by Adam on 12-11-2.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "ECClickableElementDelegate.h"

@interface ECEmbedMapView : MKMapView {
  
  @private
  id<ECClickableElementDelegate> _delegate;
  
}
- (id)initWithFrame:(CGRect)frame clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate;

@end
