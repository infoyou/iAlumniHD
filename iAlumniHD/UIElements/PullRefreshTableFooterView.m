//
//  PullRefreshTableFooterView.m
//  iAlumniHD
//
//  Created by Adam on 12-11-10.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "PullRefreshTableFooterView.h"

#define kReleaseToReloadStatus	0
#define kPullToReloadStatus		1
#define kLoadingStatus			2

#define FRAME_Y					10.0f
#define TEXT_HEIGHT				20.0f

#define ACTIVITY_VIEW_X			95.0f
#define ACTIVITY_VIEW_WIDTH		20.0f

@implementation PullRefreshTableFooterView
@synthesize state = _state;

- (id)initWithFrame:(CGRect)frame tableStyle:(UITableViewStyle)tableStyle
{
    
    self = [super initWithFrame:frame];
    
	if (self) {

		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		
        CGRect labelFrame = CGRectMake(0.0f, FRAME_Y, frame.size.width, TEXT_HEIGHT);
        
        if (tableStyle == UITableViewStyleGrouped) {
            labelFrame = CGRectMake(30.0f, FRAME_Y, frame.size.width-60.f, TEXT_HEIGHT);
        }
        
		WXWLabel *label = [[WXWLabel alloc] initWithFrame:labelFrame
                                              textColor:BASE_INFO_COLOR
                                            shadowColor:[UIColor whiteColor]];
		label.font = BOLD_FONT(13);
		label.textAlignment = NSTextAlignmentCenter;
		[self addSubview:label];
		_statusLabel = label;
		[label release];
		label = nil;
		
		UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		view.frame = CGRectMake(ACTIVITY_VIEW_X, FRAME_Y, ACTIVITY_VIEW_WIDTH, TEXT_HEIGHT);
		[self addSubview:view];
		_activityView = view;
		[view release];
		view = nil;
		
		[self setState:PULL_FOOTER_NORMAL];
	}
	return self;
}

- (void)setState:(PullFooterRefreshState)aState{
	
	switch (aState) {
		case PULL_FOOTER_NORMAL:
		{
			_statusLabel.text = LocaleStringForKey(NSLoadMoreTitle, nil);
			[_activityView stopAnimating];
			break;
		}
            
		case PULL_FOOTER_LOADING:
		{
			_statusLabel.text = LocaleStringForKey(NSLoadingTitle, nil);
			[_activityView startAnimating];
			break;
		}
            
		default:
			break;
	}
	
	CGRect originalFrame = self.frame;
	CGRect oldStatusLabelFrame = _statusLabel.frame;
    
    self.frame = CGRectMake(originalFrame.origin.x, originalFrame.origin.y, LIST_WIDTH, self.frame.size.height);
    _statusLabel.frame = CGRectMake(0.0f, oldStatusLabelFrame.origin.y, oldStatusLabelFrame.size.width, oldStatusLabelFrame.size.height);
	_state = aState;
}

- (void)dealloc {
    
	_activityView = nil;
	_statusLabel = nil;
	
	[super dealloc];
}

@end
