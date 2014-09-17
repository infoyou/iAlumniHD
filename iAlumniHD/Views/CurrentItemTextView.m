//
//  CurrentItemTextView.m
//  iAlumniHD
//
//  Created by Adam on 12-11-9.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "CurrentItemTextView.h"

#define FONT_SIZE   11.0f

@implementation CurrentItemTextView

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    
    self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.6f];
    
    _contentLabel = [[[WXWLabel alloc] initWithFrame:CGRectMake(MARGIN, 0, self.bounds.size.width - MARGIN, BUTTON_TEXT_VIEW_HEIGHT)
                                          textColor:[UIColor whiteColor]
                                        shadowColor:TRANSPARENT_COLOR] autorelease];
    _contentLabel.backgroundColor = TRANSPARENT_COLOR;
    _contentLabel.font = BOLD_FONT(FONT_SIZE);
    _contentLabel.numberOfLines = 6;
    _contentLabel.lineBreakMode = UILineBreakModeTailTruncation;
    [self addSubview:_contentLabel];
  }
  return self;
}

- (void)updateContent:(NSString *)content {
  _contentLabel.text = content;
}


@end
