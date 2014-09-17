//
//  AppManager.m
//  iAlumniHD
//
//  Created by Adam on 12-11-3.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "AppManager.h"
#import "iAlumniHDAppDelegate.h"
#import "ImageCache.h"
#import "LocationManager.h"
#import "CommonUtils.h"
#import "CoreDataUtils.h"
#import "WXWAsyncConnectorFacade.h"
#import "XMLParser.h"
#import "SortOption.h"
#import "TextConstants.h"
#import "Place.h"
#import "WXWUIUtils.h"
#import "RootViewController.h"

#define LOCATION_REFRESH_INTERVAL     60 * 5

@interface AppManager()

@property (nonatomic, retain) NSMutableDictionary *connDic;
@property (nonatomic, retain) NSMutableDictionary *errorMsgDic;
- (void)getCurrentLocationInfo;
- (void)locateUserCurrentCity;
- (void)getLocationIfNecessary;
- (BOOL)checkUserLocaleInfo;

@end

@implementation AppManager

@synthesize version;
@synthesize system;
@synthesize deviceToken;
@synthesize softName;
@synthesize device;
@synthesize releaseChannelType;
@synthesize isNewVersion;
@synthesize sessionExpire;
@synthesize isSinglePage;

@synthesize msgNumber;
@synthesize sessionId;
@synthesize hostUrl;
@synthesize softDesc;
@synthesize softUrl;
@synthesize errCode;
@synthesize errDesc;
@synthesize loginHelpUrl;
@synthesize serviceTel;
@synthesize needPrompt;

@synthesize isLoadClassDataOK;
@synthesize isLoadCountryDataOK;
@synthesize isLoadIndustryDataOK;
@synthesize isLoadHomeGroupDataOK;
@synthesize isLoadADDataOK;
@synthesize isLoadVedioFilterOk;

@synthesize recommend;
@synthesize classGroupId;
@synthesize className;

@synthesize userType;
@synthesize userId = _userId;
@synthesize personId;
@synthesize passwd;
@synthesize username = _username;
@synthesize userMobile = _userMobile;
@synthesize userImgUrl;
@synthesize email = _email;
@synthesize photoUrl = _photoUrl;
@synthesize accessToken = _accessToken;
@synthesize systemMessage = _systemMessage;

@synthesize isLanguageChange = _isLanguageChange;
@synthesize currentLanguageCode = _currentLanguageCode;
@synthesize currentLanguageDesc = _currentLanguageDesc;
@synthesize currentLanguage = _switchTargetLanguageCode;

@synthesize networkStable = _networkStable;
@synthesize host = _host;
@synthesize imageCache = _imageCache;
@synthesize loadedItemCount = _loadedItemCount;
@synthesize locationFetched = _locationFetched;
@synthesize hasLogoff = _hasLogoff;
@synthesize latitude = _latitude;
@synthesize longitude = _longitude;
@synthesize cityId = _cityId;
@synthesize cityName = _cityName;
@synthesize MOC = _MOC;
@synthesize connDic = _connDic;
@synthesize errorMsgDic = _errorMsgDic;
@synthesize countryId = _countryId;
@synthesize countryName = _countryName;
@synthesize feedGroupId = _feedGroupId;
@synthesize qaGroupId = _qaGroupId;
@synthesize unreadMessageReceived = _unreadMessageReceived;
@synthesize messageAutoLoaded = _messageAutoLoaded;
@synthesize fontSizeType = _fontSizeType;

@synthesize clubAdmin;
@synthesize isAdminCheckIn;
@synthesize eventId;
@synthesize clubId;
@synthesize clubName;
@synthesize clubType;
@synthesize clubSupType;
@synthesize hostSupTypeValue;
@synthesize hostTypeValue;
@synthesize isNeedReLoadUserList;
@synthesize isNeedReLoadClubDetail;
@synthesize isAddUserList;
@synthesize isClub2Event;
@synthesize isAlumniCheckIn;

