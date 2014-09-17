//
//  WXWNavigationController.h
//  iAlumniHD
//
//  Created by Adam on 12-11-8.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"

@interface WXWNavigationController : UINavigationController {
}

- (id)initWithRootViewController:(UIViewController *)rootViewController shadowType:(ShadowType)shadowType;

- (id)initWithRootViewController:(UIViewController *)rootViewController;

- (void)cancelContainsViewControllersConnectionAndImageLoading;

- (void)deSelectCell;

@end
