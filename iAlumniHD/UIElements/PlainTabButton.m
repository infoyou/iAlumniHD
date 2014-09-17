//
//  PlainTabButton.m
//  iAlumniHD
//
//  Created by MobGuang on 13-2-18.
//
//

#import "PlainTabButton.h"
#import "WXWUIUtils.h"
#import "WXWLabel.h"

#define HIGHTLIGHT_TITLE_COLOR  COLOR(171, 15, 18) 
#define NORMAL_TITLE_COLOR      COLOR(54, 54, 54)

@implementation PlainTabButton

#pragma mark - lifecycle methods
- (id)initWithFrame:(CGRect)frame
     needLeftBorder:(BOOL)needLeftBorder
              title:(NSString *)title
             parent:(id)parent
    selectionAction:(SEL)selectionAction
        buttonIndex:(NSInteger)buttonIndex {
  
  self = [super initWithFrame:frame];
  if (self) {
    
    _parent = parent;
    
    _selectinAction = selectionAction;
    
    _needLeftBorder  = needLeftBorder;
    
    _buttonIndex = buttonIndex;
      
    _titleLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                         textColor:NORMAL_TITLE_COLOR
                                       shadowColor:TRANSPARENT_COLOR
                                              font:BOLD_FONT(13)] autorelease];
    _titleLabel.text = title;
    _titleLabel.textAlignment = UITextAlignmentCenter;
    _titleLabel.numberOfLines = 2;
    _titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
    CGSize size = [title sizeWithFont:_titleLabel.font
                    constrainedToSize:CGSizeMake(self.frame.size.width - MARGIN * 2, self.frame.size.height - MARGIN)
                        lineBreakMode:_titleLabel.lineBreakMode];
    _titleLabel.frame = CGRectMake((self.frame.size.width - size.width)/2.0f,
                                   (self.frame.size.height - size.height)/2.0f,
                                   size.width,
                                   size.height);
    [self addSubview:_titleLabel];
  }
  return self;
}

- (void)dealloc {
  
  [super dealloc];
}

- (void)changeBackgroundColor {
  
  if (_selected) {
    self.backgroundColor = COLOR(225, 225, 225);
  } else {
    self.backgroundColor = COLOR(195, 195, 195);
  }
}

- (void)drawBorderInContext:(CGContextRef)context {
  UIColor *borderColor = nil;
  UIColor *borderShadowColor = nil;
  if (_selected) {
    borderColor = COLOR(161, 161, 161);
    borderShadowColor = COLOR(213, 213, 213);
  } else {
    borderColor = COLOR(181, 181, 181);
    borderShadowColor = COLOR(204, 204, 204);
  }
  
  [WXWUIUtils draw1PxStroke:context
                 startPoint:CGPointMake(self.bounds.size.width - 2.0f, 0)
                   endPoint:CGPointMake(self.bounds.size.width - 2.0f, self.bounds.size.height)
                      color:borderColor.CGColor
               shadowOffset:CGSizeMake(1.0f, 0.0f)
                shadowColor:borderShadowColor];
}

- (void)drawRect:(CGRect)rect {
  
  if (_needLeftBorder) {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self drawBorderInContext:context];
  }
}

#pragma mark - user actions
- (void)select {
  _selected = YES;
  
  _titleLabel.textColor = HIGHTLIGHT_TITLE_COLOR;
  
  [self changeBackgroundColor];
  
  [self setNeedsDisplay];
}

- (void)deselect {
  _selected = NO;
  
  _titleLabel.textColor = NORMAL_TITLE_COLOR;
  
  [self changeBackgroundColor];
  
  [self setNeedsDisplay];
}

#pragma mark - touch event
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  if (_parent && _selectinAction) {
    [_parent performSelector:_selectinAction withObject:@(_buttonIndex)];
  }
}

@end
