//
//  CPPopoverController.h
//  iAlumniHD
//
//  Created by Adam on 12-10-21.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"

@interface CPPopoverController : NSObject <UIPopoverControllerDelegate> {
    
}

+ (UIPopoverController *)popoverForViewController:(UIViewController *)viewController;
+ (CPPopoverController *)popoverReleaserDelegate;
+ (void)discardPopover;

@end

@interface UIPopoverController(customize)
- (void)presentPopoverFromView:(UIView *)view;
- (void)dismissAndRelease;
@end
