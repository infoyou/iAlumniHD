
#import <UIKit/UIKit.h>
#import "GlobalConstants.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreData/CoreData.h>
#import <AddressBook/AddressBook.h>

@class Alumni;
@class Post;
@class Event;
@class Brand;
@class Video;

@interface CommonUtils : NSObject {
	
}

#pragma mark - files
+ (NSString *)documentsDirectory;

#pragma mark - device
+ (UIInterfaceOrientation)currentOrientation;
+ (BOOL)currentOrientationIsLandscape;
+ (NSString *)deviceModel;
+ (CGFloat)currentOSVersion;
+ (CGFloat)screenWidth;
+ (CGFloat)screenHeight;

#pragma mark - system language
+ (LanguageType)currentLanguage;
+ (void)getLocalLanguage;
+ (void)getDBLanguage;
+ (void)setLanguage:(NSString *)languageDesc;
+ (void)resetCurrentAppLanguage;
+ (NSString *)localizedStringForKey:(NSString *)key alter:(NSString *)alternate;

#pragma mark - date time
+ (NSString *)currentHourTime;
+ (NSString *)currentHourMinSecondTime;
+ (NSDate *)convertDateTimeFromUnixTS:(NSTimeInterval)unixDate;
+ (NSString *)simpleFormatDate:(NSDate *)date secondAccuracy:(BOOL)secondAccuracy;
+ (NSTimeInterval)convertToUnixTS:(NSDate *)date;
+ (NSString *)simpleFormatDateWithYear:(NSDate *)date secondAccuracy:(BOOL)secondAccuracy;
+ (NSString *)getElapsedTime:(NSDate *)timeline;
+ (NSInteger)getElapsedDayCount:(NSDate *)date;
+ (NSDate *)getOffsetDateTime:(NSDate *)nowDate offset:(NSInteger)offset;

#pragma mark - network
+ (NSString *)assembleUrl:(NSString *)param;
+ (NSString *)convertParaToHttpBodyStr:(NSDictionary *)dic;
+ (NSString *)assembleRequestUrl:(NSString *)param;
+ (NSString *)assembleurlWithType:(DomainType)type;
+ (NSString *)assembleXmlRequestUrl:(NSString *)actionName param:(NSString *)param;

#pragma mark - parser hyper link
+ (NSString *)parsedTextForHyperLink:(NSString *)originalText;
+ (NSString *)parsedTextForHyperLinkNoBold:(NSString *)originalText;

#pragma mark - image handlers
+ (ImageOrientationType)imageOrientationType:(UIImage *)image;
+ (UIImage*)scaleAndRotateImage:(UIImage*)sourceImage
                     sourceType:(UIImagePickerControllerSourceType)sourceType;
+ (UIImage *)resizeImage:(UIImage *)image length:(float)length square:(BOOL)square;
+ (UIImage *)cutPartImage:(UIImage *)image 
                    width:(CGFloat)width 
                   height:(CGFloat)height
                   square:(BOOL)square;
+ (UIImage *)cutPartImage:(UIImage *)image width:(CGFloat)width height:(CGFloat)height;
+ (UIImage *)cutMiddlePartImage:(UIImage *)image
                          width:(CGFloat)width
                         height:(CGFloat)height;

#pragma mark - rotate image
+ (UIImage *)rotateImage:(UIImage *)aImage;

#pragma mark - image effect handler
+ (UIImage *)effectedImageWithType:(PhotoEffectType)type originalImage:(UIImage *)originalImage;

#pragma mark - user default local storage
+ (void)saveIntegerValueToLocal:(NSInteger)value key:(NSString *)key;
+ (void)saveLongLongIntegerValueToLocal:(long long)value key:(NSString *)key;
+ (void)saveStringValueToLocal:(NSString *)value key:(NSString *)key;
+ (long long)fetchLonglongIntegerValueFromLocal:(NSString *)key;
+ (NSString *)fetchStringValueFromLocal:(NSString *)key;
+ (void)removeLocalInfoValueForKey:(NSString *)key;
+ (void)saveBoolValueToLocal:(BOOL)value key:(NSString *)key;
+ (BOOL)fetchBoolValueFromLocal:(NSString *)key;
+ (NSInteger)fetchIntegerValueFromLocal:(NSString *)key;

#pragma mark - string utilies methods
+ (NSString *)decodeForText:(NSString *)text;
+ (NSString *)replacePlusForText:(NSString *)text;
+ (NSString *)replaceSpaceForText:(NSString *)text;
+ (NSString *)decodeAndReplacePlusForText:(NSString *)text;

