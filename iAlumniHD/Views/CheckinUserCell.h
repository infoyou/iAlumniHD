//
//  CheckinUserCell.h
//  iAlumniHD
//
//  Created by MobGuang on 12-8-17.
//
//

#import "BaseUITableViewCell.h"
#import "GlobalConstants.h"
#import "ECClickableElementDelegate.h"

@class WXWLabel;
@class Alumni;
@class CheckedinMember;

@interface CheckinUserCell : BaseUITableViewCell {
  @private
  
  UIView *_authorPicBackgroundView;
  UIImageView *_authorPic;

  WXWLabel *_nameLabel;
  WXWLabel *_classLabel;
  WXWLabel *_companyLabel;
  
  WXWLabel *_checkinTimeLabel;
  WXWLabel *_checkinCountLabel;
  
  UIButton *_dmButton;
  
  id<ECClickableElementDelegate> _delegate;
  
  CheckedinMember *_checkedinAlumni;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
imageDisplayerDelegate:(id<ImageDisplayerDelegate>)imageDisplayerDelegate
imageClickableDelegate:(id<ECClickableElementDelegate>)imageClickableDelegate
                MOC:(NSManagedObjectContext *)MOC;

- (void)drawCellWithAlumni:(CheckedinMember *)alumni;

@end
