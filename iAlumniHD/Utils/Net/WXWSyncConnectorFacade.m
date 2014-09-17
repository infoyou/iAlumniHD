//
//  WXWSyncConnectorFacade.m
//  iAlumniHD
//
//  Created by Adam on 12-10-12.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "WXWSyncConnectorFacade.h"
#import "AppManager.h"

@implementation WXWSyncConnectorFacade

- (void)dealloc {
    
    [super dealloc];
}

#pragma mark - upload log
- (NSMutableData *)assembleLogData:(NSDictionary *)dic
                       logFileName:(NSString *)logFileName
                        logContent:(NSData *)logContent
                      originalData:(NSMutableData *)originalData {
    
    NSString *param = [CommonUtils convertParaToHttpBodyStr:dic];
    
    param = [param stringByAppendingString:[NSString stringWithFormat:@"--%@\n", IALUMNIHD_FORM_BOUNDARY]];
    param = [param stringByAppendingString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"attach\"; filename=\"%@\"\nContent-Type: application/octet-stream\n\n",
                                            logFileName]];
    
    [originalData appendData:[param dataUsingEncoding:NSUTF8StringEncoding
                                 allowLossyConversion:YES]];
    
    [originalData appendData:logContent];
    
    // append footer
	NSString *footer = [NSString stringWithFormat:@"\n--%@--\n", IALUMNIHD_FORM_BOUNDARY];
	[originalData appendData:[footer dataUsingEncoding:NSUTF8StringEncoding
                                  allowLossyConversion:YES]];

  if (EC_DEBUG) {
    NSLog(@"params: %@", [[[NSString alloc] initWithData:originalData encoding:NSUTF8StringEncoding] autorelease]);
  }
  return originalData;
}

- (NSData *)uploadLog:(NSString *)logContent logFileName:(NSString*)logFileName{

    NSDictionary *dic = nil;
    
    dic = @{@"action": @"error_upload",
    @"plat": @"p",
    @"type": @"iAlumni"};
    
    return [self syncPost:ERROR_LOG_UPLOAD_URL
                     data:[self assembleLogData:dic
                                    logFileName:logFileName
                                     logContent:[logContent dataUsingEncoding:NSUTF8StringEncoding]
                                   originalData:[NSMutableData data]]];
}

- (NSData *)uploadLogData:(NSData *)data logFileName:(NSString*)logFileName {
    
    NSDictionary *dic = nil;
    
    dic = @{@"action": @"error_upload",
    @"plat": @"p",
    @"type": @"iAlumni"};
    
    return [self syncPost:ERROR_LOG_UPLOAD_URL
                     data:[self assembleLogData:dic
                                    logFileName:logFileName
                                     logContent:data
                                   originalData:[NSMutableData data]]];
    
}

- (NSData *)uploadLog:(NSString *)logContent {
    
    NSDictionary *dic = nil;
    
    dic = @{@"action": @"log_upload",
    @"plat": @"p",
    @"version": VERSION,
    @"user_id": [AppManager instance].userId,
    @"message": logContent};
    
	return [self syncPost:ERROR_LOG_UPLOAD_URL paramDic:dic];
}

@end
