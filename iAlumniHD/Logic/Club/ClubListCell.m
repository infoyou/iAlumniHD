//
//  ClubListCell.m
//  iAlumniHD
//
//  Created by Adam on 12-10-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ClubListCell.h"

#define FONT_SIZE         14.0f
#define TITLE_HEIGHT      20.0f
#define NUMBER_W          5 * MARGIN
#define LABEL_H           20.0f
#define BOTTOM_LABEL_Y    CLUB_LIST_CELL_HEIGHT - 5 * MARGIN

static int LABEL_W = 0;

@implementation ClubListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        if([AppManager instance].currentLanguageCode == EN_TY) {
            LABEL_W = 47.f;
        } else {
            LABEL_W = 8 * MARGIN;
        }
        
        _name = [self initLabel:CGRectZero
                      textColor:[UIColor blackColor]
                    shadowColor:[UIColor whiteColor]];
        _name.backgroundColor = TRANSPARENT_COLOR;
        _name.font = BOLD_FONT(FONT_SIZE);
        _name.lineBreakMode = UILineBreakModeTailTruncation;
        _name.numberOfLines = 1;
        _name.textAlignment = UITextAlignmentLeft;
        [self.contentView addSubview:_name];
        
        _post = [self initLabel:CGRectZero
                      textColor:[UIColor blackColor]
                    shadowColor:[UIColor whiteColor]];

        _post.backgroundColor = TRANSPARENT_COLOR;
        _post.font = Arial_FONT(FONT_SIZE);
        _post.lineBreakMode = UILineBreakModeTailTruncation;
        _post.numberOfLines = 1;
        [self.contentView addSubview:_post];
        
        // post
        _postLabel = [self initLabel:CGRectZero
                           textColor:COLOR(112, 112, 112)
                         shadowColor:[UIColor whiteColor]];
        _postLabel.backgroundColor = TRANSPARENT_COLOR;
        _postLabel.font = FONT(FONT_SIZE-3);
        _postLabel.text = [NSString stringWithFormat:@"%@: ", LocaleStringForKey(NSClubListPostTitle, nil)];
        [self.contentView addSubview:_postLabel];
        
        _postNum = [self initLabel:CGRectZero
                           textColor:COLOR(193, 95, 70)
                         shadowColor:[UIColor whiteColor]];
        _postNum.backgroundColor = TRANSPARENT_COLOR;
        _postNum.font = BOLD_FONT(FONT_SIZE-3);
        [self.contentView addSubview:_postNum];
        
        // event
        _eventLabel = [self initLabel:CGRectZero
                           textColor:COLOR(112, 112, 112)
                         shadowColor:[UIColor whiteColor]];
        _eventLabel.backgroundColor = TRANSPARENT_COLOR;
        _eventLabel.font = FONT(FONT_SIZE-3);
        _eventLabel.text = [NSString stringWithFormat:@"%@: ", LocaleStringForKey(NSClubListEventTitle, nil)];
        [self.contentView addSubview:_eventLabel];
        
        _eventNum = [self initLabel:CGRectZero
                         textColor:COLOR(193, 95, 70)
                       shadowColor:[UIColor whiteColor]];
        _eventNum.backgroundColor = TRANSPARENT_COLOR;
        _eventNum.font = BOLD_FONT(FONT_SIZE-3);
        [self.contentView addSubview:_eventNum];
        
        // member
        _memberLabel = [self initLabel:CGRectZero
                           textColor:COLOR(112, 112, 112)
                         shadowColor:[UIColor whiteColor]];
        _memberLabel.backgroundColor = TRANSPARENT_COLOR;
        _memberLabel.font = FONT(FONT_SIZE-3);
        _memberLabel.text = [NSString stringWithFormat:@"%@: ", LocaleStringForKey(NSClubListMemberTitle, nil)];
        [self.contentView addSubview:_memberLabel];
        
        _memberNum = [self initLabel:CGRectZero
                         textColor:COLOR(193, 95, 70)
                       shadowColor:[UIColor whiteColor]];
        _memberNum.backgroundColor = TRANSPARENT_COLOR;
        _memberNum.font = BOLD_FONT(FONT_SIZE-3);
        [self.contentView addSubview:_memberNum];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)dealloc
{
    RELEASE_OBJ(_name);
    RELEASE_OBJ(_post);
    RELEASE_OBJ(_eventNum);
    RELEASE_OBJ(_eventLabel);
    RELEASE_OBJ(_lineView);
    RELEASE_OBJ(_memberNum);
    RELEASE_OBJ(_memberLabel);
    [super dealloc];
}

