//
//  AlumniCouponTitleCell.m
//  iAlumniHD
//
//  Created by MobGuang on 12-8-22.
//
//

#import "AlumniCouponTitleCell.h"
#import <QuartzCore/QuartzCore.h>
#import "WXWLabel.h"
#import "TextConstants.h"
#import "CommonUtils.h"

@implementation AlumniCouponTitleCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
      
      self.backgroundColor = SERVICE_ITEM_CELL_COLOR;
      self.selectionStyle = UITableViewCellSelectionStyleNone;
      
      _title = [self initLabel:CGRectZero
                     textColor:DARK_TEXT_COLOR
                   shadowColor:[UIColor whiteColor]];
      _title.font = BOLD_FONT(14);
      [self.contentView addSubview:_title];
      
      _subTitleLabel = [self initLabel:CGRectZero
                              textColor:[UIColor whiteColor]
                            shadowColor:TRANSPARENT_COLOR];
      _subTitleLabel.backgroundColor = BASE_INFO_COLOR;
      _subTitleLabel.layer.masksToBounds = YES;
      _subTitleLabel.font = BOLD_FONT(10);
      _subTitleLabel.numberOfLines = 0;
      _subTitleLabel.lineBreakMode = UILineBreakModeWordWrap;
      _subTitleLabel.textAlignment = UITextAlignmentCenter;
      _subTitleLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
      [self.contentView addSubview:_subTitleLabel];
    }
    return self;
}

- (void)dealloc {
  
  RELEASE_OBJ(_title);
  RELEASE_OBJ(_subTitleLabel);
  
  [super dealloc];
}

- (void)arrangeSubTitle:(NSString *)subTitle {
  if (subTitle && subTitle.length > 0) {
    _subTitleLabel.hidden = NO;
    
    _subTitleLabel.text = subTitle;
    CGSize size = [_subTitleLabel.text sizeWithFont:_subTitleLabel.font
                                  constrainedToSize:CGSizeMake(self.contentView.frame.size.width -
                                                               (_title.frame.origin.x + _title.frame.size.width + MARGIN * 4),
                                                               CGFLOAT_MAX)
                                      lineBreakMode:UILineBreakModeWordWrap];
    _subTitleLabel.frame = CGRectMake(_title.frame.origin.x + _title.frame.size.width + MARGIN * 2,
                                      _title.frame.origin.y + _title.frame.size.height - size.height - 2.0f,
                                      size.width + MARGIN * 4, size.height);
    _subTitleLabel.layer.cornerRadius = size.height/2.0f;
  } else {
    _subTitleLabel.hidden = YES;
  }
}

- (void)drawCell:(NSString *)text
        subTitle:(NSString *)subTitle
            font:(UIFont *)font
       textColor:(UIColor *)textColor
   textAlignment:(UITextAlignment)textAlignment
      cellHeight:(CGFloat)cellHeight
showBottomShadow:(BOOL)showBottomShadow {
  
  self.layer.shadowPath = nil;
  
  _title.font = font;
  _title.textColor = textColor;
  _title.text = text;
  CGSize size = [_title.text sizeWithFont:_title.font
                        constrainedToSize:CGSizeMake(LIST_WIDTH - MARGIN * 12, CGFLOAT_MAX)
                            lineBreakMode:UILineBreakModeWordWrap];
  
  if (textAlignment == UITextAlignmentCenter) {
    _title.frame = CGRectMake(((LIST_WIDTH - MARGIN * 12) - size.width)/2.0f,
                              (cellHeight - size.height)/2.0f,
                              size.width,
                              size.height);
  } else {
    _title.frame = CGRectMake(MARGIN * 2, (cellHeight - size.height)/2.0f, size.width, size.height);
  }
  
  if (subTitle && subTitle.length > 0) {
    [self arrangeSubTitle:subTitle];
  }
  
  if (showBottomShadow) {
    [self drawOutBottomShadow:cellHeight];
  }
}

@end
