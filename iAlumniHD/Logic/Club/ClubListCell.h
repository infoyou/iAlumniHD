//
//  ClubListCell.h
//  iAlumniHD
//
//  Created by Adam on 12-10-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseUITableViewCell.h"
#import "Club.h"

@interface ClubListCell : BaseUITableViewCell{
    
    UILabel *_name;
    UILabel *_post;
    
    UILabel *_postLabel;
    UILabel *_postNum;
    
    UILabel *_eventLabel;
    UILabel *_eventNum;
    
    UILabel *_memberLabel;
    UILabel *_memberNum;
    
    UILabel *_lineView;
    
    WXWLabel *_time;
}

- (void)drawClub:(Club *)club;

@end
