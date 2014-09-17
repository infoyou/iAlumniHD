//
//  AppSettingDelegate.h
//  iAlumniHD
//
//  Created by Adam on 12-11-22.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AppSettingDelegate <NSObject>

@optional
- (void)triggerReloadForLanguageSwitch;
- (void)languageSwitchDone;
- (void)signOut;
- (void)closeSpinView;

@end
