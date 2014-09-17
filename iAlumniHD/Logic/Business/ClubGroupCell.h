//
//  ClubGroupCell.h
//  iAlumniHD
//
//  Created by Adam on 13-3-11.
//
//

#import <UIKit/UIKit.h>

@class ClubGroupItemView;
@class Club;

@interface ClubGroupCell : UITableViewCell {
@private
  ClubGroupItemView *_leftItemView;
  ClubGroupItemView *_rightItemView;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

- (void)drawLeftItem:(NSInteger)row
               group:(Club *)group
     selectedGroupId:(long long)selectedGroupId
            entrance:(id)entrance
              action:(SEL)action;

- (void)hideLeftItem;

- (void)drawRightItem:(NSInteger)row
                group:(Club *)group
      selectedGroupId:(long long)selectedGroupId
             entrance:(id)entrance
               action:(SEL)action;

- (void)hideRightItem;

@end
