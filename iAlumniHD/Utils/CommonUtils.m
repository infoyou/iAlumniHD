#import "CommonUtils.h"
#import "netinet/in.h"
#import "netdb.h"
#import "arpa/inet.h"
#import "sys/utsname.h"
#import "zlib.h"
#import <execinfo.h>
#import <QuartzCore/QuartzCore.h>
#import <CommonCrypto/CommonDigest.h>
#import <AddressBook/AddressBook.h>
#import "SystemConfiguration/SCNetworkReachability.h"
#import "GTMNSString+HTML.h"
#import "AppManager.h"
#import "DebugLogOutput.h"
#import "UIDevice-hardware.h"
#import "RKLMatchEnumerator.h"
#import "TextConstants.h"
#import "UnicodeUtils.h"
#import "GPUImagePicture.h"
#import "GPUImageSepiaFilter.h"
#import "GPUImageGrayscaleFilter.h"
#import "GPUImageColorInvertFilter.h"
#import "GPUImageAdaptiveThresholdFilter.h"
#import "GPUImageBoxBlurFilter.h"
#import "EncryptUtil.h"
#import "ZipFile.h"
#import "ZipWriteStream.h"
#import "ZipReadStream.h"
#import "FileInZipInfo.h"
#import "WXApi.h"
#import "Alumni.h"
#import "Post.h"
#import "Event.h"
#import "Reachability.h"
#import "Brand.h"
#import "Video.h"

#define ACT_VIEW_TAG            181
#define MIN_CELL_HEIGHT         44
#define PORTRAIT_WIDTH          447
#define LANDSCAPE_WIDTH         480
#define RADIANS( degrees )			( degrees * M_PI / 180 )

#define LOADING_LABEL_WIDTH         100.0f
#define LOADING_LABEL_HEIGHT        40.0f

#define INFOLABEL_WIDTH             150.0f
#define INFOLABEL_HEIGHT            150.0f

#define INFOIMG_WIDTH               40.0f
#define INFOIMG_HEIGHT              40.0f

#define	ACTIVITY_DURA_TIME          0.3f

#define SHADOW_HEIGHT               10.0
#define SHADOW_INVERSE_HEIGHT       5.0
#define SHADOW_RATIO (SHADOW_INVERSE_HEIGHT / SHADOW_HEIGHT)

#define BUFFER_SIZE 1024 * 100

@interface CommonUtils(private)
+ (void)fcAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
+ (void)initActivityView;
+ (NSDate *)getOffsetDateTime:(NSDate *)nowDate offset:(NSInteger)offset;
@end

@implementation CommonUtils

static NSBundle *bundle = nil;

#pragma mark - files
+ (NSString *)documentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

#pragma mark - device
+(void)getDeviceSystemInfo
{
    //here use sys/utsname.h
    struct utsname systemInfo;
    uname(&systemInfo);
    
    //get the device model and the system version
    [AppManager instance].device = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    [AppManager instance].system = [[UIDevice currentDevice] systemVersion];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    [AppManager instance].softName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    //    NSString *shortVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    [AppManager instance].version = [infoDictionary objectForKey:@"CFBundleVersion"];
    
  //[AppManager instance].releaseChannelType = APP_STORE_TYPE;
    [AppManager instance].releaseChannelType = OTA_TYPE;
}

+ (UIInterfaceOrientation)currentOrientation {
  
  /*
  UIInterfaceOrientation iOrientation = [UIApplication sharedApplication].statusBarOrientation;
  UIDeviceOrientation dOrientation = [UIDevice currentDevice].orientation;
  
  bool landscape;
  
  if (dOrientation == UIDeviceOrientationUnknown || dOrientation == UIDeviceOrientationFaceUp || dOrientation == UIDeviceOrientationFaceDown) {
    // If the device is laying down, use the UIInterfaceOrientation based on the status bar.
    landscape = UIInterfaceOrientationIsLandscape(iOrientation);
  } else {
    // If the device is not laying down, use UIDeviceOrientation.
    landscape = UIDeviceOrientationIsLandscape(dOrientation);
    
    // There's a bug in iOS!!!! http://openradar.appspot.com/7216046
    // So values needs to be reversed for landscape!
    if (dOrientation == UIDeviceOrientationLandscapeLeft) iOrientation = UIInterfaceOrientationLandscapeRight;
    else if (dOrientation == UIDeviceOrientationLandscapeRight) iOrientation = UIInterfaceOrientationLandscapeLeft;
    
    else if (dOrientation == UIDeviceOrientationPortrait) iOrientation = UIInterfaceOrientationPortrait;
    else if (dOrientation == UIDeviceOrientationPortraitUpsideDown) iOrientation = UIInterfaceOrientationPortraitUpsideDown;
  }
  
  if (landscape) {
    // Do stuff for landscape mode.
  } else {
    // Do stuff for portrait mode.
  }
  
  // Set the status bar to the right spot just in case
  [[UIApplication sharedApplication] setStatusBarOrientation:iOrientation];
  
  return iOrientation;
  */
  return [[UIApplication sharedApplication] statusBarOrientation];
}

+ (BOOL)currentOrientationIsLandscape {
    if ([self currentOrientation] == UIDeviceOrientationPortrait
        || [self currentOrientation] == UIDeviceOrientationPortraitUpsideDown) {
        return NO;
    } else {
        return YES;
    }
}

+ (NSString *)deviceModel {
	UIDevice *device = [[[UIDevice alloc] init] autorelease];
	return [device platformString];
}

+ (CGFloat)currentOSVersion {
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}

+ (CGFloat)screenWidth {
    
    if ([self currentOrientationIsLandscape]) {
        return 480.0f;
    } else {
        return LIST_WIDTH;
    }
    
}

+ (CGFloat)screenHeight {
    
    if ([self currentOrientationIsLandscape]) {
        return LIST_WIDTH;
    } else {
        return 480.0f;
    }
}

#pragma mark - system language
+ (LanguageType)currentLanguage {
    return [AppManager instance].currentLanguageCode;
}

+ (void)getDBLanguage{
    switch ([AppManager instance].currentLanguageCode) {
        case EN_TY:
        {
            [AppManager setEN];
        }
            break;
            
        default:
        {
            [AppManager setCN];
        }
            break;
    }
    
    [self setLanguage:[AppManager instance].currentLanguageDesc];
}

+ (void)getLocalLanguage {
    NSArray* preferredLangs = [NSLocale preferredLanguages];
    
	if ([((NSString *)[preferredLangs objectAtIndex:0]) rangeOfString:@"en"].length > 0) {
        [AppManager setEN];
	} else if ([((NSString *)[preferredLangs objectAtIndex:0]) rangeOfString:@"zh-Hans"].length > 0) {
        [AppManager setCN];
	} else {
        [AppManager setCN];
	}
    
    // Save
    [self setLanguage:[AppManager instance].currentLanguageDesc];
}

+ (void)setLanguage:(NSString *)languageDesc {
    
    if ([languageDesc isEqualToString:@"zh"]) {
        languageDesc = @"zh-Hans";
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:languageDesc
                                                     ofType:@"lproj" ];
    bundle = [[NSBundle bundleWithPath:path] retain];
    
    // Save languageCode
    [self saveIntegerValueToLocal:[AppManager instance].currentLanguageCode
                              key:SYSTEM_LANGUAGE_LOCAL_KEY];
}

+ (BOOL)getDeviceAndOSInfo
{
    if ([IPAD_SIMULATOR isEqualToString:[CommonUtils deviceModel]]) {
        return NO;
    }
    
    if ([[AppManager instance].system hasPrefix:@"4"]) {
        return YES;
    } else {
        return NO;
    }
    
}

+ (void)resetCurrentAppLanguage {
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    NSArray* languages = [defs objectForKey:@"AppleLanguages"];
    NSString *current = [languages objectAtIndex:0];
    [self setLanguage:current];
}

+ (NSString *)localizedStringForKey:(NSString *)key alter:(NSString *)alternate {
    return [bundle localizedStringForKey:key value:alternate table:nil];
}

#pragma mark - date time
+ (NSString *)currentHourTime {
    NSDate *today = [NSDate dateWithTimeIntervalSinceNow:0];
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd HH"];
	NSString *dateString = [dateFormat stringFromDate:today];
	[dateFormat release];
	dateFormat = nil;
	return dateString;
}

+ (NSString *)currentHourMinSecondTime {
    NSDate *today = [NSDate dateWithTimeIntervalSinceNow:0];
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	NSString *dateString = [dateFormat stringFromDate:today];
	[dateFormat release];
	dateFormat = nil;
	return dateString;
}

+ (NSDate *)convertDateTimeFromUnixTS:(NSTimeInterval)unixDate {
	return [NSDate dateWithTimeIntervalSince1970:unixDate];
}

+ (NSTimeInterval)convertToUnixTS:(NSDate *)date {
	return [date timeIntervalSince1970];
}

