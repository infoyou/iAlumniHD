//
//  HorizontalScrollViewController.h
//  iAlumniHD
//
//  Created by Adam on 11-10-4.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"

@interface HorizontalScrollViewController : UIViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate>
{
    
    UIView* _slideView;
	UIView* _borderView;
	
	UIView* _viewAtLeft;
	UIView* _viewAtRight;
	UIView* _viewAtLeft2;
	UIView* _viewAtRight2;
    
	UIView* _viewAtRightAtTouchBegan;
	UIView* _viewAtLeftAtTouchBegan;
	
	NSMutableArray* _viewControllersStack;
	
	NSString* _dragDirection;
	
	CGFloat _viewXPosition;		
	CGFloat _displacementPosition;
	CGFloat _lastTouchPoint;
	CGFloat _slideStartPosition;
	
	CGPoint _positionOfViewAtRightAtTouchBegan;
	CGPoint _positionOfViewAtLeftAtTouchBegan;
    
@private
    id _target;
    SEL _linkageAction;
    
    UIViewController *_newAddedController;
    UIViewController *_invokeByController;
    BOOL _needResetMultilevelMenuPosition;
}

@property (nonatomic, retain) UIView* slideView;
@property (nonatomic, retain) UIView* borderView;
@property (nonatomic, assign) CGFloat slideStartPosition;
@property (nonatomic, assign) NSMutableArray* viewControllersStack;

- (id)initWithTarget:(id)target linkageAction:(SEL)linkageAction;
- (void)addViewInSlider:(UIViewController*)controller 
     invokeByController:(UIViewController*)invokeByController 
         stackStartView:(BOOL)stackStartView;
- (void)bounceBack:(NSString*)animationId
          finished:(NSNumber*)finished 
           context:(void*)context;

- (void)closeItemList;
- (void)closeOther;

@end
