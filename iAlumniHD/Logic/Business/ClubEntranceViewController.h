//
//  ClubEntranceViewController.h
//  iAlumniHD
//
//  Created by Adam on 13-3-7.
//
//

#import "TapSwitchDelegate.h"
#import "BaseListViewController.h"

@class BizGroupIndicatorBar;
@class PlainTabView;

@interface ClubEntranceViewController : BaseListViewController <UIScrollViewDelegate, TapSwitchDelegate> {
  @private
  CGFloat _viewHeight;
  
  UIViewController *_parentVC;
  
  PlainTabView *_tabSwitchView;
  
  NSInteger _groupCategory;
    
  BizGroupIndicatorBar *_selectionIndicator;
  
  CGFloat _lastContentOffset;
  
  NSInteger _scrollDirection;
  
  NSInteger _currentPageIndex;
  
  NSInteger _popularGroupCellCount;
    
  CGFloat _clubGroupTypeY;
    
    long long _selectedGroupId;
  
  BOOL _needRefresh;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
         parentVC:(UIViewController *)parentVC;

@end