+ (NSString *)simpleFormatDateWithYear:(NSDate *)date secondAccuracy:(BOOL)secondAccuracy {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	switch ([self currentLanguage]) {
		case ZH_HANS_TY:
		{
			[formatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"] autorelease]];
            if (secondAccuracy) {
                [formatter setDateFormat:@"yyyy年 MM月 dd日 HH:mm"];
            } else {
                [formatter setDateFormat:@"yyyy年 MM月 dd日"];
            }
			
			break;
		}
		case EN_TY:
		{
            [formatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en"] autorelease]];
            if (secondAccuracy) {
                [formatter setDateFormat:@"dd MMM yyyy HH:mm"];
            } else {
                [formatter setDateFormat:@"dd MMM yyyy"];
            }
			
			break;
		}
		default:
			break;
	}
	
	NSString *timeline = [formatter stringFromDate:date];
    //NSString *timelineResult = [[NSString alloc] initWithFormat:@"%@",timeline];
	[formatter release];
	formatter = nil;
	
	//return timelineResult;
    return timeline;
}

+ (NSString *)simpleFormatDate:(NSDate *)date secondAccuracy:(BOOL)secondAccuracy {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	switch ([self currentLanguage]) {
		case ZH_HANS_TY:
		{
			[formatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"] autorelease]];
            if (secondAccuracy) {
                [formatter setDateFormat:@"MM月 dd日 HH:mm"];
            } else {
                [formatter setDateFormat:@"MM月 dd日"];
            }
			
			break;
		}
		case EN_TY:
		{
            [formatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en"] autorelease]];
            if (secondAccuracy) {
                [formatter setDateFormat:@"dd MMM HH:mm"];
            } else {
                [formatter setDateFormat:@"dd MMM"];
            }
			
			break;
		}
		default:
			break;
	}
	
	NSString *timeline = [formatter stringFromDate:date];
    //NSString *timelineResult = [[NSString alloc] initWithFormat:@"%@",timeline];
	[formatter release];
	formatter = nil;
	
	//return timelineResult;
    return timeline;
}

+ (NSString *)getElapsedTime:(NSDate *)timeline {
    
    NSUInteger desiredComponents = NSDayCalendarUnit | NSHourCalendarUnit
    | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    
    NSDateComponents *elapsedTimeUnits = [[NSCalendar currentCalendar] components:desiredComponents
                                                                         fromDate:timeline
                                                                           toDate:[NSDate date]
                                                                          options:0];
    // format to be used to generate string to display
    NSInteger number = 0;
    NSString *elapsedTime = nil;
    
    if ([elapsedTimeUnits day] > 0) {
        
        elapsedTime = [CommonUtils simpleFormatDate:timeline secondAccuracy:YES];
        
    } else if ([elapsedTimeUnits hour] > 0) {
        number = [elapsedTimeUnits hour];
        if (number > 1) {
            elapsedTime = [NSString stringWithFormat:@"%d %@", number, LocaleStringForKey(NSHoursAgoTitle, nil)];
        } else {
            elapsedTime = [NSString stringWithFormat:@"%d %@", number, LocaleStringForKey(NSHourAgoTitle, nil)];
        }
        
    } else if ([elapsedTimeUnits minute] > 0) {
        number = [elapsedTimeUnits minute];
        if (number > 1) {
            elapsedTime = [NSString stringWithFormat:@"%d %@", number, LocaleStringForKey(NSMinsAgoTitle, nil)];
        } else {
            elapsedTime = [NSString stringWithFormat:@"%d %@", number, LocaleStringForKey(NSMinAgoTitle, nil)];
        }
    } else if ([elapsedTimeUnits second] > 0) {
        number = [elapsedTimeUnits second];
        if (number > 1) {
            elapsedTime = [NSString stringWithFormat:@"%d %@", number, LocaleStringForKey(NSSecsAgoTitle, nil)];
        } else {
            elapsedTime = [NSString stringWithFormat:@"%d %@", number, LocaleStringForKey(NSSecAgoTitle, nil)];
        }
    } else if ([elapsedTimeUnits second] <= 0) {
        
        elapsedTime = [NSString stringWithFormat:@"1 %@", LocaleStringForKey(NSSecAgoTitle, nil)];
    }
    
    return elapsedTime;
}

+ (NSDate *)getOffsetDateTime:(NSDate *)nowDate offset:(NSInteger)offset {
	NSDateComponents *components = [[NSDateComponents alloc] init];
    
	[components setDay:offset];
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSDate *newDate = [gregorian dateByAddingComponents:components
                                                 toDate:nowDate
                                                options:0];
	
	[components release];
	components = nil;
	[gregorian release];
	gregorian = nil;
	
	return newDate;
}

+ (NSInteger)getElapsedDayCount:(NSDate *)date {
    NSDateComponents *elapsedTimeUnits = [[NSCalendar currentCalendar] components:NSDayCalendarUnit
                                                                         fromDate:date
                                                                           toDate:[NSDate date]
                                                                          options:0];
    return [elapsedTimeUnits day];
}

#pragma mark - network
+ (NSString *)assembleUrl:(NSString *)param {
	
    NSString *url;
	if (param) {
		url = [NSString stringWithFormat:@"%@%@%@", [AppManager instance].hostUrl, PHONE_CONTROLLER, param];
        
        if ([AppManager instance].sessionId && [[AppManager instance].sessionId length] > 0) {
            url = [NSString stringWithFormat:@"%@&session=%@", url, [AppManager instance].sessionId];
        }
        
        url = [NSString stringWithFormat:@"%@&lang=%@", url, [AppManager instance].currentLanguageDesc];
	} else {
        // used for "Http POST" method
		url = [NSString stringWithFormat:@"%@%@", [AppManager instance].hostUrl, PHONE_CONTROLLER];
	}
    
    return [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (NSString *)assembleRequestUrl:(NSString *)param {
    return [NSString stringWithFormat:@"%@%@%@", [AppManager instance].hostUrl, PHONE_CONTROLLER, param];
}

+ (NSString*)stringByURLEncodingStringParameter:(NSString *)originalUrl
{
    // NSURL's stringByAddingPercentEscapesUsingEncoding: does not escape
    // some characters that should be escaped in URL parameters, like / and ?;
    // we'll use CFURL to force the encoding of those
    //
    // We'll explicitly leave spaces unescaped now, and replace them with +'s
    //
    // Reference: <a href="\"http://www.ietf.org/rfc/rfc3986.txt\"" target="\"_blank\"" onclick="\"return" checkurl(this)\"="" id="\"url_2\"">http://www.ietf.org/rfc/rfc3986.txt</a>
    
    NSString *resultStr = originalUrl;
    
    CFStringRef originalString = (CFStringRef) originalUrl;
    CFStringRef leaveUnescaped = CFSTR(" ");
    CFStringRef forceEscaped = CFSTR("!*'();:@&=+$,/?%#[]");
    
    CFStringRef escapedStr;
    escapedStr = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                         originalString,
                                                         leaveUnescaped,
                                                         forceEscaped,
                                                         kCFStringEncodingUTF8);
    
    if( escapedStr ) {
        NSMutableString *mutableStr = [NSMutableString stringWithString:(NSString *)escapedStr];
        CFRelease(escapedStr);
        
        // replace spaces with plusses
        [mutableStr replaceOccurrencesOfString:@" "
                                    withString:@"%20"
                                       options:0
                                         range:NSMakeRange(0, [mutableStr length])];
        resultStr = mutableStr;
    }
    return resultStr;
}

+ (NSString *)assembleXmlRequestUrl:(NSString *)actionName param:(NSString *)param {
	
    NSString *encodedUrl = [self stringByURLEncodingStringParameter:param];//ENCODE_URL(param);
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@%@", [AppManager instance].hostUrl, PHONE_CONTROLLER, [NSString stringWithFormat:@"?action=%@&strxml=%@", actionName, encodedUrl]];
    
    return requestUrl;
}

+ (NSString *)assembleurlWithType:(DomainType)type {
    
    switch (type) {
        case LINKEDIN_DOMAIN_TY:
            return [NSString stringWithFormat:@"%@/ajax_linkedin?", [AppManager instance].hostUrl];
            
        default:
            return [self assembleUrl:nil];
    }
}

+ (NSString *) convertParaToHttpBodyStr:(NSDictionary *)dic
{
	NSArray *keys = [dic allKeys];
	NSString *res = [NSString string];
	
	for (int i = 0; i < [keys count]; i++) {
		res = [res stringByAppendingString:
               [@"--" stringByAppendingString:
                [IALUMNIHD_FORM_BOUNDARY stringByAppendingString:
                 [@"\nContent-Disposition: form-data; name=\"" stringByAppendingString:
                  [[keys objectAtIndex: i] stringByAppendingString:
                   [@"\"\r\n\r\n" stringByAppendingString:
                    [[dic valueForKey: [keys objectAtIndex:i]] stringByAppendingString:@"\r\n"]]]]]]];
        
	}
	
	return res;
}

#pragma mark - parser hyper link

+ (NSString *)parsedTextForHyperLinkNoBold:(NSString *)originalText {
    return [self parsedTextUrl:originalText needBold:NO];
}

+ (NSString *)parsedTextForHyperLink:(NSString *)originalText {
    return [self parsedTextUrl:originalText needBold:YES];
}

+ (NSString *)parsedTextUrl:(NSString *)originalText needBold:(BOOL)needBold {
    NSArray *expressions = [[[NSArray alloc] initWithObjects:
                             //@"([@#][a-zA-Z0-9]+)", // screen names, temp removed because there is no requirement for @somebody or #topic current
                             @"(((([hH][tT][tT][pP]([sS]?))\\:\\/\\/)?)([-0-9a-zA-Z]+\\.)+[a-zA-Z]{2,6}(\\:[0-9]+)?(\\/[-0-9a-zA-Z_#!:.?+=&%@~*\\';,/$]*)?)",
                             nil] autorelease];
    NSString *res = @"";
    NSRange matchRangeInOriginalText, lastRange, midRange;
    
    lastRange.location = 0;
    lastRange.length = 0;
    midRange.location = 0;
    for (NSString *expression in expressions) {
        
		NSEnumerator *enumerator = [originalText matchEnumeratorWithRegex:expression];
        NSString *match = nil;
		while (match = [enumerator nextObject]) {
            
			matchRangeInOriginalText = [originalText rangeOfString:match];
            
            NSString *link = match;
            if ([match rangeOfString:@"http" options:NSCaseInsensitiveSearch].length <= 0) {
                link = [NSString stringWithFormat:@"http://%@", match];
            }
            
            if (matchRangeInOriginalText.location < midRange.location) {
                midRange.length = 0;
            } else {
                midRange.length = matchRangeInOriginalText.location - midRange.location;
            }
            
            NSString *midStr = [originalText substringWithRange:midRange];
            if (midStr) {
                res = [res stringByAppendingString:midStr];
            }
            
            NSString *str = nil;
            if (needBold) {
                str = [NSString stringWithFormat:@"<a href=\"%@\" style=\"color:#7D9EC0;text-decoration:none;text-shadow:1px 1px 1px white;word-break:break-word\"><b>%@</b></a>", link, match];
                
            } else {
                str = [NSString stringWithFormat:@"<a href=\"%@\" style=\"font-family:ArialMT;color:#7D9EC0;text-shadow:1px 1px 1px white;word-break:break-word\">%@</a>", link, match];
            }
			res = [res stringByAppendingString:str];
            
            midRange.location = matchRangeInOriginalText.location + matchRangeInOriginalText.length;
        }
	}
    
    if (midRange.location < [originalText length]) {
        midRange.length = [originalText length] - midRange.location;
        NSString *lastStr = [originalText substringWithRange:midRange];
        res = [res stringByAppendingString:lastStr];
    }
    return res;
}

#pragma mark - rotate image
+ (UIImage *)rotateImage:(UIImage *)aImage
{
    CGImageRef imgRef = aImage.CGImage;
    UIImageOrientation takeOrient = aImage.imageOrientation;
    UIImageOrientation newOrient = UIImageOrientationUp;
    
    switch (takeOrient) {
            
        case 0://左拍 home键在右
            newOrient = UIImageOrientationUp;
            break;
            
        case 1://右拍 home键在左
            newOrient = UIImageOrientationDown;
            break;
            
        case 2://倒拍 home键在上
            newOrient = UIImageOrientationLeft;
            break;
            
        case 3://竖拍 home键在下
            newOrient = UIImageOrientationRight;
            break;
            
        default:
            newOrient = UIImageOrientationRight;
            break;
    }
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    CGFloat ratio = 0;
    
    if ((width > 1024) || (height > 1024)) {
        if (width >= height) {
            ratio = 1024/width;
        }
        else {
            ratio = 1024/height;
        }
        width *= ratio;
        height *= ratio;
    }
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    CGFloat scaleRatio = 1;
    CGFloat boundHeight;
    
    switch( newOrient )
    {
        case UIImageOrientationUp:
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationDown:
            transform = CGAffineTransformMakeTranslation(width, height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRight:
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (newOrient == UIImageOrientationRight || newOrient == UIImageOrientationLeft)
    {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    } else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

#pragma mark - image effect handler
+ (void)filterClassic:(UInt8 *)pixelBuf offset:(UInt32)offset context:(void *)context {
	int r = offset;
	int g = offset+1;
	int b = offset+2;
	
	int red = pixelBuf[r];
	int green = pixelBuf[g];
	int blue = pixelBuf[b];
	
	pixelBuf[r] = SAFECOLOR((red * 0.393) + (green * 0.769) + (blue * 0.189));
	pixelBuf[g] = SAFECOLOR((red * 0.349) + (green * 0.686) + (blue * 0.168));
	pixelBuf[b] = SAFECOLOR((red * 0.272) + (green * 0.534) + (blue * 0.131));
    
}

+ (UIImage *)effectedImageWithFilterType:(PhotoEffectType)type
                           originalImage:(UIImage *)originalImage {
    
    switch (type) {
        case CLASSIC_PHOTO_TY:
        {
            GPUImageSepiaFilter *sepiaFilter = [[[GPUImageSepiaFilter alloc] init] autorelease];
            return [sepiaFilter imageByFilteringImage:originalImage];
        }
            
        case INKWELL_PHOTO_TY:
        {
            GPUImageGrayscaleFilter *grayscaleFilter = [[[GPUImageGrayscaleFilter alloc] init] autorelease];
            
            return [grayscaleFilter imageByFilteringImage:originalImage];
        }
            
        case COLORINVERT_PHOTO_TY:
        {
            GPUImageColorInvertFilter *tempFilter = [[[GPUImageColorInvertFilter alloc] init] autorelease];
            
            return [tempFilter imageByFilteringImage:originalImage];
        }
            
        case ADAPTIVETHRESHOLD_PHOTO_TY:
        {
            GPUImageAdaptiveThresholdFilter *tempFilter = [[[GPUImageAdaptiveThresholdFilter alloc] init] autorelease];
            
            return [tempFilter imageByFilteringImage:originalImage];
        }
            
        case BOXBLUR_PHOTO_TY:
        {
            GPUImageBoxBlurFilter *tempFilter = [[[GPUImageBoxBlurFilter alloc] init] autorelease];
            
            return [tempFilter imageByFilteringImage:originalImage];
        }
            
        default:
            return originalImage;
    }
}

+ (UIImage *)effectedImageWithType:(PhotoEffectType)type
                     originalImage:(UIImage *)originalImage {
    
    return [self effectedImageWithFilterType:type
                               originalImage:originalImage];
}

+ (ImageOrientationType)imageOrientationType:(UIImage *)image {
    if (nil == image) {
        return IMG_ZERO_TY;
    }
    if (image.size.width > image.size.height) {
        return IMG_LANDSCAPE_TY;
    } else if (image.size.width < image.size.height) {
        return IMG_PORTRAIT_TY;
    } else {
        return IMG_SQUARE_TY;
    }
}

+ (BOOL)needBeScaledSize:(UIImage *)sourceImage
              targetSize:(CGSize *)targetSize
              sourceType:(UIImagePickerControllerSourceType)sourceType {
	NSString *model = [CommonUtils deviceModel];
	
	if ([model isEqualToString:IPHONE_3G_NAMESTRING] || [model isEqualToString:IPHONE_1G_NAMESTRING]) {
		if ((sourceImage.size.width <= PHOTO_LONG_LEN_1G3G &&
             sourceImage.size.height <= PHOTO_SHORT_LEN_1G3G) ||
            (sourceImage.size.width <= PHOTO_SHORT_LEN_1G3G &&
             sourceImage.size.height <= PHOTO_LONG_LEN_1G3G)) {
                
                return NO;
            } else {
                if (sourceImage.size.width < sourceImage.size.height) {
                    *targetSize = CGSizeMake(PHOTO_SHORT_LEN_1G3G, PHOTO_LONG_LEN_1G3G);
                } else {
                    *targetSize = CGSizeMake(PHOTO_LONG_LEN_1G3G, PHOTO_SHORT_LEN_1G3G);
                }
            }
		
	} else if ([model isEqualToString:IPHONE_3GS_NAMESTRING]) {
		if ((sourceImage.size.width <= PHOTO_LONG_LEN_3GS && sourceImage.size.height <= PHOTO_SHORT_LEN_3GS)
            || (sourceImage.size.width <= PHOTO_SHORT_LEN_3GS && sourceImage.size.height <= PHOTO_LONG_LEN_3GS)) {
            
			return NO;
		} else {
			if (sourceImage.size.width < sourceImage.size.height) {
				*targetSize = CGSizeMake(PHOTO_SHORT_LEN_3GS, PHOTO_LONG_LEN_3GS);
			} else {
				*targetSize = CGSizeMake(PHOTO_LONG_LEN_3GS, PHOTO_SHORT_LEN_3GS);
			}
		}
	} else if ([model isEqualToString:IPHONE_4_NAMESTRING] || [model isEqualToString:IPOD_4G_NAMESTRING] || [model isEqualToString:IPHONE_4S_NAMESTRING]) {
        
        if (sourceType == UIImagePickerControllerSourceTypeCamera
            && ((sourceImage.size.width == FRONT_PHOTO_LONG_LEN && sourceImage.size.height == FRONT_PHOTO_SHORT_LEN)
                || (sourceImage.size.width == FRONT_PHOTO_SHORT_LEN && sourceImage.size.height == FRONT_PHOTO_LONG_LEN))) {
                /*
                 * iphone4 and ipod touch 4 has front facing camera, the photo size taken by front facing camera is 640×480 or 480×640,
                 * this kind of photo need be adjusted
                 */
                return YES;
            }
        
		if ((sourceImage.size.width <= PHOTO_LONG_LEN_4G && sourceImage.size.height <= PHOTO_SHORT_LEN_4G)
            || (sourceImage.size.width <= PHOTO_SHORT_LEN_4G && sourceImage.size.height <= PHOTO_LONG_LEN_4G)) {
            
			return NO;
		} else {
			if (sourceImage.size.width < sourceImage.size.height) {
				*targetSize = CGSizeMake(PHOTO_SHORT_LEN_4G, PHOTO_LONG_LEN_4G);
			} else {
				*targetSize = CGSizeMake(PHOTO_LONG_LEN_4G, PHOTO_SHORT_LEN_4G);
			}
		}
	}
    
	return YES;
}

+ (UIImage *)scaleImage:(UIImage *)sourceImage
             sourceType:(UIImagePickerControllerSourceType)sourceType {
    CGSize targetSize = CGSizeMake(sourceImage.size.width, sourceImage.size.height);
	BOOL isNeed = [self needBeScaledSize:sourceImage targetSize:&targetSize sourceType:sourceType];
    
	if (!isNeed) {
		return sourceImage;
	}
    
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
		
        if (widthFactor > heightFactor) {
            scaleFactor = widthFactor; // scale to fit height
        }
        else {
            scaleFactor = heightFactor; // scale to fit width
        }
		
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
		
    }
	
    CGImageRef imageRef = [sourceImage CGImage];
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
	
    CGContextRef bitmap;
    if (sourceImage.imageOrientation == UIImageOrientationUp || sourceImage.imageOrientation == UIImageOrientationDown || sourceImage.imageOrientation == UIImageOrientationRight) {
        bitmap = CGBitmapContextCreate(NULL,
                                       targetWidth,
                                       targetHeight,
                                       CGImageGetBitsPerComponent(imageRef),
                                       CGImageGetBytesPerRow(imageRef),
                                       colorSpaceInfo,
                                       bitmapInfo);
    } else {
        bitmap = CGBitmapContextCreate(NULL,
                                       targetHeight,
                                       targetWidth,
                                       CGImageGetBitsPerComponent(imageRef),
                                       CGImageGetBytesPerRow(imageRef),
                                       colorSpaceInfo,
                                       bitmapInfo);
    }
    
    // ENHANCEMENT FOR NEW IMAGE PORITION Y ADJUSTMENT:
	float newImage_x = 0.0f;
	if (sourceImage.imageOrientation == UIImageOrientationRight
        || sourceImage.imageOrientation == UIImageOrientationLeft) {
		if (targetWidth < targetHeight) {
			newImage_x = targetWidth - targetHeight;
		}
	}
    
    CGContextDrawImage(bitmap, CGRectMake(newImage_x, 0, scaledWidth, scaledHeight), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* newImage = [UIImage imageWithCGImage:ref];
	
    CGContextRelease(bitmap);
    CGImageRelease(ref);
	
    return newImage;
    
}

+ (UIImage*)scaleAndRotateImage:(UIImage*)sourceImage
                     sourceType:(UIImagePickerControllerSourceType)sourceType
{
	CGSize targetSize = CGSizeMake(sourceImage.size.width, sourceImage.size.height);
	BOOL isNeed = [self needBeScaledSize:sourceImage targetSize:&targetSize sourceType:sourceType];
    
	if (!isNeed) {
		return sourceImage;
	}
	
	CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
	
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
		
        if (widthFactor > heightFactor) {
            scaleFactor = widthFactor; // scale to fit height
        }
        else {
            scaleFactor = heightFactor; // scale to fit width
        }
		
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
		
        // center the image
        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
	
    CGImageRef imageRef = [sourceImage CGImage];
    //CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGColorSpaceCreateDeviceRGB();//CGImageGetColorSpace(imageRef);
    
    CGContextRef bitmap;
    if (sourceImage.imageOrientation == UIImageOrientationUp || sourceImage.imageOrientation == UIImageOrientationDown || sourceImage.imageOrientation == UIImageOrientationRight) {
        bitmap = CGBitmapContextCreate(NULL,
                                       (int)targetWidth,
                                       (int)targetHeight,
                                       CGImageGetBitsPerComponent(imageRef),
                                       (4 * targetWidth),
                                       colorSpaceInfo,
                                       /*bitmapInfo*/kCGImageAlphaPremultipliedFirst);
    } else {
        bitmap = CGBitmapContextCreate(NULL,
                                       (int)targetHeight,
                                       (int)targetWidth,
                                       CGImageGetBitsPerComponent(imageRef),
                                       (4 * targetWidth),
                                       colorSpaceInfo,
                                       /*bitmapInfo*/kCGImageAlphaPremultipliedFirst);
    }
    
    CGColorSpaceRelease(colorSpaceInfo);
    
    // In the right or left cases, we need to switch scaledWidth and scaledHeight,
    // and also the thumbnail point
    if (sourceImage.imageOrientation == UIImageOrientationLeft) {
        
        CGFloat oldScaledWidth = scaledWidth;
        scaledWidth = scaledHeight;
        scaledHeight = oldScaledWidth;
		
        CGContextRotateCTM (bitmap, RADIANS(90));
        CGContextTranslateCTM (bitmap, 0, -targetHeight);
		
    } else if (sourceImage.imageOrientation == UIImageOrientationRight) {
        
        CGFloat oldScaledWidth = scaledWidth;
        scaledWidth = scaledHeight;
        scaledHeight = oldScaledWidth;
		
        CGContextRotateCTM (bitmap, RADIANS(-90));
        CGContextTranslateCTM (bitmap, -targetWidth, 0);
		
    } else if (sourceImage.imageOrientation == UIImageOrientationUp) {
        // NOTHING
    } else if (sourceImage.imageOrientation == UIImageOrientationDown) {
        CGContextTranslateCTM (bitmap, targetWidth, targetHeight);
        CGContextRotateCTM (bitmap, RADIANS(-180.));
    }
	
	// ENHANCEMENT FOR NEW IMAGE PORITION Y ADJUSTMENT:
	float newImage_x = 0.0f;
	if (sourceImage.imageOrientation == UIImageOrientationRight) {
		if (targetWidth < targetHeight) {
			newImage_x = targetWidth - targetHeight;
		}
	}
	
    CGContextSetInterpolationQuality(bitmap, kCGInterpolationHigh);
    
    CGContextDrawImage(bitmap, CGRectMake(newImage_x, 0, scaledWidth, scaledHeight), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* newImage = [UIImage imageWithCGImage:ref];
	
    CGContextRelease(bitmap);
    CGImageRelease(ref);
	
    return newImage;
}

+ (UIImage *)resizeImage:(UIImage *)image
                   width:(CGFloat)width
                  height:(CGFloat)height
               minLength:(CGFloat)minLength {
    
    if (nil == image) {
        return nil;
    }
    
    UIImage *scaledImage = nil;
    
    CGRect destRect = CGRectMake(0, 0, width, height);
    CGRect sourceRect = CGRectMake(0, 0, image.size.width, image.size.height);
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
	if ([CommonUtils currentOSVersion] >= IOS4) {
        
        // 0.0 for scale means "correct scale for device's main screen".
		UIGraphicsBeginImageContextWithOptions(CGSizeMake(minLength, minLength), NO, 0.0);
        
        // cropping happens here.
		CGImageRef sourceImg = CGImageCreateWithImageInRect(image.CGImage, sourceRect);
        
        // create cropped UIImage.
		scaledImage = [UIImage imageWithCGImage:sourceImg scale:0.0 orientation:image.imageOrientation];
        
        // the actual scaling happens here, and orientation is taken care of automatically.
		[scaledImage drawInRect:destRect];
        
		CGImageRelease(sourceImg);
		scaledImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
	}
#endif
	if (!scaledImage) {
		// Try older method.
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, (width * 4),
                                                     colorSpace, kCGImageAlphaPremultipliedLast);
		CGImageRef sourceImg = CGImageCreateWithImageInRect(image.CGImage, sourceRect);
		CGContextDrawImage(context, destRect, sourceImg);
		CGImageRelease(sourceImg);
		CGImageRef finalImage = CGBitmapContextCreateImage(context);
		CGContextRelease(context);
		CGColorSpaceRelease(colorSpace);
		scaledImage = [UIImage imageWithCGImage:finalImage];
		CGImageRelease(finalImage);
	}
    return scaledImage;
}

+ (UIImage *)resizeImage:(UIImage *)image length:(float)length square:(BOOL)square {
    // Resize image if needed.
    float width  = image.size.width;
    float height = image.size.height;
    
    // fail safe
    if (width == 0 || height == 0)
        return image;
	
	float scale;
    if (square) {
        return [self resizeImage:image width:length height:length minLength:length];
    } else {
        if (width > length || height > length) {

            if (width > height) {
                scale = length / height;
                width *= scale;
                height = length;
            } else {
                scale = length / width;
                height *= scale;
                width = length;
            }

            return [self resizeImage:image width:width height:height minLength:length];
        }
        
        return image;
    }
}

+ (UIImage *)cutPartImage:(UIImage *)image
                    width:(CGFloat)width
                   height:(CGFloat)height
                   square:(BOOL)square {

    float imageWidth  = image.size.width;
    float imageHeight = image.size.height;
    
    if (imageWidth == 0 || imageHeight == 0) {
        return nil;
    }
    
    if (imageHeight < width || imageHeight < height) {
        return image;
    } else {
        CGFloat minLength = 0.0f;
        switch ([CommonUtils imageOrientationType:image]) {
            case IMG_LANDSCAPE_TY:
                minLength = width;
                break;
                
            case IMG_PORTRAIT_TY:
                minLength = height;
                break;
                
            default:
                minLength = height;
                break;
        }
        
        return [self resizeImage:image
                          length:minLength
                          square:square];
    }
}

+ (UIImage *)cutPartImage:(UIImage *)image width:(CGFloat)width height:(CGFloat)height {

    return [self cutPartImage:image width:width height:height square:NO];
}

+ (UIImage *)cutMiddlePartImage:(UIImage *)image
                          width:(CGFloat)width
                         height:(CGFloat)height {
    
    float imageWidth  = image.size.width;
    float imageHeight = image.size.height;
    
    if (imageWidth == 0 || imageHeight == 0) {
        return nil;
    }
    
    CGRect sourceRect = CGRectZero;
    
    CGFloat y = 0;
    CGFloat x = 0;
    
    CGFloat croppedWidth = image.size.width;
    CGFloat croppedHeight = image.size.height;
    
    // check current display area orientation
    // aspect ratio: areaHeight/areaWidth = croppedHeight/imageWidth
    if (width > height) {
        
        // display area is landscape, regardless of the image orientation, we should crop the middle part in vertical direction
        croppedHeight = (height * image.size.width)/width;
        y = (image.size.height - croppedHeight)/2.0f;
        
    } else {
        
        // display area is portrait or square, regardless of the image orientation, we should crop the middle part in horizontal direction
        croppedWidth = (width * image.size.height)/height;
        x = (image.size.width - croppedWidth)/2.0f;
    }
    
    sourceRect = CGRectMake(x, y, croppedWidth, croppedHeight);
    
    // cropping happens here.
    CGImageRef sourceImg = CGImageCreateWithImageInRect(image.CGImage, sourceRect);
    
    // create cropped UIImage.
    UIImage *scaledImage = [UIImage imageWithCGImage:sourceImg];
    
    CGImageRelease(sourceImg);
    
    return scaledImage;
}

#pragma mark - address book
+ (NSString*) telFilter:(NSString*) phoneNO
{
    phoneNO = [phoneNO stringByReplacingOccurrencesOfString:@"-" withString:@""];
    phoneNO = [phoneNO stringByReplacingOccurrencesOfString:@"(" withString:@""];
    phoneNO = [phoneNO stringByReplacingOccurrencesOfString:@")" withString:@""];
    phoneNO = [phoneNO stringByReplacingOccurrencesOfString:@"+" withString:@""];
    phoneNO = [phoneNO stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    //  NSLog(@"phoneNO is %@",phoneNO);
    return phoneNO;
}

+ (void)appenSpace:(NSMutableString **)str {
    if ((*str).length > 0) {
        [(*str) appendString:@", "];
    }
}

+ (void)assemblePhoneNumber:(id)person phoneNumberStr:(NSMutableString **)phoneNumberStr {
    ABMultiValueRef phones = (ABMultiValueRef) ABRecordCopyValue(person, kABPersonPhoneProperty);
    if (nil == phones) {
        return;
    }
    int phonesCount = ABMultiValueGetCount(phones);
    
    for(int i = 0 ;i < phonesCount;i++)
    {
        NSString *phoneNO = [(NSString*)ABMultiValueCopyValueAtIndex(phones, i) autorelease];
        
        phoneNO = [self telFilter:phoneNO];
        
        [(*phoneNumberStr) appendString:phoneNO];
        
        if (i != phonesCount-1) {
            [(*phoneNumberStr) appendString:@","];
        }
        
    }
    
    CFRelease(phones);
}

+ (void)assembleEmails:(id)person emailStr:(NSMutableString **)emailStr {
    ABMultiValueRef mails = (ABMultiValueRef) ABRecordCopyValue(person, kABPersonEmailProperty);
    if (nil == mails) {
        return;
    }
    int mailsCount = ABMultiValueGetCount(mails);
    
    for(int i = 0 ;i < mailsCount;i++)
    {
        NSString *mailNO = [(NSString *)ABMultiValueCopyValueAtIndex(mails, i) autorelease];
        [(*emailStr) appendString: mailNO];
        
        if (i != mailsCount-1) {
            [(*emailStr) appendString:@","];
        }
    }
    
    CFRelease(mails);
}

#pragma mark - user default local storage
+ (void)saveIntegerValueToLocal:(NSInteger)value key:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:value]
                                              forKey:key];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)saveLongLongIntegerValueToLocal:(long long)value key:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLongLong:value]
                                              forKey:key];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)saveStringValueToLocal:(NSString *)value key:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setObject:value
                                              forKey:key];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)saveBoolValueToLocal:(BOOL)value key:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:value]
                                              forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSInteger)fetchIntegerValueFromLocal:(NSString *)key {
    NSNumber *number = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (nil == number) {
        return 0;
    } else {
        return number.intValue;
    }
}

