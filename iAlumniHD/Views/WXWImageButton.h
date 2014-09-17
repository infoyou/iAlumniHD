//
//  WXWImageButton.h
//  iAlumniHD
//
//  Created by Adam on 12-11-13.
//
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"

@interface WXWImageButton : UIButton

- (id)initImageButtonWithFrame:(CGRect)frame
                        target:(id)target
                        action:(SEL)action
                         title:(NSString *)title
                         image:(UIImage*)image
                   backImgName:(NSString*)backImgName
                selBackImgName:(NSString*)selBackImgName
                     titleFont:(UIFont *)titleFont
                    titleColor:(UIColor *)titleColor
              titleShadowColor:(UIColor *)titleShadowColor
                   roundedType:(ButtonRoundedType)roundedType
               imageEdgeInsert:(UIEdgeInsets)imageEdgeInsert
               titleEdgeInsert:(UIEdgeInsets)titleEdgeInsert;

- (void)setButtonPropertiesWithFrame:(CGRect)frame
                               title:(NSString *)title
                               image:(UIImage*)image
                         backImgName:(NSString*)backImgName
                      selBackImgName:(NSString*)selBackImgName
                          titleColor:(UIColor *)titleColor
                    titleShadowColor:(UIColor *)titleShadowColor
                     imageEdgeInsert:(UIEdgeInsets)imageEdgeInsert
                     titleEdgeInsert:(UIEdgeInsets)titleEdgeInsert;

@end
