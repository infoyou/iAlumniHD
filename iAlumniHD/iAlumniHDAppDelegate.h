//
//  iAlumniHDAppDelegate.h
//  iAlumniHD
//
//  Created by Adam on 12-10-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "HorizontalScrollViewController.h"
#import "LogUploader.h"
#import "WXApi.h"

@class LoginViewController;
@class VerticalMenuViewController;
@class HomepageViewController;

@interface iAlumniHDAppDelegate : NSObject <UIApplicationDelegate, WXApiDelegate>
{

    NSManagedObjectContext *_MOC;
    NSManagedObjectModel *_MOM;
    NSPersistentStoreCoordinator *_PSC;

    LoginViewController *startVC;
    
    LogUploader *_logUploader;
    
    BOOL _startup;
    
    id<WXApiDelegate> _wxApiDelegate;
}

@property (nonatomic, retain, readonly) NSManagedObjectContext *_MOC;
@property (nonatomic, retain, readonly) NSManagedObjectModel *_MOM;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *_PSC;
@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) LoginViewController *startVC;
@property (nonatomic, retain) id<WXApiDelegate> wxApiDelegate;
// app is running current and just back from background
@property (nonatomic, assign) BOOL toForeground;

- (void)openLogin:(BOOL)isNeedPrompt autoLogin:(BOOL)autoLogin;
- (NSURL *)applicationDocumentsDirectory;

#pragma mark - UI utility methods
- (UIView *)foundationView;
- (UIViewController *)foundationViewController;
- (UIViewController *)foundationRootViewController;
- (HomepageViewController *)foundationHomeViewController;

- (void)closeViewStack;

- (void)addViewInSlider:(UIViewController*)controller
     invokeByController:(UIViewController*)invokeByController
         stackStartView:(BOOL)stackStartView;

- (void)setMenuTitle:(NSString*)title;

#pragma mark - go logic view
- (void)goHelpView;
- (void)singleLogin;

#pragma mark - open shared items
- (void)openHomePageAfterClearAllViewControllers;
- (void)openSharedEventById:(long long)eventId eventType:(int)eventType;
- (void)openSharedBrandById:(long long)brandId;
- (void)openSharedVideoById:(long long)videoId;

@end
