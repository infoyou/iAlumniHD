//
//  SortOptionCell.h
//  iAlumniHD
//
//  Created by Mobguang on 11-11-25.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"
#import "BaseUITableViewCell.h"

@class WXWLabel;
@class SortOption;

@interface SortOptionCell : BaseUITableViewCell {
  @private
  WXWLabel *_optionLabel;
  UIImageView *_selectedStatusIcon;
}

- (void)drawOption:(SortOption *)option;

@end
