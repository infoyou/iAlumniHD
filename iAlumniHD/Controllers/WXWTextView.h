//
//  WXWTextView.h
//  iAlumniHD
//
//  Created by Adam on 12-11-18.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WXWTextView : UITextView {
  NSString *placeholder;
  UIColor	*placeholderColor;
  UILabel *label;
}

@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, retain) UIColor *placeholderColor;

- (id)initWithFrame:(CGRect)frame;
-(void)textChanged:(NSNotification*)notification;
@end
