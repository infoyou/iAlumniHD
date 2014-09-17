//
//  AppManager.h
//  iAlumniHD
//
//  Created by Adam on 12-11-3.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "LocationFetcherDelegate.h"
#import <MapKit/MKReverseGeocoder.h>
#import "WXWConnectorDelegate.h"
#import "AppSettingDelegate.h"
#import "ImageFetcherDelegate.h"
#import "WXApi.h"

@class ImageCache;
@class RootViewController;

@interface AppManager : NSObject <LocationFetcherDelegate, WXWConnectorDelegate> {
    
    NSString *version;
    NSString *device;
    NSString *system;
    NSString *deviceToken;
    NSString *softName;
    PublishChannelType releaseChannelType;
    BOOL sessionExpire;
    BOOL isNewVersion;
    BOOL isSinglePage;
    
    NSString *msgNumber;
    NSString *hostUrl;
    NSString *softUrl;
    NSString *loginHelpUrl;
    NSString *serviceTel;
    NSString *softDesc;
    NSString *needPrompt;
    NSString *errCode;
    NSString *errDesc;
    
    NSString *recommend;
    NSString *sessionId;
    NSString *personId;
    NSString *userType;
    NSString *classGroupId;
    NSString *className;
    
    // user
    NSString *_userId;
    NSString *passwd;
    NSString *_username;
    NSString *userImgUrl;
    NSString *_email;
    NSString *_photoUrl;
    NSString *_accessToken;
    NSString *_systemMessage;
    BOOL _hasLogoff;
    id _appDelegate;
    SEL _verifyFinishAction;
    
    // language
    BOOL _isLanguageChange;
    NSInteger _currentLanguageCode;
    NSString *_currentLanguageDesc;
    NSString *_switchTargetLanguageCode;
    
    // network
    BOOL _networkStable;
    NSString *_host;
    NSMutableDictionary *_connDic;
    NSMutableDictionary *_errorMsgDic;
    
    // Search Alumni base data
    BOOL isLoadClassDataOK;
    BOOL isLoadCountryDataOK;
    BOOL isLoadIndustryDataOK;
    BOOL isLoadHomeGroupDataOK;
    BOOL isLoadADDataOK;
    BOOL isLoadVedioFilterOk;
    
    // image cache
    ImageCache *_imageCache;
    
    // new item info
    NSInteger _loadedItemCount;
    
    // news font size
    FontSizeType _fontSizeType;
    
    // new system message
    BOOL _messageAutoLoaded;
    BOOL _unreadMessageReceived;
    
    // location
    BOOL _locationFetched;
    double _latitude;
    double _longitude;
    NSString *_cityName;
    long long _cityId;
    NSTimer *_locationTimer;
    
    // country
    long long _countryId;
    NSString *_countryName;
    
    // default group info
    NSNumber *_feedGroupId;
    NSNumber *_qaGroupId;
    
    // core data
    NSManagedObjectContext *_MOC;
    
    id<AppSettingDelegate> _settingDelegate;
    NSString *eventId;
    NSString *eventAlumniMobile;
    NSString *eventAlumniEmail;
    NSString *eventAlumniWeibo;
    
    NSString *clubId;
    NSString *clubName;
    NSString *clubType;
    NSString *hostSupTypeValue;
    NSString *hostTypeValue;
    NSString *clubSupType;
    BOOL clubAdmin;
    BOOL isAdminCheckIn;
    BOOL isNeedReLoadUserList;
    BOOL isNeedReLoadClubDetail;
    BOOL isAddUserList;
    BOOL isClub2Event;
    BOOL isAlumniCheckIn;
    
    BOOL isClubPostShow;
    NSMutableArray *clubPostArray;
    NSMutableArray *supClubFilterList;
    NSMutableArray *clubFilterList;
    NSString *supClubTypeValue;
    NSString *myClassNum;
    BOOL needSaveMyClassNum;
    NSString *clubKeyWord;
    
