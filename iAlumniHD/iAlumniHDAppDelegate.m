//
//  iAlumniHDAppDelegate.m
//  iAlumniHD
//
//  Created by Adam on 12-10-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "iAlumniHDAppDelegate.h"
#import <CrashReporter/CrashReporter.h>
#import "VerticalMenuViewController.h"
#import "WXWNavigationController.h"
#import "HomepageViewController.h"
#import "LoginViewController.h"
#import "DebugLogOutput.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "AppManager.h"
#import "WXWUIUtils.h"
#import "HelpViewController.h"
#import "HomepageViewController.h"
#import "MobClick.h"

@implementation iAlumniHDAppDelegate

@synthesize window = _window;
@synthesize _MOC;
@synthesize _MOM;
@synthesize _PSC;
@synthesize startVC;
@synthesize wxApiDelegate = _wxApiDelegate;

#pragma mark - Core Data stack
/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (_MOM != nil)
    {
        return _MOM;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"iAlumniHD" withExtension:@"momd"];
    _MOM = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _MOM;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_PSC != nil)
    {
        return _PSC;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:DBFile];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtURL:storeURL error:nil];
    
    NSError *error = nil;
    _PSC = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    if (![_PSC addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _PSC;
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (_MOC != nil)
    {
        return _MOC;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        _MOC = [[NSManagedObjectContext alloc] init];
        [_MOC setPersistentStoreCoordinator:coordinator];
    }
    return _MOC;
}

#pragma mark - Application's Documents directory
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)dealloc
{
    [_window release];
    [_MOC release];
    [_MOM release];
    [_PSC release];
    self.startVC = nil;
    
    [super dealloc];
}

- (void)generateConnectionIdentifier {
    NSString *seed = [NSString stringWithFormat:@"%@_%@_%@", [NSDate date], [CommonUtils deviceModel], [[AppManager instance] getUserIdFromLocal]];
    [AppManager instance].deviceConnectionIdentifier = [CommonUtils hashStringAsMD5:seed];
}

- (void)prepareApp {
    [self prepareCrashReporter];
    
    [self generateConnectionIdentifier];
    
    _startup = YES;
    [AppManager instance].sharedItemType = DEFAULT_ID_VALUE;
    [[AppManager instance] getCurrentLocationInfo];
    if (![IPAD_SIMULATOR isEqualToString:[CommonUtils deviceModel]]) {
        NSLog(@"%@",[CommonUtils deviceModel]);
        [self registerNotify];
    }
    
    [self applyCurrentLanguage];
    
    // register call back method for MOC save notification
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSaveNotification:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:_MOC];
    
    [self prepareCache];
    
    // register app to WeChat
    [WXApi registerApp:WX_API_KEY];
    
    // get Device System
    [CommonUtils getDeviceSystemInfo];
    
    [[AppManager instance] initUser];
    
    // init MOC
    [self managedObjectContext];
    
    [[AppManager instance] prepareForNecessaryData];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [self prepareApp];
    
    if (IS_NEED_3RD_LOGIN == 1) {
        [self singleLogin];
    } else {
        //    [self goHelpView];
        [self doLogin];
    }
    
    [MobClick startWithAppkey:@"530af9ab56240b84cc1a9e2e" reportPolicy:SEND_INTERVAL   channelId:@"Web"];
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [MobClick setAppVersion:version];
    
     [MobClick setLogEnabled:YES];
    
    return YES;
}

- (void)openLogin:(BOOL)isNeedPrompt autoLogin:(BOOL)autoLogin
{
    if (IS_NEED_3RD_LOGIN == 1) {
        [self singleLogin];
    } else {
        [self goLoginScreenView:autoLogin];
        
        if (isNeedPrompt) {
            [AppManager instance].sessionExpire = NO;
            
            [WXWUIUtils showNotificationWithMsg:LocaleStringForKey(NSSessionInvalidTitle, nil)
                                        msgType:INFO_TY
                                     holderView:self.startVC.view];
        }
    }
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}
#endif

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of startVCorary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    self.toForeground = NO;
    _startup = NO;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    
    self.toForeground = YES;
    [[AppManager instance] relocationForAppActivate];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    _logUploader = [[[LogUploader alloc] init] autorelease];
    
    [NSThread detachNewThreadSelector:@selector(triggerUpload) toTarget:_logUploader withObject:nil];
    
    // close loading activity during become active
    if ([CommonUtils fetchBoolValueFromLocal:LOADING_NOTIFY_LOCAL_KEY]) {
        [WXWUIUtils closeActivityView];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
}

