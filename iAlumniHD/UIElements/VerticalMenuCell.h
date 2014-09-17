//
//  VerticalMenuCell.h
//  iAlumniHD
//
//  Created by Adam on 12-10-3.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VerticalMenuCell : UITableViewCell {

  @private
  UIImageView *_selectedImgView;
    
  id _delegate;
  BOOL _enabled;
  UIView *_disabledView;
  
  CGFloat _width;

}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier width:(CGFloat)width;

@end