+ (long long)fetchLonglongIntegerValueFromLocal:(NSString *)key {
    NSNumber *number = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:key];
    return number.longLongValue;
}

+ (NSString *)fetchStringValueFromLocal:(NSString *)key {
    return (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:key];
}

+ (BOOL)fetchBoolValueFromLocal:(NSString *)key {
    NSNumber *number = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:key];
    return number.boolValue;
}

+ (void)removeLocalInfoValueForKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - string utilies methods
+ (NSString *)decodeForText:(NSString *)text {
    if (text) {
        return [text stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    } else {
        return nil;
    }
}

+ (NSString *)replaceHtmlSpecialChar:(NSString *)text {
    return [text stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
}

+ (NSString *)replacePlusForText:(NSString *)text {
    if (text) {
        return [text stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    } else {
        return nil;
    }
}

+ (NSString *)decodeAndReplacePlusForText:(NSString *)text {
    if (text && text.length > 0) {
        text = [self replaceHtmlSpecialChar:text];
        NSString *decodedText = [self decodeForText:text];
        
        if (nil == decodedText) {
            decodedText = text;
        }
        
        return [self replacePlusForText:decodedText];
    } else {
        return nil;
    }
}

+ (NSString *)replaceSpaceForText:(NSString *)text {
    if (text) {
        return [text stringByReplacingOccurrencesOfString:@" " withString:@""];
    } else {
        return nil;
    }
}

#pragma mark - remove html tag from string
+ (NSString *)stringByDecodingHTMLEntitiesFromContent:(NSMutableString *)content {
    // Can return self so create new string if we're a mutable string
    return [NSString stringWithString:[content gtm_stringByUnescapingFromHTML]];
}

+ (NSString *)convertingHTMLToPlainTextFromContent:(NSString *)content {
    
    if (nil == content || 0 == content.length) {
        return nil;
    }
    
	// Pool
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
	// Character sets
	NSCharacterSet *stopCharacters = [NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@"< \t\n\r%d%d%d%d", 0x0085, 0x000C, 0x2028, 0x2029]];
	NSCharacterSet *newLineAndWhitespaceCharacters = [NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@" \t\n\r%d%d%d%d", 0x0085, 0x000C, 0x2028, 0x2029]];
	NSCharacterSet *tagNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"];
    
	// Scan and find all tags
	NSMutableString *result = [[NSMutableString alloc] initWithCapacity:content.length];
	NSScanner *scanner = [[NSScanner alloc] initWithString:content];
	[scanner setCharactersToBeSkipped:nil];
	[scanner setCaseSensitive:YES];
	NSString *str = nil, *tagName = nil;
	BOOL dontReplaceTagWithSpace = NO;
	do {
        
		// Scan up to the start of a tag or whitespace
		if ([scanner scanUpToCharactersFromSet:stopCharacters intoString:&str]) {
			[result appendString:str];
			str = nil; // reset
		}
        
		// Check if we've stopped at a tag/comment or whitespace
		if ([scanner scanString:@"<" intoString:NULL]) {
            
			// Stopped at a comment or tag
			if ([scanner scanString:@"!--" intoString:NULL]) {
                
				// Comment
				[scanner scanUpToString:@"-->" intoString:NULL];
				[scanner scanString:@"-->" intoString:NULL];
                
			} else {
                
				// Tag - remove and replace with space unless it's
				// a closing inline tag then dont replace with a space
				if ([scanner scanString:@"/" intoString:NULL]) {
                    
					// Closing tag - replace with space unless it's inline
					tagName = nil; dontReplaceTagWithSpace = NO;
					if ([scanner scanCharactersFromSet:tagNameCharacters intoString:&tagName]) {
						tagName = [tagName lowercaseString];
						dontReplaceTagWithSpace = ([tagName isEqualToString:@"a"] ||
                                                   [tagName isEqualToString:@"b"] ||
                                                   [tagName isEqualToString:@"i"] ||
                                                   [tagName isEqualToString:@"q"] ||
                                                   [tagName isEqualToString:@"span"] ||
                                                   [tagName isEqualToString:@"em"] ||
                                                   [tagName isEqualToString:@"strong"] ||
                                                   [tagName isEqualToString:@"cite"] ||
                                                   [tagName isEqualToString:@"abbr"] ||
                                                   [tagName isEqualToString:@"acronym"] ||
                                                   [tagName isEqualToString:@"label"]);
					}
                    
					// Replace tag with string unless it was an inline
					if (!dontReplaceTagWithSpace && result.length > 0 && ![scanner isAtEnd]) [result appendString:@" "];
                    
				}
                
				// Scan past tag
				[scanner scanUpToString:@">" intoString:NULL];
				[scanner scanString:@">" intoString:NULL];
                
			}
            
		} else {
            
			// Stopped at whitespace - replace all whitespace and newlines with a space
			if ([scanner scanCharactersFromSet:newLineAndWhitespaceCharacters intoString:NULL]) {
				if (result.length > 0 && ![scanner isAtEnd]) [result appendString:@" "]; // Dont append space to beginning or end of result
			}
            
		}
        
	} while (![scanner isAtEnd]);
    
	// Cleanup
	[scanner release];
    
	// Decode HTML entities and return
	NSString *retString = [[self stringByDecodingHTMLEntitiesFromContent:result] retain];
	[result release];
    
	// Drain
	[pool drain];
    
	// Return
	return [retString autorelease];
    
}



#pragma mark - sha1 hash
+ (NSString*)sha1:(NSString*)input
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

#pragma mark - md5 hash

+ (NSString*)hashStringAsMD5:(NSString*)str {
    
	const char *concat_str = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(concat_str, strlen(concat_str), result);
    NSMutableString *hash = [NSMutableString string];
    
	for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++){
        [hash appendFormat:@"%02X", result[i]];
	}
    
	return [hash lowercaseString];
}

