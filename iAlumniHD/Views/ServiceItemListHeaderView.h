//
//  ServiceItemListHeaderView.h
//  iAlumniHD
//
//  Created by Mobguang on 12-6-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"
#import "FilterListDelegate.h"

@class NearbySearchBar;
@class TipsEntranceView;

@interface ServiceItemListHeaderView : UIView {
  
  TipsEntranceView *_tipsView;
  
  NearbySearchBar *_toolbar;
}

@property (nonatomic, retain) TipsEntranceView *tipsView;
@property (nonatomic, retain) NearbySearchBar *toolbar;

- (id)initWithFrame:(CGRect)frame
 filterListDelegate:(id<FilterListDelegate>)filterListDelegate;

@end
