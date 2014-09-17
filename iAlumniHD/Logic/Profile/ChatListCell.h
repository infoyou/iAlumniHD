//
//  ChatListCell.h
//  iAlumniHD
//
//  Created by Adam on 12-11-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseUITableViewCell.h"
#import "CMPopTipView.h"

@class Chat;
@class AlumniDetail;

@interface ChatListCell : BaseUITableViewCell <CMPopTipViewDelegate>
{
    UIView *parentView;
    UILabel *bubbleLabel;
    UIView *popView;
    UILabel *dateLabel;
    UIImageView *bubbleImageView;
    UIButton *_selfImageButton;
    UIButton *_targetImageButton;
    NSString *selfImgUrl;
    NSString *targetImgUrl;
    
    UIButton *_popViewBut;
    AlumniDetail    *_alumni;
    
    id<ECClickableElementDelegate> _delegate;
}

@property (nonatomic, retain) UIView *parentView;
@property (nonatomic, copy) NSString *selfImgUrl;
@property (nonatomic, copy) NSString *targetImgUrl;

- (void)drawChat:(Chat*)chart;
- (id)initWithStyle:(UITableViewCellStyle)style alumni:(AlumniDetail*)alumni reuseIdentifier:(NSString *)reuseIdentifier imageClickableDelegate:(id<ECClickableElementDelegate>)imageClickableDelegate;

@end
