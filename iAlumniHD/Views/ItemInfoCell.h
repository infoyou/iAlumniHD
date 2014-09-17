//
//  ItemInfoCell.h
//  iAlumniHD
//
//  Created by Mobguang on 11-12-23.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"
#import "BaseUITableViewCell.h"

@class ServiceProvider;
@class WXWLabel;

@interface ItemInfoCell : BaseUITableViewCell {
  @private
  WXWLabel *_label;
}

- (void)drawInfoCell:(ServiceProvider *)sp 
            infoType:(ServiceProviderInfoType)infoType
    needBottomShadow:(BOOL)needBottomShadow;

@end
