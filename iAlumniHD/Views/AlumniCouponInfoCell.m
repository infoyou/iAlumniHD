//
//  AlumniCouponInfoCell.m
//  iAlumniHD
//
//  Created by MobGuang on 12-8-22.
//
//

#import "AlumniCouponInfoCell.h"
#import "WXWLabel.h"
#import "TextConstants.h"
#import "CommonUtils.h"

@implementation AlumniCouponInfoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
      self.backgroundColor = SERVICE_ITEM_CELL_COLOR;
      
      self.selectionStyle = UITableViewCellSelectionStyleNone;
      
      _title = [self initLabel:CGRectZero
                     textColor:NAVIGATION_BAR_COLOR
                   shadowColor:[UIColor whiteColor]];
      _title.font = FONT(13);
      _title.numberOfLines = 0;
      [self.contentView addSubview:_title];
      
      UIImageView *icon = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"coupon.png"]] autorelease];
      icon.frame = CGRectMake(0, 0, icon.frame.size.width, icon.frame.size.height);
      
      [self.contentView addSubview:icon];
    }
    return self;
}

- (void)dealloc {
  
  RELEASE_OBJ(_title);
  
  [super dealloc];
}

- (void)drawCell:(NSString *)couponInfo {
  _title.text = couponInfo;
  CGSize size = [_title.text sizeWithFont:_title.font
                        constrainedToSize:CGSizeMake((LIST_WIDTH - MARGIN * 12) - MARGIN * 8, CGFLOAT_MAX)
                            lineBreakMode:UILineBreakModeWordWrap];
  _title.frame = CGRectMake(MARGIN * 4, MARGIN * 2, size.width, size.height);
  
}

@end