#pragma mark - Gene XML
+ (NSString*)geneXML:(NSString*)param
{
    NSString *result = [NSString stringWithFormat:@"%@%@%@%@%@<plat>%@</plat><channel>%d</channel><system>%@</system><version>%@</version><device_token>%@</device_token><user_id>%@</user_id><user_name>%@</user_name><person_id>%@</person_id><user_type>%@</user_type><session_id>%@</session_id><class_id>%@</class_id><class_name>%@</class_name><connect_id>%@</connect_id>%@%@", REQ_XML_HEADER, REQ_CTNT_TAG_HEADER, REQ_LOCALE_TAG_HEADER, [AppManager instance].currentLanguageDesc, REQ_LOCALE_TAG_END, PLATFORM, [AppManager instance].releaseChannelType, [AppManager instance].system, VERSION, [AppManager instance].deviceToken, [AppManager instance].userId, [AppManager instance].username, [AppManager instance].personId, [AppManager instance].userType, [AppManager instance].sessionId, [AppManager instance].classGroupId, [AppManager instance].className, [AppManager instance].deviceConnectionIdentifier, param, REQ_CTNT_TAG_END];
    
    return result;
}

#pragma mark - Gene Url
+ (NSString *)geneUrl:(NSString *)param itemType:(WebItemType)itemType
{
    NSString *url = nil;
    
    if (itemType == IMAGE_TY) {
        return param;
    }
    
    switch (itemType) {
            
        case CHECK_VERSION_TY:
        {
            url = SOFT_VERSION_CHECK_URL;
            break;
        }
            
        // Use get method, No xml param.
        case LOGIN_TY:
        {
            url = [NSString stringWithFormat:@"%@%@&%@&locale=%@",
                   [AppManager instance].hostUrl,
                   ALUMNI_LOGIN_REQ_URL,
                   //  ALUMNI_AUTO_LOGIN_REQ_URL,
                   param,
                   [AppManager instance].currentLanguageDesc];
            break;
            
        }
            
        case LOAD_SYS_MESSAGE_TY:
        {
            url = [NSString stringWithFormat:@"%@&locale=%@",
                   SYSTEM_MSG_URL,
                   [AppManager instance].currentLanguageDesc];
            break;
        }
            
            // Use get method, No xml param.
        case EVENT_ALUMNI_DETAIL_TY:
            url = ALUMNI_DETAIL_URL;
            break;
            
        case ALUMNI_REPORT_TY:
        {
            url = ALUMNI_NEWS_PAST_REQ_URL;
            break;
        }
            
        case ALUMNI_UPCOMING_TY:
        {
            url = ALUMNI_EVENT_Future_REQ_URL;
            break;
        }
            
            // Event
        case EVENT_FLITER_TY:
        {
            url = EVENT_FLITER_URL;
            break;
        }
            
        case EVENTLIST_TY:
        {
            url = ALUMNI_EVENT_REQ_URL;
            break;
        }
            
        case EVENTDETAIL_TY:
        {
            url = EVENT_DETAIL_URL;
            break;
        }
            
        case CHECKIN_TY:
        {
            url = EVENT_CHECK_IN_URL;
            break;
        }
            
        case EVENT_CHECK_IN_UPDATE_TY:
        {
            url = EVENT_CHECK_IN_UPDATE_URL;
            break;
        }
            
        case ADMIN_CHECK_IN_TY:
        {
            url = EVENT_ADMIN_CHECK_IN_URL;
            break;
        }
            
        case EVENT_ADMIN_CHECK_SMS_TY:
        {
            url = EVENT_ADMIN_CHECK_SMS_URL;
            break;
        }
            
        case CLUBLIST_TY:
        case LOAD_JOINED_GROUPS_TY:
        {
            url = CLUB_LIST_URL;
            break;
        }
            
        case ALUMNI_TY:
        {
            url = ALUMNI_QUERY_REQ_URL;
            break;
        }
            
        case EVENT_CITY_LIST_TY:
            url = EVENT_CITY_LIST_URL;
            break;
            
        case CLASS_TY:
            url = ALUMNI_CLASS_REQ_URL;
            break;
            
        case COUNTRY_TY:
            url = ALUMNI_NATION_REQ_URL;
            break;
            
        case INDUSTRY_TY:
            url = ALUMNI_INDUSTRY_REQ_URL;
            break;
            
        case IMAGE_TY:
            // TODO 图片添加参数
            url = [NSString stringWithFormat:@"%@&username=%@&sessionId=%@",
                   param,
                   [EncryptUtil TripleDES:[AppManager instance].userId
                         encryptOrDecrypt:kCCEncrypt],
                   [EncryptUtil TripleDES:[AppManager instance].sessionId
                         encryptOrDecrypt:kCCEncrypt]];
            break;
            
        case SIGNUP_USER_TY:
            url = EVENT_APPLY_URL;
            break;
            
        case CHECKIN_USER_TY:
            url = EVENT_CHECKIN_URL;
            break;
            
        case WINNER_USER_TY:
            url = EVENT_WINNER_URL;
            break;
            
        case MODIFY_MOBILE_TY:
            url = MODIFY_MOBILE_URL;
            break;
            
        case MODIFY_EMAIL_TY:
            url = MODIFY_EMAIL_URL;
            break;
            
            // Feedback
        case FETCH_FEEDBACK_SUBMIT_TY:
            url = SOFT_FEEDBACK_SUBMIT_URL;
            break;
            
            // Club
        case SPONSOR_TY:
            url = EVENT_SPONSOR_URL;
            break;
            
        case CLUB_DETAIL_SIMPLE_TY:
            url = CLUB_DETAIL_SIMPLE_URL;
            break;
            
        case CLUB_FLITER_TY:
            url = CLUB_FLITER_URL;
            break;
            
        case CLUB_USER_DETAIL_TY:
            url = CLUB_USER_DETAIL_URL;
            break;
            
        case CLUB_JOIN_TY:
            url = CLUB_JOIN_URL;
            break;
            
        case CLUB_QUIT_TY:
            url = CLUB_QUIT_URL;
            break;
            
        case CLUB_APPROVE_TY:
            url = CLUB_APPROVE_URL;
            break;
            
        case CLUB_MANAGE_USER_TY:
            url = CLUB_MANAGE_USER_URL;
            break;
            
        case CLUB_MANAGE_QUERY_USER_TY:
            url = CLUB_MANAGE_QUERY_USER_URL;
            break;
            
        case CLUB_POST_LIST_TY:
        case SHARE_POST_LIST_TY:
        case LOAD_BIZ_POST_TY:
            url = CLUB_POST_LIST_URL;
            break;
            
        case SEND_POST_TY:
            url = POST_URL;
            break;
            
        case POST_TAG_LIST_TY:
            url = POST_TAG_LIST_URL;
            break;
            
        case POST_FAVORITE_ACTION_TY:
            url = POST_FAVORITE_ACTION_URL;
            break;
            
        case POST_UNFAVORITE_ACTION_TY:
            url = POST_UNFAVORITE_ACTION_URL;
            break;
            
        case POST_LIKE_ACTION_TY:
            url = POST_LIKE_ACTION_URL;
            break;
            
        case POST_UNLIKE_ACTION_TY:
            url = POST_UNLIKE_ACTION_URL;
            break;
            
        case POST_LIKE_USER_LIST_TY:
            url = POST_LIKE_USERS_LIST_URL;
            break;
            
        case SEND_COMMENT_TY:
            url = SEND_COMMENT_URL;
            break;
            
        case COMMENT_LIST_TY:
            url = COMMENT_LIST_URL;
            break;
            
        case SHAKE_USER_LIST_TY:
        case LOAD_NAME_CARD_CANDIDATES_TY:
            url = SHAKE_USER_LIST_URL;
            break;
            
        case SHAKE_PLACE_THING_TY:
            url = SHAKE_PLACE_THING_URL;
            break;
            
        case LOAD_NEARBY_PLACE_LIST_TY:
            url = NEARBY_PLACE_LIST_URL;
            break;
            
        case CHART_LIST_TY:
            url = CHART_LIST_URL;
            break;
            
        case CHAT_USER_LIST_TY:
            url = CHART_USER_LIST_URL;
            break;
            
        case CHAT_SUBMIT_TY:
            url = CHART_SUBMIT_URL;
            break;
            
        case VIDEO_TY:
            url = VIDEO_URL;
            break;
            
        case VIDEO_FILTER_TY:
            url = VIDEO_FILTER_URL;
            break;
            
        case VIDEO_CLICK_TY:
            url = VIDEO_CLICK_URL;
            break;
            
        case DELETE_POST_TY:
            url = DELETE_SHARE_POST_URL;
            break;
            
        case DELETE_COMMENT_TY:
            url = DELETE_COMMENT_URL;
            break;
            
        case AD_TY:
            url = AD_URL;
            break;
            
        case LOAD_SERVICE_CATEGORY_TY:
            url = SERVICE_CATEGORY_URL;
            break;
            
        case LOAD_SERVICE_ITEM_TY:
            url = SERVICE_ITEM_URL;
            break;
            
        case LOAD_SERVICE_ITEM_DETAIL_TY:
            url = SERVICE_ITEM_DETAIL_URL;
            break;
            
        case LOAD_SERVICE_ITEM_COMMENT_TY:
        case LOAD_BRAND_COMMENT_TY:
            url = SERVICE_ITEM_COMMENT_URL;
            break;
            
        case LOAD_VIDEO_COMMENT_TY:
            url = LOAD_VIDEO_COMMENT_URL;
            break;
            
        case LOAD_LIKERS_TY:
            url = SERVICE_ITEM_LIKERS_URL;
            break;
            
        case LOAD_SERVICE_ITEM_ALBUM_PHOTO_TY:
            url = SERVICE_ITEM_PHOTO_URL;
            break;
            
        case LOAD_RECOMMENDED_ITEM_TY:
            url = SERVICE_RECOMMENDED_ITEM_URL;
            break;
            
        case LOAD_RECOMMENDED_ITEM_LIKERS_TY:
            url = RECOMMENDED_ITEM_LIKERS_URL;
            break;
            
        case ITEM_FAVORITE_TY:
            url = SERVICE_ITEM_FAVORITE_URL;
            break;
            
        case ITEM_LIKE_TY:
            url = SERVICE_ITEM_LIKE_URL;
            break;
            
        case RECOMMENDED_ITEM_LIKE_TY:
            url = RECOMMENDED_ITEM_LIKE_URL;
            break;
            
        case LOAD_CHECKEDIN_ALUMNUS_TY:
            url = SERVICE_ITEM_CHECKEDIN_URL;
            break;
            
        case ITEM_CHECKIN_TY:
            url = SERVICE_ITEM_CHECKIN_URL;
            break;
            
        case LOAD_BRANDS_TY:
            url = BRANDS_URL;
            break;
            
        case LOAD_BRAND_ALUMNUS_TY:
            url = BRAND_ALUMNUS_URL;
            break;
            
        case LOAD_BRAND_DETAIL_TY:
            url = BRAND_DETAIL_URL;
            break;
            
        case EVENT_POST_TY:
            url = EVENT_DISCUSS_POST_URL;
            break;
            
        case LOAD_EVENT_TOPICS_TY:
            url = EVENT_TOPIC_LIST_URL;
            break;
            
        case LOAD_EVENT_OPTIONS_TY:
            url = TOPIC_OPTION_LIST_URL;
            break;
            
        case SUBMIT_OPTION_TY:
            url = SUBMIT_OPTION_URL;
            break;
            
        case LOAD_WINNER_AWARDS_TY:
            url = LOAD_WINNER_AWARDS_URL;
            break;
            
            // alumni network
        case LOAD_WITH_ME_LINK_TY:
            url = WITH_ME_LINK_URL;
            break;
            
        case LOAD_ALL_KNOWN_ALUMNUS_TY:
            url = ALL_KNOWN_ALUMNUS_URL;
            break;
            
        case FAVORITE_ALUMNI_TY:
            url = FAVORITE_ALUMNI_URL;
            break;
            
        case LOAD_CONNECTED_ALUMNUS_COUNT_TY:
            url = CONNECTED_ALUMNUS_COUNT_URL;
            break;
            
        case LOAD_ATTRACTIVE_ALUMNUS_TY:
            url = ATTRACTIVE_ALUMNUS_URL;
            break;
            
        case LOAD_KNOWN_ALUMNUS_TY:
            url = KNOWN_ALUMNUS_URL;
            break;
            
        case LOAD_ALUMNI_NEWS_TY:
        case LOAD_NEWS_REPORT_TY:
            url = ALUMNI_NEWS_URL;
            break;
            
            // biz coop
        case LOAD_BIZ_GROUPS_TY:
            url = BIZ_GROUP_URL;
            break;
            
            // event
        case LOAD_EVENT_AWARD_RESULT_TY:
            url = EVENT_AWARD_URL;
            break;

            //event_apply_questions
        case EVENT_APPLY_QUESTIONS_TY:
            url = EVENT_APPLY_QUESTIONS_URL;
            break;
            
        case SENT_QUESTIONS_RESULT_TY:
            url = SENT_QUESTIONS_RESULT_URL;
            break;
            
        case EVENT_SIGNUP_TY:
            url = EVENT_SIGNUP_URL;
            break;
            
        case SURVEY_DATA_TY:
            url = SURVEY_DATA_URL;
            break;
            
            // pay
        case PAY_DATA_TY:
            url = PAY_DATA_URL;
            break;

            // startup project
        case STARTUP_QUESTIONS_TY:
            url = STARTUP_QUESTIONS_URL;
            break;
            
        case STARTUP_RESULT_SUBMIT_TY:
            url = STARTUP_RESULT_SUBMIT_URL;
            break;
            
        case LOAD_PROJECT_BACKERS_TY:
            url = LOAD_PROJECT_BACKERS_URL;
            break;
            
        default:
            break;
    }
    
    if (param) {
        NSString *reqContent = [self geneXML:param];
        reqContent = [reqContent stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
        if ([url hasPrefix:@"http://"]) {
            url = [NSString stringWithFormat:@"%@&ReqContent=%@", url, reqContent];
        }else{
            url = [NSString stringWithFormat:@"%@%@&ReqContent=%@", [AppManager instance].hostUrl, url, reqContent];
        }
    }
    
    return url;
    
}

#pragma mark - delete all objects

+ (BOOL)doDelete:(NSManagedObjectContext *)MOC
      entityName:(NSString *)entityName
       predicate:(NSPredicate *)predicate
{
	NSFetchRequest * fetch = [[[NSFetchRequest alloc] init] autorelease];
    if (predicate) {
        fetch.predicate = predicate;
    }
	[fetch setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:MOC]];
	NSError *error = nil;
	NSArray *result = [MOC executeFetchRequest:fetch error:&error];
	if ([result count] ==  0) {
		return YES;
	}
    
	if (!error) {
		for (id object in result) {
			[MOC deleteObject:object];
		}
		
		if (![MOC save:&error]) {
            NSLog(@"Delete all %@ failed: %@", entityName, [error domain]);
			debugLog(@"Delete all %@ failed: %@", entityName, [error domain]);
			return NO;
		} else {
			return YES;
		}
	} else {
		debugLog(@"Delete all %@ failed: %@", entityName, [error domain]);
		return NO;
	}
}

