//
//  HorizontalScrollViewController.h
//  iAlumniHD
//
//  Created by Adam on 12-10-4.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"

@interface HorizontalScrollViewController : UIViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate>
{
    
    UIView  *_slideView;
	UIView  *_borderView;
	
	UIView  *_viewAtLeft;
	UIView  *_viewAtRight;
    
	NSMutableArray  *_viewControllersStack;
	
	NSString    *_dragDirection;
	
	CGFloat _viewXPosition;
	CGFloat _lastTouchPoint;
	CGFloat _slideStartPosition;
    
@private
    id _target;
    SEL _linkageAction;
    
    UIViewController *_addNewController;
    UIViewController *_invokeByController;
    BOOL _needResetMultilevelMenuPosition;
}

@property (nonatomic, retain) UIView    *slideView;
@property (nonatomic, retain) UIView    *borderView;
@property (nonatomic, assign) CGFloat   slideStartPosition;
@property (nonatomic, retain) NSMutableArray    *viewControllersStack;

- (id)initWithTarget:(id)target linkageAction:(SEL)linkageAction;

- (void)addViewInSlider:(UIViewController*)controller
     invokeByController:(UIViewController*)invokeByController
         stackStartView:(BOOL)stackStartView;

- (void)closeItemList;
- (void)closeOther;

- (void)clearAllViewControllerStuff;

@end
