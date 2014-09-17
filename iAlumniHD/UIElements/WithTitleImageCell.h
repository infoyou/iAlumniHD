//
//  WithTitleImageCell.h
//  iAlumniHD
//
//  Created by MobGuang on 12-11-24.
//
//

#import "ConfigurableTextCell.h"
#import "GlobalConstants.h"

@interface WithTitleImageCell : ConfigurableTextCell {
  @private
  UIImageView *_titleImage;
}

- (void)drawWithTitleImageCellWithTitle:(NSString *)title
                               subTitle:(NSString *)subTitle
                                content:(NSString *)content
                                  image:(UIImage *)image
                   contentLineBreakMode:(UILineBreakMode)contentLineBreakMode
                             cellHeight:(CGFloat)cellHeight
                              clickable:(BOOL)clickable;

@end
