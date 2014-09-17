//
//  FavoriteAlumniResultView.h
//  iAlumniHD
//
//  Created by MobGuang on 12-11-21.
//
//

#import <UIKit/UIKit.h>
#import "BaseConnectorConsumerView.h"
#import "GlobalConstants.h"
#import "ECClickableElementDelegate.h"
#import "WXWImageButton.h"
#import "ImageDisplayerDelegate.h"
#import "WXWConnectionTriggerHolderDelegate.h"

@class Alumni;

@interface FavoriteAlumniResultView : BaseConnectorConsumerView {
  @private
  
  NSManagedObjectContext *_MOC;
  
  UIView *_topView;
  
  WXWImageButton *_wantToKnowButton;
  WXWImageButton *_knownButton;
  WXWImageButton *_deleteButton;
    
    BOOL _userCancel;
  AlumniRelationshipType _relationshipType;
  
  CGFloat _checkButtonBottomY;
  
  id<ECClickableElementDelegate> _holder;
  SEL _closeAction;
  SEL _favoriteAction;
}

- (id)initWithFrame:(CGRect)frame
                MOC:(NSManagedObjectContext *)MOC
             holder:(id<ECClickableElementDelegate>)holder
        closeAction:(SEL)closeAction
     favoriteAction:(SEL)favoriteAction
imageDisplayerDelegate:(id<ImageDisplayerDelegate>)imageDisplayerDelegate
connectTriggerDelegate:(id<WXWConnectionTriggerHolderDelegate>)connectTriggerDelegate
             alumni:(Alumni *)alumni;

@end
