//
//  AlumniProfileTopBackgroundView.m
//  iAlumniHD
//
//  Created by MobGuang on 12-11-13.
//
//

#import "AlumniProfileTopBackgroundView.h"
#import <QuartzCore/QuartzCore.h>
#import "WXWLabel.h"
#import "Alumni.h"
#import "CircularAvatarBackgroundView.h"

#define AVATAR_RADIUS 40.0f

#define AVATAR_BORDER_WIDTH 5.0f
#define CIRCULAR_BACKGROUND_WIDTH (AVATAR_RADIUS + AVATAR_BORDER_WIDTH) * 2
#define CIRCULAR_BACKGROUND_HEIGHT 70.0f

#define TOP_BACKGROUND_VIEW_COLOR COLOR(234,234,234)

@interface AlumniProfileTopBackgroundView()
@property (nonatomic, retain) Alumni *alumni;
@end

@implementation AlumniProfileTopBackgroundView

- (WXWLabel *)initLabel:(CGRect)frame
             textColor:(UIColor *)textColor
           shadowColor:(UIColor *)shadowColor
                  font:(UIFont *)font {
  
  WXWLabel *label = [[WXWLabel alloc] initWithFrame:frame
                                        textColor:textColor
                                      shadowColor:shadowColor];
  label.font = font;
  
  return label;
}

- (void)addShadow {
  UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.bounds];
  
  self.layer.shadowPath = shadowPath.CGPath;
  self.layer.shadowColor = [UIColor darkGrayColor].CGColor;
  self.layer.shadowOffset = CGSizeMake(0, 0);
  self.layer.shadowOpacity = 0.9f;
  self.layer.masksToBounds = NO;
}

- (void)arrangeLabels {
    _nameLabel.text = self.alumni.name;
  
  CGFloat labelWidth = (self.frame.size.width - MARGIN * 4 - AVATAR_RADIUS * 2 - MARGIN * 4)/2.0f;
  CGFloat labelHeight = self.frame.size.height - MARGIN * 4;
  CGSize size = [self.alumni.name sizeWithFont:_nameLabel.font
                             constrainedToSize:CGSizeMake(labelWidth, labelHeight)
                                 lineBreakMode:UILineBreakModeWordWrap];
  _nameLabel.frame = CGRectMake(MARGIN * 2,
                                (self.frame.size.height - size.height)/2.0f,
                                size.width, size.height);
  
    _classLabel.text = self.alumni.classGroupName;
  
  size = [self.alumni.classGroupName sizeWithFont:_classLabel.font
                                constrainedToSize:CGSizeMake(labelWidth, labelHeight) lineBreakMode:UILineBreakModeWordWrap];
  _classLabel.frame = CGRectMake(self.frame.size.width - MARGIN * 2 - size.width,
                                 (self.frame.size.height - size.height)/2.0f,
                                 size.width, size.height);

}

- (void)refreshAfterAlumniLoaded:(Alumni *)alumni {
  self.alumni = alumni;
  
  [self arrangeLabels];
}

- (void)initViews {
  
  self.backgroundColor = TOP_BACKGROUND_VIEW_COLOR;
  
  [self addShadow];
  
  _circularAvatarBackgroundView = [[[CircularAvatarBackgroundView alloc] initWithFrame:CGRectMake((self.frame.size.width - CIRCULAR_BACKGROUND_WIDTH)/2.0f, MARGIN, CIRCULAR_BACKGROUND_WIDTH, CIRCULAR_BACKGROUND_HEIGHT)] autorelease];
  [self addSubview:_circularAvatarBackgroundView];
  
  _nameLabel = [[self initLabel:CGRectZero
                      textColor:DARK_TEXT_COLOR
                    shadowColor:TEXT_SHADOW_COLOR
                           font:BOLD_FONT(14)] autorelease];
  _nameLabel.numberOfLines = 0;
  [self addSubview:_nameLabel];
  
  _classLabel = [[self initLabel:CGRectZero
                       textColor:DARK_TEXT_COLOR
                     shadowColor:TEXT_SHADOW_COLOR
                            font:BOLD_FONT(14)] autorelease];
  _classLabel.numberOfLines = 0;
  [self addSubview:_classLabel];
  
  [self arrangeLabels];
}

- (id)initWithFrame:(CGRect)frame alumni:(Alumni *)alumni
{
  self = [super initWithFrame:frame];
  if (self) {
    
    self.alumni = alumni;
    
    [self initViews];
  }
  return self;
}

- (void)drawRect:(CGRect)rect {

}


@end
