//
//  WXWConnectorDelegate.h
//  iAlumniHD
//
//  Created by Adam on 12-11-3.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "GlobalConstants.h"

@protocol WXWConnectorDelegate <NSObject>

@optional
- (void)registerConnector:(id<WXWConnectorDelegate>)connector
                      url:(NSString *)url;

- (void)connectStarted:(NSString *)url
           contentType:(WebItemType)contentType;

- (void)connectDone:(NSData *)result 
                url:(NSString *)url 
        contentType:(WebItemType)contentType;

- (void)connectDone:(NSData *)result 
                url:(NSString *)url 
        contentType:(WebItemType)contentType
closeAsyncLoadingView:(BOOL)closeAsyncLoadingView;

- (void)connectCancelled:(NSString *)url
             contentType:(WebItemType)contentType;

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url 
          contentType:(WebItemType)contentType;

- (void)traceParserXMLErrorMessage:(NSString *)message url:(NSString *)url;

- (void)parserConnectionError:(NSError *)error;
@end
