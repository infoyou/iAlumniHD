//
//  HomepageViewController.m
//  iAlumniHD
//
//  Created by Adam on 12-10-3.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "HomepageViewController.h"
#import "HorizontalScrollViewController.h"
#import "VerticalMenuViewController.h"
#import "MultilevelScrollMenusView.h"
#import "GlobalConstants.h"
#import "CommonUtils.h"
#import "AppManager.h"
#import "XMLParser.h"
#import "WXWUIUtils.h"

@interface UIViewCheckTouch : UIView {
    UIView *rightSlideView;
}

@property (nonatomic, retain) UIView *rightSlideView;
@end

@implementation UIViewCheckTouch

@synthesize rightSlideView;

- (UIView *)hitTest:(CGPoint)aPoint withEvent:(UIEvent *)event {
    UIView *returnView = nil;
    
    CGPoint returnPoint;
    UIView *rightView = self.rightSlideView;
    
    if ([rightView.subviews objectAtIndex:0]) {
        UIView *stackScrollView = [rightView.subviews objectAtIndex:0];
        
        if ([stackScrollView.subviews objectAtIndex:1]) {
            UIView *slideView = [stackScrollView.subviews objectAtIndex:1];
            for (UIView *view in slideView.subviews) {
                CGPoint point = [view convertPoint:aPoint fromView:self];
                if ([view pointInside:point withEvent:event]) {
                    returnView = view;
                    returnPoint = point;
                }
            }
        }
    }
    
    if (nil != returnView) {
        return [returnView hitTest:returnPoint withEvent:event];
    }
    
    return [super hitTest:aPoint withEvent:event];
}

- (void)dealloc {
    
    self.rightSlideView = nil;
    
    [super dealloc];
}

@end

@implementation HomepageViewController

@synthesize menuViewController = _menuViewController;
@synthesize stackScrollViewController = _stackScrollViewController;
//@synthesize multilevelMenu = _multilevelMenu;

- (id)initWithMOC:(NSManagedObjectContext *)MOC {
    
    self = [super init];
    if (self) {
        _MOC = MOC;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(arrangeLayoutAfterRotation)
                                                     name:UI_ROTATE_NOTIFY
                                                   object:nil];
    }
    return self;
}

- (void)unregisterNotifications {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UI_ROTATE_NOTIFY object:nil];
}

- (void)dealloc {
    
    [self unregisterNotifications];
    
    if ([AppManager instance].isLoadClassDataOK) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(classId > 0)"];
        [CommonUtils unLoadObject:_MOC predicate:predicate entityName:@"ClassGroup"];
    }
    
    if ([AppManager instance].isLoadIndustryDataOK) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(industryId > 0)"];
        [CommonUtils unLoadObject:_MOC predicate:predicate entityName:@"Industry"];
    }
    
    if ([AppManager instance].isLoadCountryDataOK) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(countryId > 0)"];
        [CommonUtils unLoadObject:_MOC predicate:predicate entityName:@"UserCountry"];
    }
    
    RELEASE_OBJ(_menuViewController);
    if (_stackScrollViewController) {
        [_stackScrollViewController clearAllViewControllerStuff];
    }
    RELEASE_OBJ(_stackScrollViewController);
    RELEASE_OBJ(_leftMenuView);
    RELEASE_OBJ(_rightSlideView);
//    RELEASE_OBJ(_multilevelMenu);
    RELEASE_OBJ(_rootView);
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark - arrange views
- (void)arrangeViewForShowThirdMenu:(NSString *)command {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:ANIMATION_DURATION];
    
    if ([SHOW_MENU isEqualToString:command]) {
        _rightSlideView.frame = CGRectMake(_rightSlideView.frame.origin.x, _rightSlideView.frame.origin.y + THIRD_LEVEL_HEIGHT, _rightSlideView.frame.size.width, _rightSlideView.frame.size.height - THIRD_LEVEL_HEIGHT);
        
    } else if ([HIDE_MENU isEqualToString:command]){
        [UIView setAnimationDidStopSelector:@selector(removeThirdMenu)];
        _rightSlideView.frame = CGRectMake(_rightSlideView.frame.origin.x, _rightSlideView.frame.origin.y - THIRD_LEVEL_HEIGHT, _rightSlideView.frame.size.width, _rightSlideView.frame.size.height + THIRD_LEVEL_HEIGHT);
    }
    
    [UIView commitAnimations];
}

- (void)sendMultilevelMenuToBack {
//    [_rootView sendSubviewToBack:_multilevelMenu];
}

