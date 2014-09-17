//
//  ConnectorConsumerView.h
//  iAlumniHD
//
//  Created by MobGuang on 12-10-14.
//
//

#import <UIKit/UIKit.h>
#import "ECConnectorDelegate.h"
#import "ECConnectionTriggerHolderDelegate.h"

@class ECAsyncConnectorFacade;

@interface ConnectorConsumerView : UIView <ECConnectorDelegate> {
  @private
  
  id<ECConnectionTriggerHolderDelegate> _connectTriggerDelegate;
}

- (id)initWithFrame:(CGRect)frame
connectTriggerDelegate:(id<ECConnectionTriggerHolderDelegate>)connectTriggerDelegate;

#pragma mark - network consumer methods
- (ECAsyncConnectorFacade *)setupAsyncConnectorForUrl:(NSString *)url
                                          contentType:(WebItemType)contentType;

@end
