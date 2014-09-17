//
//  TextComposerView.m
//  iAlumniHD
//
//  Created by Adam on 12-11-17.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "TextComposerView.h"
#import "UserProfileCell.h"
#import "WXWGradientButton.h"
#import "WXWTextView.h"

#define FONT_SIZE               22.f
#define LINE_Y_OFFSET           10.f

#define ATTACHMENT_X            144.f
#define ATTACHMENT_BUTTON_Y     12.f

#define BUTTON_WIDTH            145.0f
#define BUTTON_HEIGHT           30.0f

#define CANCEL_BUTTON_WIDTH     24.0f
#define CANCEL_BUTTON_HEIGHT    24.0f

#define HIDE_KEYBOARD_BTN_WIDTH   45.0f
#define HIDE_KEYBOARD_BTN_HEIGHT  24.0f

@interface TextComposerView()
@end

@implementation TextComposerView
@synthesize _textView;

- (void)showKeyboard
{
    _textView.userInteractionEnabled = YES;
    [_textView becomeFirstResponder];
}

- (void)hideKeyboard
{
    _textView.userInteractionEnabled = NO;
    [_textView resignFirstResponder];
}

#pragma mark - ui elements status
- (NSInteger)charCount {
    return [_textView.text length];
}

#pragma mark - UITextViewDelegate methods
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    
    [_composerDelegate textChanged:textView.text];
}

#pragma mark - lifecycle methods

- (void)addShadow {
    
    CGRect bounds = self.bounds;
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPath];
    
    [shadowPath moveToPoint:CGPointMake(-2, bounds.size.height)];
    [shadowPath addLineToPoint:CGPointMake(bounds.size.width + 2, bounds.size.height)];
    [shadowPath addLineToPoint:CGPointMake(bounds.size.width + 2, bounds.size.height + 3)];
    [shadowPath addLineToPoint:CGPointMake(-2, bounds.size.height + 3)];
    [shadowPath addLineToPoint:CGPointMake(-2, bounds.size.height)];
    
    self.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.layer.shadowOpacity = 0.8f;
    self.layer.masksToBounds = NO;
    self.layer.shadowPath = shadowPath.CGPath;
}

- (id)initWithFrame:(CGRect)frame
           topColor:(UIColor *)topColor
        bottomColor:(UIColor *)bottomColor
   composerDelegate:(id<ComposerDelegate>)composerDelegate {
    
    self = [super initWithFrame:frame topColor:topColor bottomColor:bottomColor];
    
    if (self) {
        
        [self addShadow];
        
        _composerDelegate = composerDelegate;
        
        [self addTextStyle:frame];
        [self addTextView:frame];
    }
    
    return self;
}

- (void)addTextStyle:(CGRect)frame
{
    // Left Mark Line
    UIView *left1MarkLine = [[[UIView alloc] initWithFrame:CGRectMake(1.f, 0, 1.f, frame.size.height)] autorelease];
    left1MarkLine.backgroundColor = COLOR(255, 232, 232);
    [self addSubview:left1MarkLine];
    
    UIView *left2MarkLine = [[[UIView alloc] initWithFrame:CGRectMake(3.f, 0, 1.f, frame.size.height)] autorelease];
    left2MarkLine.backgroundColor = COLOR(255, 232, 232);
    [self addSubview:left2MarkLine];
    
    // Cell Line
    CGSize fontSize = [@"中" sizeWithFont:FONT(FONT_SIZE)
                       constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                           lineBreakMode:UILineBreakModeWordWrap];
    
    for (int index = 0; index < 35; index++) {
        UIView *cellLine = [[[UIView alloc] initWithFrame:CGRectMake(3.f, index*fontSize.height + LINE_Y_OFFSET, frame.size.width-6.f, 1.1f)] autorelease];
        cellLine.backgroundColor = COLOR(202, 214, 219);
        [self addSubview:cellLine];
    }
    
    // Right Mark Line
    UIView *right1MarkLine = [[[UIView alloc] initWithFrame:CGRectMake(frame.size.width-3.f, 0, 1.f, frame.size.height)] autorelease];
    right1MarkLine.backgroundColor = COLOR(255, 232, 232);
    [self addSubview:right1MarkLine];
    
    UIView *right2MarkLine = [[[UIView alloc] initWithFrame:CGRectMake(frame.size.width-1.f, 0, 1.f, frame.size.height)] autorelease];
    right2MarkLine.backgroundColor = COLOR(255, 232, 232);
    [self addSubview:right2MarkLine];
    
}

- (void)addTextView:(CGRect)frame
{
    CGRect textFrame = CGRectMake(0.f, MARGIN, frame.size.width - MARGIN-0.f, frame.size.height - MARGIN * 2);
    
    _backgroundView = [[UIView alloc] initWithFrame:textFrame];
    _backgroundView.backgroundColor = TRANSPARENT_COLOR;
    [self addSubview:_backgroundView];
    
    _textView = [[WXWTextView alloc] initWithFrame:CGRectMake(MARGIN*4, 0, textFrame.size.width-MARGIN*8, 162.f)];
    _textView.delegate = self;
    _textView.editable = YES;
    _textView.backgroundColor = TRANSPARENT_COLOR;
    _textView.contentSize = CGSizeMake(_textView.frame.size.width, _textView.frame.size.height - HIDE_KEYBOARD_BTN_HEIGHT);
    _textView.font = FONT(FONT_SIZE);
    
    [_backgroundView addSubview:_textView];
}

- (void)dealloc {

    RELEASE_OBJ(_textView);
    RELEASE_OBJ(_backgroundView);
    
    [super dealloc];
}

@end
