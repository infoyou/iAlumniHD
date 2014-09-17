//
//  FilterSortListHeaderView.h
//  iAlumniHD
//
//  Created by Mobguang on 12-6-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"
#import "FilterListDelegate.h"

@interface FilterSortListHeaderView : UIView {

}

- (id)initWithFrame:(CGRect)frame 
             target:(id)target 
   filterSortAction:(SEL)filterSortAction
       cancelAction:(SEL)cancelAction;

@end
