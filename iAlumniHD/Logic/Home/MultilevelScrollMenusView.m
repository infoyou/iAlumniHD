//
//  MultilevelScrollMenusView.m
//  iAlumniHD
//
//  Created by Adam on 12-10-9.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "MultilevelScrollMenusView.h"
#import "CommonUtils.h"
#import "TextConstants.h"
#import "SecondMenuButton.h"
#import "CPScrollView.h"
#import "CPShadowView.h"

#define ALUMNI_MENU_ITEM_COUNT                          8

@implementation MultilevelScrollMenusView

#pragma mark - user second menu actions

- (void)arrangeTitleToCenter
{
    _titleLabel.center = _secondLevelMenu.center;
}

- (void)setTitle:(NSString *)title
{
    _titleLabel.text = title;

    if (title) {
        CGSize size = [title sizeWithFont:_titleLabel.font
                        constrainedToSize:CGSizeMake(300, SECOND_LEVEL_HEIGHT)
                            lineBreakMode:UILineBreakModeWordWrap];
        _titleLabel.frame = CGRectMake(0, 0, size.width, SECOND_LEVEL_HEIGHT);
        _titleLabel.center = _secondLevelMenu.center;
    }
}

- (void)initSecondLevel:(CGFloat)width
{
    
    _secondLevelMenu = [[CPScrollView alloc] initWithFrame:CGRectMake(0, 0, width, SECOND_LEVEL_HEIGHT) startColor:COLOR(115, 116, 118) endColor:COLOR(25, 25, 25)];
    _secondLevelMenu.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _secondLevelMenu.canCancelContentTouches = NO;
    _secondLevelMenu.clipsToBounds = YES;
    _secondLevelMenu.scrollEnabled = NO;
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.backgroundColor = TRANSPARENT_COLOR;
    _titleLabel.font = BOLD_FONT(18);
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.textAlignment = UITextAlignmentCenter;
    [_secondLevelMenu addSubview:_titleLabel];
    
    [self addSubview:_secondLevelMenu];
}

- (id)initWithMenuType:(HomeMenuType)type
                 frame:(CGRect)frame
                target:(id)target
     arrangeViewAction:(SEL)arrangeViewAction
{
    
    self = [super init];
    
    if (self) {
        
        _target = target;
        _arrangeViewAction = arrangeViewAction;
        
        self.frame = frame;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        CPShadowView *shadowView = [[[CPShadowView alloc] initWithFrame:CGRectMake(-40, 0, 40, self.frame.size.height)] autorelease];
        
        [shadowView setBackgroundColor:TRANSPARENT_COLOR];
        [shadowView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [shadowView setClipsToBounds:NO];
        [self addSubview:shadowView];
        
        [self initSecondLevel:frame.size.width];
        
    }
    
    return self;
}

- (void)dealloc {
    
    RELEASE_OBJ(_secondLevelMenu);
    RELEASE_OBJ(_titleLabel);
    
    [super dealloc];
}

@end
