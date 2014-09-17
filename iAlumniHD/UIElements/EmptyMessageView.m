//
//  EmptyMessageView.m
//  iAlumniHD
//
//  Created by MobGuang on 12-12-26.
//
//

#import "EmptyMessageView.h"
#import "WXWLabel.h"
#import "CommonUtils.h"
#import "TextConstants.h"

@implementation EmptyMessageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"lightBackground.png"]];
        
        UIImageView *imageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"emptyMsg.png"]] autorelease];
        imageView.backgroundColor = TRANSPARENT_COLOR;
        imageView.frame = CGRectMake((self.frame.size.width - imageView.frame.size.width)/2.0f,
                                     (self.frame.size.height - imageView.frame.size.height)/3.0f,
                                     imageView.frame.size.width,
                                     imageView.frame.size.height);
        [self addSubview:imageView];
        
        WXWLabel *label = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                 textColor:DARK_TEXT_COLOR
                                               shadowColor:TRANSPARENT_COLOR] autorelease];
        label.font = BOLD_FONT(25);
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        label.text = LocaleStringForKey(NSEmptyListMsg, nil);
        
        CGSize size = [label.text sizeWithFont:label.font
                             constrainedToSize:CGSizeMake(self.frame.size.width - MARGIN * 4, self.frame.size.height/2.0f)
                                 lineBreakMode:UILineBreakModeWordWrap];
        label.frame = CGRectMake((self.frame.size.width - size.width)/2.0f,
                                 imageView.frame.origin.y + imageView.frame.size.height + MARGIN * 6,
                                 size.width, size.height);
        [self addSubview:label];
    }
    
    return self;
}

- (void)dealloc {
    
    [super dealloc];
}

@end
