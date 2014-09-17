//
//  VideoDetailViewController.h
//  iAlumniHD
//
//  Created by Adam on 13-3-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseListViewController.h"
#import "GlobalConstants.h"
#import "ECClickableElementDelegate.h"
#import "ItemUploaderDelegate.h"
#import "WXApi.h"

@class HandyCommentComposerView;
@class News;
@class Video;

@interface VideoDetailViewController : BaseListViewController <UIGestureRecognizerDelegate, ECClickableElementDelegate, WXApiDelegate, UIAlertViewDelegate> {
  @private
  
  HandyCommentComposerView *_commentComposerView;
  
  long long _itemId;
  
  UITapGestureRecognizer *_oneTapRecoginzer;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder 
 backToHomeAction:(SEL)backToHomeAction 
           itemId:(long long )itemId
            video:(Video *)video;

@end
