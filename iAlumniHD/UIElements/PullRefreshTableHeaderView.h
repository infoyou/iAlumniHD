//
//  PullRefreshTableHeaderView.h
//  iAlumniHD
//
//  Created by Adam on 12-11-10.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "GlobalConstants.h"

@interface PullRefreshTableHeaderView : UIView {
	UILabel *_lastUpdatedLabel;
	UILabel *_statusLabel;
	CALayer *_arrowImage;
	UIActivityIndicatorView *_activityView;
	
	PullHeaderRefreshState _state;
}

@property(nonatomic, assign) PullHeaderRefreshState state;
@property(nonatomic, retain) UIActivityIndicatorView *activityView;

- (void)setCurrentDate;

@end