- (void)drawClub:(Club *)club
{
    // name
    _name.frame = CGRectMake(MARGIN * 2, MARGIN * 2, LIST_WIDTH - MARGIN * 6, TITLE_HEIGHT);
    _name.text = club.clubName;
    
    //draw badge number
    int badgeNum = [club.badgeNum intValue];
    
    if (badgeNum > 0) {
        
        UIImage *badgeImage = [[UIImage imageNamed:@"badge.png"]
                               stretchableImageWithLeftCapWidth:15
                               topCapHeight:10];
        UIButton *badgeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [badgeButton setBackgroundColor:TRANSPARENT_COLOR];
        [badgeButton setBackgroundImage:badgeImage forState:UIControlStateNormal];
        badgeButton.adjustsImageWhenHighlighted = NO;
        badgeButton.contentEdgeInsets = UIEdgeInsetsMake(1, 8, 1, 8);
        [badgeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        badgeButton.titleLabel.font = BOLD_FONT(11);
        badgeButton.titleLabel.textAlignment = UITextAlignmentCenter;
        [badgeButton setTitle:[NSString stringWithFormat:@"%d", badgeNum]
                     forState:UIControlStateNormal];
        [badgeButton sizeToFit];
        
        CGRect badgeRect = badgeButton.frame;
        badgeRect.origin.x = LIST_WIDTH - badgeRect.size.width - 2*MARGIN;
        badgeRect.origin.y = MARGIN;
        badgeButton.frame = badgeRect;
        
        [self.contentView addSubview:badgeButton];
    }
    
    // post
    if (club.postDesc && ![@"" isEqualToString:club.postDesc]) {
        _post.text = [NSString stringWithFormat:@"%@: %@", club.postAuthor, club.postDesc];
        CGSize postSize = [_name.text sizeWithFont:_post.font
                                 constrainedToSize:CGSizeMake(_post.frame.size.width, UILineBreakModeTailTruncation)
                                     lineBreakMode:UILineBreakModeTailTruncation];
        _post.frame = CGRectMake(MARGIN * 2, MARGIN * 7, LIST_WIDTH - MARGIN * 6, postSize.height);
    }
    
    // bottom
    _postLabel.frame = CGRectMake(MARGIN * 2, BOTTOM_LABEL_Y, LABEL_W, LABEL_H);
    _postNum.frame = CGRectMake(_postLabel.frame.origin.x + LABEL_W, BOTTOM_LABEL_Y, NUMBER_W, LABEL_H);
    _postNum.text = club.postNum;
    
    _eventLabel.frame = CGRectMake(MARGIN * 2 + LABEL_W + NUMBER_W, BOTTOM_LABEL_Y, LABEL_W, LABEL_H);
    _eventNum.frame = CGRectMake(_eventLabel.frame.origin.x + LABEL_W, BOTTOM_LABEL_Y, NUMBER_W, LABEL_H);
    _eventNum.text = club.activity;
    
    _memberLabel.frame = CGRectMake(MARGIN * 2 + LABEL_W*2 + NUMBER_W*2, BOTTOM_LABEL_Y, LABEL_W, LABEL_H);
    _memberNum.frame = CGRectMake(_memberLabel.frame.origin.x + LABEL_W, BOTTOM_LABEL_Y, NUMBER_W, LABEL_H);
    _memberNum.text = club.member;
    
    // time
    if (![@"" isEqualToString:club.postDesc]) {
        _time = [[WXWLabel alloc] initWithFrame:CGRectZero
                                     textColor:BASE_INFO_COLOR
                                   shadowColor:[UIColor whiteColor]];
        _time.font = BOLD_FONT(FONT_SIZE-3);
        [self.contentView addSubview:_time];
        
        _time.text = club.postTime;
        CGSize timeSize = [_time.text sizeWithFont:_time.font
                                 constrainedToSize:CGSizeMake(200, CGFLOAT_MAX)
                                     lineBreakMode:UILineBreakModeTailTruncation];
        _time.frame = CGRectMake(LIST_WIDTH - timeSize.width - MARGIN*2,
                                 BOTTOM_LABEL_Y, timeSize.width, LABEL_H);
    }
    
//    [self setCellStyle:CLUB_LIST_CELL_HEIGHT];
}

@end
