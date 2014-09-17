//
//  ClubGroupCell.m
//  iAlumniHD
//
//  Created by Adam on 13-3-11.
//
//

#import "ClubGroupCell.h"
#import <QuartzCore/QuartzCore.h>
#import "ClubGroupItemView.h"
#import "Club.h"
#import "WXWUIUtils.h"

#define ITEM_WIDTH  208.f
#define ITEM_HEIGHT 144.f

@interface ClubGroupCell()

@end

@implementation ClubGroupCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        
        _leftItemView = [[[ClubGroupItemView alloc] initWithFrame:CGRectMake(MARGIN * 2, MARGIN, ITEM_WIDTH, ITEM_HEIGHT)] autorelease];
        [self.contentView addSubview:_leftItemView];
        
        _rightItemView = [[[ClubGroupItemView alloc] initWithFrame:CGRectMake(_leftItemView.frame.origin.x + _leftItemView.frame.size.width + MARGIN * 2 + 1, MARGIN, ITEM_WIDTH, ITEM_HEIGHT)] autorelease];
        [self.contentView addSubview:_rightItemView];
    }
    return self;
}

- (void)dealloc {
    
    [super dealloc];
}

#pragma mark - draw cell
- (void)drawLeftItem:(NSInteger)row
               group:(Club *)group
     selectedGroupId:(long long)selectedGroupId
            entrance:(id)entrance
              action:(SEL)action
{
    _leftItemView.hidden = NO;
    AlumniEntranceItemColorType colorType = 0;
    if (row % 2 == 0) {
        colorType = YELLOW_ITEM_TY;
    } else {
        colorType = GREENT_ITEM_TY;
    }
    
    if (selectedGroupId == group.clubId.longLongValue) {
        [WXWUIUtils addShadowForView:_leftItemView];
    } else {
        [WXWUIUtils removeShadowForView:_leftItemView];
    }
    
    [_leftItemView setEntrance:entrance
                    withAction:action
                 withColorType:colorType];
    
    [_leftItemView setGroupInfo:group];
}

- (void)hideLeftItem {
    _leftItemView.hidden = YES;
    _leftItemView.userInteractionEnabled = NO;
}

- (void)drawRightItem:(NSInteger)row
                group:(Club *)group
      selectedGroupId:(long long)selectedGroupId
             entrance:(id)entrance
               action:(SEL)action
{
    
    _rightItemView.hidden = NO;
    AlumniEntranceItemColorType colorType = 0;
    if (row % 2 == 0) {
        colorType = GREENT_ITEM_TY;
    } else {
        colorType = YELLOW_ITEM_TY;
    }
    
    if (selectedGroupId == group.clubId.longLongValue) {
        [WXWUIUtils addShadowForView:_rightItemView];
        
    } else {
        [WXWUIUtils removeShadowForView:_rightItemView];
    }

    [_rightItemView setEntrance:entrance
                     withAction:action
                  withColorType:colorType];
    
    [_rightItemView setGroupInfo:group];
}

- (void)hideRightItem {
    _rightItemView.hidden = YES;
    _rightItemView.userInteractionEnabled = NO;
}

@end
