//
//  MultilevelScrollMenusView.h
//  iAlumniHD
//
//  Created by Adam on 12-10-9.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"

@class CPScrollView;

@interface MultilevelScrollMenusView : UIView {
    
@private
    CPScrollView *_secondLevelMenu;
    UILabel *_titleLabel;
    
    id _target;
    SEL _arrangeViewAction;
}

- (id)initWithMenuType:(HomeMenuType)type
                 frame:(CGRect)frame
                target:(id)target
     arrangeViewAction:(SEL)arrangeViewAction;

- (void)setTitle:(NSString *)title;

- (void)arrangeTitleToCenter;

@end
