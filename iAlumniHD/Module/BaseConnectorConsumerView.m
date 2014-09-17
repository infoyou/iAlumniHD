//
//  BaseConnectorConsumerView.m
//  iAlumniHD
//
//  Created by MobGuang on 12-10-27.
//
//

#import "BaseConnectorConsumerView.h"
#import "WXWAsyncConnectorFacade.h"

@interface BaseConnectorConsumerView()
@property (nonatomic, retain) NSMutableArray *imageUrls;
@end

@implementation BaseConnectorConsumerView

#pragma mark - lifecycle methods
- (id)initWithFrame:(CGRect)frame
imageDisplayerDelegate:(id<ImageDisplayerDelegate>)imageDisplayerDelegate
connectTriggerDelegate:(id<WXWConnectionTriggerHolderDelegate>)connectTriggerDelegate {
  self = [super initWithFrame:frame];
  if (self) {
    _imageDisplayerDelegate = imageDisplayerDelegate;
    
    _connectTriggerDelegate = connectTriggerDelegate;
  }
  return self;
}

- (void)dealloc {
  
  for (NSString *url in self.imageUrls) {
    [[AppManager instance] clearCallerFromCache:url];
  }
  
  self.imageUrls = nil;
  
  [super dealloc];
}

#pragma mark - image fetch methods
- (CATransition *)imageTransition {
  CATransition *imageFadein = [CATransition animation];
  imageFadein.duration = FADE_IN_DURATION;
  imageFadein.type = kCATransitionFade;
  return imageFadein;
}

- (void)fetchImage:(NSMutableArray *)imageUrls forceNew:(BOOL)forceNew {
  
  if (imageUrls.count == 0) {
    return;
  }
  
  self.imageUrls = imageUrls;
  
  for (NSString *url in imageUrls) {
    
    // register image url, when the displayer (view controller) be pop up from view controller stack, if
    // image still being loaded, the process could be cancelled
    [_imageDisplayerDelegate registerImageUrl:url];
    
    [[AppManager instance] fetchImage:url
                               caller:self
                             forceNew:forceNew];
  }
}

#pragma mark - ImageFetcherDelegate methods
- (void)imageFetchStarted:(NSString *)url {
  // implemented by sub class
}

- (void)imageFetchDone:(UIImage *)image url:(NSString *)url {
  // implemented by sub class
}

- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url {
  // implemented by sub class
}

- (void)imageFetchFailed:(NSError *)error url:(NSString *)url {
  // implemented by sub class
}


#pragma mark - label methods
- (WXWLabel *)initLabel:(CGRect)frame
             textColor:(UIColor *)textColor
           shadowColor:(UIColor *)shadowColor
                  font:(UIFont *)font
{
  
  WXWLabel *label = [[WXWLabel alloc] initWithFrame:frame
                                        textColor:textColor
                                      shadowColor:shadowColor];
  label.font = font;
  
  return label;
}


#pragma mark - network consumer methods
- (WXWAsyncConnectorFacade *)setupAsyncConnectorForUrl:(NSString *)url
                                          contentType:(WebItemType)contentType {
  WXWAsyncConnectorFacade *connector = [[[WXWAsyncConnectorFacade alloc] initWithDelegate:self
                                                                 interactionContentType:contentType] autorelease];
  
  if (_connectTriggerDelegate) {
    [_connectTriggerDelegate registerRequestUrl:url
                                     connFacade:connector];
  }
  return connector;
}

@end
