//
//  BizPartnerGroupScrollView.h
//  iAlumniHD
//
//  Created by Mobguang on 11-12-15.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "GlobalConstants.h"
#import "ImageDisplayerDelegate.h"
#import "FilterListDelegate.h"

@class ItemGroupButton;

@interface BizPartnerGroupScrollView : UIView {
  @private
  UIScrollView *_groupContiner;
  
  NSManagedObjectContext *_MOC;
  
  id _switchHandler;
  SEL _switchAction;
  
  id<ImageDisplayerDelegate> _imageDisplayerDelegate;
  
  NSMutableArray *_btns;
  
  ItemGroupButton *_lastSelectedButton;
  
  ItemGroupButton *_peopleButton;
}

@property (nonatomic, retain) ItemGroupButton *peopleButton;

- (id)initWithFrame:(CGRect)frame 
                MOC:(NSManagedObjectContext *)MOC 
      switchHandler:(id)switchHandler 
       switchAction:(SEL)switchAction 
imageDisplayerDelegate:(id<ImageDisplayerDelegate>)imageDisplayerDelegate;

- (void)drawItemButtons;

- (void)defaultSelectDummyAll;

#pragma mark - disable/enable buttons
- (void)enableCategoryButtons:(BOOL)enable;

@end