    BOOL clubFliterLoaded;
    BOOL eventCityLoaded;
    
    NSMutableArray *supClassFilterList;
    NSMutableArray *classFilterList;
    BOOL classFliterLoaded;
    
    NSMutableArray *distanceList;
    NSMutableArray *timeList;
    NSMutableArray *sortList;
    
    NSMutableArray *videoTypeList;
    NSMutableArray *videoSortList;
    
    NSInteger videoTypeIndex;
    NSString *videoTypeVal;
    NSInteger videoSortIndex;
    NSString *videoSortVal;
    
    NSMutableArray *pickerSel0IndexList;
    NSMutableArray *pickerSel1IndexList;
    
    BOOL hasSetingedPlace2Thing;
    BOOL isAlumniList2Shake;
    
    NSString *defaultPlace;
    NSString *defaultDistance;
    NSString *defaultThing;
    NSString *shakeLocationHistory;
    
    NSMutableArray *visiblePopTipViews;
    NSString *chartContent;
    
    BOOL isPostDetail;
    
    // event
    BOOL _allowSendSMS;
    
    NSString *adminCheckinTableInfo;
    
    WinnerType shakeWinnerType;
    NSString *shakeWinnerInfo;
    
    // back alumni
    BOOL accessCheckInAvailable;
    NSString *backAlumniActivityMsg;
    NSString *backAlumniActivityType;
    NSString *backAlumniEventMsg;
    
    // Composer
    NSString *composerPlace;
    
    // Root
    RootViewController *rootVC;
    
    NSInteger showIndex;
    
    // question
    NSMutableArray *baseDataArray;
    NSMutableArray *questionsList;
    NSMutableArray *questionsOptionsList;
    NSMutableDictionary *questionDictMutable;
    
    SharedItemType sharedItemType;
    
@private
    BOOL _existingUser;
    BOOL _reloadDataForLanguageSwitch;
    
    long long _sharedEventId;
    long long _sharedBrandId;
    long long _sharedVideoId;
    
    int _sharedEventType;
}

@property (nonatomic, copy) NSString *device;
@property (nonatomic, copy) NSString *version;
@property (nonatomic, copy) NSString *system;
@property (nonatomic, copy) NSString *deviceToken;
@property (nonatomic, copy) NSString *softName;
@property (nonatomic, assign) PublishChannelType releaseChannelType;
@property (nonatomic, assign) BOOL sessionExpire;
@property (nonatomic, assign) BOOL isNewVersion;
@property (nonatomic, assign) BOOL isSinglePage;

@property (nonatomic, copy) NSString *msgNumber;
@property (nonatomic, copy) NSString *passwd;
@property (nonatomic, copy) NSString *hostUrl;
@property (nonatomic, copy) NSString *softUrl;
@property (nonatomic, copy) NSString *loginHelpUrl;
@property (nonatomic, copy) NSString *serviceTel;
@property (nonatomic, copy) NSString *softDesc;
@property (nonatomic, copy) NSString *errCode;
@property (nonatomic, copy) NSString *errDesc;
@property (nonatomic, copy) NSString *recommend;
@property (nonatomic, copy) NSString *userImgUrl;
@property (nonatomic, copy) NSString *needPrompt;

@property (nonatomic, copy) NSString *sessionId;
@property (nonatomic, copy) NSString *classGroupId;
@property (nonatomic, copy) NSString *className;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *userType;
@property (nonatomic, copy) NSString *personId;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *userMobile;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *photoUrl;
@property (nonatomic, copy) NSString *systemMessage;
@property (nonatomic, copy) NSString *accessToken;

@property (nonatomic, assign) BOOL isLanguageChange;
@property (nonatomic, assign) NSInteger currentLanguageCode;
@property (nonatomic, copy) NSString *currentLanguageDesc;
@property (nonatomic, copy) NSString *currentLanguage;

