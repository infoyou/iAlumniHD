//
//  TabSwitchView.m
//  iAlumniHD
//
//  Created by MobGuang on 12-8-29.
//
//

#import "TabSwitchView.h"
#import <QuartzCore/QuartzCore.h>
#import "TrapezoidalButton.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "WXWUIUtils.h"

#define BUTTON_HEIGHT   30.0f

#define INTERSECTION_SID_LENTGTH  2.0f

#define BUTTON_COLOR(BRIGHTNESS)    COLOR_HSB(0.0f, 0.0f, 94.0f, BRIGHTNESS)

@interface TabSwitchView()
@property (nonatomic, retain) NSMutableDictionary *buttonDic;
@end

@implementation TabSwitchView

@synthesize buttonDic = _buttonDic;

#pragma mark - switch action

- (void)arrangeButton:(NSInteger)selectedButtonTag {
  TrapezoidalButton *selectedButton = (TrapezoidalButton *)(self.buttonDic)[@(selectedButtonTag)];
  
  [self bringSubviewToFront:selectedButton];
  
  for (NSNumber *key in [self.buttonDic allKeys]) {
    
    TrapezoidalButton *button = (TrapezoidalButton *)(self.buttonDic)[key];
    
    if (key.intValue != selectedButtonTag) {
      button.color = BUTTON_COLOR(0.9f);
    } else {
      button.color = BUTTON_COLOR(1.0f);      
    }
    
    [button setNeedsDisplay];
  }
}

- (void)handleSwitch:(NSInteger)tabTag {
  [self arrangeButton:tabTag];
  
  if (_tapSwitchDelegate) {
    [_tapSwitchDelegate selectTapByIndex:tabTag];
  }
}

- (void)switchAction:(id)sender {
  TrapezoidalButton *button = (TrapezoidalButton *)sender;
  
  [self handleSwitch:button.tag];
}

#pragma mark - lifeycycle methods

- (void)initButton:(NSInteger)index
             title:(NSString *)title
             width:(CGFloat)width
           overlap:(NSUInteger)overlap {

  CGFloat buttonHeight = self.frame.size.height - MARGIN;
  
  CGRect tabFrame = CGRectMake(index * width,
                               self.frame.size.height - buttonHeight,
                               width, buttonHeight);
  
  if (index > 0) {
    tabFrame.origin.x -= index * overlap;
  }
  
  TrapezoidalButton *button = [[[TrapezoidalButton alloc] initWithFrame:tabFrame
                                                         topBorderShort:YES
                                                                  title:title
                                                              titleFont:BOLD_FONT(13)
                                                             titleColor:DARK_TEXT_COLOR
                                                        backgroundColor:BUTTON_COLOR(1.0f)
                                                                 target:self
                                                                 action:@selector(switchAction:)] autorelease];
  button.tag = index;
  [self addSubview:button];
  (self.buttonDic)[@(index)] = button;
}

- (id)initWithFrame:(CGRect)frame
       buttonTitles:(NSArray *)buttonTitles
  tapSwitchDelegate:(id<TapSwitchDelegate>)tapSwitchDelegate
           tabIndex:(NSInteger)tabIndex {
  self = [super initWithFrame:frame];
  if (self) {
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 0.0f;
    self.layer.borderColor = TRANSPARENT_COLOR.CGColor;

    _tapSwitchDelegate = tapSwitchDelegate;
    
    self.buttonDic = [NSMutableDictionary dictionary];
    
    _longerSideLength = (self.frame.size.width - MARGIN * 4)/buttonTitles.count;
    
    // calculate tab width
    CGFloat overlapAsPercentageOfTabWidth = 0.2f;
    CGFloat tabWidth = self.frame.size.width / buttonTitles.count;
    NSUInteger overlap = tabWidth * overlapAsPercentageOfTabWidth;
    tabWidth = (self.frame.size.width + overlap * (buttonTitles.count - 1)) / buttonTitles.count;
    
    for (int i = 0; i < buttonTitles.count; i++) {
      [self initButton:i
                 title:buttonTitles[i]
                 width:tabWidth
               overlap:overlap];
    }

    [self arrangeButton:tabIndex];
  }
  return self;
}

- (void)dealloc {
  
  self.buttonDic = nil;
  
  [super dealloc];
}

- (void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  [WXWUIUtils draw1PxStroke:context
              startPoint:CGPointMake(0, self.bounds.size.height - 1.0f)
                endPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height - 1.0f)
                   color:COLOR(218,221,228).CGColor
            shadowOffset:CGSizeMake(0, 0)
             shadowColor:TRANSPARENT_COLOR];
}

#pragma mark - bottom shadow
- (void)displayBottomShadow {
  
  if (_bottomShadowDisplaying) {
    return;
  }
  
  [UIView animateWithDuration:0.2f
                   animations:^{
                     UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.bounds];
                     self.layer.shadowPath = shadowPath.CGPath;
                     self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
                     self.layer.shadowOpacity = 0.9f;
                     self.layer.shadowColor = [UIColor blackColor].CGColor;
                     self.layer.masksToBounds = NO;
                     
                     _bottomShadowDisplaying = YES;
                   }];
}

- (void)hideBottomShadow {
  
  if (!_bottomShadowDisplaying) {
    return;
  }
  
  [UIView animateWithDuration:0.2f
                   animations:^{
                     self.layer.shadowPath = nil;
                     self.layer.shadowColor = TRANSPARENT_COLOR.CGColor;
                     
                     _bottomShadowDisplaying = NO;
                   }];
}

@end
