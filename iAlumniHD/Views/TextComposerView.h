//
//  TextComposerView.h
//  iAlumniHD
//
//  Created by Adam on 12-11-17.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "WXWGradientView.h"
#import "ComposerDelegate.h"

@class WXWTextView;

@interface TextComposerView : WXWGradientView <UITextViewDelegate> {

    WXWTextView *_textView;

    UIView *_backgroundView;
     
    id<ComposerDelegate> _composerDelegate;

}

@property (nonatomic, retain) WXWTextView *_textView;

- (id)initWithFrame:(CGRect)frame
           topColor:(UIColor *)topColor
        bottomColor:(UIColor *)bottomColor
   composerDelegate:(id<ComposerDelegate>)composerDelegate;

#pragma mark - ui elements status
- (NSInteger)charCount;

- (void)showKeyboard;
- (void)hideKeyboard;

@end
