//
//  NewsListCell.h
//  iAlumniHD
//
//  Created by Adam on 12-11-23.
//
//

#import "WXWImageConsumerCell.h"
#import "GlobalConstants.h"

@class WXWLabel;
@class News;

@interface NewsListCell : WXWImageConsumerCell {
@private
  WXWLabel *_titleLabel;

  UIView *_imageBackgroundView;
  UIImageView *_newsImageView;
}

- (void)drawNews:(News *)news;

@end
