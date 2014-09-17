//
//  StartUpListCell.h
//  iAlumniHD
//
//  Created by Adam on 11-12-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "BaseUITableViewCell.h"

@class Event;

@interface StartUpListCell : BaseUITableViewCell {
    
@private
    UIImageView *_bgBackView;
    
    UIImageView *_postImageView;
    UIImageView *_eventDateImageView;
    WXWLabel *_titleLabel;
    UILabel *_descLabel;
    
    WXWLabel *_dateLabel;
    WXWLabel *_intervalDayLabel;
    WXWLabel *_signUpCountLabel;
    
    WXWLabel *_checkInCountPrefixLabel;
    WXWLabel *_checkInCountLabel;
    WXWLabel *_checkInCountSuffixLabel;
    
    NSString *_url;

}

@property (nonatomic, retain) NSString *url;

- (void)drawStartUp:(Event *)event;
@end

