//
//  PullRefreshTableFooterView.h
//  iAlumniHD
//
//  Created by Adam on 12-11-10.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseUIView.h"

@interface PullRefreshTableFooterView : BaseUIView {
  UILabel *_statusLabel;
	UIActivityIndicatorView *_activityView;
	
	PullFooterRefreshState _state;
}

@property(nonatomic, assign) PullFooterRefreshState state;

- (id)initWithFrame:(CGRect)frame tableStyle:(UITableViewStyle)tableStyle;

@end
