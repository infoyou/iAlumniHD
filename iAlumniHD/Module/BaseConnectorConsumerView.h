//
//  BaseConnectorConsumerView.h
//  iAlumniHD
//
//  Created by MobGuang on 12-10-27.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "WXWConnectorDelegate.h"
#import "WXWConnectionTriggerHolderDelegate.h"
#import "ImageDisplayerDelegate.h"
#import "ImageFetcherDelegate.h"
#import "GlobalConstants.h"
#import "CoreDataUtils.h"
#import "CommonUtils.h"
#import "AppManager.h"
#import "WXWLabel.h"
#import "WXWUIUtils.h"

@class WXWAsyncConnectorFacade;
@class WXWLabel;

@interface BaseConnectorConsumerView : UIView <WXWConnectorDelegate, ImageFetcherDelegate> {
@private
  
  id<ImageDisplayerDelegate> _imageDisplayerDelegate;
  
  id<WXWConnectionTriggerHolderDelegate> _connectTriggerDelegate;
  
}

- (id)initWithFrame:(CGRect)frame
imageDisplayerDelegate:(id<ImageDisplayerDelegate>)imageDisplayerDelegate
connectTriggerDelegate:(id<WXWConnectionTriggerHolderDelegate>)connectTriggerDelegate;

#pragma mark - label methods
- (WXWLabel *)initLabel:(CGRect)frame
             textColor:(UIColor *)textColor
           shadowColor:(UIColor *)shadowColor
                  font:(UIFont *)font;

#pragma mark - image fetch methods
- (void)fetchImage:(NSMutableArray *)imageUrls forceNew:(BOOL)forceNew;
- (CATransition *)imageTransition;

#pragma mark - network consumer methods
- (WXWAsyncConnectorFacade *)setupAsyncConnectorForUrl:(NSString *)url
                                          contentType:(WebItemType)contentType;

@end
