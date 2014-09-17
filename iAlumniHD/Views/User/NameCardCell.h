//
//  NameCardCell.h
//  iAlumniHD
//
//  Created by Adam on 12-12-12.
//
//

#import "PeopleCell.h"
#import "GlobalConstants.h"

@class NameCard;

@interface NameCardCell : PeopleCell {
  @private
  
  UIImageView *_selectIcon;
}
- (void)drawCell:(NameCard *)nameCard;

@end
