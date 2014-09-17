//
//  WXWTextView.m
//  iAlumniHD
//
//  Created by Adam on 12-11-18.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "WXWTextView.h"
#import "GlobalConstants.h"

#define LABEL_TAG     999

@implementation WXWTextView

@synthesize placeholder;
@synthesize placeholderColor;

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
	if (self) {
		self.placeholder = @"";
		self.placeholderColor = [UIColor lightGrayColor];
		self.backgroundColor = TRANSPARENT_COLOR;
		[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textChanged:) 
                                                 name:UITextViewTextDidChangeNotification
                                               object:nil];
	}
	return self;
}

- (void)textChanged:(NSNotification *)notification {
  if([[self placeholder] length] == 0)
    return;
  if([[self text] length] == 0)
    [[self viewWithTag:LABEL_TAG] setAlpha:1];
  else 
    [[self viewWithTag:LABEL_TAG] setAlpha:0];
}

- (void)drawRect:(CGRect)rect {
  
  if([[self placeholder] length] > 0){
    
    label = (UILabel *)[self viewWithTag:LABEL_TAG];
    if (nil == label) {
      label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, rect.size.width - 16, 0)];
      label.lineBreakMode = UILineBreakModeWordWrap;
      label.numberOfLines = 5;
      label.textAlignment = UITextAlignmentCenter;
      label.font = [UIFont fontWithName:@"Verdana-Italic" size:12];
      label.backgroundColor = TRANSPARENT_COLOR;
      label.textColor = self.placeholderColor;
      label.text = self.placeholder;
      label.alpha = 0;
      label.tag = LABEL_TAG;
      [self addSubview:label];      
      [self sendSubviewToBack:label];
    }
  }
  
  if( ([[self text] length] == 0 && [[self placeholder] length] > 0)
     || [[self text] isEqualToString:@" "]) {

    label.alpha = 1.0f;
  } else {
    label.alpha = 0.0f;
  }
  
  CGSize size = [label.text sizeWithFont:label.font
                       constrainedToSize:CGSizeMake(rect.size.width, CGFLOAT_MAX) 
                           lineBreakMode:UILineBreakModeWordWrap];
  label.frame = CGRectMake(0, 0, size.width, size.height);
  label.center = CGPointMake(rect.size.width/2, rect.size.height/2);
  
  [super drawRect:rect];
}

- (void)setContentOffset:(CGPoint)contentOffset {
  [self setContentInset:UIEdgeInsetsZero];
  [super setContentOffset:contentOffset];
}

- (void) dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  self.placeholder = nil;
  self.placeholderColor = nil;
  
  RELEASE_OBJ(label);
  
  [super dealloc];
}

@end