@property (nonatomic, assign) BOOL isLoadClassDataOK;
@property (nonatomic, assign) BOOL isLoadCountryDataOK;
@property (nonatomic, assign) BOOL isLoadIndustryDataOK;
@property (nonatomic, assign) BOOL isLoadHomeGroupDataOK;
@property (nonatomic, assign) BOOL isLoadADDataOK;
@property (nonatomic, assign) BOOL isLoadVedioFilterOk;

@property (nonatomic, assign) BOOL networkStable;
@property (nonatomic, copy) NSString *deviceConnectionIdentifier;
@property (nonatomic, copy) NSString *host;
@property (nonatomic, retain) ImageCache *imageCache;
@property (nonatomic, assign) NSInteger loadedItemCount;
@property (nonatomic, assign) BOOL locationFetched;
@property (nonatomic, assign) BOOL hasLogoff;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, assign) long long cityId;
@property (nonatomic, copy) NSString *cityName;
@property (nonatomic, retain) NSManagedObjectContext *MOC;
@property (nonatomic, assign) long long countryId;
@property (nonatomic, copy) NSString *countryName;
@property (nonatomic, retain) NSNumber *feedGroupId;
@property (nonatomic, retain) NSNumber *qaGroupId;
@property (nonatomic, assign) BOOL unreadMessageReceived;
@property (nonatomic, assign) BOOL messageAutoLoaded;
@property (nonatomic, assign) FontSizeType fontSizeType;

@property (nonatomic, copy) NSString *eventId;
@property (nonatomic, copy) NSString *clubId;
@property (nonatomic, copy) NSString *clubName;
@property (nonatomic, copy) NSString *clubType;
@property (nonatomic, copy) NSString *hostSupTypeValue;
@property (nonatomic, copy) NSString *hostTypeValue;

@property (nonatomic, copy) NSString *clubSupType;
@property (nonatomic, copy) NSString *eventAlumniMobile;
@property (nonatomic, copy) NSString *eventAlumniEmail;
@property (nonatomic, copy) NSString *eventAlumniWeibo;

@property (nonatomic, assign) BOOL clubAdmin;
@property (nonatomic, assign) BOOL isAdminCheckIn;
@property (nonatomic, assign) BOOL isClub2Event;
@property (nonatomic, assign) BOOL isNeedReLoadUserList;
@property (nonatomic, assign) BOOL isNeedReLoadClubDetail;

@property (nonatomic, assign) BOOL isAddUserList;
@property (nonatomic, assign) BOOL isAlumniCheckIn;

@property (nonatomic, assign) BOOL isClubPostShow;
@property (nonatomic, retain) NSMutableArray *clubPostArray;

@property (nonatomic, retain) NSMutableArray *supClubFilterList;
@property (nonatomic, retain) NSMutableArray *clubFilterList;
@property (nonatomic, copy)   NSString *myClassNum;
@property (nonatomic, assign) BOOL needSaveMyClassNum;
@property (nonatomic, copy)   NSString *supClubTypeValue;
@property (nonatomic, copy)   NSString *clubKeyWord;

@property (nonatomic, assign) BOOL eventCityLoaded;
@property (nonatomic, assign) BOOL clubFliterLoaded;

@property (nonatomic, retain) NSMutableArray *supClassFilterList;
@property (nonatomic, retain) NSMutableArray *classFilterList;
@property (nonatomic, assign) BOOL classFliterLoaded;

@property (nonatomic, retain) NSMutableArray *distanceList;
@property (nonatomic, retain) NSMutableArray *timeList;
@property (nonatomic, retain) NSMutableArray *sortList;

@property (nonatomic, retain) NSMutableArray *videoTypeList;
@property (nonatomic, retain) NSMutableArray *videoSortList;

@property (nonatomic, assign) NSInteger videoTypeIndex;
@property (nonatomic, copy) NSString *videoTypeVal;
@property (nonatomic, assign) NSInteger videoSortIndex;
@property (nonatomic, copy) NSString *videoSortVal;


