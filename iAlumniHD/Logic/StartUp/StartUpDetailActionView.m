//
//  StartUpDetailActionView.m
//  iAlumniHD
//
//  Created by Adam on 13-1-26.
//
//

#import "StartUpDetailActionView.h"
#import <QuartzCore/QuartzCore.h>
#import "WXWLabel.h"
#import "Event.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "ECPlainButton.h"
#import "WXWGradientButton.h"
#import "WXWImageButton.h"
#import "WXWUIUtils.h"

#define BUTTON_SIZE         3
#define BUTTON_WIDTH        LIST_WIDTH / BUTTON_SIZE
#define BUTTON_HEIGHT       48.f
#define BOTTOM_TOOL_H       48.f
#define BUTTOM_ICON_W       20.f

enum {
    VOTE_TAG,
    AWARD_TAG,
    DISCUSS_TAG,
    OTHER_TAG,
};

@implementation StartUpDetailActionView

- (void)selectionAction:(id)sender {
    
    if (nil == _delegate) {
        return;
    }
    
    WXWGradientButton *button = (WXWGradientButton *)sender;
    
    switch (button.tag) {
            
        case VOTE_TAG:
            [_delegate voteAction];
            break;
            
        case DISCUSS_TAG:
            [_delegate discussAction];
            break;
            
        case OTHER_TAG:
            [_delegate moreAction];
            break;
            
        default:
            break;
    }
}

- (id)initWithFrame:(CGRect)frame
              event:(Event *)event
           delegate:(id<EventActionDelegate>)delegate
{
    self = [super initWithFrame:frame
                       topColor:COLOR(40, 40, 40)
                    bottomColor:COLOR(3, 3, 3)];

    if (self) {
        _delegate = delegate;
        [self initButtons];
    }
    return self;
}

- (void)initButtons {
    
    WXWGradientButton *voteBtn = [[[WXWGradientButton alloc] initWithFrame:CGRectMake(0, 0, BUTTON_WIDTH, BUTTON_HEIGHT)
                                                                  target:self
                                                                  action:@selector(selectionAction:)
                                                               colorType:TRANSPARENT_BTN_COLOR_TY
                                                                   title:LocaleStringForKey(NSVoteTitle, nil)
                                                                   image:[UIImage imageNamed:@"vote.png"]
                                                              titleColor:[UIColor whiteColor]
                                                        titleShadowColor:[UIColor clearColor]
                                                               titleFont:FONT(10)
                                                             roundedType:NO_ROUNDED
                                                         imageEdgeInsert:UIEdgeInsetsMake(11.f, (BUTTON_WIDTH-BUTTOM_ICON_W)/2, 21.f, (BUTTON_WIDTH-BUTTOM_ICON_W)/2)
                                                         titleEdgeInsert:UIEdgeInsetsMake(12.f, -21, -10.f, 10)
                                                              hideBorder:YES] autorelease];
    voteBtn.tag = VOTE_TAG;
    voteBtn.showsTouchWhenHighlighted = YES;
    [self addSubview:voteBtn];
    
    WXWGradientButton *discussBtn = [[[WXWGradientButton alloc] initWithFrame:CGRectMake(BUTTON_WIDTH * 1, 0,
                                                                                       BUTTON_WIDTH,
                                                                                       BUTTON_HEIGHT)
                                                                     target:self
                                                                     action:@selector(selectionAction:)
                                                                  colorType:TRANSPARENT_BTN_COLOR_TY
                                                                      title:LocaleStringForKey(NSDiscussTitle, nil)
                                                                      image:[UIImage imageNamed:@"discuss.png"]
                                                                 titleColor:[UIColor whiteColor]
                                                           titleShadowColor:[UIColor clearColor]
                                                                  titleFont:FONT(10)
                                                                roundedType:NO_ROUNDED
                                                              imageEdgeInsert:UIEdgeInsetsMake(11.f, (BUTTON_WIDTH-BUTTOM_ICON_W)/2, 21.f, (BUTTON_WIDTH-BUTTOM_ICON_W)/2)
                                                              titleEdgeInsert:UIEdgeInsetsMake(12.f, -21, -10.f, 10)
                                                                 hideBorder:YES] autorelease];
    discussBtn.tag = DISCUSS_TAG;
    discussBtn.showsTouchWhenHighlighted = YES;
    [self addSubview:discussBtn];
    
    WXWGradientButton *otherBtn = [[[WXWGradientButton alloc] initWithFrame:CGRectMake(BUTTON_WIDTH * 2, 0,
                                                                                     BUTTON_WIDTH,
                                                                                     BUTTON_HEIGHT)
                                                                   target:self
                                                                   action:@selector(selectionAction:)
                                                                colorType:TRANSPARENT_BTN_COLOR_TY
                                                                    title:LocaleStringForKey(NSShareTitle, nil)
                                                                    image:[UIImage imageNamed:@"eventShare.png"]
                                                               titleColor:[UIColor whiteColor]
                                                         titleShadowColor:[UIColor clearColor]
                                                                titleFont:FONT(10)
                                                              roundedType:NO_ROUNDED
                                                            imageEdgeInsert:UIEdgeInsetsMake(11.f, (BUTTON_WIDTH-BUTTOM_ICON_W)/2, 21.f, (BUTTON_WIDTH-BUTTOM_ICON_W)/2)
                                                            titleEdgeInsert:UIEdgeInsetsMake(12.f, -23, -10.f, 10)
                                                               hideBorder:YES] autorelease];
    
    otherBtn.tag = OTHER_TAG;
    otherBtn.showsTouchWhenHighlighted = YES;
    [self addSubview:otherBtn];
    
}

#pragma mark - draw
- (void)drawRect:(CGRect)rect {
    
    for (int i = 1; i<BUTTON_SIZE; i++) {
                
        [self drawSplitLine:CGRectMake(floor(LIST_WIDTH/BUTTON_SIZE)*i, 0, 1, self.frame.size.height) color:COLOR(0, 0, 0)];
        [self drawSplitLine:CGRectMake(floor(LIST_WIDTH/BUTTON_SIZE)*i+1, 0, 1, self.frame.size.height) color:COLOR(77, 77, 77)];
    }
    
}

- (void)drawSplitLine:(CGRect)lineFrame color:(UIColor *)color {
    
    UIImage *lineImg = [CommonUtils createImageWithColor:color];
    UIImageView *splitLine = [[[UIImageView alloc] initWithImage:lineImg] autorelease];
    splitLine.frame = lineFrame;
    
    [self addSubview:splitLine];
    lineImg = nil;
}

@end