#pragma mark - crash handler
- (void)onCrash {
}

- (void)applyCurrentLanguage {
    [AppManager instance].currentLanguageCode = [CommonUtils fetchIntegerValueFromLocal:SYSTEM_LANGUAGE_LOCAL_KEY];
    
    if ([AppManager instance].currentLanguageCode == NO_TY) {
        [CommonUtils getLocalLanguage];
    }else {
        [CommonUtils getDBLanguage];
    }
}

- (void)prepareCache {
    [AppManager instance].userId = @"";
    [AppManager instance].MOC = [self managedObjectContext];
}

- (void)prepareCrashReporter {
    
    // Enable the Crash Reporter
    NSError *error;
	if (![[PLCrashReporter sharedReporter] enableCrashReporterAndReturnError: &error]) {
		debugLog(@"Warning: Could not enable crash reporter: %@", error);
    }
}

#pragma mark - notify
- (void)registerNotify
{
    //debugLog(@"%d",[UIApplication sharedApplication].applicationIconBadgeNumber);
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                                           UIRemoteNotificationTypeSound |
                                                                           UIRemoteNotificationTypeAlert)];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSLog(@"My token is: %@", deviceToken);
    [AppManager instance].deviceToken = [NSString stringWithFormat:@"%@", deviceToken];
    [AppManager instance].deviceToken = [[AppManager instance].deviceToken stringByReplacingOccurrencesOfString:@"<" withString:@""];
    [AppManager instance].deviceToken = [[AppManager instance].deviceToken stringByReplacingOccurrencesOfString:@">" withString:@""];
    [AppManager instance].deviceToken = [[AppManager instance].deviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
}

//-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
//{
//    for (id key in userInfo) {
//        NSLog(@"key: %@, value: %@", key, [userInfo objectForKey:key]);
//    }
//}

//接收到push消息
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    NSLog(@"收到推送消息: %@", userInfo[@"aps"][@"alert"]);
    NSLog(@"badge number: %@", userInfo[@"aps"][@"badge"]);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"推送通知"
                                                    message:userInfo[@"aps"][@"alert"]
                                                   delegate:self
                                          cancelButtonTitle:LocaleStringForKey(NSIKnowTitle, nil)
                                          otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
}

- (void)handleSaveNotification:(NSNotification *)aNotification {
    
    [_MOC performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:)
                           withObject:aNotification
                        waitUntilDone:YES];
}

#pragma mark - UI utility methods
- (UIView *)foundationView {
    LoginViewController *loginVC = (LoginViewController*)self.startVC;
    return loginVC.homepageVC.view;
}

- (UIViewController *)foundationViewController {
    LoginViewController *loginVC = (LoginViewController*)self.startVC;
    return loginVC.homepageVC.menuViewController;
}

- (UIViewController *)foundationRootViewController {
    return self.startVC;
}

- (HomepageViewController *)foundationHomeViewController {
    return self.startVC.homepageVC;
}

- (void)closeViewStack {
    LoginViewController *loginVC = (LoginViewController*)self.startVC;
    [loginVC.homepageVC.stackScrollViewController closeItemList];
}

- (void)addViewInSlider:(UIViewController*)controller
     invokeByController:(UIViewController*)invokeByController
         stackStartView:(BOOL)stackStartView {
    
    LoginViewController *loginVC = (LoginViewController*)self.startVC;
    [loginVC.homepageVC.stackScrollViewController addViewInSlider:controller
                                               invokeByController:invokeByController
                                                   stackStartView:stackStartView];
}

- (void)setMenuTitle:(NSString*)title {
    LoginViewController *loginVC = (LoginViewController*)self.startVC;
    [loginVC.homepageVC.multilevelMenu setTitle:title];
}

