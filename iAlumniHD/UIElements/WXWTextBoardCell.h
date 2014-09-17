//
//  WXWTextBoardCell.h
//  iAlumniHD
//
//  Created by Mobguang on 12-5-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseConfigurableCell.h"
#import <QuartzCore/QuartzCore.h>
#import "GlobalConstants.h"
#import "CommonUtils.h"

@class WXWLabel;

@interface WXWTextBoardCell : UITableViewCell {
  @private
  NSMutableArray *_labelsContainer;
}

- (WXWLabel *)initLabel:(CGRect)frame 
             textColor:(UIColor *)textColor 
           shadowColor:(UIColor *)shadowColor;

@end