@property (nonatomic, retain) NSMutableArray *pickerSel0IndexList;
@property (nonatomic, retain) NSMutableArray *pickerSel1IndexList;

@property (nonatomic, assign) BOOL hasSetingedPlace2Thing;
@property (nonatomic, copy) NSString *defaultPlace;
@property (nonatomic, copy) NSString *defaultDistance;
@property (nonatomic, copy) NSString *defaultThing;
@property (nonatomic, copy) NSString *shakeLocationHistory;

@property (nonatomic, retain) NSMutableArray *visiblePopTipViews;
@property (nonatomic, copy) NSString *chartContent;

@property (nonatomic, assign) BOOL isPostDetail;

@property (nonatomic, copy) NSString *adminCheckinTableInfo;

// event
@property (nonatomic, assign) BOOL allowSendSMS;
@property (nonatomic, assign) BOOL eventPagePrompt;
@property (nonatomic, assign) WinnerType shakeWinnerType;
@property (nonatomic, assign) NSInteger commingLectureEventCount;
@property (nonatomic, assign) NSInteger commingEntertainmentEventCount;
@property (nonatomic, copy) NSString *shakeWinnerInfo;

// back alumni
@property (nonatomic, assign) BOOL accessCheckInAvailable;
@property (nonatomic, copy) NSString *backAlumniActivityMsg;
@property (nonatomic, copy) NSString *backAlumniActivityType;
@property (nonatomic, copy) NSString *backAlumniEventMsg;

// Composer
@property (nonatomic, copy) NSString *composerPlace;

@property (nonatomic, retain) NSNumber *wantToKnowAlumnusCount;
@property (nonatomic, retain) NSNumber *knownAlumnusCount;

@property (nonatomic, retain) RootViewController *rootVC;

@property (nonatomic, assign) NSInteger showIndex;

// question
@property (nonatomic, retain) NSMutableArray *baseDataArray;
@property (nonatomic, retain) NSMutableArray *questionsList;
@property (nonatomic, retain) NSMutableArray *questionsOptionsList;
@property (nonatomic, retain) NSMutableDictionary *questionDictMutable;

// questionnaire sub title
@property (nonatomic, copy) NSString *questionSubTitle;
@property (nonatomic, assign) long long questionId;

@property (nonatomic, assign) SharedItemType sharedItemType;

@property (nonatomic, retain) NSIndexPath *lastSelectedIndexPath;

#pragma mark - instance
+ (AppManager *)instance;

#pragma mark - user
- (void)initUser;
- (void)prepareApp:(id)appDelegate verifyFinishAction:(SEL)verifyFinishAction;
- (void)prepareForNecessaryData;
- (void)reloadForLanguageSwitch:(id<AppSettingDelegate>)settingDelegate;
- (BOOL)allNecessaryUserInfoFetched;

#pragma mark - sign out
- (void)clearUserInfoForSignOut;

- (NSString *)getUserIdFromLocal;
- (NSString *)getPasswordFromLocal;
- (NSString *)getHostStrFromLocal;
- (void)saveUserInfoIntoLocal;

#pragma mark - image management
- (void)fetchImage:(NSString*)url
            caller:(id<ImageFetcherDelegate>)caller
          forceNew:(BOOL)forceNew;

- (void)clearImageCacheForHandleMemoryWarning;

- (void)cancelPendingImageLoadProcess:(NSMutableDictionary *)urlDic;

- (void)clearCallerFromCache:(NSString *)url;

- (void)clearAllCachedImages;
- (void)clearAllCachedAndLocalImages;

#pragma mark - language set
+ (void)setEN;
+ (void)setCN;

- (void)getCurrentLocationInfo;
- (void)relocationForAppActivate;

#pragma mark - handle open shared

- (void)openAppFromWeChatByMessage:(WXMediaMessage *)message;

- (void)doOpenSharedEvent;
- (void)doOpenSharedBrand;
- (void)doOpenSharedVideo;

@end
