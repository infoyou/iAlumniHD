//
//  WXWConnectionTriggerHolderDelegate.h
//  iAlumniHD
//
//  Created by Adam on 12-11-5.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXWAsyncConnectorFacade.h"

@protocol WXWConnectionTriggerHolderDelegate <NSObject>

@required
// some kind of views, e.g., table view cells in list, which triggered connection process, when these views being destructed, 
// the connection should be cancelled immediately, and the parent/holder of these views response for cancel action,
// so the connection of these views should be registered in parent/holder firstly, following method be called when
// views trigger connection process, once user navigates back to home or back, these registered connections will be
// cancelled immediately (in RootViewController cancelSubViewConnections method)
- (void)registerRequestUrl:(NSString *)url connFacade:(WXWAsyncConnectorFacade *)connFacade;

@end
