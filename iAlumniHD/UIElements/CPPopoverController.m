//
//  CPPopoverController.m
//  iAlumniHD
//
//  Created by Adam on 12-10-21.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "CPPopoverController.h"
#import "WXWUIUtils.h"

static UIPopoverController *popoverView = nil;
static UIView *sourceView = nil;
static UIDeviceOrientation lastOrientation = UIDeviceOrientationUnknown;

@implementation CPPopoverController

+ (UIPopoverController *)popoverForViewController:(UIViewController *)viewController {
  [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
  popoverView = [[UIPopoverController alloc] initWithContentViewController:viewController];
  popoverView.delegate = [CPPopoverController popoverReleaserDelegate];
  return popoverView;
}

+ (void)discardPopover {
  
  if ([WXWUIUtils activityViewIsAnimating]) {
    [WXWUIUtils closeActivityView];
  }
  
  if (nil == popoverView) {
    return;
  }
  
  [popoverView autorelease];
  popoverView = nil;
  
  RELEASE_OBJ(sourceView);
  
  [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

+ (CPPopoverController *)popoverReleaserDelegate {
  static CPPopoverController *instance = nil;
  if (nil == instance) {
    instance = [[CPPopoverController alloc] init];
  }
  return instance;
}

+ (void)load {
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(orientationDidChange:) 
                                               name:UIDeviceOrientationDidChangeNotification
                                             object:nil];
}

+ (void)updatePopoverForNewOrientation {
  UIView *view = sourceView;
  while (![view isKindOfClass:[UIView class]]) {
    if (nil == view || view.hidden) {
      [popoverView dismissAndRelease];
      return;
    }
    view = view.superview;
  }
  [popoverView presentPopoverFromView:sourceView];
}

+ (void)orientationDidChange:(NSNotification *)note {
  UIDeviceOrientation newOrientation = [UIDevice currentDevice].orientation;
  if (UIDeviceBatteryStateUnknown == newOrientation 
      || lastOrientation == newOrientation) {
    return;
  }
  
  if (!UIDeviceOrientationIsPortrait(newOrientation) &&
      !UIDeviceOrientationIsLandscape(newOrientation)) {
    return;
  }
  
  lastOrientation = newOrientation;
  [self performSelector:@selector(updatePopoverForNewOrientation)
             withObject:nil
             afterDelay:0.0f];
}

#pragma mark - UIPopoverControllerDelegate methods
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
  [CPPopoverController discardPopover];
}

@end

@implementation UIPopoverController(customize)
- (void)presentPopoverFromView:(UIView *)view {
  sourceView = [view retain];
  self.popoverContentSize = self.contentViewController.view.frame.size;
  [self presentPopoverFromRect:sourceView.frame
                        inView:sourceView.superview 
      permittedArrowDirections:UIPopoverArrowDirectionAny 
                      animated:YES];
}

- (void)dismissAndRelease {
  
  [popoverView dismissPopoverAnimated:NO];
  [CPPopoverController discardPopover];
}

@end