+ (BOOL)doDelete:(NSManagedObjectContext *)MOC entityName:(NSString *)entityName
{
	return [self doDelete:MOC entityName:entityName predicate:nil];
}

+ (BOOL)deleteAllObjects:(NSManagedObjectContext *)MOC
{
    [AppManager instance].isLoadClassDataOK = NO;
    [AppManager instance].isLoadIndustryDataOK = NO;
    [AppManager instance].isLoadCountryDataOK = NO;
    [AppManager instance].isLoadHomeGroupDataOK = NO;
    [AppManager instance].isLoadADDataOK = NO;
    
    if (![self doDelete:MOC entityName:@"Report"]) {
		return NO;
	} else if (![self doDelete:MOC entityName:@"Upcoming"]) {
		return NO;
	} else if (![self doDelete:MOC entityName:@"ClassGroup"]) {
		return NO;
	} else if (![self doDelete:MOC entityName:@"Industry"]) {
		return NO;
	} else if (![self doDelete:MOC entityName:@"UserCountry"]) {
		return NO;
	} else if (![self doDelete:MOC
                    entityName:@"ItemGroup"
                     predicate:[NSPredicate predicateWithFormat:@"(usageType == %d)", HOME_USAGE_TY]]) {
		return NO;
	}
    
	return YES;
}

