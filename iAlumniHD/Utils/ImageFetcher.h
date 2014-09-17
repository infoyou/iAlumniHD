//
//  ImageFetcher.h
//  iAlumniHD
//
//  Created by Adam on 12-11-9.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXWConnector.h"

@interface ImageFetcher : WXWConnector {
  @private
  NSMutableDictionary *_urlDic;
}

- (void)fetchImage:(NSString *)url showAlertMsg:(BOOL)showAlertMsg;
- (BOOL)imageBeingLoaded:(NSString *)url;
@end
