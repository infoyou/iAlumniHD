//
//  ConnectorConsumerView.m
//  iAlumniHD
//
//  Created by MobGuang on 12-10-14.
//
//

#import "ConnectorConsumerView.h"
#import "ECAsyncConnectorFacade.h"

@implementation ConnectorConsumerView

#pragma mark - lifecycle methods
- (id)initWithFrame:(CGRect)frame
connectTriggerDelegate:(id<ECConnectionTriggerHolderDelegate>)connectTriggerDelegate {
  self = [super initWithFrame:frame];
  if (self) {
    _connectTriggerDelegate = connectTriggerDelegate;
  }
  return self;
}

- (void)dealloc {
  
  [super dealloc];
}

#pragma mark - network consumer methods
- (ECAsyncConnectorFacade *)setupAsyncConnectorForUrl:(NSString *)url
                                          contentType:(WebItemType)contentType {
  ECAsyncConnectorFacade *connector = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                 interactionContentType:contentType] autorelease];

  if (_connectTriggerDelegate) {
    [_connectTriggerDelegate registerRequestUrl:url
                                     connFacade:connector];
  }
  return connector;
}



@end