- (void)arrangeMultilevelMenu:(NSString *)direction {
    
    /*
    if ([RIGHT_DIRECTION isEqualToString:direction]) {
        
        _multilevelMenu.frame = CGRectMake(_multilevelMenu.frame.origin.x + MULTI_LEVEL_MENU_OFFSET,
                                           _multilevelMenu.frame.origin.y,
                                           _multilevelMenu.frame.size.width - MULTI_LEVEL_MENU_OFFSET,
                                           _multilevelMenu.frame.size.height);
        [self performSelector:@selector(sendMultilevelMenuToBack) withObject:nil afterDelay:ANIMATION_DURATION];
        
    } else if ([LEFT_DIRECTION isEqualToString:direction]) {
        
        if (_multilevelMenu.frame.origin.x > _leftMenuView.frame.size.width - MULTI_LEVEL_MENU_OFFSET) {
            // means multi-level menu has not been moved to left yet, otherwise, _multilevelMenu.frame.origin.x larger than
            // left menu widht
            _multilevelMenu.frame = CGRectMake(_multilevelMenu.frame.origin.x - MULTI_LEVEL_MENU_OFFSET,
                                               _multilevelMenu.frame.origin.y,
                                               _multilevelMenu.frame.size.width + MULTI_LEVEL_MENU_OFFSET,
                                               _multilevelMenu.frame.size.height);
            [_rootView bringSubviewToFront:_multilevelMenu];
        }
    }
    
    [_multilevelMenu arrangeTitleToCenter];
     */
}

- (void)resetMultilevelMenuPosition {
    /*
    if (_multilevelMenu.frame.origin.x < _leftMenuView.frame.size.width) {
        // multi-level menu moved to left already, then it needs be reset position (move to right)
        [self arrangeMultilevelMenu:RIGHT_DIRECTION];
    }
     */
}

- (void)arrangeLayoutAfterRotation {
    
    [WXWUIUtils arrangeMessageViews];
    [WXWUIUtils arrangeActivityViewRotation];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    int offsetY = 0;
    if ([CommonUtils is7System]) {
        offsetY = 20;
    }
    
    // Back Image
    UIImageView *backImgView = [[[UIImageView alloc] init] autorelease];
    backImgView.frame = CGRectMake(0, offsetY, SCREEN_WIDTH, self.view.frame.size.height-offsetY);
    [backImgView setImage:[UIImage imageNamed:@"back.png"]];
    [self.view addSubview:backImgView];
    
    // root
    _rootView = [[UIViewCheckTouch alloc] initWithFrame:CGRectMake(0, offsetY, self.view.frame.size.width, self.view.frame.size.height-offsetY)];
	_rootView.autoresizingMask = UIViewAutoresizingFlexibleWidth + UIViewAutoresizingFlexibleHeight;
	_rootView.backgroundColor = TRANSPARENT_COLOR;
	
    // left menu
	_leftMenuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, VERTICAL_MENU_WIDTH, self.view.frame.size.height)];
	_leftMenuView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    CGRect leftMenuFrame = CGRectMake(0, 0, _leftMenuView.frame.size.width, _leftMenuView.frame.size.height);
	_menuViewController = [[VerticalMenuViewController alloc] initWithFrame:leftMenuFrame MOC:_MOC];
    _menuViewController.view.backgroundColor = TRANSPARENT_COLOR;
	[_leftMenuView addSubview:_menuViewController.view];
    [_rootView addSubview:_leftMenuView];
    
    // right slide
	_rightSlideView = [[UIView alloc] initWithFrame:CGRectMake(_leftMenuView.frame.size.width, 0, _rootView.frame.size.width - _leftMenuView.frame.size.width, _rootView.frame.size.height)];
	_rightSlideView.autoresizingMask = UIViewAutoresizingFlexibleWidth + UIViewAutoresizingFlexibleHeight;
    
 	_stackScrollViewController = [[HorizontalScrollViewController alloc] initWithTarget:self linkageAction:@selector(arrangeMultilevelMenu:)];
	[_stackScrollViewController.view setFrame:CGRectMake(0, 0, _rightSlideView.frame.size.width, _rightSlideView.frame.size.height)];
    _stackScrollViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth + UIViewAutoresizingFlexibleHeight;
	[_stackScrollViewController viewWillAppear:NO];
	[_stackScrollViewController viewDidAppear:NO];
	[_rightSlideView addSubview:_stackScrollViewController.view];
    
	[_rootView addSubview:_rightSlideView];
    _rootView.rightSlideView = _rightSlideView;
    
	[self.view addSubview:_rootView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self goLogicView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
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

#pragma mark - go Logic View

- (void)goLogicView {
    
    [_menuViewController selectedCell:[AppManager instance].showIndex];
    
    switch ([AppManager instance].sharedItemType) {
        case SHARED_EVENT_TY:
            [[AppManager instance] doOpenSharedEvent];
            break;
            
        case SHARED_BRAND_TY:
            [[AppManager instance] doOpenSharedBrand];
            break;
            
        case SHARED_VIDEO_TY:
            [[AppManager instance] doOpenSharedVideo];
            break;
            
        default:
            break;
    }

}

#pragma mark - open shared item
- (void)openSharedEventById:(long long)eventId eventType:(int)eventType {
    [_menuViewController openSharedEventById:eventId eventType:eventType];
}

- (void)openAutoSelectEventTabFlagWithId:(long long)eventId eventType:(int)eventType {
    
}

- (void)openSharedBrandWithId:(long long)brandId {
    [_menuViewController openSharedBrandWithId:brandId];
}

- (void)openSharedVideoWithId:(long long)videoId {
    [_menuViewController openSharedVideoWithId:videoId];
}

@end