#pragma mark - handle OpenURL
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    // 处理传递过来的参数
    if ([[url scheme] isEqualToString:APP_NAME]) {
        return YES;
    } else {
        return [WXApi handleOpenURL:url delegate:[self foundationHomeViewController]];
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    if ([[url scheme] isEqualToString:APP_NAME]) {
        NSString *resultMsg = [NSString stringWithFormat:@"%@", url];
        NSLog(@"result = %@", resultMsg);
        
        NSString *paraStr = [NSString stringWithFormat:@"%@://loginreturn?user=&token=&", APP_NAME];
        
        if ([resultMsg isEqualToString:paraStr]) {
            [self goHelpView];
        } else {
            NSArray *resultArray = [resultMsg componentsSeparatedByString:@"?"];
            NSArray *pramArray = [resultArray[1] componentsSeparatedByString:@"&"];
            
            [AppManager instance].userId = [pramArray[0] componentsSeparatedByString:@"="][1];
            NSString *sessionId = [pramArray[1] componentsSeparatedByString:@"="][1];
            
            NSString *decryptSessionId = [sessionId stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            [AppManager instance].sessionId = [EncryptUtil TripleDES:decryptSessionId encryptOrDecrypt:kCCDecrypt];
            
            NSLog(@"[AppManager instance].sessionId = %@", [AppManager instance].sessionId);
            
            [self goLoginScreenView:YES];
        }
        
        return YES;
    } else {
        if (self.wxApiDelegate) {
            return [WXApi handleOpenURL:url delegate:self.wxApiDelegate];
        } else {
            return [WXApi handleOpenURL:url delegate:self];
        }
    }
    
    return NO;
}

#pragma mark - go logic view
- (void)singleLogin {
    
    NSString *paraStr = [NSString stringWithFormat:@"%@://loginreturn?user=&token=&resultmsg=", APP_NAME];
    
    NSString *encodeStr = [CommonUtils stringByURLEncodingStringParameter:paraStr];
    
    NSString *transUrl = [NSString stringWithFormat:@"%@://login?returnurl=%@", SINGLE_LOGIN_APP_NAME, encodeStr];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:transUrl]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:transUrl]];
    } else {
        
         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/ceibs-icampus/id486623316?mt=8"]];
         
         /*
         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms://itunes.apple.com/cn/app/ceibs-icampus/id486623316?mt=8"]];
         */
        
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id486623316"]];
        
    }
    
}

- (void)goHelpView {
    
    HelpViewController *helpVC = [[[HelpViewController alloc] initWithMOC:_MOC] autorelease];
    
    WXWNavigationController *nc = [[[WXWNavigationController alloc] initWithRootViewController:helpVC] autorelease];
    nc.navigationBarHidden = YES;
    self.window.rootViewController = nc;
    [self.window makeKeyAndVisible];
}

- (void)goLoginScreenView:(BOOL)autoLogin {
    
    self.startVC = [[[LoginViewController alloc] initWithMOC:_MOC autoLogin:autoLogin] autorelease];
    WXWNavigationController *nc = [[[WXWNavigationController alloc] initWithRootViewController:self.startVC] autorelease];
    nc.navigationBarHidden = YES;
    self.window.rootViewController = nc;
    [self.window makeKeyAndVisible];
}

- (void)doLogin {
    
    if ([AppManager instance].getPasswordFromLocal == nil || [@"" isEqualToString:[AppManager instance].getPasswordFromLocal]) {
        [self openLogin:NO autoLogin:NO];
    } else {
        [self openLogin:NO autoLogin:YES];
    }
}

#pragma mark - WXApiDelegate methods

- (void)onReq:(BaseReq*)req {
    if ([req isKindOfClass:[ShowMessageFromWXReq class]]) {
        ShowMessageFromWXReq *wxReq = (ShowMessageFromWXReq *)req;
        
        //handle open shared event
        [[AppManager instance] openAppFromWeChatByMessage:wxReq.message];
    }
}

#pragma mark - open shared

- (void)openHomePageAfterClearAllViewControllers {
    
}

- (void)openSharedEventById:(long long)eventId eventType:(int)eventType {
    // step 1: open home page
    [self openHomePageAfterClearAllViewControllers];
    
    // step 2: select event tab and open shared event automatically
    [[self foundationHomeViewController] openSharedEventById:eventId eventType:eventType];
}

- (void)openSharedBrandById:(long long)brandId {
    // step 1: open home page
    [self openHomePageAfterClearAllViewControllers];
    
    // step 2: open shared brand
    [[self foundationHomeViewController] openSharedBrandWithId:brandId];
}

- (void)openSharedVideoById:(long long)videoId {
    // step 1: open home page
    [self openHomePageAfterClearAllViewControllers];
    
    // step 2: open shared video
    [[self foundationHomeViewController] openSharedVideoWithId:videoId];
}

@end
