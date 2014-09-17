//
//  WithTitleImageCell.m
//  iAlumniHD
//
//  Created by MobGuang on 12-11-24.
//
//

#import "WithTitleImageCell.h"

@implementation WithTitleImageCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    _titleImage = [[[UIImageView alloc] init] autorelease];
    _titleImage.backgroundColor = TRANSPARENT_COLOR;
    [self.contentView addSubview:_titleImage];
  }
  return self;
}

- (void)dealloc {
  
  
  [super dealloc];
}

- (void)drawWithTitleImageCellWithTitle:(NSString *)title
                               subTitle:(NSString *)subTitle
                                content:(NSString *)content
                                  image:(UIImage *)image
                   contentLineBreakMode:(UILineBreakMode)contentLineBreakMode
                             cellHeight:(CGFloat)cellHeight
                              clickable:(BOOL)clickable {
  
  _titleImage.image = image;
  
  _titleImage.frame = CGRectMake(MARGIN * 2, MARGIN * 1.5,
                                 CELL_TITLE_IMAGE_SIDE_LENGTH,
                                 CELL_TITLE_IMAGE_SIDE_LENGTH);
  
  [self drawCellWithTitle:title
                 subTitle:subTitle
                  content:content
     contentLineBreakMode:contentLineBreakMode
               cellHeight:cellHeight
                clickable:clickable
            hasTitleImage:YES];
}

@end
