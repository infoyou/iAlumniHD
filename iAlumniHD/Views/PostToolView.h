//
//  PostToolView.h
//  iAlumniHD
//
//  Created by Adam on 12-11-24.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "WXWGradientView.h"
#import "FilterListDelegate.h"
#import "ECClickableElementDelegate.h"

@class WXWGradientButton;
@class WXWLabel;
@class WinnerHeaderView;

@interface PostToolView : WXWGradientView {
    
@private
    WXWGradientButton *_distanceButton;
    WXWGradientButton *_timeButton;
    WXWLabel *_distanceLabel;
    WXWLabel *_timeLabel;
    
    WXWGradientButton *_filterButton;
    WXWLabel *_filterLabel;
    WXWGradientButton *_sortButton;
    WXWLabel *_sortLabel;
    
    WinnerHeaderView *_winnerHeaderView;
    
    id<FilterListDelegate> _delegate;
}

- (id)initWithFrame:(CGRect)frame
           topColor:(UIColor *)topColor
        bottomColor:(UIColor *)bottomColor
           delegate:(id<FilterListDelegate>)delegate;

- (id)initForShake:(CGRect)frame
          topColor:(UIColor *)topColor
       bottomColor:(UIColor *)bottomColor
          delegate:(id<FilterListDelegate>)delegate
  userListDelegate:(id<ECClickableElementDelegate>)userListDelegate;

#pragma mark - biz methods
- (void)setWinnerInfo:(NSString *)info winnerType:(WinnerType)winnerType;
- (void)animationGift;

- (void)setFiltersText:(NSString *)text;

- (void)setSortText:(NSString *)text;

- (void)setBackValue:(NSString *)distance time:(NSString *)time sort:(NSString *)sort;

@end