@synthesize isClubPostShow;
@synthesize clubPostArray;

@synthesize eventAlumniMobile;
@synthesize eventAlumniWeibo;
@synthesize eventAlumniEmail;
@synthesize supClubFilterList;
@synthesize clubFilterList;
@synthesize myClassNum;
@synthesize needSaveMyClassNum;
@synthesize supClubTypeValue;
@synthesize clubKeyWord;

@synthesize eventCityLoaded;
@synthesize clubFliterLoaded;

@synthesize supClassFilterList;
@synthesize classFilterList;
@synthesize classFliterLoaded;

@synthesize distanceList;
@synthesize timeList;
@synthesize sortList;

@synthesize videoTypeList;
@synthesize videoSortList;
@synthesize videoTypeIndex;
@synthesize videoTypeVal;
@synthesize videoSortIndex;
@synthesize videoSortVal;

@synthesize pickerSel0IndexList;
@synthesize pickerSel1IndexList;

@synthesize hasSetingedPlace2Thing;
@synthesize defaultPlace;
@synthesize defaultDistance;
@synthesize defaultThing;
@synthesize shakeLocationHistory;

@synthesize visiblePopTipViews;
@synthesize chartContent;

@synthesize isPostDetail;

@synthesize adminCheckinTableInfo;

@synthesize shakeWinnerType;
@synthesize shakeWinnerInfo;

// event
@synthesize allowSendSMS = _allowSendSMS;

// back alumni
@synthesize accessCheckInAvailable;
@synthesize backAlumniActivityMsg;
@synthesize backAlumniActivityType;
@synthesize backAlumniEventMsg;

// Composer
@synthesize composerPlace;

// Root
@synthesize rootVC;

// 点击视频播放后，修改Menu的索引
@synthesize showIndex;

// question
@synthesize baseDataArray;
@synthesize questionsList;
@synthesize questionsOptionsList;
@synthesize questionDictMutable;

@synthesize sharedItemType;

@synthesize lastSelectedIndexPath;

#pragma mark - instance
static AppManager *shareInstance = nil;

