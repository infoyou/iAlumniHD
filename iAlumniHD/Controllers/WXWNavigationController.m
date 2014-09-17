//
//  WXWNavigationController.m
//  iAlumniHD
//
//  Created by Adam on 12-11-8.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "WXWNavigationController.h"
#import "RootViewController.h"
#import "AppManager.h"
#import "CommonUtils.h"
#import "LoginViewController.h"
#import "NameCardListViewController.h"

#pragma mark - life cycle
@implementation WXWNavigationController

- (id)initWithRootViewController:(UIViewController *)rootViewController shadowType:(ShadowType)shadowType {
    
    self = [super initWithRootViewController:rootViewController];
    
    if (self) {
        
        self.navigationBar.tintColor = TITLESTYLE_COLOR;
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
        
        if ([CommonUtils currentOSVersion] < IOS5) {
          [rootViewController viewDidAppear:YES];
        }
        
        [self addShadowToView:shadowType];
    }
    return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController {
    
    return [self initWithRootViewController:rootViewController shadowType:SHADOW_LEFT];
}

- (void)dealloc {
    
    [super dealloc];
}

#pragma mark - view orientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft||interfaceOrientation==UIInterfaceOrientationLandscapeRight);
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
//ios 6 rotation
-(NSUInteger)supportedInterfaceOrientations{
  return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotate {
  return YES;
}
#endif

#pragma mark - UINavigationController methods

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    [super pushViewController:viewController animated:animated];
    
    if ([CommonUtils currentOSVersion] < IOS5) {
        
    if ([self needLoadViewAppear:viewController]) {
        [viewController viewWillAppear:YES];
        [viewController viewDidAppear:YES];
        }
    }
}

- (BOOL)needLoadViewAppear:(UIViewController *)viewController
{

    if ([viewController isKindOfClass:LoginViewController.class]) {
        return NO;
    }
    if ([viewController isKindOfClass:NameCardListViewController.class]) {
        return NO;
    }

    return YES;
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    
    RootViewController *rootViewController = (RootViewController *)[super popViewControllerAnimated:animated];
    
    [rootViewController cancelConnectionAndImageLoading];
    
    if ([CommonUtils currentOSVersion] < IOS5) {
        NSInteger lastIndex = self.viewControllers.count - 1;
        UIViewController *parentVC = [self.viewControllers objectAtIndex:lastIndex];
        [parentVC viewWillAppear:YES];
        [parentVC viewDidAppear:YES];
    }
    
    return rootViewController;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.frame = CGRectMake(0, 0, LIST_WIDTH, self.view.frame.size.height);
}

- (void)cancelContainsViewControllersConnectionAndImageLoading {
  for (UIViewController *vc in self.viewControllers) {
    if ([vc isKindOfClass:[RootViewController class]]) {
      [((RootViewController *)vc) cancelConnectionAndImageLoading];
    }
  }
}

- (void)deSelectCell {
    for (UIViewController *vc in self.viewControllers) {
        if ([vc isKindOfClass:[RootViewController class]]) {
            [((RootViewController *)vc) deSelectCell];
        }
    }
}

- (void)addShadowToView:(ShadowType)shadowType {
  
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGRect bounds = self.view.bounds;
    int shadowWidth = 5;
    int boundsWidth = bounds.size.width;
    
    switch (shadowType) {
        case SHADOW_ALL:
        {
            [path moveToPoint:CGPointMake(0 - shadowWidth, 0)];
            [path addLineToPoint:CGPointMake(boundsWidth + shadowWidth, 0)];
            [path addLineToPoint:CGPointMake(boundsWidth + shadowWidth, SCREEN_WIDTH)];
            [path addLineToPoint:CGPointMake(0 - shadowWidth, SCREEN_WIDTH)];
            [path addLineToPoint:CGPointMake(0 - shadowWidth, 0)];
            
        }
            break;
         
        case SHADOW_RIGHT:
        {
            [path moveToPoint:CGPointMake(boundsWidth, 0)];
            [path addLineToPoint:CGPointMake(boundsWidth + shadowWidth, 0)];
            [path addLineToPoint:CGPointMake(boundsWidth + shadowWidth, SCREEN_WIDTH)];
            [path addLineToPoint:CGPointMake(boundsWidth, SCREEN_WIDTH)];
            [path addLineToPoint:CGPointMake(boundsWidth, 0)];
        }
            break;
            
        case SHADOW_LEFT:
        {
            [path moveToPoint:CGPointMake(0 - shadowWidth, 0)];
            [path addLineToPoint:CGPointMake(0, 0)];
            [path addLineToPoint:CGPointMake(0, SCREEN_WIDTH)];
            [path addLineToPoint:CGPointMake(0 - shadowWidth, SCREEN_WIDTH)];
            [path addLineToPoint:CGPointMake(0 - shadowWidth, 0)];
        }
            break;
            
        default:
            break;
    }
    
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.view.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.view.layer.shadowRadius = 6.0f;
    self.view.layer.shadowOpacity = 0.7f;
    self.view.layer.masksToBounds = NO;
    self.view.layer.shadowPath = path.CGPath;
}

@end