#pragma mark - remove html tag from string
+ (NSString *)convertingHTMLToPlainTextFromContent:(NSString *)content;

#pragma mark - md5 hash

+ (NSString*)hashStringAsMD5:(NSString*)str;

+ (void)getDeviceSystemInfo;
+ (NSString *)geneUrl:(NSString *)param itemType:(WebItemType)itemType;
+ (NSString*)geneXML:(NSString*)param;

+ (BOOL)doDelete:(NSManagedObjectContext *)MOC entityName:(NSString *)entityName;
+ (NSArray *)objectsInMOC:(NSManagedObjectContext *)MOC 
               entityName:(NSString *)entityName 
             sortDescKeys:(NSArray *)sortDescKeys 
                predicate:(NSPredicate *)predicate;
+ (NSManagedObject *)hasSameObjectAlready:(NSManagedObjectContext *)MOC 
                               entityName:(NSString *)entityName 
                             sortDescKeys:(NSArray *)sortDescKeys 
                                predicate:(NSPredicate *)predicate;
+ (BOOL)saveMOCChange:(NSManagedObjectContext *)MOC;
+ (void)unLoadObject:(NSManagedObjectContext *)MOC 
           predicate:(NSPredicate *)predicate
          entityName:(NSString *)entityName;
+ (BOOL)deleteAllObjects:(NSManagedObjectContext *)MOC;

+ (NSFetchedResultsController *)fetchObject:(NSManagedObjectContext *)aManagedObjectContext 
                   fetchedResultsController:(NSFetchedResultsController *)aFetchedResultsController
                                 entityName:(NSString *)entityName 
                         sectionNameKeyPath:(NSString *)sectionNameKeyPath 
                            sortDescriptors:(NSMutableArray *)sortDescriptors
                                  predicate:(NSPredicate *)aPredicate;

+ (NSDate *)NSStringDateToNSDate:(NSString *)string;
+ (NSString *)datetimeWithFormat:(NSString *)format datetime:(NSDate *)datetime;

+ (BOOL)objectInLocalStorage:(NSManagedObjectContext *)MOC entityName:(NSString *)entityName;

+ (BOOL)getDeviceAndOSInfo;

#pragma mark - Url encoding
+ (NSString*)stringByURLEncodingStringParameter:(NSString *)originalUrl;

#pragma mark - zip
+ (NSData *)gzipInflate:(NSData*)data;
+ (NSData *)gzipDeflate:(NSData*)data;
+ (void)saveToZipFile:(NSString *)logFilePath
        logFolderPath:(NSString *)logFolderPath
  zipNoSuffixFileName:(NSString *)zipNoSuffixFileName;

#pragma mark - create Image With Color
+ (UIImage *)createImageWithColor:(UIColor *)color;

#pragma mark - exception handler
+ (NSArray*)callstackAsArray;

#pragma mark - address book
+ (ABRecordRef)prepareContactData:(Alumni *)alumni;

#pragma mark - web view
+ (void)clearWebViewCookies;

+ (void)openWebView:(UINavigationController *)parentNavController
              title:(NSString *)title
                url:(NSString *)url
          backTitle:(NSString *)backTitle
        needRefresh:(BOOL)needRefresh
     needNavigation:(BOOL)needNavigation;

+ (void)openWebView:(UINavigationController *)parentNavController
              title:(NSString *)title
                url:(NSString *)url
          backTitle:(NSString *)backTitle
        needRefresh:(BOOL)needRefresh
     needNavigation:(BOOL)needNavigation
blockViewWhenLoading:(BOOL)blockViewWhenLoading;

#pragma mark - Share to WeChat
+ (void)shareByWeChat:(NSInteger)scene
                title:(NSString *)title
          description:(NSString *)description
                  url:(NSString *)url;

+ (void)sharePostByWeChat:(Post *)post
                    scene:(NSInteger)scene
                      url:(NSString *)url
                    image:(UIImage *)image;

+ (void)shareBrand:(Brand *)brand
             scene:(NSInteger)scene
             image:(UIImage *)image;


+ (void)shareEvent:(Event *)event
             scene:(NSInteger)scene
             image:(UIImage *)image;

+ (void)shareVideo:(Video *)video
             scene:(NSInteger)scene
             image:(UIImage *)image;

#pragma mark - connection available
+ (BOOL)isConnectionOK;

+ (BOOL)is7System;

@end
