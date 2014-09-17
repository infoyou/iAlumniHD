//
//  ConfigurableTextCell.m
//  iAlumniHD
//
//  Created by MobGuang on 12-11-18.
//
//

#import "ConfigurableTextCell.h"
#import "WXWLabel.h"


@interface ConfigurableTextCell()
@property (nonatomic, retain) NSMutableArray *labelsContainer;
@end

@implementation ConfigurableTextCell

#pragma mark - lifecycle methods
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.labelsContainer = [NSMutableArray array];
        
        _titleLabel = [[self initLabel:CGRectZero
                             textColor:CELL_TITLE_COLOR
                           shadowColor:[UIColor whiteColor]] autorelease];
        
        _titleLabel.font = COMMON_CELL_TITLE_FONT;
        [self.contentView addSubview:_titleLabel];
        
        _subTitleLabel = [[self initLabel:CGRectZero
                                textColor:[UIColor whiteColor]
                              shadowColor:TRANSPARENT_COLOR] autorelease];
        _subTitleLabel.backgroundColor = BASE_INFO_COLOR;
        _subTitleLabel.layer.masksToBounds = YES;
        _subTitleLabel.font = COMMON_CELL_SUBTITLE_FONT;
        _subTitleLabel.numberOfLines = 0;
        _subTitleLabel.lineBreakMode = UILineBreakModeWordWrap;
        _subTitleLabel.textAlignment = UITextAlignmentCenter;
        _subTitleLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
        [self.contentView addSubview:_subTitleLabel];
        
        _contentLabel = [[self initLabel:CGRectZero
                               textColor:BASE_INFO_COLOR
                             shadowColor:[UIColor whiteColor]] autorelease];
        _contentLabel.font = COMMON_CELL_CONTENT_FONT;
        _contentLabel.numberOfLines = 0;
        _contentLabel.lineBreakMode = UILineBreakModeWordWrap;
        [self.contentView addSubview:_contentLabel];
        
    }
    return self;
}

- (void)dealloc {
    
    self.labelsContainer = nil;
    
    [super dealloc];
}

#pragma mark - label handlers
- (WXWLabel *)initLabel:(CGRect)frame
             textColor:(UIColor *)textColor
           shadowColor:(UIColor *)shadowColor {
    
    WXWLabel *label = [[WXWLabel alloc] initWithFrame:frame
                                          textColor:textColor
                                        shadowColor:shadowColor];
    
    if (nil == self.labelsContainer) {
        self.labelsContainer = [NSMutableArray array];
    }
    
    [self.labelsContainer addObject:label];
    return label;
}

#pragma mark - remove shadow of labels when selected or highlighted

