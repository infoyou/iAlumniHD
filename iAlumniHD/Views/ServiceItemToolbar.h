//
//  ServiceItemToolbar.h
//  iAlumniHD
//
//  Created by Mobguang on 12-4-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"
#import "ECClickableElementDelegate.h"
#import "WXWConnectionTriggerHolderDelegate.h"
#import "WXWConnectorDelegate.h"

@class WXWLabel;
@class ServiceItem;

@interface ServiceItemToolbar : UIView <WXWConnectorDelegate> {
  @private
  
  ServiceItem *_item;
  
  NSManagedObjectContext *_MOC;
  
  id<ECClickableElementDelegate> _clickableElementDelegate;
  id<WXWConnectionTriggerHolderDelegate> _connectionTriggerHolderDelegate;
  
  UIButton *_favoriteButton;
  UIButton *_shareButton;
  UIButton *_commentButton;
  UIButton *_closeButton;
  
  UIActivityIndicatorView *_favoriteSpinView;
  
  UIImageView *_moreImageView;
  
  BOOL _expanded;
  
  BOOL _connectionCancelled;

}

- (id)initWithFrame:(CGRect)frame 
               item:(ServiceItem *)item
                MOC:(NSManagedObjectContext *)MOC
clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate
connectionTriggerHolderDelegate:(id<WXWConnectionTriggerHolderDelegate>)connectionTriggerHolderDelegate;

- (void)displayMoreImage;

- (void)collapseIfNeeded;
@end
