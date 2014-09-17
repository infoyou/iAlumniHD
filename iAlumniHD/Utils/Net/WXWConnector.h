//
//  WXWConnector.h
//  iAlumniHD
//
//  Created by Adam on 12-10-12.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXWConnectorDelegate.h"
#import "GlobalConstants.h"
#import "DebugLogOutput.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "WXWUIUtils.h"

@interface WXWConnector : NSObject {
    
    id<WXWConnectorDelegate> _delegate;
    NSInteger _statusCode;
    BOOL _getMethod;
    NSMutableData *_receivedData;
    
    NSString *_requestUrl;
    NSString *_postParam;
    
    WebItemType _interactionContentType;
    
    long long _expectedContentLength;
    
@private
    NSURLConnection *_conn;
    NSTimer *_connectionTimer;
    BOOL _running;
    BOOL _syncConnectionDone;
    BOOL _showAlertMsg;
    
}

@property (nonatomic, retain) id<WXWConnectorDelegate> delegate;
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, copy) NSString *requestUrl;
@property (nonatomic, assign) WebItemType interactionContentType;

- (id)initWithDelegate:(id<WXWConnectorDelegate>)delegate
interactionContentType:(WebItemType)interactionContentType;

#pragma mark - sync methods
- (NSData *)syncGet:(NSString *)urlStr;
- (NSData *)getDataFromWeb:(NSString *)urlStr;
- (NSData *)syncPost:(NSString *)aUrl paramDic:(NSDictionary *)paramDic;
- (NSData *)syncPost:(NSString *)aUrl data:(NSData *)data;

#pragma mark - async methods
- (void)asyncGet:(NSString *)urlStr showAlertMsg:(BOOL)showAlertMsg;

#pragma mark - cancel
- (void)cancelConnection;

#pragma mark - post method
- (void)post:(NSString *)aUrl data:(NSData *)data;

@end