//
//  ImageCache.h
//  iAlumniHD
//
//  Created by Adam on 12-11-9.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageFetcherDelegate.h"
#import "WXWConnectorDelegate.h"

@interface ImageCache : NSObject <WXWConnectorDelegate> {
    
@private
    NSMutableDictionary *_imageDic;
    NSMutableDictionary *_callerDic;
	NSMutableDictionary *_pendingDic;
    
}

- (void)fetchImage:(NSString*)url
            caller:(id<ImageFetcherDelegate>)caller
          forceNew:(BOOL)forceNew;

- (void)cancelPendingImageLoadProcess:(NSMutableDictionary *)urlDic;

- (void)clearCallerFromCache:(NSString *)url;

- (void)clearAllCachedImages;
- (void)clearAllCachedAndLocalImages;

- (void)didReceiveMemoryWarning;

- (UIImage *)getImage:(NSString*)anUrl;
- (void)saveImageIntoCache:(NSString *)url image:(UIImage *)image;
- (void)removeDelegate:(id)delegate forUrl:(NSString *)key;

@end
