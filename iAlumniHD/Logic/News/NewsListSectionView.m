//
//  NewsListSectionView.m
//  iAlumniHD
//
//  Created by Adam on 12-11-23.
//
//

#import "NewsListSectionView.h"
#import <QuartzCore/QuartzCore.h>
#import "WXWLabel.h"
#import "GlobalConstants.h"
#import "WXWUIUtils.h"

@implementation NewsListSectionView

- (id)initWithFrame:(CGRect)frame title:(NSString *)title
{
  self = [super initWithFrame:frame];
  if (self) {
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundColor = TRANSPARENT_COLOR;
    
    CAGradientLayer *gradientLayer = (CAGradientLayer *)self.layer;

    gradientLayer.colors = @[(id)COLOR(170, 170, 170).CGColor, (id)COLOR(212, 212, 212).CGColor];
    NSArray *locations = [[NSArray alloc] initWithObjects:@0.50f, @1.0f, nil];
    gradientLayer.locations = locations;
    RELEASE_OBJ(locations);
    
    WXWLabel *titleLable = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                textColor:[UIColor whiteColor]
                                              shadowColor:COLOR(136, 136, 136)] autorelease];
    titleLable.backgroundColor = TRANSPARENT_COLOR;
    titleLable.font = BOLD_FONT(12);
    titleLable.text = title;
    CGSize size = [titleLable.text sizeWithFont:titleLable.font
                              constrainedToSize:CGSizeMake(320, frame.size.height - 2)
                                  lineBreakMode:UILineBreakModeWordWrap];
    titleLable.frame = CGRectMake(self.frame.size.width - MARGIN * 2 - size.width, 2, size.width, 13);
    [self addSubview:titleLable];
    
  }
  return self;
}

- (void)drawRect:(CGRect)rect {
  // draw top and bottom border
  CGPoint startPoint = CGPointMake(0, 0);
  CGPoint endPoint = CGPointMake(self.frame.size.width, 0);
  
  CGColorRef borderColorRef = COLOR(113,125,133).CGColor;
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  [WXWUIUtils draw1PxStroke:context
              startPoint:startPoint
                endPoint:endPoint
                   color:borderColorRef
            shadowOffset:CGSizeMake(0, 1.0f)
             shadowColor:COLOR(165, 177, 186)];
  
}


+ (Class)layerClass
{
	return [CAGradientLayer class];
}


- (void)dealloc {
  
  [super dealloc];
}


@end
