//
//  ReviewsListViewController.h
//  iAlumniHD
//
//  Created by Mobguang on 11-12-25.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "BaseListViewController.h"
#import "GlobalConstants.h"
#import "ECClickableElementDelegate.h"
#import "ItemUploaderDelegate.h"

@class ServiceProvider;

@interface ReviewsListViewController : BaseListViewController <ECClickableElementDelegate, ItemUploaderDelegate> {
  @private

  ServiceProvider *_sp;
  
  BOOL _allowAddComment;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC 
           holder:(id)holder 
 backToHomeAction:(SEL)backToHomeAction
               sp:(ServiceProvider *)sp
  allowAddComment:(BOOL)allowAddComment;

@end
