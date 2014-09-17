//
//  PlainTabView.h
//  iAlumniHD
//
//  Created by MobGuang on 13-2-18.
//
//

#import <UIKit/UIKit.h>
#import "TapSwitchDelegate.h"

@interface PlainTabView : UIView {

@private
  id<TapSwitchDelegate> _tapSwitchDelegate;
}

- (id)initWithFrame:(CGRect)frame
       buttonTitles:(NSArray *)buttonTitles
  tapSwitchDelegate:(id<TapSwitchDelegate>)tapSwitchDelegate
        selTabIndex:(int)selTabIndex;

#pragma mark - user action
- (void)selectButtonWithIndex:(NSInteger)index;
- (void)selectButtonWithIndexWithoutTriggerEvent:(NSInteger)index;

@end
