//
//  BizGroupIndicatorBar.h
//  iAlumniHD
//
//  Created by MobGuang on 13-1-26.
//
//

#import <UIKit/UIKit.h>
#import "BaseUIView.h"

@class WXWLabel;

@interface BizGroupIndicatorBar : BaseUIView {
  @private
  
  WXWLabel *_firstPageIndicator;
  WXWLabel *_firstNameLabel;
  UIImageView *_leftArrow;
  
  WXWLabel *_secondPageIndicator;
  WXWLabel *_secondNameLabel;
  UIImageView *_rightArrow;
}

#pragma mark - arrange for page switch
- (void)switchToPageWithIndex:(BizCoopPageIndex)index;


@end