+ (NSArray *)objectsInMOC:(NSManagedObjectContext *)MOC
               entityName:(NSString *)entityName
             sortDescKeys:(NSArray *)sortDescKeys
                predicate:(NSPredicate *)predicate {
    
	NSFetchRequest *fetchRequest1 = [[[NSFetchRequest alloc] init] autorelease];
	[fetchRequest1 setEntity:[NSEntityDescription entityForName:entityName
                                         inManagedObjectContext:MOC]];
	[fetchRequest1 setPredicate:predicate];
    [fetchRequest1 setSortDescriptors:sortDescKeys];
    //	[fetchRequest1 setFetchLimit:1];
	
	NSError *error = nil;
	NSArray *objects = [MOC executeFetchRequest:fetchRequest1
                                          error:&error] ;
	return objects;
}

+ (NSManagedObject *)hasSameObjectAlready:(NSManagedObjectContext *)MOC
                               entityName:(NSString *)entityName
                             sortDescKeys:(NSArray *)sortDescKeys
                                predicate:(NSPredicate *)predicate {
	
	NSArray *objects = [self objectsInMOC:MOC entityName:entityName sortDescKeys:sortDescKeys predicate:predicate];
	
	if ([objects count] == 0) {
		return nil;
	}
	
	return (NSManagedObject *)objects[0];
}

+ (BOOL)saveMOCChange:(NSManagedObjectContext *)MOC {
    if ([MOC hasChanges]) {
        NSError *error;
        if (![MOC save:&error]) {
            return NO;
        }
    }
    
    return YES;
}

+ (void)unLoadObject:(NSManagedObjectContext *)MOC
           predicate:(NSPredicate *)predicate
          entityName:(NSString *)entityName {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:entityName
                                        inManagedObjectContext:MOC]];
    
    [fetchRequest setPredicate:predicate];
    fetchRequest.includesPropertyValues = NO;
    
    NSError *error = nil;
	NSArray *result = [MOC executeFetchRequest:fetchRequest error:&error];
    for (id post in result) {
		[MOC deleteObject:post];
	}
    
    if ([MOC hasChanges]) {
		if (![MOC save:&error]) {
			debugLog(@"Clear class failed.");
        }
	}
	
    RELEASE_OBJ(pool);
}

+ (NSFetchedResultsController *)fetchObject:(NSManagedObjectContext *)aManagedObjectContext
                   fetchedResultsController:(NSFetchedResultsController *)aFetchedResultsController
                                 entityName:(NSString *)entityName
                         sectionNameKeyPath:(NSString *)sectionNameKeyPath
                            sortDescriptors:(NSMutableArray *)sortDescriptors
                                  predicate:(NSPredicate *)aPredicate {
    
    NSFetchedResultsController *result = nil;
    
    if (aFetchedResultsController == nil) {
		// set entity
		NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
		[fetchRequest setEntity:[NSEntityDescription entityForName:entityName
                                            inManagedObjectContext:aManagedObjectContext]];
		
		// set predicate
		if (aPredicate != nil) {
			[fetchRequest setPredicate:aPredicate];
		}
		
        [fetchRequest setSortDescriptors:sortDescriptors];
        
		// do fetch
		NSString *cacheName = [[NSString alloc] initWithFormat:@"%@Cache", entityName];
		
		// result should be released by caller, e.g., the method "segmentAction" of GuideNewsViewController
		result = [[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                      managedObjectContext:aManagedObjectContext
                                                        sectionNameKeyPath:sectionNameKeyPath
                                                                 cacheName:cacheName] autorelease];
		[cacheName release];
		cacheName = nil;
		
	} else {
		result = aFetchedResultsController;
	}
	
	return result;
}