+ (AppManager *)instance {
    @synchronized(self) {
        if (nil == shareInstance) {
            shareInstance = [[self alloc] init];
        }
    }
    
    return shareInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (nil == shareInstance) {
            shareInstance = [super allocWithZone:zone];
            return shareInstance;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (oneway void)release {
}

- (unsigned)retainCount {
    return UINT_MAX;
}

- (id)autorelease {
    return self;
}

- (void)dealloc {
    [super dealloc];
}

#pragma mark - prepare necessary data
-(void)prepareLocalDataAndCache {
    if (nil == self.connDic) {
        self.connDic = [NSMutableDictionary dictionary];
    } else {
        [self.connDic removeAllObjects];
    }
    
    if (nil == self.errorMsgDic) {
        self.errorMsgDic = [NSMutableDictionary dictionary];
    } else {
        [self.errorMsgDic removeAllObjects];
    }
    
    [CommonUtils deleteAllObjects:self.MOC];
}

- (void)prepareForNecessaryData {
    
    [self prepareLocalDataAndCache];
    [self getLocationIfNecessary];
}

#pragma mark - language switch
- (void)userMetaDataLoaded {
    
    if (_settingDelegate) {
        [_settingDelegate languageSwitchDone];
        _settingDelegate = nil;
    }
    
    _reloadDataForLanguageSwitch = NO;
}

- (void)loadUserMetaData {
    //  NSString *url = [CommonUtils geneUrl:@"" itemType:@"WebItemType"];
    
    //  WXWAsyncConnectorFacade *connFacade = [[[WXWAsyncConnectorFacade alloc] initWithDelegate:self
    //                                                                  interactionContentType:WebItemType] autorelease];
    // [self.connDic setObject:connFacade forKey:url];
    
    //  [connFacade fetchUserMetaData:url];
}

- (void)reloadForLanguageSwitch:(id<AppSettingDelegate>)settingDelegate {
    
    _settingDelegate = settingDelegate;
    _reloadDataForLanguageSwitch = YES;
    [self prepareLocalDataAndCache];
    [self userMetaDataLoaded];
}

#pragma mark - locate current city where user stays
- (void)handleLocateFailedForCurrentCity {
    
    // CoreLocation locate failed, then assign the local storage firstly,
    self.cityId = [CommonUtils fetchLonglongIntegerValueFromLocal:USER_CITY_ID_LOCAL_KEY];
    self.cityName = [CommonUtils fetchStringValueFromLocal:USER_CITY_NAME_LOCAL_KEY];
    
    if (nil == self.cityName || self.cityName.length == 0) {
        // no local storage for current city, then assign the "Other City" to current user
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(cityId == %lld AND placeId == %@)", OTHER_CITY_ID.longLongValue, OTHER_CITY_ID];
        Place *otherCity = (Place *)[CoreDataUtils fetchObjectFromMOC:self.MOC entityName:@"Place" predicate:predicate];
        self.cityId = otherCity.cityId.longLongValue;
        self.cityName = otherCity.cityName;
        
        [CommonUtils saveLongLongIntegerValueToLocal:self.cityId key:USER_CITY_ID_LOCAL_KEY];
        [CommonUtils saveStringValueToLocal:self.cityName key:USER_CITY_NAME_LOCAL_KEY];
    }
}

- (void)locateUserCurrentCity {
    if (self.latitude == 0.0 && self.longitude == 0.0f) {
        [self handleLocateFailedForCurrentCity];
        
    } else {
        // fetch current city according to latest latitude and longitude
        NSString *url = [CommonUtils geneUrl:@"" itemType:NONE_TY];
        
        WXWAsyncConnectorFacade *connFacade = [[[WXWAsyncConnectorFacade alloc] initWithDelegate:self
                                                                        interactionContentType:LOCATE_CURRENT_CITY_TY] autorelease];
        // [self.connDic setObject:connFacade forKey:url];
        
        [connFacade fetchCurrentCity:url];
    }
}

#pragma mark - prepare app
- (void)prepareHost {
    
    NSString *url = [NSString stringWithFormat:@"http://www.weixun.co/host_get.php?host_type=%d", HOST_TYPE];
    
    WXWAsyncConnectorFacade *connFacade = [[[WXWAsyncConnectorFacade alloc] initWithDelegate:self
                                                                    interactionContentType:FETCH_HOST_TY] autorelease];
    [connFacade fetchHost:url];
    // [self.connDic setObject:connFacade forKey:url];
}

- (void)verifyUser {
    
    _existingUser = [self checkUserLocaleInfo];
    
    if (_existingUser) {
        // verify the user's validity with server
        NSString *url = [CommonUtils geneUrl:@"" itemType:NONE_TY];
        
        WXWAsyncConnectorFacade *connFacade = [[[WXWAsyncConnectorFacade alloc] initWithDelegate:self
                                                                        interactionContentType:VERIFY_USER_TY] autorelease];
        [connFacade verifyUser:url showAlertMsg:NO];
        // [self.connDic setObject:connFacade forKey:url];
        
    } else {
        if (_appDelegate && _verifyFinishAction) {
            [_appDelegate performSelector:_verifyFinishAction withObject:[NSNumber numberWithBool:NO]];
        }
    }
}

- (void)prepareApp:(id)appDelegate verifyFinishAction:(SEL)verifyFinishAction {
    
    _appDelegate = appDelegate;
    _verifyFinishAction = verifyFinishAction;
    
    [self prepareHost];
    
}

- (void)enterHomePage:(NSNumber *)flag {
    
    if (_appDelegate && _verifyFinishAction) {
        [_appDelegate performSelector:_verifyFinishAction withObject:flag];
    }
}

#pragma mark - user
- (BOOL)checkUserLocaleInfo {
    
    BOOL ret = YES;
    
    // set initialized value
    [AppManager instance].sessionId = NULL_PARAM_VALUE;
    
    [AppManager instance].fontSizeType = [CommonUtils fetchIntegerValueFromLocal:FONT_SIZE_LOCAL_KEY];
    
    NSString *username = [CommonUtils fetchStringValueFromLocal:USER_NAME_LOCAL_KEY];
    [AppManager instance].username = username;
    if (nil == username || username.length == 0) {
        ret = NO;
    }
    
    NSString *email = [CommonUtils fetchStringValueFromLocal:USER_EMAIL_LOCAL_KEY];
    [AppManager instance].email = email;
    if (nil == email || email.length == 0) {
        ret = NO;
    }
    
    long long userId = [CommonUtils fetchLonglongIntegerValueFromLocal:USER_ID_LOCAL_KEY];
    [AppManager instance].userId = [NSString stringWithFormat:@"%lld", userId];
    if (userId == 0) {
        ret = NO;
    }
    
    NSString *accessToken = [CommonUtils fetchStringValueFromLocal:USER_ACCESS_TOKEN_LOCAL_KEY];
    [AppManager instance].accessToken = accessToken;
    if (nil == accessToken || accessToken.length == 0) {
        ret = NO;
    }
    
    [AppManager instance].countryId = [CommonUtils fetchLonglongIntegerValueFromLocal:USER_COUNTRY_ID_LOCAL_KEY];
    if (0 == [AppManager instance].countryId) {
        ret = NO;
    }
    
    NSString *countryName = [CommonUtils fetchStringValueFromLocal:USER_COUNTRY_NAME_LOCAL_KEY];
    [AppManager instance].countryName = countryName;
    if (nil == countryName || countryName.length == 0) {
        ret = NO;
    }
    
    [AppManager instance].cityId = [CommonUtils fetchLonglongIntegerValueFromLocal:USER_CITY_ID_LOCAL_KEY];
    if (0 == [AppManager instance].cityId) {
        return NO;
    }
    
    NSString *cityName = [CommonUtils fetchStringValueFromLocal:USER_CITY_NAME_LOCAL_KEY];
    [AppManager instance].cityName = cityName;
    if (nil == cityName || cityName.length == 0) {
        ret = NO;
    }
    
    return ret;
}

- (BOOL)allNecessaryUserInfoFetched {
    
    if (self.countryId > 0 &&
        self.countryName &&
        self.countryName.length > 0 &&
        self.cityId > 0 &&
        self.cityName &&
        self.cityName.length > 0 &&
        self.email &&
        self.email.length > 0 &&
        self.userId &&
        self.userId.length > 0 &&
        self.username &&
        self.username.length > 0) {
        
        return YES;
    } else {
        return NO;
    }
}

- (void)relocationForAppActivate {
    [self getCurrentLocationInfo];
}

- (void)getCurrentLocationInfo {
    
    // fetch current geographic info
    LocationManager *locationManager = [[LocationManager alloc] initWithDelegate:self
                                                                    showAlertMsg:NO];
    [locationManager getCurrentLocation];
    
}

- (void)getLocationIfNecessary {
    if (![AppManager instance].locationFetched) {
        //    [self getCurrentLocationInfo];
    } else {
        // fetch user current city info
        //    [self locateUserCurrentCity];
    }
}

- (void)startLocationTimer {
    if (nil == _locationTimer) {
        _locationTimer = [NSTimer scheduledTimerWithTimeInterval:LOCATION_REFRESH_INTERVAL
                                                          target:self
                                                        selector:@selector(getCurrentLocationInfo)
                                                        userInfo:nil
                                                         repeats:YES];
    }
}

- (void)initUser {
    
    [AppManager instance].sessionId = @"";
    [AppManager instance].personId = @"-1";
    [AppManager instance].userType = @"1";
    [AppManager instance].userId = @"-1";
    [AppManager instance].username = @"游客";
    [AppManager instance].classGroupId = @"EMBA08SH2";
    [AppManager instance].className = @"EMBA08SH2";
    [AppManager instance].showIndex = EVENT_MENU_TY;
    [AppManager instance].hostUrl = @"http://alumniapp.ceibs.edu:8080/ceibs/";
    [CommonUtils saveStringValueToLocal:[AppManager instance].hostUrl key:HOST_LOCAL_KEY];
    //    [self startLocationTimer];
}

#pragma mark - sign out
- (void)clearUserInfoForSignOut {
    [CommonUtils removeLocalInfoValueForKey:USER_ID_LOCAL_KEY];
    [CommonUtils removeLocalInfoValueForKey:USER_NAME_LOCAL_KEY];
    [CommonUtils removeLocalInfoValueForKey:USER_COUNTRY_NAME_LOCAL_KEY];
    [CommonUtils removeLocalInfoValueForKey:USER_COUNTRY_ID_LOCAL_KEY];
    
    self.userId = nil;
    self.username = nil;
    self.countryId = 0ll;
    self.countryName = nil;
    self.sessionId = nil;
}

#pragma mark - image management
- (ImageCache *)imageCache {
    if (nil == _imageCache) {
        _imageCache = [[ImageCache alloc] init];
    }
    return _imageCache;
}

- (void)clearImageCacheForHandleMemoryWarning {
    // clear image cache
    [[[AppManager instance] imageCache] didReceiveMemoryWarning];
}

- (void)fetchImage:(NSString*)url
            caller:(id<ImageFetcherDelegate>)caller
          forceNew:(BOOL)forceNew {
    [[[AppManager instance] imageCache] fetchImage:url
                                            caller:caller
                                          forceNew:forceNew];
}

- (void)cancelPendingImageLoadProcess:(NSMutableDictionary *)urlDic {
    [[[AppManager instance] imageCache] cancelPendingImageLoadProcess:urlDic];
}

- (void)clearCallerFromCache:(NSString *)url {
    [[[AppManager instance] imageCache] clearCallerFromCache:url];
}

- (void)clearAllCachedImages {
    [[[AppManager instance] imageCache] clearAllCachedImages];
}

- (void)clearAllCachedAndLocalImages {
    [[[AppManager instance] imageCache] clearAllCachedAndLocalImages];
}

- (UIImage *)getImage:(NSString*)anUrl {
    return [[[AppManager instance] imageCache] getImage:anUrl];
}

- (void)saveImageIntoCache:(NSString *)url image:(UIImage *)image {
    [[[AppManager instance] imageCache] saveImageIntoCache:url image:image];
}

- (void)removeDelegate:(id)delegate forUrl:(NSString *)key {
    [[[AppManager instance] imageCache] removeDelegate:delegate
                                                forUrl:key];
}

#pragma mark - LocationFetcherDelegate methods

- (void)locationManagerDidUpdateLocation:(LocationManager *)manager
                                location:(CLLocation *)location {
    return;
}

- (void)locationManagerDidReceiveLocation:(LocationManager *)manager location:(CLLocation *)location {
    
    self.latitude = location.coordinate.latitude;
    self.longitude = location.coordinate.longitude;
    
    if (_reloadDataForLanguageSwitch) {
        //    [self loadUserMetaData];
    } else {
        // fetch user current city info
        //    [self locateUserCurrentCity];
    }
    
    [manager autorelease];
  
  // if current location update triggered by user active app, then the nearby service venues
  // should be refreshed if user stay at the nearby service venues list before deactive app
  [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_NEARBY_NOTIFY
                                                      object:nil
                                                    userInfo:nil];
}

- (void)locationManagerDidFail:(LocationManager *)manager {
    
    if (_reloadDataForLanguageSwitch) {
        //    [self loadUserMetaData];
    } else {
        // fetch user current city info
        //    [self locateUserCurrentCity];
    }
    
    [manager autorelease];
}

- (void)locationManagerCancelled:(LocationManager *)manager {
    
    if (_reloadDataForLanguageSwitch) {
        //    [self loadUserMetaData];
    } else {
        // fetch user current city info
        //    [self locateUserCurrentCity];
    }
    
    [manager autorelease];
}

- (NSString *)getEmailFromLocal {
	return (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"email"];
}

- (NSString *)getPasswordFromLocal {
	return (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
}

- (NSString *)getUserIdFromLocal {
	return (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
}

- (NSString *)getUsernameFromLocal {
	NSData *usernameData = (NSData *)[[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
	if (usernameData && usernameData.length > 0) {
		return [[[NSString alloc] initWithData:usernameData encoding:NSUTF8StringEncoding] autorelease];
	} else {
		return nil;
	}
}

- (NSString *)getHostStrFromLocal {
	NSData *hostData = (NSData *)[[NSUserDefaults standardUserDefaults] objectForKey:@"host"];
	if (hostData && hostData.length > 0) {
		return [[[NSString alloc] initWithData:hostData encoding:NSUTF8StringEncoding] autorelease];
	} else {
		return nil;
	}
}

- (void)saveUserInfoIntoLocal {
	[[NSUserDefaults standardUserDefaults] setObject:[self.username dataUsingEncoding:NSUTF8StringEncoding]
                                              forKey:@"username"];
    [[NSUserDefaults standardUserDefaults] setObject:self.userId forKey:@"userId"];
    [[NSUserDefaults standardUserDefaults] setObject:self.email forKey:@"email"];
    [[NSUserDefaults standardUserDefaults] setObject:self.passwd forKey:@"password"];
    [[NSUserDefaults standardUserDefaults] setObject:self.hostUrl forKey:@"host"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - language set
+ (void)setEN{
    [AppManager instance].currentLanguageCode = EN_TY;
    [AppManager instance].currentLanguageDesc = LANG_EN_TY;
    [AppManager instance].currentLanguage = @"English";
}

+ (void)setCN{
    [AppManager instance].currentLanguageCode = ZH_HANS_TY;
    [AppManager instance].currentLanguageDesc = LANG_CN_TY;
    [AppManager instance].currentLanguage = @"中文";
}

#pragma mark - WXWConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(WebItemType)contentType
{
}

- (void)connectDone:(NSData *)result
                url:(NSString *)url
        contentType:(WebItemType)contentType
{
}

- (void)connectCancelled:(NSString *)url
             contentType:(WebItemType)contentType
{
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(WebItemType)contentType {
}

#pragma mark - handle open shared

- (void)openAppFromWeChatByMessage:(WXMediaMessage *)message {
    WXAppExtendObject *object = message.mediaObject;
    
    if (object) {
        [AppManager instance].sharedItemType = [self parserSharedItem:object.extInfo];
        switch ([AppManager instance].sharedItemType) {
            case SHARED_EVENT_TY:
                [self openSharedEvent:object.extInfo];
                break;
                
            case SHARED_BRAND_TY:
                [self openSharedBrand:object.extInfo];
                break;
                
            case SHARED_VIDEO_TY:
                [self openSharedVideo:object.extInfo];
                break;
                
            case NONE_SHARED_TY:
                [self openHomepage];
                break;
                
            default:
                break;
        }
    }
}

- (void)parserEventInfo:(NSString *)info {
    if (info.length > 0) {
        
        if ([info rangeOfString:EVENT_ID_FLAG].length > 0) {
            NSArray *list = [info componentsSeparatedByString:EVENT_FIELD_SEPARATOR];
            if (list.count == 2) {
                NSString *eventIds = list[0];
                NSString *eventTypes = list[1];
                
                // parser event id
                if (eventIds.length > 0) {
                    NSArray *idContents = [eventIds componentsSeparatedByString:SHARED_ITEM_KV_SEPARATOR];
                    if (idContents.count == 2) {
                        _sharedEventId = ((NSString *)idContents[1]).longLongValue;
                    }
                }
                
                if (eventTypes.length > 0) {
                    NSArray *typeContents = [eventTypes componentsSeparatedByString:SHARED_ITEM_KV_SEPARATOR];
                    if (typeContents.count == 2) {
                        _sharedEventType = ((NSString *)typeContents[1]).intValue;
                    }
                }
            }
        }
    }
}

- (long long)parserItemId:(NSString *)info {
    if (info.length > 0) {
        NSArray *list = [info componentsSeparatedByString:SHARED_ITEM_KV_SEPARATOR];
        if (list.count == 2) {
            return ((NSString *)list[1]).longLongValue;
        }
    }
    
    return 0ll;
}

- (SharedItemType)parserSharedItem:(NSString *)extInfo {
    if (0 == extInfo.length || nil == extInfo) {
        return NONE_SHARED_TY;
    }
    
    if ([extInfo rangeOfString:EVENT_ID_FLAG].length > 0) {
        return SHARED_EVENT_TY;
    } else if ([extInfo rangeOfString:BRAND_ID_FLAG].length > 0) {
        return SHARED_BRAND_TY;
    } else if ([extInfo rangeOfString:VIDEO_ID_FLAG].length > 0) {
        return SHARED_VIDEO_TY;
    }
    
    return NONE_SHARED_TY;
}

- (void)doOpenSharedEvent {
    [((iAlumniHDAppDelegate*)APP_DELEGATE) openSharedEventById:_sharedEventId eventType:_sharedEventType];
}

- (void)doOpenSharedBrand {
    [((iAlumniHDAppDelegate*)APP_DELEGATE) openSharedBrandById:_sharedBrandId];
}

- (void)doOpenSharedVideo {
    [((iAlumniHDAppDelegate*)APP_DELEGATE) openSharedVideoById:_sharedVideoId];
}

- (void)openHomepage {
    if (((iAlumniHDAppDelegate*)APP_DELEGATE).toForeground) {
        
        [((iAlumniHDAppDelegate*)APP_DELEGATE) openHomePageAfterClearAllViewControllers];
    }
}

- (void)openSharedEvent:(NSString *)extInfo {
    [self parserEventInfo:extInfo];
    
    if (_sharedEventId > 0ll) {
        
        // open shared event step by step
        
        //_startUpByOpenSharedEvent = YES;
        sharedItemType = SHARED_EVENT_TY;
        
        // 1. if app is running currently, then open shared event directly when
        // app enter to foreground;
        // 2. if app is not running, the shared event will be opened after
        // initialization process finished
        
        if (((iAlumniHDAppDelegate*)APP_DELEGATE).toForeground) {
            
            [self doOpenSharedEvent];
        }
        
    } else {
        // open app frome shared post in WeChat
        [self openHomepage];
    }
}

- (void)openSharedBrand:(NSString *)extInfo {
    _sharedBrandId = [self parserItemId:extInfo];
    
    if (_sharedBrandId > 0ll) {
        
        sharedItemType = SHARED_BRAND_TY;
        
        if (((iAlumniHDAppDelegate*)APP_DELEGATE).toForeground) {
            
            [self doOpenSharedBrand];
        }
        
    } else {
        // open app frome shared post in WeChat
        [self openHomepage];
    }
}

- (void)openSharedVideo:(NSString *)extInfo {
    _sharedVideoId = [self parserItemId:extInfo];
    
    if (_sharedVideoId > 0ll) {
        sharedItemType = SHARED_VIDEO_TY;
        
        if (((iAlumniHDAppDelegate*)APP_DELEGATE).toForeground) {
            
            [self doOpenSharedVideo];
        }
        
    } else {
        [self openHomepage];
    }
}

@end
