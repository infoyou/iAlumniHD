//
//  HorizontalScrollViewController.m
//  iAlumniHD
//
//  Created by Adam on 12-10-4.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "HorizontalScrollViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "WXWUIUtils.h"
#import "CommonUtils.h"
#import "AppManager.h"
#import "WXWNavigationController.h"
#import "RootViewController.h"

#define SLIDE_VIEWS_START_X_POS       0

#define LANDSCAPE_HIDE_THRESHOLD      485.0f//200.0f
#define PORTRAIT_HIDE_THRESHOLD       600.0f

#define TAG_BASE                      8000

static NSInteger lineView1Tag = 101;
static NSInteger lineView2Tag = 102;
static NSInteger lineView3Tag = 103;

enum {
    PAGE_LEFT_IDX = 0,
    PAGE_RIGHT_IDX,
};

@interface HorizontalScrollViewController()
@property (nonatomic, copy) NSString *dragDirection;
@property (nonatomic, retain) UIViewController *invokeByController;
@property (nonatomic, retain) UIViewController *addNewController;
@end

@implementation HorizontalScrollViewController

@synthesize slideView = _slideView;
@synthesize borderView = _borderView;
@synthesize viewControllersStack = _viewControllersStack;
@synthesize slideStartPosition = _slideStartPosition;
@synthesize dragDirection = _dragDirection;
@synthesize invokeByController = _invokeByController;
@synthesize addNewController = _addNewController;

#pragma mark - view life cycle
- (id)initWithTarget:(id)target linkageAction:(SEL)linkageAction {
    self = [super init];
    
    if (self) {
        
        _target = target;
        _linkageAction = linkageAction;
        
        _viewControllersStack = [[NSMutableArray alloc] init];
        _borderView = [[UIView alloc] initWithFrame:CGRectMake(SLIDE_VIEWS_MINUS_X_POSITION - 2, -2, 2, self.view.frame.size.height)];
        _borderView.backgroundColor = TRANSPARENT_COLOR;
        
        UIView *verticalLineView1 = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, _borderView.frame.size.height)] autorelease];
        verticalLineView1.backgroundColor = [UIColor whiteColor];
        verticalLineView1.tag = lineView1Tag;
        verticalLineView1.hidden = YES;
		[_borderView addSubview:verticalLineView1];
        
        UIView *verticalLineView2 = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, _borderView.frame.size.height)] autorelease];
        verticalLineView2.backgroundColor = [UIColor whiteColor];
        verticalLineView2.tag = lineView2Tag;
        verticalLineView2.hidden = YES;
		[_borderView addSubview:verticalLineView2];
        
        [self.view addSubview:_borderView];
        
        _slideView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        _slideView.backgroundColor = TRANSPARENT_COLOR;
        
        self.view.backgroundColor = TRANSPARENT_COLOR;
        self.view.frame = _slideView.frame;
        self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        
        _viewXPosition = 0;
        _lastTouchPoint = -1;
        
        self.dragDirection = @"";
        
        _viewAtLeft = nil;
        _viewAtRight = nil;
        
		[self.view addSubview:_slideView];
        
        // 页面滑动
        UIPanGestureRecognizer *panRecognizer = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(doGesture:)] autorelease];
        panRecognizer.maximumNumberOfTouches = 1;
        panRecognizer.delaysTouchesBegan = YES;
        panRecognizer.delaysTouchesEnded = YES;
        panRecognizer.cancelsTouchesInView = YES;
        
        [self.view addGestureRecognizer:panRecognizer];
    }
    
    return self;
}

