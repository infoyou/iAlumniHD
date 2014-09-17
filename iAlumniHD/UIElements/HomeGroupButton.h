//
//  HomeGroupButton.h
//  iAlumniHD
//
//  Created by Adam on 12-11-4.
//
//

#import <UIKit/UIKit.h>
#import "WXWGradientButton.h"
#import "GlobalConstants.h"
#import "ImageFetcherDelegate.h"
#import "ImageDisplayerDelegate.h"

@class HomeGroup;
@interface HomeGroupButton : UIButton <ImageFetcherDelegate> {
    
    HomeGroup *_itemGroup;
    
@private
    id<ImageDisplayerDelegate> _imageDisplayerDelegate;
    
    ButtonColorType _colorType;
    BOOL _hideBorder;
    
    NSString *_titleText;
}

@property (nonatomic, retain) HomeGroup *itemGroup;

- (id)initWithFrame:(CGRect)frame
             target:(id)target
             action:(SEL)action
          colorType:(ButtonColorType)colorType
              title:(NSString *)title
         titleColor:(UIColor *)titleColor
   titleShadowColor:(UIColor *)titleShadowColor
          titleFont:(UIFont *)titleFont
    imageEdgeInsert:(UIEdgeInsets)imageEdgeInsert
    titleEdgeInsert:(UIEdgeInsets)titleEdgeInsert
          itemGroup:(HomeGroup *)itemGroup
imageDisplayerDelegate:(id<ImageDisplayerDelegate>)imageDisplayerDelegate;

@end
