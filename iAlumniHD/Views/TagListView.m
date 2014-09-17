//
//  TagListView.m
//  iAlumniHD
//
//  Created by Mobguang on 12-6-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TagListView.h"
#import "Tag.h"
#import "WXWUIUtils.h"
#import "WXWLabel.h"
#import "GlobalConstants.h"

#define ICON_WIDTH  16.0f
#define ICON_HEIGHT 16.0f

@interface TagListView()
@property (nonatomic, retain) NSMutableDictionary *tagAndLabelDic;
@property (nonatomic, retain) CAGradientLayer *maskLayer;
@end

@implementation TagListView

@synthesize tagAndLabelDic = _tagAndLabelDic;
@synthesize maskLayer = _maskLayer;

- (void)addMaskLayerIfNeeded {
  
  if (_tagsContainerView.frame.size.width >= _tagsContainerView.contentSize.width) {
    // the content width less than the size of scroll view, then no need to add the fading effect for edge
    return;
  }
  
  if (nil == self.maskLayer) {
    self.maskLayer = [CAGradientLayer layer];
    
    CGColorRef innerColor = CELL_COLOR.CGColor;
    
    CGColorRef outerColor = TRANSPARENT_COLOR.CGColor;
        
    self.maskLayer.colors = [NSArray arrayWithObjects:(id)outerColor,
                             (id)innerColor, (id)innerColor, (id)outerColor, nil];
    self.maskLayer.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0f], 
                           [NSNumber numberWithFloat:0.05f], 
                           [NSNumber numberWithFloat:0.95f],
                           [NSNumber numberWithFloat:1.0f], nil];
    
    self.maskLayer.startPoint = CGPointMake(0.0f, 0.5f);
    self.maskLayer.endPoint = CGPointMake(1.0f, 0.5f);
    
    self.maskLayer.bounds = CGRectMake(0, 0, _tagsContainerView.frame.size.width, _tagsContainerView.frame.size.height);
    self.maskLayer.anchorPoint = CGPointZero;
    
    _tagsContainerView.layer.mask = self.maskLayer;
  }
}

- (void)addTagIcon {
  _icon = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
  _icon.backgroundColor = TRANSPARENT_COLOR;
  _icon.image = [UIImage imageNamed:@"tag.png"];
  [self addSubview:_icon];
}

- (CGSize)sizeOfTagContent:(NSArray *)tags {
  
  self.tagAndLabelDic = [NSMutableDictionary dictionary];
  
  CGFloat labelStartX = 0.0f;
  
  for (Tag *tag in tags) {
    
    WXWLabel *label = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                           textColor:BASE_INFO_COLOR
                                         shadowColor:[UIColor whiteColor]] autorelease];
    label.textAlignment = UITextAlignmentLeft;
    label.font = FONT(11);
    
    label.text = [NSString stringWithFormat:@"%@", tag.tagName];
    
    CGSize size = [label.text sizeWithFont:label.font
                         constrainedToSize:CGSizeMake(self.frame.size.width, CGFLOAT_MAX)
                             lineBreakMode:UILineBreakModeWordWrap];
    
    labelStartX += MARGIN * 2;
    
    label.frame = CGRectMake(labelStartX, 
                             (_tagsContainerView.frame.size.height - size.height)/2.0f, 
                             size.width + MARGIN, size.height);
    
    [_tagsContainerView addSubview:label];
    
    labelStartX += label.frame.size.width;//size.width;
    
    [self.tagAndLabelDic setObject:label forKey:tag.tagId];
  }
  
  return CGSizeMake(labelStartX, _tagsContainerView.frame.size.height);
}

- (void)addScrollView {
  
  _tagsContainerView = [[[UIScrollView alloc] initWithFrame:CGRectZero] autorelease];
  _tagsContainerView.backgroundColor = TRANSPARENT_COLOR;
  _tagsContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  _tagsContainerView.canCancelContentTouches = NO;
  _tagsContainerView.clipsToBounds = YES;
  _tagsContainerView.scrollEnabled = YES;
  _tagsContainerView.showsVerticalScrollIndicator = NO;
  _tagsContainerView.showsHorizontalScrollIndicator = NO;
  _tagsContainerView.delegate = self;
  
  [self addSubview:_tagsContainerView];
}

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    
    self.backgroundColor = TRANSPARENT_COLOR;
    
    [self addTagIcon];
    
    [self addScrollView];
  }
  return self;
}

- (void)dealloc {
  
  self.tagAndLabelDic = nil;
  self.maskLayer = nil;
  
  _tagsContainerView.delegate = nil;
  
  [super dealloc];
}

- (void)drawViews:(NSArray *)tags {
    
  _icon.frame = CGRectMake(MARGIN * 7.5,
                           0, 
                           ICON_WIDTH,
                           ICON_HEIGHT);
  
  CGFloat x = MARGIN;
  _tagsContainerView.frame = CGRectMake(x, _icon.frame.size.height,
                                        self.frame.size.width - x - MARGIN * 2, 
                                        self.frame.size.height - _icon.frame.size.height);
  
  if (self.tagAndLabelDic.count == 0) {
    _tagsContainerView.contentSize = [self sizeOfTagContent:tags];
  }
  
  [self addMaskLayerIfNeeded];
}

- (void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  CGFloat pattern[2] = {2.0, 2.0};
  
  CGFloat y = ICON_HEIGHT/2.0f + 0.5f;
  [WXWUIUtils draw1PxDashLine:context 
                startPoint:CGPointMake(MARGIN * 2, y)
                  endPoint:CGPointMake(MARGIN * 6, y)
                  colorRef:SEPARATOR_LINE_COLOR.CGColor
              shadowOffset:CGSizeMake(0.0f, 1.0f)
               shadowColor:[UIColor whiteColor]
                   pattern:pattern];

  [WXWUIUtils draw1PxDashLine:context 
                startPoint:CGPointMake(_icon.frame.origin.x + ICON_WIDTH + MARGIN, y)
                  endPoint:CGPointMake(self.frame.size.width - MARGIN * 2, y)
                  colorRef:SEPARATOR_LINE_COLOR.CGColor
              shadowOffset:CGSizeMake(0.0f, 1.0f)
               shadowColor:[UIColor whiteColor]
                   pattern:pattern];
}

#pragma mark - UIScrollViewDelegate methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  [CATransaction begin];
  [CATransaction setDisableActions:YES];
  self.maskLayer.position = CGPointMake(scrollView.contentOffset.x, 0);
  [CATransaction commit];
}

@end