- (void)dealloc {
    
    self.dragDirection = nil;
    self.addNewController = nil;
    self.invokeByController = nil;
    
    RELEASE_OBJ(_viewControllersStack);
    RELEASE_OBJ(_borderView);
    RELEASE_OBJ(_slideView);
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    for (UIViewController* subController in _viewControllersStack) {
		[subController viewDidUnload];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotate {
    return YES;
}
#endif

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
	BOOL isViewOutOfScreen = NO;
	for (UIViewController* subController in _viewControllersStack) {
        
		if (_viewAtRight != nil && [_viewAtRight isEqual:subController.view]) {
			if (_viewAtRight.frame.origin.x <= (_viewAtLeft.frame.origin.x + _viewAtLeft.frame.size.width)) {
				[subController.view setFrame:CGRectMake(self.view.frame.size.width - subController.view.frame.size.width, subController.view.frame.origin.y, subController.view.frame.size.width, self.view.frame.size.height)];
			} else {
				[subController.view setFrame:CGRectMake(_viewAtLeft.frame.origin.x + _viewAtLeft.frame.size.width, subController.view.frame.origin.y, subController.view.frame.size.width, self.view.frame.size.height)];
			}
			isViewOutOfScreen = YES;
		} else if (_viewAtLeft != nil && [_viewAtLeft isEqual:subController.view]) {
			if (_viewAtLeft.frame.origin.x == SLIDE_VIEWS_MINUS_X_POSITION || _viewAtLeft.frame.origin.x == SLIDE_VIEWS_START_X_POS) {
                
				[subController.view setFrame:CGRectMake(subController.view.frame.origin.x, subController.view.frame.origin.y, subController.view.frame.size.width, self.view.frame.size.height)];
			} else {
				if (_viewAtLeft.frame.origin.x + _viewAtLeft.frame.size.width == self.view.frame.size.width) {
					[subController.view setFrame:CGRectMake(self.view.frame.size.width - subController.view.frame.size.width, subController.view.frame.origin.y, subController.view.frame.size.width, self.view.frame.size.height)];
				}
			}
		} else if(!isViewOutOfScreen) {
			[subController.view setFrame:CGRectMake(subController.view.frame.origin.x, subController.view.frame.origin.y, subController.view.frame.size.width, self.view.frame.size.height)];
		} else {
			[subController.view setFrame:CGRectMake(self.view.frame.size.width, subController.view.frame.origin.y, subController.view.frame.size.width, self.view.frame.size.height)];
		}
	}
    
	for (UIViewController* subController in _viewControllersStack) {
		[subController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
		if (!((_viewAtRight != nil && [_viewAtRight isEqual:subController.view]) || (_viewAtLeft != nil && [_viewAtLeft isEqual:subController.view]) )) {
			[[subController view] setHidden:YES];
		}
	}
	
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
	for (UIViewController* subController in _viewControllersStack) {
		[subController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	}
    
	if (_viewAtLeft !=nil) {
		[_viewAtLeft setHidden:NO];
	}
	if (_viewAtRight !=nil) {
		[_viewAtRight setHidden:NO];
	}
}

- (NSInteger)findToppestSlideViewIndex {
    
    NSInteger subViewCount = [[_slideView subviews] count];
    NSInteger baseViewIndexForToppest = 0;
    NSInteger toppestIndex = 0;
    
    if (subViewCount > 1) {
        baseViewIndexForToppest = [[_slideView subviews] count] - 2;
        toppestIndex = baseViewIndexForToppest + 1;
    }
    
    return toppestIndex;
}

- (void)stopAllConnectionsAndImageLoading:(NSInteger)index {
    id obj = [_viewControllersStack objectAtIndex:index];
    if ([obj isKindOfClass:[WXWNavigationController class]]) {
        [((WXWNavigationController *)obj) cancelContainsViewControllersConnectionAndImageLoading];
    }
}

- (void)deSelectCell {
    id obj = [_viewControllersStack objectAtIndex:PAGE_LEFT_IDX];
    if ([obj isKindOfClass:[WXWNavigationController class]]) {
        [((WXWNavigationController *)obj) deSelectCell];
    }
}

- (void)popViewController {
    id obj = [_viewControllersStack objectAtIndex:PAGE_RIGHT_IDX];
    if ([obj isKindOfClass:[WXWNavigationController class]]) {
        if ([[obj viewControllers] count] > 1) {
            [((WXWNavigationController *)obj) popViewControllerAnimated:YES];
        } else {
            [self closeItemList];
            [self deSelectCell];
        }
    }
}

- (void)clearAllViewControllerStuff {
    if (_viewControllersStack.count > 0) {
        for (int i = _viewControllersStack.count - 1; i >= 0; i--) {
            [self stopAllConnectionsAndImageLoading:i];
        }
    }
    
    [_viewControllersStack removeAllObjects];
}

- (void)addNewInvokerViewController:(UIViewController *)aNewAddedController
                 invokeByController:(UIViewController *)aInvokeByController {
    
    if ([_viewControllersStack count] > 1) {
        
		NSInteger indexOfViewController = [_viewControllersStack
                                           indexOfObject:aInvokeByController]+1;
		
		if ([aInvokeByController parentViewController]) {
			indexOfViewController = [_viewControllersStack
                                     indexOfObject:[aInvokeByController parentViewController]]+1;
		}
        
		for (int i = indexOfViewController; i < [_viewControllersStack count]; i++) {
            
			[[_slideView viewWithTag:(i+TAG_BASE)] removeFromSuperview];
            
            [self stopAllConnectionsAndImageLoading:i];
            
			[_viewControllersStack removeObjectAtIndex:i];
			_viewXPosition = self.view.frame.size.width - [aNewAddedController view].frame.size.width;
		}
	} else if([_viewControllersStack count] == 0) {
        
		for (UIView *subview in [_slideView subviews]) {
			[subview removeFromSuperview];
		}
        
        [_viewControllersStack removeAllObjects];
		[[_borderView viewWithTag:lineView3Tag] setHidden:YES];
		[[_borderView viewWithTag:lineView2Tag] setHidden:YES];
		[[_borderView viewWithTag:lineView1Tag] setHidden:YES];
	}
    
	[_viewControllersStack addObject:aNewAddedController];
	if (aInvokeByController !=nil) {
		_viewXPosition = aInvokeByController.view.frame.origin.x + aInvokeByController.view.frame.size.width;
	}
	if ([[_slideView subviews] count] == 0) {
		_slideStartPosition = SLIDE_VIEWS_START_X_POS;
		_viewXPosition = _slideStartPosition;
	}
    
	[[aNewAddedController view] setFrame:CGRectMake(_viewXPosition, 0, [aNewAddedController view].frame.size.width, self.view.frame.size.height)];
    
	[aNewAddedController.view setTag:([_viewControllersStack count]-1)+TAG_BASE];
    
	[_slideView addSubview:aNewAddedController.view];
    
    int slideViewSize = [[_slideView subviews] count];
	if (slideViewSize > 0) {
		switch (slideViewSize) {
            case 1:
            {
                _viewAtLeft = [[_slideView subviews] objectAtIndex:slideViewSize-1];
                _viewAtRight = nil;
            }
                break;
                
            case 2:
            {
                _viewAtRight = [[_slideView subviews] objectAtIndex:slideViewSize-1];
                _viewAtLeft = [[_slideView subviews] objectAtIndex:slideViewSize-2];
                
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:_viewAtLeft cache:YES];
                [UIView setAnimationBeginsFromCurrentState:NO];
                
                if (_target && _linkageAction) {
                    [_target performSelector:_linkageAction withObject:LEFT_DIRECTION];
                }
                
                [_viewAtLeft setFrame:CGRectMake(MID_LIST_VIEW_START_X_POS, _viewAtLeft.frame.origin.y, _viewAtLeft.frame.size.width, _viewAtLeft.frame.size.height)];
                [_viewAtRight setFrame:CGRectMake(self.view.frame.size.width - _viewAtRight.frame.size.width, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width, _viewAtRight.frame.size.height)];
                [UIView commitAnimations];
                _slideStartPosition = MID_LIST_VIEW_START_X_POS;
            }
                break;
                
            default:
            {
                if (((UIView *)[[_slideView subviews] objectAtIndex:0]).frame.origin.x > SLIDE_VIEWS_MINUS_X_POSITION) {
                    [UIView beginAnimations:@"ALIGN_TO_MINIMENU" context:NULL];
                    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:_viewAtLeft cache:YES];
                    [UIView setAnimationBeginsFromCurrentState:NO];
                    
                    [_viewAtLeft setFrame:CGRectMake(SLIDE_VIEWS_MINUS_X_POSITION, _viewAtLeft.frame.origin.y, _viewAtLeft.frame.size.width, _viewAtLeft.frame.size.height)];
                    [_viewAtRight setFrame:CGRectMake(self.view.frame.size.width - _viewAtRight.frame.size.width, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width, _viewAtRight.frame.size.height)];
                    
                } else {
                    _viewAtRight = [[_slideView subviews] objectAtIndex:slideViewSize-1];
                    _viewAtLeft = [[_slideView subviews] objectAtIndex:0];
                }
            }
                break;
        }
	}
}

- (void)addViewInSlider:(UIViewController*)controller
     invokeByController:(UIViewController*)invokeByController
         stackStartView:(BOOL)stackStartView {
    
    self.addNewController = nil;
    self.invokeByController = nil;
	
    [AppManager instance].isSinglePage = stackStartView;
    
	if (stackStartView) {
		_slideStartPosition = SLIDE_VIEWS_START_X_POS;
		_viewXPosition = _slideStartPosition;
        
        self.addNewController = controller;
        self.invokeByController = invokeByController;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:ANIMATION_DURATION];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(clearAllSubviewsAndAddNewViewController)];
        
        NSInteger count = 0;
		for (UIView* subview in [_slideView subviews]) {
            if (subview.frame.origin.x < 0) {
                subview.frame = CGRectMake(subview.frame.origin.x + MULTI_LEVEL_MENU_OFFSET,
                                           subview.frame.origin.y,
                                           subview.frame.size.width,
                                           subview.frame.size.height);
            }
            count++;
		}
        
        if (count > 0) {
            _needResetMultilevelMenuPosition = YES;
        } else {
            _needResetMultilevelMenuPosition = NO;
        }
        
        if ([_target respondsToSelector:@selector(resetMultilevelMenuPosition)]) {
            [_target performSelector:@selector(resetMultilevelMenuPosition)];
        }
        [UIView commitAnimations];
        
	} else {
        
        _needResetMultilevelMenuPosition = NO;
        
        [self addNewInvokerViewController:controller invokeByController:invokeByController];
    }
	
    [WXWUIUtils setTopViewController:(UIViewController *)[_viewControllersStack lastObject]];
}