+(NSDate *)NSStringDateToNSDate:(NSString *)string {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"CCT"]];
    [formatter setDateFormat:kDEFAULT_DATE_TIME_FORMAT];
    NSDate *date = [formatter dateFromString:string];
    [formatter release];
    return date;
}

+ (NSString *)datetimeWithFormat:(NSString *)format datetime:(NSDate *)datetime
{
    NSDateFormatter* dayFormater = [[[NSDateFormatter alloc] init] autorelease];
    [dayFormater setDateFormat:format];
    switch ([AppManager instance].currentLanguageCode) {
        case EN_TY:
            dayFormater.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en-US"] autorelease];
            break;
            
        default:
            dayFormater.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"] autorelease];
            break;
    }
    
    return [dayFormater stringFromDate:datetime];
}

+ (BOOL)objectInLocalStorage:(NSManagedObjectContext *)MOC entityName:(NSString *)entityName {
    NSArray *objs = [self objectsInMOC:MOC entityName:entityName sortDescKeys:nil predicate:nil];
    if ([objs count] > 0) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - zip
+ (NSData *)gzipInflate:(NSData*)data
{
    if ([data length] == 0) return data;
    
    unsigned full_length = [data length];
    unsigned half_length = [data length] / 2;
    
    NSMutableData *decompressed = [NSMutableData dataWithLength: full_length + half_length];
    BOOL done = NO;
    int status;
    
    z_stream strm;
    strm.next_in = (Bytef *)[data bytes];
    strm.avail_in = [data length];
    strm.total_out = 0;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    
    if (inflateInit2(&strm, (15+32)) != Z_OK) return nil;
    while (!done)
    {
        // Make sure we have enough room and reset the lengths.
        if (strm.total_out >= [decompressed length])
            [decompressed increaseLengthBy: half_length];
        strm.next_out = [decompressed mutableBytes] + strm.total_out;
        strm.avail_out = [decompressed length] - strm.total_out;
        
        // Inflate another chunk.
        status = inflate (&strm, Z_SYNC_FLUSH);
        if (status == Z_STREAM_END) done = YES;
        else if (status != Z_OK) break;
    }
    if (inflateEnd (&strm) != Z_OK) return nil;
    
    // Set real length.
    if (done)
    {
        [decompressed setLength: strm.total_out];
        return [NSData dataWithData: decompressed];
    }
    else return nil;
}

+ (NSData *)gzipDeflate:(NSData*)data
{
    NSLog(@"data length: %d", data.length);
    if ([data length] == 0) return data;
    
    z_stream strm;
    
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    strm.total_out = 0;
    strm.next_in=(Bytef *)[data bytes];
    strm.avail_in = [data length];
    
    // Compresssion Levels:
    //   Z_NO_COMPRESSION
    //   Z_BEST_SPEED
    //   Z_BEST_COMPRESSION
    //   Z_DEFAULT_COMPRESSION
    
    if (deflateInit2(&strm, Z_DEFAULT_COMPRESSION, Z_DEFLATED, (15+16), 8, Z_DEFAULT_STRATEGY) != Z_OK) return nil;
    
    NSMutableData *compressed = [NSMutableData dataWithLength:16384];  // 16K chunks for expansion
    
    do {
        
        if (strm.total_out >= [compressed length])
            [compressed increaseLengthBy: 16384];
        
        strm.next_out = [compressed mutableBytes] + strm.total_out;
        strm.avail_out = [compressed length] - strm.total_out;
        
        deflate(&strm, Z_FINISH);
        
    } while (strm.avail_out == 0);
    
    deflateEnd(&strm);
    
    [compressed setLength: strm.total_out];
    
    NSData *compressedData = [NSData dataWithData:compressed];
    NSLog(@"compressed length: %d", compressedData.length);
    
    return compressedData;
}

+ (void)saveToZipFile:(NSString *)logFilePath
        logFolderPath:(NSString *)logFolderPath
  zipNoSuffixFileName:(NSString *)zipNoSuffixFileName {
    
    NSError *error = nil;
    
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:logFilePath error:&error];
    NSDate *date = [attributes objectForKey:NSFileCreationDate];
    
    
    NSString *zipFilePath = [NSString stringWithFormat:@"%@/%@%@", logFolderPath, zipNoSuffixFileName, ZIP_SUFFIX];
    NSString *logFileName = [NSString stringWithFormat:@"%@%@", zipNoSuffixFileName, LOG_SUFFIX];
    ZipFile *zipFile = [[[ZipFile alloc] initWithFileName:zipFilePath mode:ZipFileModeCreate] autorelease];
    ZipWriteStream *writeStream = [zipFile writeFileInZipWithName:logFileName
                                                         fileDate:date
                                                 compressionLevel:ZipCompressionLevelBest];
    NSData *data = [NSData dataWithContentsOfFile:logFilePath];
    [writeStream writeData:data];
    [writeStream finishedWriting];
    
    [zipFile close];
}

#pragma mark - create Image With Color
+ (UIImage *)createImageWithColor:(UIColor *)color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

#pragma mark - exception handler
+ (NSArray*)callstackAsArray {
    void* callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (int i = 0; i < frames; i++) {
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    
    return backtrace;
}

#pragma mark - address book
+ (ABRecordRef)prepareContactData:(Alumni *)alumni {
    ABRecordRef person = ABPersonCreate();
    
    // name
    ABRecordSetValue(person, kABPersonLastNameProperty, alumni.name, NULL);
    ABRecordSetValue(person, kABPersonNoteProperty, alumni.classGroupName, NULL);
    
    // Job title
    if (alumni.companyName && ![alumni.companyName isEqualToString:@""]) {
        ABRecordSetValue(person, kABPersonOrganizationProperty, alumni.companyName, NULL);
    }
    if (alumni.jobTitle && ![alumni.jobTitle isEqualToString:@""]) {
        ABRecordSetValue(person, kABPersonJobTitleProperty, alumni.jobTitle, NULL);
    }
    
    // phone
    ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    
    if (alumni.companyPhone && ![alumni.companyPhone isEqualToString:@""]) {
        ABMultiValueAddValueAndLabel(multiPhone, alumni.companyPhone,kABPersonPhoneMainLabel, NULL);
    }
    if (alumni.phoneNumber && ![alumni.phoneNumber isEqualToString:@""]) {
        ABMultiValueAddValueAndLabel(multiPhone, alumni.phoneNumber,
                                     kABPersonPhoneMobileLabel, NULL);
    }
    if (alumni.companyFax && ![alumni.companyFax isEqualToString:@""]) {
        ABMultiValueAddValueAndLabel(multiPhone, alumni.companyFax, kABPersonPhoneWorkFAXLabel, NULL);
    }
    
    ABRecordSetValue(person, kABPersonPhoneProperty, multiPhone, nil);
    CFRelease(multiPhone);
    
    // email
    if (alumni.email && ![alumni.email isEqualToString:@""]) {
        ABMutableMultiValueRef multiEmail = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(multiEmail, alumni.email, kABWorkLabel, NULL);
        ABRecordSetValue(person, kABPersonEmailProperty, multiEmail, NULL);
        CFRelease(multiEmail);
    }
    
    // address
    ABMutableMultiValueRef multiAddress = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
    
    NSMutableDictionary *addressDictionary = [[[NSMutableDictionary alloc] init] autorelease];
    
    if ((alumni.companyAddressC && ![alumni.companyAddressC isEqualToString:@""]) ||
        (alumni.companyAddressE && ![alumni.companyAddressE isEqualToString:@""])) {
        addressDictionary[(NSString *) kABPersonAddressStreetKey] = [NSString stringWithFormat:@"%@ %@", alumni.companyAddressC, alumni.companyAddressE];
    }
    if (alumni.companyProvince && ![alumni.companyProvince isEqualToString:@""]) {
        
        addressDictionary[(NSString *)kABPersonAddressCityKey] = alumni.companyProvince;
    }
    
    ABMultiValueAddValueAndLabel(multiAddress, addressDictionary, kABWorkLabel, NULL);
    ABRecordSetValue(person, kABPersonAddressProperty, multiAddress, NULL);
    CFRelease(multiAddress);
    
    return (ABRecordRef)[(id)person autorelease];
    
}

#pragma mark - web view
+ (void)clearWebViewCookies {
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in storage.cookies) {
        [storage deleteCookie:cookie];
    }
}

+ (void)openWebView:(UINavigationController *)parentNavController
              title:(NSString *)title
                url:(NSString *)url
          backTitle:(NSString *)backTitle
        needRefresh:(BOOL)needRefresh
     needNavigation:(BOOL)needNavigation {
  
}

+ (void)openWebView:(UINavigationController *)parentNavController
              title:(NSString *)title
                url:(NSString *)url
          backTitle:(NSString *)backTitle
        needRefresh:(BOOL)needRefresh
     needNavigation:(BOOL)needNavigation
blockViewWhenLoading:(BOOL)blockViewWhenLoading {
  
}

#pragma mark - Share to WeChat
+ (void)shareByWeChat:(NSInteger)scene
                title:(NSString *)title
          description:(NSString *)description
                  url:(NSString *)url {
    
    // 发送内容给微信
    WXMediaMessage *message = [WXMediaMessage message];
    
    // avoid length larger than the specification
    if (title.length > MAX_WECHAT_MAX_TITLE_CHAR_COUNT) {
        title = [title substringWithRange:NSMakeRange(0, MAX_WECHAT_MAX_TITLE_CHAR_COUNT)];
        
        NSMutableString *reducedTitle = [NSMutableString stringWithString:title];
        [reducedTitle appendString:@"..."];
        message.title = reducedTitle;
    } else {
        message.title = title;
    }
    
    if (description.length > MAX_WECHAT_MAX_DESC_CHAR_COUNT) {
        description = [description substringWithRange:NSMakeRange(0, MAX_WECHAT_MAX_DESC_CHAR_COUNT)];
        NSMutableString *reducedDesc = [NSMutableString stringWithString:description];
        [reducedDesc appendString:@"..."];
        message.description = reducedDesc;
    } else {
        message.description = description;
    }
    
    [message setThumbImage:[UIImage imageNamed:@"Icon.png"]];
    
    WXAppExtendObject *ext = [WXAppExtendObject object];
    ext.extInfo = @"";
    ext.url = url;
    
    /*
     Byte* pBuffer = (Byte *)malloc(BUFFER_SIZE);
     memset(pBuffer, 0, BUFFER_SIZE);
     NSData* data = [NSData dataWithBytes:pBuffer length:BUFFER_SIZE];
     free(pBuffer);
     ext.fileData = data;
     */
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init] autorelease];
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    
    [WXApi sendReq:req];
}

