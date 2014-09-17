//
//  WXWSyncConnectorFacade.h
//  iAlumniHD
//
//  Created by Adam on 12-10-12.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXWConnector.h"

@interface WXWSyncConnectorFacade : WXWConnector {
    
}

#pragma mark - upload log
- (NSData *)uploadLog:(NSString *)logContent logFileName:(NSString*)logFileName;
- (NSData *)uploadLogData:(NSData *)data logFileName:(NSString*)logFileName;
- (NSData *)uploadLog:(NSString *)logContent;

@end
