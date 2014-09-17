//
//  ImageFetcherDelegate.h
//  iAlumniHD
//
//  Created by Adam on 12-11-9.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

@protocol ImageFetcherDelegate <NSObject>

@optional
- (void)imageFetchStarted:(NSString *)url;
- (void)imageFetchFailed:(NSError *)error url:(NSString *)url;

@required
- (void)imageFetchDone:(UIImage *)image url:(NSString *)url;
- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url;

@end