- (void)clearAllSubviewsAndAddNewViewController {
    
    if (_needResetMultilevelMenuPosition) {
        
        for (UIView *subview in [_slideView subviews]) {
            [subview removeFromSuperview];
        }
        
        _needResetMultilevelMenuPosition = NO;
        
        [[_borderView viewWithTag:lineView3Tag] setHidden:YES];
		[[_borderView viewWithTag:lineView2Tag] setHidden:YES];
		[[_borderView viewWithTag:lineView1Tag] setHidden:YES];
        
        
        [self clearAllViewControllerStuff];
    }
    
    [self addNewInvokerViewController:self.addNewController
                   invokeByController:self.invokeByController];
}

#pragma mark - user action
- (void)releaseItemList {
    
    NSInteger toppestIndex = [self findToppestSlideViewIndex];
    
    [[_slideView viewWithTag:(toppestIndex+TAG_BASE)] removeFromSuperview];
    
    //  [self clearAllViewControllerStuff];
}

- (void)closeOther
{
    NSInteger toppestIndex = [self findToppestSlideViewIndex];
    if (toppestIndex > 1) {
        [self closeItemList];
    }
}

- (void)closeItemList {
    
    NSInteger toppestIndex = [self findToppestSlideViewIndex];
    
    if (toppestIndex <= 0) {
        return;
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:ANIMATION_DURATION];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:nil cache:YES];
    
    [[_borderView viewWithTag:lineView3Tag] setHidden:YES];
    [[_borderView viewWithTag:lineView2Tag] setHidden:YES];
    [[_borderView viewWithTag:lineView1Tag] setHidden:YES];
    
    // Removes the selection of row for the first slide view
    for (UIView *tableView in [[[_slideView subviews] objectAtIndex:/*0*/(toppestIndex - 1)] subviews]) {
        
        if([tableView isKindOfClass:[UITableView class]]) {
            NSIndexPath *selectedRow = [(UITableView*)tableView indexPathForSelectedRow];
            NSArray *indexPaths = [NSArray arrayWithObjects:selectedRow, nil];
            [(UITableView*)tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:NO];
        }
    }
    
    if (toppestIndex > 0) {
        // remove the item list view to outside of screen
        _viewAtRight.frame = CGRectMake(self.view.frame.size.width, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width, _viewAtRight.frame.size.height);
        
        _viewAtRight = nil;
        
        // adjust group list position
        [_viewAtLeft setFrame:CGRectMake(SLIDE_VIEWS_START_X_POS, _viewAtLeft.frame.origin.y, _viewAtLeft.frame.size.width, _viewAtLeft.frame.size.height)];
    }
    
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(releaseItemList)];
    [UIView commitAnimations];
    
    _lastTouchPoint = -1;
    _dragDirection = @"";

}

- (void)doGesture:(UIPanGestureRecognizer *)recognizer {
    
    if ([[_slideView subviews] count] <= 1) {
        return;
    }
	
//	CGPoint translatedPoint = [recognizer translationInView:self.view];
	
	if (recognizer.state == UIGestureRecognizerStateBegan) {
		_lastTouchPoint = -1;
        _dragDirection = @"";
	}
	
	CGPoint location =  [recognizer locationInView:self.view];
	if (location.x < VERTICAL_MENU_WIDTH + LIST_WIDTH) {
        return;
    }
    
	if (_lastTouchPoint != -1) {

		if (location.x < _lastTouchPoint) {
			_dragDirection = @"LEFT";
		} else if (location.x > _lastTouchPoint) {
			_dragDirection = @"RIGHT";
			
			if (_viewAtRight != nil) {
                [self popViewController];
            }
		}
	}
	
	_lastTouchPoint = location.x;
	
	// STATE END
	if (recognizer.state == UIGestureRecognizerStateEnded) {
        _lastTouchPoint = -1;
        _dragDirection = @"";
    }
}

@end
