//
//  HandyCommentListViewController.h
//  iAlumniHD
//
//  Created by Mobguang on 12-3-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseListViewController.h"
#import "GlobalConstants.h"
#import "ECClickableElementDelegate.h"
#import "ItemUploaderDelegate.h"

@class HandyCommentComposerView;
@class News;

@interface HandyCommentListViewController : BaseListViewController <UIGestureRecognizerDelegate, ECClickableElementDelegate> {
  @private
  id<ItemUploaderDelegate> _itemUploaderDelegate;
  
  HandyCommentComposerView *_commentComposerView;
  
  long long _itemId;
  
  long long _brandId;
  
  UITapGestureRecognizer *_oneTapRecoginzer;
    
  WebItemType _contentType;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder 
 backToHomeAction:(SEL)backToHomeAction 
           itemId:(long long )itemId
          brandId:(long long)brandId
      contentType:(WebItemType)contentType
itemUploaderDelegate:(id<ItemUploaderDelegate>)itemUploaderDelegate;

@end
