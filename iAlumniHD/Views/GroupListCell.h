//
//  GroupListCell.h
//  iAlumniHD
//
//  Created by MobGuang on 12-10-5.
//
//

#import "BaseUITableViewCell.h"
#import "GlobalConstants.h"

@class CoreTextView;
@class WXWLabel;
@class Club;

@interface GroupListCell : BaseUITableViewCell {
    
@private
    WXWLabel *_groupNameLabel;
    CoreTextView *_postContentView;
    CoreTextView *_baseInfoView;
    
    WXWLabel *_dateTimeLabel;
    
    UIImageView *_badgeImageView;
    WXWLabel *_badgeNumLabel;
    
    Club *_club;
}

- (void)drawCell:(Club *)club;

@end
