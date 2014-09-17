
//  HomepageViewController.h
//  iAlumniHD
//
//  Created by Adam on 12-10-3.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "WXApi.h"

@class VerticalMenuViewController;
@class HorizontalScrollViewController;
@class MultilevelScrollMenusView;

@class UIViewCheckTouch;

@interface HomepageViewController : UIViewController <WXApiDelegate> {
  
  VerticalMenuViewController *_menuViewController;
  HorizontalScrollViewController *_stackScrollViewController;

  @private
  UIViewCheckTouch *_rootView;
  UIView *_leftMenuView;
  UIView *_rightSlideView;
//  MultilevelScrollMenusView *_multilevelMenu;
  
  NSManagedObjectContext *_MOC;
}

@property (nonatomic, retain) VerticalMenuViewController* menuViewController;
@property (nonatomic, retain) HorizontalScrollViewController* stackScrollViewController;
@property (nonatomic, retain) MultilevelScrollMenusView *multilevelMenu;

- (id)initWithMOC:(NSManagedObjectContext *)MOC;

- (void)resetMultilevelMenuPosition;

#pragma mark - open shared event
- (void)openSharedEventById:(long long)eventId eventType:(int)eventType;

- (void)openAutoSelectEventTabFlagWithId:(long long)eventId eventType:(int)eventType;

- (void)openSharedBrandWithId:(long long)brandId;

- (void)openSharedVideoWithId:(long long)videoId;

@end
