//
//  VideoToolView.m
//  iAlumniHD
//
//  Created by Adam on 13-1-10.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "VideoToolView.h"
#import "WXWLabel.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "WXWUIUtils.h"

#define ITEM_HEIGHT     30.0f
#define LABEL_HEIGHT    20.0f

#define LABEL_X         MARGIN*9

@implementation VideoToolView

#pragma mark - shake user list
- (void)showTypeFilters:(id)sender {
    [_delegate showVideoTypeList:sender];
}

- (void)showSortFilters:(id)sender {
    [_delegate showVideoSortList:sender];
}

- (void)addShadowEffect {
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPath];
    [shadowPath moveToPoint:CGPointMake(0, self.frame.size.height)];
    [shadowPath addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height)];
    [shadowPath addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height + 2)];
    [shadowPath addLineToPoint:CGPointMake(0, self.frame.size.height + 2)];
    [shadowPath addLineToPoint:CGPointMake(0, self.frame.size.height)];
    
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.layer.shadowOpacity = 0.7f;
    self.layer.masksToBounds = NO;
    self.layer.shadowPath = shadowPath.CGPath;
    
}

- (id)initForVideo:(CGRect)frame
          topColor:(UIColor *)topColor
       bottomColor:(UIColor *)bottomColor
          delegate:(id<FilterListDelegate>)delegate
  userListDelegate:(id<ECClickableElementDelegate>)userListDelegate{
    
    self = [super initWithFrame:frame topColor:topColor bottomColor:bottomColor];
    if (self) {

        _delegate = delegate;
        
        CGRect filterFrame = CGRectMake(0, 0, self.frame.size.width, TOOL_TITLE_HEIGHT);
        UIImageView *filterView = [[[UIImageView alloc] initWithFrame:filterFrame] autorelease];
        filterView.image = [UIImage imageNamed:@"fliter_bar.png"];
        filterView.userInteractionEnabled = YES;
        [self addSubview:filterView];

        // type
        _typeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _typeButton.frame = CGRectMake(0, 0, LIST_WIDTH/2.f, TOOL_TITLE_HEIGHT);
        [_typeButton addTarget:self action:@selector(showTypeFilters:)
              forControlEvents:UIControlEventTouchUpInside];

        [_typeButton setBackgroundColor:TRANSPARENT_COLOR];
        [self addSubview:_typeButton];
        
        // Label
        _typeLabel = [[WXWLabel alloc] initWithFrame:CGRectMake(LABEL_X, 12, 155.f, LABEL_HEIGHT)
                                           textColor:COLOR(71, 71, 72)
                                         shadowColor:[UIColor whiteColor]];
        _typeLabel.font = BOLD_FONT(15);
        _typeLabel.lineBreakMode = UILineBreakModeTailTruncation;
        _typeLabel.backgroundColor = TRANSPARENT_COLOR;
        
        [_typeButton addSubview:_typeLabel];
        
        // icon
        UIImageView *iconView = [[[UIImageView alloc] initWithFrame:CGRectMake(150.f, 18.f, 10.f, 9.33f)] autorelease];
        iconView.image = [UIImage imageNamed:@"video_fliter.png"];
        iconView.backgroundColor = TRANSPARENT_COLOR;
        
        [_typeButton addSubview:iconView];
        
        // sort button
        _sortButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sortButton.frame = CGRectMake(LIST_WIDTH/2.f, 0, LIST_WIDTH/2.f, TOOL_TITLE_HEIGHT);
        [_sortButton addTarget:self action:@selector(showSortFilters:)
         forControlEvents:UIControlEventTouchUpInside];

        [_sortButton setBackgroundColor:TRANSPARENT_COLOR];
        [self addSubview:_sortButton];
        
        _sortLabel = [[WXWLabel alloc] initWithFrame:CGRectMake(LABEL_X, 12, 155.f, LABEL_HEIGHT) textColor:COLOR(71, 71, 72) shadowColor:[UIColor whiteColor]];
        _sortLabel.font = BOLD_FONT(15);
        _sortLabel.lineBreakMode = UILineBreakModeTailTruncation;
        _sortLabel.backgroundColor = TRANSPARENT_COLOR;
        [_sortButton addSubview:_sortLabel];
        
        UIImageView *sortIconView = [[[UIImageView alloc] initWithFrame:CGRectMake(150.f, 18.f, 10.f, 9.33f)] autorelease];
        sortIconView.image = [UIImage imageNamed:@"video_fliter.png"];
        sortIconView.backgroundColor = TRANSPARENT_COLOR;
        [_sortButton addSubview:sortIconView];
        
        _typeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        _sortButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        
        [self addShadowEffect];
    }
    
    return self;
}

- (void) onTest {
    NSLog(@"aaaaaa");
}

- (void)drawRect:(CGRect)rect {
    CGPoint startPoint = CGPointMake(0, rect.size.height - 1);
    CGPoint endPoint = CGPointMake(rect.size.width, rect.size.height - 1);
    
    CGColorRef borderColorRef = COLOR(225, 225, 226).CGColor;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [WXWUIUtils draw1PxStroke:context
                startPoint:startPoint
                  endPoint:endPoint
                     color:borderColorRef
              shadowOffset:CGSizeZero
               shadowColor:TRANSPARENT_COLOR];
    
}

- (void)dealloc {
    
    RELEASE_OBJ(_typeLabel);
    RELEASE_OBJ(_sortLabel);
    
    [super dealloc];
}

#pragma mark - biz methods

- (void)setType:(NSString *)type sort:(NSString *)sort
{
    if (![@"-1" isEqualToString:type])
        _typeLabel.text = type;
    
    if (![@"-1" isEqualToString:sort])
        _sortLabel.text = sort;
}

@end