- (void)applyLabelsShadow:(BOOL)needShadow {
    for (WXWLabel *label in self.labelsContainer) {
        if (label.noShadow) {
            label.shadowColor = nil;
        } else {
            label.shadowColor = needShadow ? [UIColor whiteColor] : nil;
        }
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    [self applyLabelsShadow:!highlighted];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    [self applyLabelsShadow:!selected];
}

#pragma mark - draw cell
- (void)drawCellWithTitle:(NSString *)title
                 subTitle:(NSString *)subTitle
                  content:(NSString *)content
     contentLineBreakMode:(UILineBreakMode)contentLineBreakMode
               cellHeight:(CGFloat)cellHeight
                clickable:(BOOL)clickable
            hasTitleImage:(BOOL)hasTitleImage {
    
    CGFloat width = 0.0f;
    if (clickable) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
        
        if ([self tableViewIsGrouped]) {
            if (hasTitleImage) {
                width = GROUPED_TABLE_WITH_TITLE_IMAGE_ACCESS_DISCLOSUR_WIDTH;
            } else {
                width = GROUPED_TABLE_NO_TITLE_IMAGE_ACCESS_DISCLOSUR_WIDTH;
            }
            
        } else {
            if (hasTitleImage) {
                width = PLAIN_TABLE_WITH_TITLE_IMAGE_ACCESS_DISCLOSUR_WIDTH;
            } else {
                width = PLAIN_TABLE_NO_TITLE_IMAGE_ACCESS_DISCLOSUR_WIDTH;
            }
        }
        
    } else {
        
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if ([self tableViewIsGrouped]) {
            if (hasTitleImage) {
                width = GROUPED_TABLE_WITH_TITLE_IMAGE_ACCESS_NONE_WIDTH;
            } else {
                width = GROUPED_TABLE_NO_TITLE_IMAGE_ACCESS_NONE_WIDTH;
            }
        } else {
            if (hasTitleImage) {
                width = PLAIN_TABLE_WITH_IMAGE_ACCESS_NONE_WIDTH;
            } else {
                width = PLAIN_TABLE_NO_IMAGE_ACCESS_NONE_WIDTH;
            }
        }
    }
    
    _titleLabel.text = title;
    
    CGSize size = [_titleLabel.text sizeWithFont:_titleLabel.font
                               constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                                   lineBreakMode:UILineBreakModeWordWrap];
    
    CGFloat x = MARGIN * 2;
    if (hasTitleImage) {
        x += CELL_TITLE_IMAGE_SIDE_LENGTH + MARGIN * 2;
    }
    _titleLabel.frame = CGRectMake(x, MARGIN * 2, size.width, size.height);
    
    if (subTitle && subTitle.length > 0) {
        _subTitleLabel.hidden = NO;
        
        _subTitleLabel.text = subTitle;
        size = [_subTitleLabel.text sizeWithFont:_subTitleLabel.font
                               constrainedToSize:CGSizeMake(self.contentView.frame.size.width -
                                                            (_titleLabel.frame.origin.x + size.width + MARGIN * 4),
                                                            CGFLOAT_MAX)
                                   lineBreakMode:UILineBreakModeWordWrap];
        
        CGFloat subTitleLabelWidth = size.width + MARGIN * 4;
        _subTitleLabel.frame = CGRectMake(_titleLabel.frame.origin.x + _titleLabel.frame.size.width + MARGIN * 2,
                                          _titleLabel.frame.origin.y + _titleLabel.frame.size.height - size.height - 2.0f,
                                          subTitleLabelWidth, size.height);
        
        _subTitleLabel.layer.cornerRadius = size.height/2.0f;
    } else {
        _subTitleLabel.hidden = YES;
    }
    
    if (content && content.length > 0) {
        _contentLabel.hidden = NO;
        _contentLabel.text = content;
        _contentLabel.lineBreakMode = contentLineBreakMode;
        size = [_contentLabel.text sizeWithFont:_contentLabel.font
                              constrainedToSize:CGSizeMake(width, cellHeight)
                                  lineBreakMode:contentLineBreakMode];
        _contentLabel.frame = CGRectMake(MARGIN * 2,
                                         _titleLabel.frame.origin.y + _titleLabel.frame.size.height +
                                         MARGIN,
                                         size.width,
                                         size.height);
    } else {
        _contentLabel.hidden = YES;
    }
}

- (void)drawCommonCellWithTitle:(NSString *)title
                       subTitle:(NSString *)subTitle
                        content:(NSString *)content
           contentLineBreakMode:(UILineBreakMode)contentLineBreakMode
                     cellHeight:(CGFloat)cellHeight
                      clickable:(BOOL)clickable {
    
    [self drawCellWithTitle:title
                   subTitle:subTitle
                    content:content
       contentLineBreakMode:contentLineBreakMode
                 cellHeight:cellHeight
                  clickable:clickable
              hasTitleImage:NO];
    
}

- (void)drawHeaderCellWithTitle:(NSString *)title
                       subTitle:(NSString *)subTitle
                        content:(NSString *)content
                     cellHeight:(CGFloat)cellHeight {
    
    _titleLabel.font = HEADER_CELL_TITLE_FONT;
    
    _titleLabel.textColor = DARK_TEXT_COLOR;
    
    self.gradientStartColor = COLOR(246.0f, 244.0f, 241.0f);
    self.gradientEndColor = COLOR(241.0f, 238.0f, 234.0f);
    
    [self drawCellWithTitle:title
                   subTitle:subTitle
                    content:content
       contentLineBreakMode:UILineBreakModeWordWrap
                 cellHeight:cellHeight
                  clickable:NO
              hasTitleImage:NO];
}

@end
