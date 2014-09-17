//
//  HorizontalScrollViewController.m
//  iAlumniHD
//
//  Created by Adam on 11-10-4.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "HorizontalScrollViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CPShadowView.h"
#import "CommonUtils.h"

#define SLIDE_VIEWS_START_X_POS       0

#define LANDSCAPE_HIDE_THRESHOLD      485.0f//200.0f
#define PORTRAIT_HIDE_THRESHOLD       600.0f

#define TAG_BASE                      1000

enum {
    ITEM_LIST_IDX = 0,
    ITEM_DETAIL_IDX,
};

static NSInteger lineView1Tag = 1;
static NSInteger lineView2Tag = 2;

@interface HorizontalScrollViewController()
@property (nonatomic, copy) NSString *dragDirection;
@property (nonatomic, retain) UIViewController *newAddedController;
@property (nonatomic, retain) UIViewController *invokeByController;
@end

@implementation HorizontalScrollViewController

@synthesize slideView = _slideView;
@synthesize borderView = _borderView;
@synthesize viewControllersStack = _viewControllersStack;
@synthesize slideStartPosition = _slideStartPosition;
@synthesize dragDirection = _dragDirection;
@synthesize newAddedController = _newAddedController;
@synthesize invokeByController = _invokeByController;

- (id)initWithTarget:(id)target linkageAction:(SEL)linkageAction {
    self = [super init];
    if (self) {
        
        _target = target;
        _linkageAction = linkageAction;
        
        _viewControllersStack = [[NSMutableArray alloc] init];
        _borderView = [[UIView alloc] initWithFrame:CGRectMake(SLIDE_VIEWS_MINUS_X_POSITION - 2, -2, 2, self.view.frame.size.height)];
        _borderView.backgroundColor = [UIColor clearColor];
        
        UIView* verticalLineView1 = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, _borderView.frame.size.height)] autorelease];
//        verticalLineView1.backgroundColor = [UIColor whiteColor];
        verticalLineView1.backgroundColor = [UIColor greenColor];
        verticalLineView1.tag = lineView1Tag;
        verticalLineView1.hidden = YES;
		[_borderView addSubview:verticalLineView1];
        
        UIView* verticalLineView2 = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, _borderView.frame.size.height)] autorelease];
//        verticalLineView2.backgroundColor = [UIColor whiteColor];
        verticalLineView2.backgroundColor = [UIColor yellowColor];
        verticalLineView2.tag = lineView2Tag;
        verticalLineView2.hidden = YES;
		[_borderView addSubview:verticalLineView2];
        
        [self.view addSubview:_borderView];
        
        _slideView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        _slideView.backgroundColor = [UIColor clearColor];
        
        self.view.backgroundColor = [UIColor clearColor];
        self.view.frame = _slideView.frame;
        self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        
        _viewXPosition = 0;
        _lastTouchPoint = -1;
        
        self.dragDirection = @"";
        
        _viewAtLeft2 = nil;
        _viewAtLeft = nil;
        _viewAtRight2 = nil;
        _viewAtRight = nil;
        _viewAtRightAtTouchBegan = nil;
        
        /*
         页面滑动
        UIPanGestureRecognizer* panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];
        panRecognizer.maximumNumberOfTouches = 1;
        panRecognizer.delaysTouchesBegan = YES;
        panRecognizer.delaysTouchesEnded = YES;
        panRecognizer.cancelsTouchesInView = YES;
        
		[self.view addGestureRecognizer:panRecognizer];
		RELEASE_OBJ(panRecognizer);
		*/
        
		[self.view addSubview:_slideView];
    }
    
    return self;
}

