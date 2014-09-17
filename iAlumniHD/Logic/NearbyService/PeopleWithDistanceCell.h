//
//  PeopleWithDistanceCell.h
//  iAlumniHD
//
//  Created by MobGuang on 13-2-20.
//
//

#import "PeopleWithChatCell.h"

@class WXWLabel;
@class Alumni;

@interface PeopleWithDistanceCell : PeopleWithChatCell {
  @private
  
  WXWLabel *_distanceLabel;
  WXWLabel *_timeLabel;
  WXWLabel *_platLabel;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
imageDisplayerDelegate:(id<ImageDisplayerDelegate>)imageDisplayerDelegate
imageClickableDelegate:(id<ECClickableElementDelegate>)imageClickableDelegate
                MOC:(NSManagedObjectContext *)MOC;

- (void)drawCell:(Alumni*)alumni;

@end
