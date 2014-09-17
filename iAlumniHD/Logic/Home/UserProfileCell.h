//
//  UserProfileCell.h
//  iAlumniHD
//
//  Created by Adam on 12-10-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseUITableViewCell.h"

@interface UserProfileCell : BaseUITableViewCell {
    
  @private
  UIImageView *_photoView;
  NSString *_url;
  UILabel *_nameLabel;
}

- (void)drawProfile:(NSString *)name imgUrl:(NSString *)imgUrl;

@end