- (void)dealloc {
    
    self.dragDirection = nil;
    self.newAddedController = nil;
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

#pragma mark - View lifecycle

- (void)viewDidUnload
{
    [super viewDidUnload];
    for (UIViewController* subController in _viewControllersStack) {
		[subController viewDidUnload];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIDeviceOrientationLandscapeRight || interfaceOrientation == UIDeviceOrientationLandscapeLeft);
}

-(void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
	BOOL isViewOutOfScreen = NO; 
	for (UIViewController* subController in _viewControllersStack) {
        
		if (_viewAtRight != nil && [_viewAtRight isEqual:subController.view]) {
			if (_viewAtRight.frame.origin.x <= (_viewAtLeft.frame.origin.x + _viewAtLeft.frame.size.width)) {
				[subController.view setFrame:CGRectMake(self.view.frame.size.width - subController.view.frame.size.width, subController.view.frame.origin.y, subController.view.frame.size.width, self.view.frame.size.height)];
			}else{
				[subController.view setFrame:CGRectMake(_viewAtLeft.frame.origin.x + _viewAtLeft.frame.size.width, subController.view.frame.origin.y, subController.view.frame.size.width, self.view.frame.size.height)];
			}
			isViewOutOfScreen = YES;
		}
		else if (_viewAtLeft != nil && [_viewAtLeft isEqual:subController.view]) {
			if (_viewAtLeft2 == nil) {
				if(_viewAtRight == nil){					
					[subController.view setFrame:CGRectMake(SLIDE_VIEWS_START_X_POS, subController.view.frame.origin.y, subController.view.frame.size.width, self.view.frame.size.height)];
				}
				else{
					[subController.view setFrame:CGRectMake(SLIDE_VIEWS_MINUS_X_POSITION, subController.view.frame.origin.y, subController.view.frame.size.width, self.view.frame.size.height)];
					[_viewAtRight setFrame:CGRectMake(SLIDE_VIEWS_MINUS_X_POSITION + subController.view.frame.size.width, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width, _viewAtRight.frame.size.height)];
				}
			}
			else if (_viewAtLeft.frame.origin.x == SLIDE_VIEWS_MINUS_X_POSITION || _viewAtLeft.frame.origin.x == SLIDE_VIEWS_START_X_POS) {
				[subController.view setFrame:CGRectMake(subController.view.frame.origin.x, subController.view.frame.origin.y, subController.view.frame.size.width, self.view.frame.size.height)];
			}
			else {
				if (_viewAtLeft.frame.origin.x + _viewAtLeft.frame.size.width == self.view.frame.size.width) {
					[subController.view setFrame:CGRectMake(self.view.frame.size.width - subController.view.frame.size.width, subController.view.frame.origin.y, subController.view.frame.size.width, self.view.frame.size.height)];
				}else{
					[subController.view setFrame:CGRectMake(_viewAtLeft2.frame.origin.x + _viewAtLeft2.frame.size.width, subController.view.frame.origin.y, subController.view.frame.size.width, self.view.frame.size.height)];
				}
			}
		}
		else if(!isViewOutOfScreen){
			[subController.view setFrame:CGRectMake(subController.view.frame.origin.x, subController.view.frame.origin.y, subController.view.frame.size.width, self.view.frame.size.height)];
		}
		else {
			[subController.view setFrame:CGRectMake(self.view.frame.size.width, subController.view.frame.origin.y, subController.view.frame.size.width, self.view.frame.size.height)];
		}
		
	}
	for (UIViewController* subController in _viewControllersStack) {
		[subController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration]; 		
		if (!((_viewAtRight != nil && [_viewAtRight isEqual:subController.view]) || (_viewAtLeft != nil && [_viewAtLeft isEqual:subController.view]) || (_viewAtLeft2 != nil && [_viewAtLeft2 isEqual:subController.view]))) {
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
	if (_viewAtLeft2 !=nil) {
		[_viewAtLeft2 setHidden:NO];
	}	
}

#pragma mark - arrange views for scroll
-(void)arrangeVerticalBar {
	
	if ([[_slideView subviews] count] > 2) {
        
		[[_borderView viewWithTag:2] setHidden:YES];
		[[_borderView viewWithTag:1] setHidden:YES];
        
		NSInteger stackCount = 0;
        
		if (_viewAtLeft != nil ) {
			stackCount = [[_slideView subviews] indexOfObject:_viewAtLeft];
		}
		
		if (_viewAtLeft != nil && _viewAtLeft.frame.origin.x == SLIDE_VIEWS_MINUS_X_POSITION) {
			stackCount += 1;
		}
		
		if (stackCount == 2) {
			[[_borderView viewWithTag:2] setHidden:NO];
		}
        
		if (stackCount >= 3) {
			[[_borderView viewWithTag:2] setHidden:NO];
			[[_borderView viewWithTag:1] setHidden:NO];
		}
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

- (void)handlePanFrom:(UIPanGestureRecognizer *)recognizer {
    
    if ([[_slideView subviews] count] <= 1) {
        return;
    }
	
	CGPoint translatedPoint = [recognizer translationInView:self.view];
	
	if (recognizer.state == UIGestureRecognizerStateBegan) {
        
		_displacementPosition = 0;
		_positionOfViewAtRightAtTouchBegan = _viewAtRight.frame.origin;
		_positionOfViewAtLeftAtTouchBegan = _viewAtLeft.frame.origin;
		_viewAtRightAtTouchBegan = _viewAtRight;
		_viewAtLeftAtTouchBegan = _viewAtLeft;
		[_viewAtLeft.layer removeAllAnimations];
		[_viewAtRight.layer removeAllAnimations];
		[_viewAtRight2.layer removeAllAnimations];
		[_viewAtLeft2.layer removeAllAnimations];
		if (_viewAtLeft2 != nil) {
			NSInteger viewAtLeft2Position = [[_slideView subviews] indexOfObject:_viewAtLeft2];
			if (viewAtLeft2Position > 0) {
				[((UIView*)[[_slideView subviews] objectAtIndex:viewAtLeft2Position -1]) setHidden:NO];
			}
		}
		
		[self arrangeVerticalBar];
	}
	
	CGPoint location =  [recognizer locationInView:self.view];
	
	if (_lastTouchPoint != -1) {
		
		if (location.x < _lastTouchPoint) {			
			
			if ([_dragDirection isEqualToString:@"RIGHT"]) {
				_positionOfViewAtRightAtTouchBegan = _viewAtRight.frame.origin;
				_positionOfViewAtLeftAtTouchBegan = _viewAtLeft.frame.origin;
				_displacementPosition = translatedPoint.x * -1;
			}				
			
			_dragDirection = @"LEFT";
			
			if (_viewAtRight != nil) {
				
				if (_viewAtLeft.frame.origin.x <= SLIDE_VIEWS_MINUS_X_POSITION) {						
					if ([[_slideView subviews] indexOfObject:_viewAtRight] < ([[_slideView subviews] count]-1)) {
						_viewAtLeft2 = _viewAtLeft;
						_viewAtLeft = _viewAtRight;
						[_viewAtRight2 setHidden:NO];
						_viewAtRight = _viewAtRight2;
						if ([[_slideView subviews] indexOfObject:_viewAtRight] < ([[_slideView subviews] count]-1)) {
							_viewAtRight2 = [[_slideView subviews] objectAtIndex:[[_slideView subviews] indexOfObject:_viewAtRight] + 1];
						}else {
							_viewAtRight2 = nil;
						}							
						_positionOfViewAtRightAtTouchBegan = _viewAtRight.frame.origin;
						_positionOfViewAtLeftAtTouchBegan = _viewAtLeft.frame.origin;
						_displacementPosition = translatedPoint.x * -1;
                        NSLog(@"index: %d", [[_slideView subviews] indexOfObject:_viewAtLeft2]);
						if ([[_slideView subviews] indexOfObject:_viewAtLeft2] > 1) {
							[[[_slideView subviews] objectAtIndex:[[_slideView subviews] indexOfObject:_viewAtLeft2] - 2] setHidden:YES];
						}						
					}					
				}
				
				if (_viewAtLeft.frame.origin.x == SLIDE_VIEWS_MINUS_X_POSITION && _viewAtRight.frame.origin.x + _viewAtRight.frame.size.width > self.view.frame.size.width) {
					if ((_positionOfViewAtRightAtTouchBegan.x + translatedPoint.x + _displacementPosition + _viewAtRight.frame.size.width) <= self.view.frame.size.width) {
						[_viewAtRight setFrame:CGRectMake(self.view.frame.size.width - _viewAtRight.frame.size.width, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width, _viewAtRight.frame.size.height)];
					} else {
						[_viewAtRight setFrame:CGRectMake(_positionOfViewAtRightAtTouchBegan.x + translatedPoint.x + _displacementPosition, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width, _viewAtRight.frame.size.height)];
					}
					
				} else if (([[_slideView subviews] indexOfObject:_viewAtRight] == [[_slideView subviews] count]-1) && _viewAtRight.frame.origin.x <= (self.view.frame.size.width - _viewAtRight.frame.size.width)) {
					if ((_positionOfViewAtRightAtTouchBegan.x + translatedPoint.x + _displacementPosition) <= SLIDE_VIEWS_MINUS_X_POSITION) {
						[_viewAtRight setFrame:CGRectMake(SLIDE_VIEWS_MINUS_X_POSITION, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width, _viewAtRight.frame.size.height)];
					} else {
//						[_viewAtRight setFrame:CGRectMake(_positionOfViewAtRightAtTouchBegan.x + translatedPoint.x + _displacementPosition, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width, _viewAtRight.frame.size.height)];
					}
				} else {						
					if (_positionOfViewAtLeftAtTouchBegan.x + translatedPoint.x + _displacementPosition <= SLIDE_VIEWS_MINUS_X_POSITION) {
						[_viewAtLeft setFrame:CGRectMake(SLIDE_VIEWS_MINUS_X_POSITION, _viewAtLeft.frame.origin.y, _viewAtLeft.frame.size.width, _viewAtLeft.frame.size.height)];
					} else {
						[_viewAtLeft setFrame:CGRectMake(_positionOfViewAtLeftAtTouchBegan.x + translatedPoint.x + _displacementPosition , _viewAtLeft.frame.origin.y, _viewAtLeft.frame.size.width, _viewAtLeft.frame.size.height)];
					}						
					[_viewAtRight setFrame:CGRectMake(_viewAtLeft.frame.origin.x + _viewAtLeft.frame.size.width, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width, _viewAtRight.frame.size.height)];
					
					if (_viewAtLeft.frame.origin.x == SLIDE_VIEWS_MINUS_X_POSITION) {
						_positionOfViewAtRightAtTouchBegan = _viewAtRight.frame.origin;
						_positionOfViewAtLeftAtTouchBegan = _viewAtLeft.frame.origin;
						_displacementPosition = translatedPoint.x * -1;
					}					
				}      
			} else {
				[_viewAtLeft setFrame:CGRectMake(_positionOfViewAtLeftAtTouchBegan.x + translatedPoint.x + _displacementPosition , _viewAtLeft.frame.origin.y, _viewAtLeft.frame.size.width, _viewAtLeft.frame.size.height)];
			}
			
			[self arrangeVerticalBar];
			
		} else if (location.x > _lastTouchPoint) {	
			
			if ([_dragDirection isEqualToString:@"LEFT"]) {
				_positionOfViewAtRightAtTouchBegan = _viewAtRight.frame.origin;
				_positionOfViewAtLeftAtTouchBegan = _viewAtLeft.frame.origin;
				_displacementPosition = translatedPoint.x;
			}	
			
			_dragDirection = @"RIGHT";
			
			if (_viewAtLeft != nil) {
				
				if (_viewAtRight.frame.origin.x >= self.view.frame.size.width) {
					
					if ([[_slideView subviews] count] == 2 && [[_slideView subviews] indexOfObject:_viewAtLeft] > 0) {							
						[_viewAtRight2 setHidden:YES];
						_viewAtRight2 = _viewAtRight;
						_viewAtRight = _viewAtLeft;
						_viewAtLeft = _viewAtLeft2;						
						if ([[_slideView subviews] indexOfObject:_viewAtLeft] > 0) {
							_viewAtLeft2 = [[_slideView subviews] objectAtIndex:[[_slideView subviews] indexOfObject:_viewAtLeft] - 1];
							[_viewAtLeft2 setHidden:NO];
						} else {
							_viewAtLeft2 = nil;
						}
						_positionOfViewAtRightAtTouchBegan = _viewAtRight.frame.origin;
						_positionOfViewAtLeftAtTouchBegan = _viewAtLeft.frame.origin;
						_displacementPosition = translatedPoint.x;
						
						[self arrangeVerticalBar];
					}
				}
                
				if((_viewAtRight.frame.origin.x < (_viewAtLeft.frame.origin.x + _viewAtLeft.frame.size.width)) && _viewAtLeft.frame.origin.x == SLIDE_VIEWS_MINUS_X_POSITION){						
					if ((_positionOfViewAtRightAtTouchBegan.x + translatedPoint.x - _displacementPosition) >= (_viewAtLeft.frame.origin.x + _viewAtLeft.frame.size.width)) {
						[_viewAtRight setFrame:CGRectMake(_viewAtLeft.frame.origin.x + _viewAtLeft.frame.size.width, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width, _viewAtRight.frame.size.height)];
					} else {
						[_viewAtRight setFrame:CGRectMake(_positionOfViewAtRightAtTouchBegan.x + translatedPoint.x - _displacementPosition, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width, _viewAtRight.frame.size.height)];
					}
					
				} else if ([[_slideView subviews] indexOfObject:_viewAtLeft] == 0) {
					if (_viewAtRight == nil) {
						[_viewAtLeft setFrame:CGRectMake(_positionOfViewAtLeftAtTouchBegan.x + translatedPoint.x - _displacementPosition, _viewAtLeft.frame.origin.y, _viewAtLeft.frame.size.width, _viewAtLeft.frame.size.height)];
					} else {
						[_viewAtRight setFrame:CGRectMake(_positionOfViewAtRightAtTouchBegan.x + translatedPoint.x - _displacementPosition, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width, _viewAtRight.frame.size.height)];
						if (_viewAtRight.frame.origin.x - _viewAtLeft.frame.size.width < SLIDE_VIEWS_MINUS_X_POSITION) {
							[_viewAtLeft setFrame:CGRectMake(SLIDE_VIEWS_MINUS_X_POSITION, _viewAtLeft.frame.origin.y, _viewAtLeft.frame.size.width, _viewAtLeft.frame.size.height)];
						} else {
							[_viewAtLeft setFrame:CGRectMake(_viewAtRight.frame.origin.x - _viewAtLeft.frame.size.width, _viewAtLeft.frame.origin.y, _viewAtLeft.frame.size.width, _viewAtLeft.frame.size.height)];
						}
					}
				} else {
					if ((_positionOfViewAtRightAtTouchBegan.x + translatedPoint.x - _displacementPosition) >= self.view.frame.size.width) {
						[_viewAtRight setFrame:CGRectMake(self.view.frame.size.width, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width, _viewAtRight.frame.size.height)];
					} else {
						[_viewAtRight setFrame:CGRectMake(_positionOfViewAtRightAtTouchBegan.x + translatedPoint.x - _displacementPosition, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width, _viewAtRight.frame.size.height)];
					}
					if (_viewAtRight.frame.origin.x - _viewAtLeft.frame.size.width < SLIDE_VIEWS_MINUS_X_POSITION) {
						[_viewAtLeft setFrame:CGRectMake(SLIDE_VIEWS_MINUS_X_POSITION, _viewAtLeft.frame.origin.y, _viewAtLeft.frame.size.width, _viewAtLeft.frame.size.height)];
					} else {
						[_viewAtLeft setFrame:CGRectMake(_viewAtRight.frame.origin.x - _viewAtLeft.frame.size.width, _viewAtLeft.frame.origin.y, _viewAtLeft.frame.size.width, _viewAtLeft.frame.size.height)];
					}
					if (_viewAtRight.frame.origin.x >= self.view.frame.size.width) {
						_positionOfViewAtRightAtTouchBegan = _viewAtRight.frame.origin;
						_positionOfViewAtLeftAtTouchBegan = _viewAtLeft.frame.origin;
						_displacementPosition = translatedPoint.x;
					}
					
					[self arrangeVerticalBar];
				}
				
			}
			
			[self arrangeVerticalBar];
		}
	}
	
	_lastTouchPoint = location.x;
	
	// STATE END	
	if (recognizer.state == UIGestureRecognizerStateEnded) {
		
		if ([_dragDirection isEqualToString:@"LEFT"]) {
			if (_viewAtRight != nil) {
				if ([[_slideView subviews] indexOfObject:_viewAtLeft] == 0 && !(_viewAtLeft.frame.origin.x == SLIDE_VIEWS_MINUS_X_POSITION || _viewAtLeft.frame.origin.x == SLIDE_VIEWS_START_X_POS)) {
					[UIView beginAnimations:nil context:NULL];
					[UIView setAnimationDuration:0.2];
					[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:nil cache:YES];
					[UIView setAnimationBeginsFromCurrentState:YES];
					if (_viewAtLeft.frame.origin.x < SLIDE_VIEWS_START_X_POS && _viewAtRight != nil) {
						[_viewAtLeft setFrame:CGRectMake(SLIDE_VIEWS_MINUS_X_POSITION, _viewAtLeft.frame.origin.y, _viewAtLeft.frame.size.width, _viewAtLeft.frame.size.height)];
						[_viewAtRight setFrame:CGRectMake(SLIDE_VIEWS_MINUS_X_POSITION + _viewAtLeft.frame.size.width, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width,_viewAtRight.frame.size.height)];
					} else {
						
						//Drop Card View Animation
						if ((((UIView*)[[_slideView subviews] objectAtIndex:0]).frame.origin.x+200) >= (self.view.frame.origin.x + ((UIView*)[[_slideView subviews] objectAtIndex:0]).frame.size.width)) {
							
							NSInteger viewControllerCount = [_viewControllersStack count];
							
							if (viewControllerCount > 1) {
								for (int i = 1; i < viewControllerCount; i++) {
									_viewXPosition = self.view.frame.size.width - [_slideView viewWithTag:i].frame.size.width;
									[[_slideView viewWithTag:i*TAG_BASE] removeFromSuperview];
									[_viewControllersStack removeLastObject];
								}
								
								[[_borderView viewWithTag:3] setHidden:YES];
								[[_borderView viewWithTag:2] setHidden:YES];
								[[_borderView viewWithTag:1] setHidden:YES];
								
							}
							
							// Removes the selection of row for the first slide view
							for (UIView* tableView in [[[_slideView subviews] objectAtIndex:0] subviews]) {
								if([tableView isKindOfClass:[UITableView class]]){
									NSIndexPath* selectedRow =  [(UITableView*)tableView indexPathForSelectedRow];
									NSArray *indexPaths = [NSArray arrayWithObjects:selectedRow, nil];
									[(UITableView*)tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:NO];
								}
							}
							_viewAtLeft2 = nil;
							_viewAtRight = nil;
							_viewAtRight2 = nil;							 
						}
						
						[_viewAtLeft setFrame:CGRectMake(SLIDE_VIEWS_START_X_POS, _viewAtLeft.frame.origin.y, _viewAtLeft.frame.size.width, _viewAtLeft.frame.size.height)];
						if (_viewAtRight != nil) {
							[_viewAtRight setFrame:CGRectMake(SLIDE_VIEWS_START_X_POS + _viewAtLeft.frame.size.width, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width,_viewAtRight.frame.size.height)];						
						}
						
					}
					[UIView commitAnimations];
				} else if (_viewAtLeft.frame.origin.x == SLIDE_VIEWS_MINUS_X_POSITION && _viewAtRight.frame.origin.x + _viewAtRight.frame.size.width > self.view.frame.size.width) {
					[UIView beginAnimations:nil context:NULL];
					[UIView setAnimationDuration:0.2];
					[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:nil cache:YES];
					[UIView setAnimationBeginsFromCurrentState:YES];
					[_viewAtRight setFrame:CGRectMake(self.view.frame.size.width - _viewAtRight.frame.size.width, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width,_viewAtRight.frame.size.height)];						
					[UIView commitAnimations];						
				} else if (_viewAtLeft.frame.origin.x == SLIDE_VIEWS_MINUS_X_POSITION && _viewAtRight.frame.origin.x + _viewAtRight.frame.size.width < self.view.frame.size.width) {
					[UIView beginAnimations:@"RIGHT-WITH-RIGHT" context:NULL];
					[UIView setAnimationDuration:0.2];
					[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:nil cache:YES];
					[UIView setAnimationBeginsFromCurrentState:YES];
					[_viewAtRight setFrame:CGRectMake(self.view.frame.size.width - _viewAtRight.frame.size.width, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width,_viewAtRight.frame.size.height)];
					[UIView setAnimationDelegate:self];
					[UIView setAnimationDidStopSelector:@selector(bounceBack:finished:context:)];
					[UIView commitAnimations];
				} else if (_viewAtLeft.frame.origin.x > SLIDE_VIEWS_MINUS_X_POSITION) {
					[UIView setAnimationDuration:0.2];
					[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:nil cache:YES];
					[UIView setAnimationBeginsFromCurrentState:YES];
					if ((_viewAtLeft.frame.origin.x + _viewAtLeft.frame.size.width > self.view.frame.size.width) && _viewAtLeft.frame.origin.x < (self.view.frame.size.width - (_viewAtLeft.frame.size.width)/2)) {
						[UIView beginAnimations:@"LEFT-WITH-LEFT" context:nil];
						[_viewAtLeft setFrame:CGRectMake(self.view.frame.size.width - _viewAtLeft.frame.size.width, _viewAtLeft.frame.origin.y, _viewAtLeft.frame.size.width, _viewAtLeft.frame.size.height)];
						
						//Show bounce effect
						[_viewAtRight setFrame:CGRectMake(self.view.frame.size.width, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width,_viewAtRight.frame.size.height)];						
					} else {
						[UIView beginAnimations:@"LEFT-WITH-RIGHT" context:nil];	
						[_viewAtLeft setFrame:CGRectMake(SLIDE_VIEWS_MINUS_X_POSITION, _viewAtLeft.frame.origin.y, _viewAtLeft.frame.size.width, _viewAtLeft.frame.size.height)];
						if (_positionOfViewAtLeftAtTouchBegan.x + _viewAtLeft.frame.size.width <= self.view.frame.size.width) {
							[_viewAtRight setFrame:CGRectMake((self.view.frame.size.width - _viewAtRight.frame.size.width), _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width,_viewAtRight.frame.size.height)];						
						} else {
							[_viewAtRight setFrame:CGRectMake(SLIDE_VIEWS_MINUS_X_POSITION + _viewAtLeft.frame.size.width, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width,_viewAtRight.frame.size.height)];						
						}
						
						//Show bounce effect
						[_viewAtRight2 setFrame:CGRectMake(_viewAtRight.frame.origin.x + _viewAtRight.frame.size.width, _viewAtRight2.frame.origin.y, _viewAtRight2.frame.size.width, _viewAtRight2.frame.size.height)];
					}
					[UIView setAnimationDelegate:self];
					[UIView setAnimationDidStopSelector:@selector(bounceBack:finished:context:)];
					[UIView commitAnimations];
				}
				
			} else {
				[UIView beginAnimations:nil context:NULL];
				[UIView setAnimationDuration:0.2];
				[UIView setAnimationBeginsFromCurrentState:YES];
				[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:nil cache:YES];
				[_viewAtLeft setFrame:CGRectMake(SLIDE_VIEWS_START_X_POS, _viewAtLeft.frame.origin.y, _viewAtLeft.frame.size.width, _viewAtLeft.frame.size.height)];
				[UIView commitAnimations];
			}
			
		} else if ([_dragDirection isEqualToString:@"RIGHT"]) {
            
			if (_viewAtLeft != nil) {
                
                NSInteger leftViewIndex = [[_slideView subviews] indexOfObject:_viewAtLeft];
				if ((leftViewIndex == ITEM_LIST_IDX || leftViewIndex == ITEM_DETAIL_IDX)
                    && !(_viewAtLeft.frame.origin.x == SLIDE_VIEWS_MINUS_X_POSITION || _viewAtLeft.frame.origin.x == SLIDE_VIEWS_START_X_POS)) {
					[UIView beginAnimations:nil context:NULL];
					[UIView setAnimationDuration:0.2];			
					[UIView setAnimationBeginsFromCurrentState:YES];
					[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:nil cache:YES];                  
                    
					if (_viewAtLeft.frame.origin.x > SLIDE_VIEWS_MINUS_X_POSITION || _viewAtRight == nil) {      
						
						//Drop Card View Animation
                        CGFloat hideThreshold = 0;
                        if ([CommonUtils currentOrientationIsLandscape]) {
                            hideThreshold = LANDSCAPE_HIDE_THRESHOLD;
                        } else {
                            hideThreshold = PORTRAIT_HIDE_THRESHOLD;
                        }
                        
                        NSInteger subViewCount = [[_slideView subviews] count];
                        NSInteger baseViewIndexForToppest = 0;
                        NSInteger toppestIndex = 0;
                        if (subViewCount > 1) {
                            baseViewIndexForToppest = [[_slideView subviews] count] - 2;
                            toppestIndex = baseViewIndexForToppest + 1;
                        }
                        
						if ((((UIView*)[[_slideView subviews] objectAtIndex:/*0*/baseViewIndexForToppest]).frame.origin.x + hideThreshold) >= (self.view.frame.origin.x + ((UIView*)[[_slideView subviews] objectAtIndex:/*0*/baseViewIndexForToppest]).frame.size.width)) {
							NSInteger viewControllerCount = [_viewControllersStack count];
							if (viewControllerCount > 1) {
								//for (int i = 1; i < viewControllerCount; i++) {
                                _viewXPosition = self.view.frame.size.width - [_slideView viewWithTag:/*i*/toppestIndex].frame.size.width;
                                [[_slideView viewWithTag:/*i*/toppestIndex*TAG_BASE] removeFromSuperview];
                                [_viewControllersStack removeLastObject];
								//}
								[[_borderView viewWithTag:3] setHidden:YES];
								[[_borderView viewWithTag:2] setHidden:YES];
								[[_borderView viewWithTag:1] setHidden:YES];
							}
							
							// Removes the selection of row for the first slide view                                                    
							for (UIView* tableView in [[[_slideView subviews] objectAtIndex:/*0*/(toppestIndex - 1)] subviews]) {
								if([tableView isKindOfClass:[UITableView class]]) {
									NSIndexPath* selectedRow =  [(UITableView*)tableView indexPathForSelectedRow];
									NSArray *indexPaths = [NSArray arrayWithObjects:selectedRow, nil];
									[(UITableView*)tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:NO];
								}
							}
							
                            if (toppestIndex == 2) {
                                // pop up the stack views
                                _viewAtRight = _viewAtLeft;
                                _viewAtLeft = _viewAtLeft2;                
                                
                            } else if (toppestIndex == 1) {
                                _viewAtRight = nil;                
                            }
							_viewAtLeft2 = nil;
                            _viewAtRight2 = nil;	
						}
                        
                        if (toppestIndex == 2) {
                            [_viewAtLeft setFrame:CGRectMake(MID_LIST_VIEW_START_X_POS, _viewAtLeft.frame.origin.y, _viewAtLeft.frame.size.width, _viewAtLeft.frame.size.height)];              
                            
                            [_viewAtRight setFrame:CGRectMake(self.view.frame.size.width - _viewAtRight.frame.size.width, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width,_viewAtRight.frame.size.height)];
                            
                        } else if (toppestIndex == 1) {
                            [_viewAtLeft setFrame:CGRectMake(SLIDE_VIEWS_START_X_POS, _viewAtLeft.frame.origin.y, _viewAtLeft.frame.size.width, _viewAtLeft.frame.size.height)];
                            
                            // reset the multi-level menu position
                            if (_target && _linkageAction) {
                                [_target performSelector:_linkageAction withObject:RIGHT_DIRECTION];
                            }
                        }
                        
					}
					else{
						[_viewAtLeft setFrame:CGRectMake(SLIDE_VIEWS_MINUS_X_POSITION, _viewAtLeft.frame.origin.y, _viewAtLeft.frame.size.width, _viewAtLeft.frame.size.height)];
						[_viewAtRight setFrame:CGRectMake(SLIDE_VIEWS_MINUS_X_POSITION + _viewAtLeft.frame.size.width, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width,_viewAtRight.frame.size.height)];
					}
					[UIView commitAnimations];
				}
				else if (_viewAtRight.frame.origin.x < self.view.frame.size.width) {
					if((_viewAtRight.frame.origin.x < (_viewAtLeft.frame.origin.x + _viewAtLeft.frame.size.width)) && _viewAtRight.frame.origin.x < (self.view.frame.size.width - (_viewAtRight.frame.size.width/2))){
						[UIView beginAnimations:@"RIGHT-WITH-RIGHT" context:NULL];
						[UIView setAnimationDuration:0.2];
						[UIView setAnimationBeginsFromCurrentState:YES];
						[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:nil cache:YES];
						[_viewAtRight setFrame:CGRectMake(SLIDE_VIEWS_MINUS_X_POSITION + _viewAtLeft.frame.size.width, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width,_viewAtRight.frame.size.height)];						
						[UIView setAnimationDelegate:self];
						[UIView setAnimationDidStopSelector:@selector(bounceBack:finished:context:)];
						[UIView commitAnimations];
					}				
					else{
						
						[UIView beginAnimations:@"RIGHT-WITH-LEFT" context:NULL];
						[UIView setAnimationDuration:0.2];
						[UIView setAnimationBeginsFromCurrentState:YES];
						[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:nil cache:YES];
						if([[_slideView subviews] indexOfObject:_viewAtLeft] > 0){ 
							if (_positionOfViewAtRightAtTouchBegan.x  + _viewAtRight.frame.size.width <= self.view.frame.size.width) {							
								[_viewAtLeft setFrame:CGRectMake(self.view.frame.size.width - _viewAtLeft.frame.size.width, _viewAtLeft.frame.origin.y, _viewAtLeft.frame.size.width, _viewAtLeft.frame.size.height)];
							}
							else{							
								[_viewAtLeft setFrame:CGRectMake(SLIDE_VIEWS_MINUS_X_POSITION + _viewAtLeft2.frame.size.width, _viewAtLeft.frame.origin.y, _viewAtLeft.frame.size.width, _viewAtLeft.frame.size.height)];
							}
							[_viewAtRight setFrame:CGRectMake(self.view.frame.size.width, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width,_viewAtRight.frame.size.height)];		
						}
						else{
							[_viewAtLeft setFrame:CGRectMake(SLIDE_VIEWS_MINUS_X_POSITION, _viewAtLeft.frame.origin.y, _viewAtLeft.frame.size.width, _viewAtLeft.frame.size.height)];
							[_viewAtRight setFrame:CGRectMake(SLIDE_VIEWS_MINUS_X_POSITION + _viewAtLeft.frame.size.width, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width,_viewAtRight.frame.size.height)];
						}
						[UIView setAnimationDelegate:self];
						[UIView setAnimationDidStopSelector:@selector(bounceBack:finished:context:)];
						[UIView commitAnimations];
					}
					
				}
			}			
		}
		_lastTouchPoint = -1;
		_dragDirection = @"";
	}	
}

- (void)bounceBack:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context {	
	
	BOOL isBouncing = NO;
	
	if([_dragDirection isEqualToString:@""] && [finished boolValue]){
		[_viewAtLeft.layer removeAllAnimations];
		[_viewAtRight.layer removeAllAnimations];
		[_viewAtRight2.layer removeAllAnimations];
		[_viewAtLeft2.layer removeAllAnimations];
		if ([animationID isEqualToString:@"LEFT-WITH-LEFT"] && _viewAtLeft2.frame.origin.x == SLIDE_VIEWS_MINUS_X_POSITION) {
			CABasicAnimation *bounceAnimation = [CABasicAnimation animationWithKeyPath:@"position.x"];
			bounceAnimation.duration = 0.2;
			bounceAnimation.fromValue = [NSValue valueWithCGPoint:_viewAtLeft.center];
			bounceAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(_viewAtLeft.center.x -10, _viewAtLeft.center.y)];
			bounceAnimation.repeatCount = 0;
			bounceAnimation.autoreverses = YES;
			bounceAnimation.fillMode = kCAFillModeBackwards;
			bounceAnimation.removedOnCompletion = YES;
			bounceAnimation.additive = NO;
			[_viewAtLeft.layer addAnimation:bounceAnimation forKey:@"bounceAnimation"];
			
			[_viewAtRight setHidden:NO];
			CABasicAnimation *bounceAnimationForRight = [CABasicAnimation animationWithKeyPath:@"position.x"];
			bounceAnimationForRight.duration = 0.2;
			bounceAnimationForRight.fromValue = [NSValue valueWithCGPoint:_viewAtRight.center];
			bounceAnimationForRight.toValue = [NSValue valueWithCGPoint:CGPointMake((_viewAtRight.center.x - 20), _viewAtRight.center.y)];
			bounceAnimationForRight.repeatCount = 0;
			bounceAnimationForRight.autoreverses = YES;
			bounceAnimationForRight.fillMode = kCAFillModeBackwards;
			bounceAnimationForRight.removedOnCompletion = YES;
			bounceAnimationForRight.additive = NO;
			[_viewAtRight.layer addAnimation:bounceAnimationForRight forKey:@"bounceAnimationRight"];
		}else if ([animationID isEqualToString:@"LEFT-WITH-RIGHT"]  && _viewAtLeft.frame.origin.x == SLIDE_VIEWS_MINUS_X_POSITION) {
			CABasicAnimation *bounceAnimation = [CABasicAnimation animationWithKeyPath:@"position.x"];
			bounceAnimation.duration = 0.2;
			bounceAnimation.fromValue = [NSValue valueWithCGPoint:_viewAtRight.center];
			bounceAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(_viewAtRight.center.x -10, _viewAtRight.center.y)];
			bounceAnimation.repeatCount = 0;
			bounceAnimation.autoreverses = YES;
			bounceAnimation.fillMode = kCAFillModeBackwards;
			bounceAnimation.removedOnCompletion = YES;
			bounceAnimation.additive = NO;
			[_viewAtRight.layer addAnimation:bounceAnimation forKey:@"bounceAnimation"];
			
			
			[_viewAtRight2 setHidden:NO];
			CABasicAnimation *bounceAnimationForRight2 = [CABasicAnimation animationWithKeyPath:@"position.x"];
			bounceAnimationForRight2.duration = 0.2;
			bounceAnimationForRight2.fromValue = [NSValue valueWithCGPoint:_viewAtRight2.center];
			bounceAnimationForRight2.toValue = [NSValue valueWithCGPoint:CGPointMake((_viewAtRight2.center.x - 20), _viewAtRight2.center.y)];
			bounceAnimationForRight2.repeatCount = 0;
			bounceAnimationForRight2.autoreverses = YES;
			bounceAnimationForRight2.fillMode = kCAFillModeBackwards;
			bounceAnimationForRight2.removedOnCompletion = YES;
			bounceAnimationForRight2.additive = NO;
			[_viewAtRight2.layer addAnimation:bounceAnimationForRight2 forKey:@"bounceAnimationRight2"];
		}else if ([animationID isEqualToString:@"RIGHT-WITH-RIGHT"]) {
			CABasicAnimation *bounceAnimationLeft = [CABasicAnimation animationWithKeyPath:@"position.x"];
			bounceAnimationLeft.duration = 0.2;
			bounceAnimationLeft.fromValue = [NSValue valueWithCGPoint:_viewAtLeft.center];
			bounceAnimationLeft.toValue = [NSValue valueWithCGPoint:CGPointMake(_viewAtLeft.center.x +10, _viewAtLeft.center.y)];
			bounceAnimationLeft.repeatCount = 0;
			bounceAnimationLeft.autoreverses = YES;
			bounceAnimationLeft.fillMode = kCAFillModeBackwards;
			bounceAnimationLeft.removedOnCompletion = YES;
			bounceAnimationLeft.additive = NO;
			[_viewAtLeft.layer addAnimation:bounceAnimationLeft forKey:@"bounceAnimationLeft"];
			
			CABasicAnimation *bounceAnimationRight = [CABasicAnimation animationWithKeyPath:@"position.x"];
			bounceAnimationRight.duration = 0.2;
			bounceAnimationRight.fromValue = [NSValue valueWithCGPoint:_viewAtRight.center];
			bounceAnimationRight.toValue = [NSValue valueWithCGPoint:CGPointMake(_viewAtRight.center.x +10, _viewAtRight.center.y)];
			bounceAnimationRight.repeatCount = 0;
			bounceAnimationRight.autoreverses = YES;
			bounceAnimationRight.fillMode = kCAFillModeBackwards;
			bounceAnimationRight.removedOnCompletion = YES;
			bounceAnimationRight.additive = NO;
			[_viewAtRight.layer addAnimation:bounceAnimationRight forKey:@"bounceAnimationRight"];
			
		}else if ([animationID isEqualToString:@"RIGHT-WITH-LEFT"]) {
			CABasicAnimation *bounceAnimationLeft = [CABasicAnimation animationWithKeyPath:@"position.x"];
			bounceAnimationLeft.duration = 0.2;
			bounceAnimationLeft.fromValue = [NSValue valueWithCGPoint:_viewAtLeft.center];
			bounceAnimationLeft.toValue = [NSValue valueWithCGPoint:CGPointMake(_viewAtLeft.center.x +10, _viewAtLeft.center.y)];
			bounceAnimationLeft.repeatCount = 0;
			bounceAnimationLeft.autoreverses = YES;
			bounceAnimationLeft.fillMode = kCAFillModeBackwards;
			bounceAnimationLeft.removedOnCompletion = YES;
			bounceAnimationLeft.additive = NO;
			[_viewAtLeft.layer addAnimation:bounceAnimationLeft forKey:@"bounceAnimationLeft"];
			
			if (_viewAtLeft2 != nil) {
				[_viewAtLeft2 setHidden:NO];
				NSInteger viewAtLeft2Position = [[_slideView subviews] indexOfObject:_viewAtLeft2];
				if (viewAtLeft2Position > 0) {
					[((UIView*)[[_slideView subviews] objectAtIndex:viewAtLeft2Position -1]) setHidden:NO];
				}
				CABasicAnimation* bounceAnimationLeft2 = [CABasicAnimation animationWithKeyPath:@"position.x"];
				bounceAnimationLeft2.duration = 0.2;
				bounceAnimationLeft2.fromValue = [NSValue valueWithCGPoint:_viewAtLeft2.center];
				bounceAnimationLeft2.toValue = [NSValue valueWithCGPoint:CGPointMake(_viewAtLeft2.center.x +10, _viewAtLeft2.center.y)];
				bounceAnimationLeft2.repeatCount = 0;
				bounceAnimationLeft2.autoreverses = YES;
				bounceAnimationLeft2.fillMode = kCAFillModeBackwards;
				bounceAnimationLeft2.removedOnCompletion = YES;
				bounceAnimationLeft2.additive = NO;
				[_viewAtLeft2.layer addAnimation:bounceAnimationLeft2 forKey:@"bounceAnimationviewAtLeft2"];
				[self performSelector:@selector(callArrangeVerticalBar) withObject:nil afterDelay:0.4];
				isBouncing = YES;
			}
			
		}
		
	}
	[self arrangeVerticalBar];	
	if ([[_slideView subviews] indexOfObject:_viewAtLeft2] == 1 && isBouncing) {
		[[_borderView viewWithTag:2] setHidden:YES];
	}
}

- (void)callArrangeVerticalBar{
	[self arrangeVerticalBar];
}

- (void)addShadowToView:(UIView *)view {
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGRect bounds = _newAddedController.view.bounds;
    [path moveToPoint:CGPointMake(-10, 0)];
    [path addLineToPoint:CGPointMake(bounds.size.width + 10, 0)];
    [path addLineToPoint:CGPointMake(bounds.size.width + 10, bounds.size.height)];
    [path addLineToPoint:CGPointMake(-10, bounds.size.height)];
    [path addLineToPoint:CGPointMake(-10, 0)];
    
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    view.layer.shadowRadius = 6.0f;
    view.layer.shadowOpacity = 0.7f;
    view.layer.masksToBounds = NO;
    view.layer.shadowPath = path.CGPath;
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
		
		NSInteger viewControllerCount = [_viewControllersStack count];
		for (int i = indexOfViewController; i < viewControllerCount; i++) {
			[[_slideView viewWithTag:i*TAG_BASE] removeFromSuperview];
			[_viewControllersStack removeObjectAtIndex:i];
			_viewXPosition = self.view.frame.size.width - [aNewAddedController view].frame.size.width;
		}
	} else if([_viewControllersStack count] == 0) {
		for (UIView* subview in [_slideView subviews]) {
			[subview removeFromSuperview];
		}		
        [_viewControllersStack removeAllObjects];
		[[_borderView viewWithTag:3] setHidden:YES];
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
	
	[aNewAddedController.view setTag:([_viewControllersStack count]-1)*TAG_BASE];

    NSLog(@"view: %@", aNewAddedController.view);
	[_slideView addSubview:aNewAddedController.view];
	
	if ([[_slideView subviews] count] > 0) {
		
		if ([[_slideView subviews] count] == 1) {
			_viewAtLeft = [[_slideView subviews] objectAtIndex:[[_slideView subviews] count]-1];
			_viewAtLeft2 = nil;
			_viewAtRight = nil;
			_viewAtRight2 = nil;
			
		} else if ([[_slideView subviews] count]==2) {
			_viewAtRight = [[_slideView subviews] objectAtIndex:[[_slideView subviews] count]-1];
			_viewAtLeft = [[_slideView subviews] objectAtIndex:[[_slideView subviews] count]-2];
			_viewAtLeft2 = nil;
			_viewAtRight2 = nil;
			
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
			
		} else {
            
			if (((UIView*)[[_slideView subviews] objectAtIndex:0]).frame.origin.x > SLIDE_VIEWS_MINUS_X_POSITION) {
				UIView* tempRight2View =[[_slideView subviews] objectAtIndex:[[_slideView subviews] count]-1];
				[UIView beginAnimations:@"ALIGN_TO_MINIMENU" context:NULL];
				[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:_viewAtLeft cache:YES];	
				[UIView setAnimationBeginsFromCurrentState:NO];				
				[_viewAtLeft setFrame:CGRectMake(SLIDE_VIEWS_MINUS_X_POSITION, _viewAtLeft.frame.origin.y, _viewAtLeft.frame.size.width, _viewAtLeft.frame.size.height)];
				[_viewAtRight setFrame:CGRectMake(self.view.frame.size.width - _viewAtRight.frame.size.width, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width, _viewAtRight.frame.size.height)];
				[tempRight2View setFrame:CGRectMake(self.view.frame.size.width, tempRight2View.frame.origin.y, tempRight2View.frame.size.width, tempRight2View.frame.size.height)];
				[UIView setAnimationDelegate:self];
				[UIView setAnimationDidStopSelector:@selector(bounceBack:finished:context:)];
				[UIView commitAnimations];
			} else {
				_viewAtRight = [[_slideView subviews] objectAtIndex:[[_slideView subviews] count]-1];
				_viewAtLeft = [[_slideView subviews] objectAtIndex:[[_slideView subviews] count]-2];
				_viewAtLeft2 = [[_slideView subviews] objectAtIndex:[[_slideView subviews] count]-3];
				[_viewAtLeft2 setHidden:NO];
				_viewAtRight2 = nil;
				
				[UIView beginAnimations:nil context:NULL];
				[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:_viewAtLeft cache:YES];	
				[UIView setAnimationBeginsFromCurrentState:NO];	
				[_viewAtLeft setFrame:CGRectMake(SLIDE_VIEWS_MINUS_X_POSITION, _viewAtLeft.frame.origin.y, _viewAtLeft.frame.size.width, _viewAtLeft.frame.size.height)];
				[_viewAtRight setFrame:CGRectMake(self.view.frame.size.width - _viewAtRight.frame.size.width, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width, _viewAtRight.frame.size.height)];
				[UIView setAnimationDelegate:self];
				[UIView setAnimationDidStopSelector:@selector(bounceBack:finished:context:)];
				[UIView commitAnimations];				
				_slideStartPosition = SLIDE_VIEWS_MINUS_X_POSITION;	
				if([[_slideView subviews] count] > 3){
					[[[_slideView subviews] objectAtIndex:[[_slideView subviews] count]-4] setHidden:YES];		
				}
			}
		}
	}
}

- (void)clearAllSubviewsAndAddNewViewController {
    
    if (_needResetMultilevelMenuPosition) {
        
        for (UIView* subview in [_slideView subviews]) {
            [subview removeFromSuperview];
        }
        
        _needResetMultilevelMenuPosition = NO;    
        
        [[_borderView viewWithTag:3] setHidden:YES];
		[[_borderView viewWithTag:2] setHidden:YES];
		[[_borderView viewWithTag:1] setHidden:YES];
		[_viewControllersStack removeAllObjects];    
    }
    
    [self addNewInvokerViewController:self.newAddedController 
                   invokeByController:self.invokeByController];
}

- (void)addViewInSlider:(UIViewController*)controller 
     invokeByController:(UIViewController*)invokeByController 
         stackStartView:(BOOL)stackStartView {
    
    self.newAddedController = nil;
    self.invokeByController = nil;
	
	if (stackStartView) {
		_slideStartPosition = SLIDE_VIEWS_START_X_POS;
		_viewXPosition = _slideStartPosition;		
        
        self.newAddedController = controller;
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
	
}

#pragma mark - user action
- (void)releaseItemList {
    
    NSInteger toppestIndex = [self findToppestSlideViewIndex];
    
    //_viewAtRight = nil;
    [[_slideView viewWithTag:/*1*/toppestIndex] removeFromSuperview];
    [_viewControllersStack removeLastObject];
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
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:ANIMATION_DURATION];			
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:nil cache:YES];
    
    [[_borderView viewWithTag:3] setHidden:YES];
    [[_borderView viewWithTag:lineView2Tag] setHidden:YES];
    [[_borderView viewWithTag:lineView1Tag] setHidden:YES];
    
    // Removes the selection of row for the first slide view
    for (UIView* tableView in [[[_slideView subviews] objectAtIndex:/*0*/(toppestIndex - 1)] subviews]) {
        
        if([tableView isKindOfClass:[UITableView class]]) {
            NSIndexPath* selectedRow =  [(UITableView*)tableView indexPathForSelectedRow];
            NSArray *indexPaths = [NSArray arrayWithObjects:selectedRow, nil];
            [(UITableView*)tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:NO];
        }
    }
    
    if (toppestIndex >= 2) {
        // remove the top right view (item detail view) to outside of screen
        _viewAtRight.frame = CGRectMake(self.view.frame.size.width, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width, _viewAtRight.frame.size.height);
        
        // pop up the stack views
        _viewAtRight = _viewAtLeft;
        _viewAtLeft = _viewAtLeft2;   
        
        // adjust current existing views position
        [_viewAtLeft setFrame:CGRectMake(MID_LIST_VIEW_START_X_POS, _viewAtLeft.frame.origin.y, _viewAtLeft.frame.size.width, _viewAtLeft.frame.size.height)]; 
        
        [_viewAtRight setFrame:CGRectMake(self.view.frame.size.width - _viewAtRight.frame.size.width, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width,_viewAtRight.frame.size.height)];
        
    } else if (toppestIndex == 1) {
        // remove the item list view to outside of screen
        _viewAtRight.frame = CGRectMake(self.view.frame.size.width, _viewAtRight.frame.origin.y, _viewAtRight.frame.size.width, _viewAtRight.frame.size.height);
        
        _viewAtRight = nil;
        
        // adjust group list position
        [_viewAtLeft setFrame:CGRectMake(SLIDE_VIEWS_START_X_POS, _viewAtLeft.frame.origin.y, _viewAtLeft.frame.size.width, _viewAtLeft.frame.size.height)];
        
        // adjust the top multi-level menu position, move it to right
        if (_target && _linkageAction) {
            [_target performSelector:_linkageAction withObject:RIGHT_DIRECTION];
        }
        
    }
    _viewAtLeft2 = nil;
    _viewAtRight2 = nil;
    
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(releaseItemList)];
    [UIView commitAnimations];
    
    _lastTouchPoint = -1;
    _dragDirection = @"";
}

@end