+ (void)sharePostByWeChat:(Post *)post
                    scene:(NSInteger)scene
                      url:(NSString *)url
                    image:(UIImage *)image {
    
    WXMediaMessage *message = [WXMediaMessage message];
    
    NSString *title = [NSString stringWithFormat:LocaleStringForKey(NSSharedFromiAlumniTitle, nil), post.elapsedTime, post.authorName];
    
    // avoid length larger than the specification
    if (title.length > MAX_WECHAT_MAX_TITLE_CHAR_COUNT) {
        title = [title substringWithRange:NSMakeRange(0, MAX_WECHAT_MAX_TITLE_CHAR_COUNT)];
        
        NSMutableString *reducedtitle = [NSMutableString stringWithString:title];
        [reducedtitle appendString:@"..."];
        
        message.title = reducedtitle;
    } else {
        message.title = title;
    }
    
    NSString *desc = post.content;
    if (desc.length > MAX_WECHAT_MAX_DESC_CHAR_COUNT) {
        desc = [desc substringWithRange:NSMakeRange(0, MAX_WECHAT_MAX_DESC_CHAR_COUNT)];
        
        NSMutableString *reducedDesc = [NSMutableString stringWithString:desc];
        [reducedDesc appendString:@"..."];
        message.description = reducedDesc;
    } else {
        message.description = desc;
    }
    
    if (image) {
        if (post.thumbnailUrl && post.thumbnailUrl.length > 0) {
            NSData *imageData = nil;
            if ([post.thumbnailUrl rangeOfString:@".png"].length > 0) {
                imageData = UIImagePNGRepresentation(image);
            } else if ([post.thumbnailUrl rangeOfString:@".jpg"].length > 0) {
                imageData = UIImageJPEGRepresentation(image, 0.1f);
            }
            
            // If the image data size is larger than 32k, then sharing action
            // will failed. So if the size is larger than 32k, then no need to
            // set the thumb image.
            if (imageData.length < MAX_WECHAT_ATTACHED_IMG_SIZE) {
                message.thumbData = imageData;
            }
        }
    }
    
    WXAppExtendObject *ext = [WXAppExtendObject object];
    ext.extInfo = @"";
    ext.url = url;
    
    /*
     Byte* pBuffer = (Byte *)malloc(BUFFER_SIZE);
     memset(pBuffer, 0, BUFFER_SIZE);
     NSData* data = [NSData dataWithBytes:pBuffer length:BUFFER_SIZE];
     free(pBuffer);
     ext.fileData = data;
     
     message.mediaObject = ext;
     
     SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init] autorelease];
     req.bText = NO;
     req.message = message;
     req.scene = scene;
     [WXApi sendReq:req];
     */
    [self sendToWechatWithExtObject:ext message:message];
}

+ (void)shareEvent:(Event *)event
             scene:(NSInteger)scene
             image:(UIImage *)image {
    WXMediaMessage *message = [WXMediaMessage message];
    
    NSString *title = event.title;
    
    // avoid length larger than the specification
    if (title.length > MAX_WECHAT_MAX_TITLE_CHAR_COUNT) {
        title = [title substringWithRange:NSMakeRange(0, MAX_WECHAT_MAX_TITLE_CHAR_COUNT)];
        
        NSMutableString *reducedtitle = [NSMutableString stringWithString:title];
        [reducedtitle appendString:@"..."];
        
        message.title = reducedtitle;
    } else {
        message.title = title;
    }
    
    NSString *desc = event.desc;
    if (desc.length > MAX_WECHAT_MAX_DESC_CHAR_COUNT) {
        desc = [desc substringWithRange:NSMakeRange(0, MAX_WECHAT_MAX_DESC_CHAR_COUNT)];
        
        NSMutableString *reducedDesc = [NSMutableString stringWithString:desc];
        [reducedDesc appendString:@"..."];
        message.description = reducedDesc;
    } else {
        message.description = desc;
    }
    
    if (image) {
        if (event.imageUrl && event.imageUrl.length > 0) {
            NSData *imageData = nil;
            if ([event.imageUrl rangeOfString:@".png"].length > 0) {
                imageData = UIImagePNGRepresentation(image);
            } else if ([event.imageUrl rangeOfString:@".jpg"].length > 0) {
                imageData = UIImageJPEGRepresentation(image, 0.1f);
            }
            
            // If the image data size is larger than 32k, then sharing action
            // will failed. So if the size is larger than 32k, then no need to
            // set the thumb image.
            if (imageData.length < MAX_WECHAT_ATTACHED_IMG_SIZE) {
                message.thumbData = imageData;
            }
        }
    }
    
    WXAppExtendObject *ext = [WXAppExtendObject object];
    ext.extInfo = [NSString stringWithFormat:@"%@%@%@%@%@", EVENT_ID_FLAG, event.eventId, EVENT_FIELD_SEPARATOR, EVENT_TYPE_FLAG, event.screenType];
    
    /*
     Byte* pBuffer = (Byte *)malloc(BUFFER_SIZE);
     memset(pBuffer, 0, BUFFER_SIZE);
     NSData* data = [NSData dataWithBytes:pBuffer length:BUFFER_SIZE];
     free(pBuffer);
     ext.fileData = data;
     
     message.mediaObject = ext;
     
     SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init] autorelease];
     req.bText = NO;
     req.message = message;
     req.scene = WXSceneSession;
     [WXApi sendReq:req];
     */
    [self sendToWechatWithExtObject:ext message:message];
}

+ (void)sendToWechatWithExtObject:(WXAppExtendObject *)ext message:(WXMediaMessage *)message {
    Byte* pBuffer = (Byte *)malloc(BUFFER_SIZE);
    memset(pBuffer, 0, BUFFER_SIZE);
    NSData* data = [NSData dataWithBytes:pBuffer length:BUFFER_SIZE];
    free(pBuffer);
    ext.fileData = data;
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init] autorelease];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneSession;
    [WXApi sendReq:req];
    
}

+ (void)shareBrand:(Brand *)brand
             scene:(NSInteger)scene
             image:(UIImage *)image {
    WXMediaMessage *message = [WXMediaMessage message];
    
    NSString *title = brand.name;
    
    // avoid length larger than the specification
    if (title.length > MAX_WECHAT_MAX_TITLE_CHAR_COUNT) {
        title = [title substringWithRange:NSMakeRange(0, MAX_WECHAT_MAX_TITLE_CHAR_COUNT)];
        
        NSMutableString *reducedtitle = [NSMutableString stringWithString:title];
        [reducedtitle appendString:@"..."];
        
        message.title = reducedtitle;
    } else {
        message.title = title;
    }
    
    NSString *desc = brand.bio;
    if (desc.length > MAX_WECHAT_MAX_DESC_CHAR_COUNT) {
        desc = [desc substringWithRange:NSMakeRange(0, MAX_WECHAT_MAX_DESC_CHAR_COUNT)];
        
        NSMutableString *reducedDesc = [NSMutableString stringWithString:desc];
        [reducedDesc appendString:@"..."];
        message.description = reducedDesc;
    } else {
        message.description = desc;
    }
    
    if (image) {
        if (brand.avatarUrl && brand.avatarUrl.length > 0) {
            NSData *imageData = nil;
            if ([brand.avatarUrl rangeOfString:@".png"].length > 0) {
                imageData = UIImagePNGRepresentation(image);
            } else if ([brand.avatarUrl rangeOfString:@".jpg"].length > 0) {
                imageData = UIImageJPEGRepresentation(image, 0.1f);
            }
            
            // If the image data size is larger than 32k, then sharing action
            // will failed. So if the size is larger than 32k, then no need to
            // set the thumb image.
            if (imageData.length < MAX_WECHAT_ATTACHED_IMG_SIZE) {
                message.thumbData = imageData;
            }
        }
    }
    
    WXAppExtendObject *ext = [WXAppExtendObject object];
    ext.extInfo = [NSString stringWithFormat:@"%@%@", BRAND_ID_FLAG, brand.brandId];
    
    /*
     Byte* pBuffer = (Byte *)malloc(BUFFER_SIZE);
     memset(pBuffer, 0, BUFFER_SIZE);
     NSData* data = [NSData dataWithBytes:pBuffer length:BUFFER_SIZE];
     free(pBuffer);
     ext.fileData = data;
     
     message.mediaObject = ext;
     
     SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init] autorelease];
     req.bText = NO;
     req.message = message;
     req.scene = WXSceneSession;
     [WXApi sendReq:req];
     */
    [self sendToWechatWithExtObject:ext message:message];
}

+ (void)shareVideo:(Video *)video
             scene:(NSInteger)scene
             image:(UIImage *)image {
    WXMediaMessage *message = [WXMediaMessage message];
    
    NSString *title = [NSString stringWithFormat:@"%@%@", LocaleStringForKey(NSRecommendBracketsVideoTitle, nil), video.videoName];
    
    // avoid length larger than the specification
    if (title.length > MAX_WECHAT_MAX_TITLE_CHAR_COUNT) {
        title = [title substringWithRange:NSMakeRange(0, MAX_WECHAT_MAX_TITLE_CHAR_COUNT)];
        
        NSMutableString *reducedtitle = [NSMutableString stringWithString:title];
        [reducedtitle appendString:@"..."];
        
        message.title = reducedtitle;
    } else {
        message.title = title;
    }
    
    NSString *desc = video.createDate;
    if (desc.length > MAX_WECHAT_MAX_DESC_CHAR_COUNT) {
        desc = [desc substringWithRange:NSMakeRange(0, MAX_WECHAT_MAX_DESC_CHAR_COUNT)];
        
        NSMutableString *reducedDesc = [NSMutableString stringWithString:desc];
        [reducedDesc appendString:@"..."];
        message.description = reducedDesc;
    } else {
        message.description = desc;
    }
    
    if (image) {
        if (video.imageUrl && video.imageUrl.length > 0) {
            NSData *imageData = nil;
            if ([video.imageUrl rangeOfString:@".png"].length > 0) {
                imageData = UIImagePNGRepresentation(image);
            } else if ([video.imageUrl rangeOfString:@".jpg"].length > 0) {
                imageData = UIImageJPEGRepresentation(image, 0.1f);
            }
            
            // If the image data size is larger than 32k, then sharing action
            // will failed. So if the size is larger than 32k, then no need to
            // set the thumb image.
            if (imageData.length < MAX_WECHAT_ATTACHED_IMG_SIZE) {
                message.thumbData = imageData;
            }
        }
    }
    
    WXAppExtendObject *ext = [WXAppExtendObject object];
    ext.extInfo = [NSString stringWithFormat:@"%@%@", VIDEO_ID_FLAG, video.videoId];
    
    /*
     Byte* pBuffer = (Byte *)malloc(BUFFER_SIZE);
     memset(pBuffer, 0, BUFFER_SIZE);
     NSData* data = [NSData dataWithBytes:pBuffer length:BUFFER_SIZE];
     free(pBuffer);
     ext.fileData = data;
     
     message.mediaObject = ext;
     
     SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init] autorelease];
     req.bText = NO;
     req.message = message;
     req.scene = WXSceneSession;
     [WXApi sendReq:req];
     */
    [self sendToWechatWithExtObject:ext message:message];
}

+ (BOOL)isConnectionOK {
    
    Reachability *r = [Reachability reachabilityWithHostName:@"www.apple.com"];
    switch ([r currentReachabilityStatus]) {
        case NotReachable:
            // 没有网络连接
            NSLog(@"没有网络");
            return NO;
            break;
        case ReachableViaWWAN:
            // 使用3G网络
            NSLog(@"正在使用3G网络");
            return YES;
            break;
        case ReachableViaWiFi:
            // 使用WiFi网络
            NSLog(@"正在使用wifi网络");
            return YES;
            break;
            
        default:
            return NO;
            break;
    }
}

+ (BOOL)is7System
{
    if ([[UIDevice currentDevice].systemVersion floatValue] < 7)
        return FALSE;
    
    return TRUE;
}

@end
