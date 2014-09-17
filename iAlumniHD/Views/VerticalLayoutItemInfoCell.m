//
//  VerticalLayoutItemInfoCell.m
//  iAlumniHD
//
//  Created by Mobguang on 12-3-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "VerticalLayoutItemInfoCell.h"
#import <QuartzCore/QuartzCore.h>
#import "WXWLabel.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "WXWUIUtils.h"

#define ACCESS_DISCLOSUR_WIDTH      LIST_WIDTH - 90.f
#define ACCESS_NONE_WIDTH           LIST_WIDTH - 75.f

@implementation VerticalLayoutItemInfoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = SERVICE_ITEM_CELL_COLOR;
        /*
         _titleLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
         textColor:COLOR(30.0f, 30.0f, 30.0f)
         shadowColor:[UIColor whiteColor]] autorelease];
         */
        _titleLabel = [[self initLabel:CGRectZero
                             textColor:CELL_TITLE_COLOR
                           shadowColor:[UIColor whiteColor]] autorelease];
        
        _titleLabel.font = BOLD_FONT(14);
        [self.contentView addSubview:_titleLabel];
        
        _subTitleLabel = [[self initLabel:CGRectZero
                                textColor:[UIColor whiteColor]
                              shadowColor:TRANSPARENT_COLOR] autorelease];
        _subTitleLabel.backgroundColor = BASE_INFO_COLOR;
        _subTitleLabel.layer.masksToBounds = YES;
        _subTitleLabel.font = BOLD_FONT(10);
        _subTitleLabel.numberOfLines = 0;
        _subTitleLabel.lineBreakMode = UILineBreakModeWordWrap;
        _subTitleLabel.textAlignment = UITextAlignmentCenter;
        _subTitleLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
        [self.contentView addSubview:_subTitleLabel];
        
        _contentLabel = [[self initLabel:CGRectZero
                               textColor:BASE_INFO_COLOR
                             shadowColor:[UIColor whiteColor]] autorelease];
        _contentLabel.font = BOLD_FONT(13);
        _contentLabel.numberOfLines = 0;
        _contentLabel.lineBreakMode = UILineBreakModeWordWrap;
        [self.contentView addSubview:_contentLabel];
        
        
    }
    return self;
}

- (void)dealloc {
    
    [super dealloc];
}

- (void)arrangeView:(NSString *)title
           subTitle:(NSString *)subTitle
            content:(NSString *)content
contentConstrainedHeight:(CGFloat)contentConstrainedHeight
      lineBreakMode:(UILineBreakMode)lineBreakMode
          clickable:(BOOL)clickable {
    
    self.layer.shadowPath = nil;
    
    CGFloat width = 0.0f;
    if (clickable) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
        
        width = ACCESS_DISCLOSUR_WIDTH;
    } else {
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        width = ACCESS_NONE_WIDTH;
    }
    
    _titleLabel.text = title;
    
    CGSize size = [_titleLabel.text sizeWithFont:_titleLabel.font
                               constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                                   lineBreakMode:UILineBreakModeWordWrap];
    
    _titleLabel.frame = CGRectMake(MARGIN * 2, MARGIN * 2, size.width, size.height);
    
    if (subTitle && subTitle.length > 0) {
        _subTitleLabel.hidden = NO;
        
        _subTitleLabel.text = subTitle;
        size = [_subTitleLabel.text sizeWithFont:_subTitleLabel.font
                               constrainedToSize:CGSizeMake(self.contentView.frame.size.width -
                                                            (_titleLabel.frame.origin.x + size.width + MARGIN * 4),
                                                            CGFLOAT_MAX)
                                   lineBreakMode:UILineBreakModeWordWrap];
        _subTitleLabel.frame = CGRectMake(_titleLabel.frame.origin.x + _titleLabel.frame.size.width + MARGIN * 2,
                                          _titleLabel.frame.origin.y + _titleLabel.frame.size.height - size.height - 2.0f,
                                          size.width + MARGIN * 4, size.height);
        _subTitleLabel.layer.cornerRadius = size.height/2.0f;
    } else {
        _subTitleLabel.hidden = YES;
    }
    
    if (content && content.length > 0) {
        _contentLabel.hidden = NO;
        _contentLabel.text = content;
        _contentLabel.lineBreakMode = lineBreakMode;
        size = [_contentLabel.text sizeWithFont:_contentLabel.font
                              constrainedToSize:CGSizeMake(width, contentConstrainedHeight)
                                  lineBreakMode:lineBreakMode];
        _contentLabel.frame = CGRectMake(MARGIN * 2, _titleLabel.frame.origin.y + _titleLabel.frame.size.height +
                                         MARGIN, size.width, size.height);
    } else {
        _contentLabel.hidden = YES;
    }
}

- (void)drawNoShadowInfoCell:(NSString *)title
                    subTitle:(NSString *)subTitle
                     content:(NSString *)content
                   clickable:(BOOL)clickable {
    
    [self arrangeView:title
             subTitle:subTitle
              content:content
contentConstrainedHeight:CGFLOAT_MAX
        lineBreakMode:UILineBreakModeWordWrap
            clickable:clickable];
}

- (void)drawDashSeparatorNoShadowInfoCell:(NSString *)title
                                 subTitle:(NSString *)subTitle
                                  content:(NSString *)content
                                clickable:(BOOL)clickable
                               cellHeight:(CGFloat)cellHeight {
    
    _separatorType = DASH_LINE_TY;
    
    _cellHeight = cellHeight;
    
    [self arrangeView:title
             subTitle:subTitle
              content:content
contentConstrainedHeight:CGFLOAT_MAX
        lineBreakMode:UILineBreakModeWordWrap
            clickable:clickable];
}

- (void)drawShadowInfoCell:(NSString *)title
                  subTitle:(NSString *)subTitle
                   content:(NSString *)content
                cellHeight:(CGFloat)cellHeight
                 clickable:(BOOL)clickable {
    
    [self drawNoShadowInfoCell:title
                      subTitle:subTitle
                       content:content
                     clickable:clickable];
    
    [self drawOutBottomShadow:cellHeight];
    
}

- (void)drawShadowInfoCell:(NSString *)title
                  subTitle:(NSString *)subTitle
                   content:(NSString *)content
  contentConstrainedHeight:(CGFloat)contentConstrainedHeight
                cellheight:(CGFloat)cellheight
             lineBreakMode:(UILineBreakMode)lineBreakMode
                 clickable:(BOOL)clickable {
    
    [self arrangeView:title
             subTitle:subTitle
              content:content
contentConstrainedHeight:contentConstrainedHeight
        lineBreakMode:lineBreakMode
            clickable:clickable];
    
    [self drawOutBottomShadow:cellheight];
}

- (void)drawRect:(CGRect)rect {
    if (_separatorType == DASH_LINE_TY) {
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGFloat pattern[2] = {1, 2};
        
        [WXWUIUtils draw1PxDashLine:context
                      startPoint:CGPointMake(0, _cellHeight - 1.5f)
                        endPoint:CGPointMake(self.frame.size.width, _cellHeight - 1.5f)
                        colorRef:SEPARATOR_LINE_COLOR.CGColor
                    shadowOffset:CGSizeMake(0.0f, 1.0f)
                     shadowColor:[UIColor whiteColor]
                         pattern:pattern];
    }
}

@end
