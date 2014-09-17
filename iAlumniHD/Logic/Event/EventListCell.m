//
//  EventListCell.m
//  iAlumniHD
//
//  Created by Adam on 11-12-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "EventListCell.h"
#import "Event.h"
#import "UIImage-Extensions.h"

#define SHORT_DESC_HEIGHT 15.0f

#define INDICATOR_TOP     25.0f
#define INDICATOR_WIDTH   16.0f
#define INDICATOR_HEIGHT  16.0f

#define FONT_SIZE         16.0f
#define POST_IMAGE_W      80.f//63.88f//53.5f
#define POST_IMAGE_H      100.18//80.f//67.f
#define DATE_IMG_W        68.f
#define BOTTOM_Y          141.f
#define BOTTOM_H          15.f
#define MAX_SHOW_LINES      3

#define EVENT_CELL_WIDTH    LIST_WIDTH - 4 * MARGIN

@implementation EventListCell
@synthesize url = _url;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {    
        UIImageView *bgBackView = [[[UIImageView alloc] initWithFrame:CGRectMake(MARGIN*2, MARGIN*2, EVENT_CELL_WIDTH, EVENT_LIST_CELL_HEIGHT-2*MARGIN)] autorelease];
        bgBackView.backgroundColor = TRANSPARENT_COLOR;
        bgBackView.image = [UIImage imageNamed:@"eventListCell.png"];
        [self.contentView addSubview:bgBackView];
        
        // date line
        [self drawSplitLine:CGRectMake(MARGIN*2, MARGIN*2+32.f, EVENT_CELL_WIDTH-6, 1.f) color:COLOR(216, 216, 216)];
        
        // date
        UIView *dateView = [[[UIView alloc] initWithFrame:CGRectMake(MARGIN * 2, MARGIN * 2, 300.f, 25.f)] autorelease];
        dateView.backgroundColor = TRANSPARENT_COLOR;
        [self.contentView addSubview:dateView];
        
        _dateLabel = [[[WXWLabel alloc] initWithFrame:CGRectMake(MARGIN * 2, MARGIN, 225.f, 20.f) textColor:COLOR(30, 30, 30) shadowColor:TRANSPARENT_COLOR highlightedTextColor:COLOR(30, 30, 30)] autorelease];
        _dateLabel.font = FONT(15);
        [dateView addSubview:_dateLabel];
        
        _eventDateImageView = [[UIImageView alloc] initWithFrame:CGRectMake(LIST_WIDTH-DATE_IMG_W-2*MARGIN, 17.f, DATE_IMG_W, 22)];
        _eventDateImageView.backgroundColor = TRANSPARENT_COLOR;
        _eventDateImageView.layer.shadowColor = [UIColor blackColor].CGColor;
        _eventDateImageView.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
        _eventDateImageView.image = [[UIImage imageNamed:@"eventDateLabel.png"] imageByScalingToSize:CGSizeMake(POST_IMAGE_W, POST_IMAGE_H)];
        [self.contentView addSubview:_eventDateImageView];
        
        _intervalDayLabel = [[[WXWLabel alloc] initWithFrame:CGRectMake(LIST_WIDTH-DATE_IMG_W+MARGIN, 17.f, 50.f, 18) textColor:COLOR(254, 254, 252) shadowColor:TRANSPARENT_COLOR highlightedTextColor:COLOR(254, 254, 252)] autorelease];
        _intervalDayLabel.font = FONT(FONT_SIZE-4);
        if ([AppManager instance].currentLanguageCode == EN_TY) {
            _intervalDayLabel.font = FONT(FONT_SIZE-5);
        }
        [self.contentView addSubview:_intervalDayLabel];
        
        _postImageView = [[UIImageView alloc] initWithFrame:CGRectMake(MARGIN*4, dateView.frame.origin.x+44.f, POST_IMAGE_W, POST_IMAGE_H)];
        _postImageView.backgroundColor = TRANSPARENT_COLOR;
        _postImageView.layer.shadowColor = [UIColor blackColor].CGColor;
        _postImageView.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
        [self.contentView addSubview:_postImageView];
        
        _titleLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero textColor:COLOR(50, 50, 50) shadowColor:TRANSPARENT_COLOR highlightedTextColor:COLOR(50, 50, 50)] autorelease];
        _titleLabel.font = FONT(FONT_SIZE);
        _titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
        _titleLabel.numberOfLines = MAX_SHOW_LINES;
        [self.contentView addSubview:_titleLabel];
        
        _descLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero textColor:COLOR(102, 102, 102) shadowColor:TRANSPARENT_COLOR highlightedTextColor:COLOR(102, 102, 102)] autorelease];
        _descLabel.font = FONT(FONT_SIZE-2);
        _descLabel.lineBreakMode = UILineBreakModeTailTruncation;
        [self.contentView addSubview:_descLabel];
        
        _signUpCountLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero textColor:COLOR(168, 168, 168) shadowColor:[UIColor whiteColor]  highlightedTextColor:COLOR(168, 168, 168)] autorelease];
        _signUpCountLabel.font = FONT(FONT_SIZE-1);
        [self.contentView addSubview:_signUpCountLabel];
        
        _checkInCountPrefixLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero textColor:COLOR(168, 168, 168) shadowColor:[UIColor whiteColor] highlightedTextColor:COLOR(168, 168, 168)] autorelease];
        _checkInCountPrefixLabel.font = FONT(FONT_SIZE-1);
        [self.contentView addSubview:_checkInCountPrefixLabel];
        
        _checkInCountLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero textColor:COLOR(179, 219, 78) shadowColor:[UIColor whiteColor] highlightedTextColor:COLOR(179, 219, 78)] autorelease];
        _checkInCountLabel.font = FONT(FONT_SIZE-1);
        [self.contentView addSubview:_checkInCountLabel];
        
        _checkInCountSuffixLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero textColor:COLOR(168, 168, 168) shadowColor:[UIColor whiteColor] highlightedTextColor:COLOR(168, 168, 168)] autorelease];
        _checkInCountSuffixLabel.font = FONT(FONT_SIZE-1);
        [self.contentView addSubview:_checkInCountSuffixLabel];
        
    }
    
    return self;
}

- (void)dealloc {
    
    RELEASE_OBJ(_postImageView);
    
    self.url = nil;
    [super dealloc];
}

- (void)drawEvent:(Event *)event {
    
    // date
    NSDate *datetime = [CommonUtils convertDateTimeFromUnixTS:[event.date doubleValue]];
    if ([AppManager instance].currentLanguageCode == EN_TY) {
        _dateLabel.text = [NSString stringWithFormat:@"%@-%@-%@ %@",
                           [CommonUtils datetimeWithFormat:@"MMM" datetime:datetime],
                           [CommonUtils datetimeWithFormat:@"d" datetime:datetime],
                           [CommonUtils datetimeWithFormat:@"yyyy" datetime:datetime],
                           [CommonUtils datetimeWithFormat:@"EEE" datetime:datetime]];
    } else {
        _dateLabel.text = [NSString stringWithFormat:@"%@%@%@%@%@ %@",
                           [CommonUtils datetimeWithFormat:@"yyyy" datetime:datetime],
                           LocaleStringForKey(NSYearTitle, nil),
                           [CommonUtils datetimeWithFormat:@"MMM" datetime:datetime],
                           [CommonUtils datetimeWithFormat:@"d" datetime:datetime],
                           LocaleStringForKey(NSDayTitle, nil),
                           [CommonUtils datetimeWithFormat:@"EEE" datetime:datetime]];
    }
    // interval day
    int interValDay = [event.intervalDayCount intValue];
    [self drawInterValDay:interValDay];
    
    // title
    _titleLabel.text = event.title;
    
    CGSize tempsize = [LocaleStringForKey(NSNoteTitle, nil) sizeWithFont:_titleLabel.font
                               constrainedToSize:CGSizeMake(EVENT_CELL_WIDTH, MAXFLOAT)
                                   lineBreakMode:UILineBreakModeTailTruncation];
    
    CGSize size = [_titleLabel.text sizeWithFont:_titleLabel.font
                               constrainedToSize:CGSizeMake(EVENT_CELL_WIDTH - (POST_IMAGE_W + MARGIN*8), tempsize.height*MAX_SHOW_LINES)
                                   lineBreakMode:UILineBreakModeTailTruncation];
    _titleLabel.frame = CGRectMake(_postImageView.frame.origin.x + POST_IMAGE_W + MARGIN*2, /* 54.f */_postImageView.frame.origin.y, size.width, size.height);
    
    // desc
    _descLabel.text = event.hostName;
    _descLabel.frame = CGRectMake(_titleLabel.frame.origin.x, _titleLabel.frame.origin.y + size.height + 4, _titleLabel.frame.size.width - MARGIN, SHORT_DESC_HEIGHT);
    
    // line
    [self drawSplitLine:CGRectMake(_descLabel.frame.origin.x-1, BOTTOM_Y - 6.f, EVENT_CELL_WIDTH-POST_IMAGE_W-8*MARGIN, 1.f) color:COLOR(206, 206, 206)];
    
    // sign up
    _signUpCountLabel.frame = CGRectMake(_descLabel.frame.origin.x, BOTTOM_Y, 160.f, BOTTOM_H);
    _signUpCountLabel.text = [NSString stringWithFormat:@"%@: %d%@", LocaleStringForKey(NSSignUpTitle, nil), [event.signupCount intValue], LocaleStringForKey(NSEventPersonTitle, nil)];
    
    // check in
    _checkInCountPrefixLabel.text = [NSString stringWithFormat:@"%@: ", LocaleStringForKey(NSAttendTitle, nil)];
    CGSize checkInCountPrefixSize = [_checkInCountPrefixLabel.text sizeWithFont:_checkInCountPrefixLabel.font constrainedToSize:CGSizeMake(MAXFLOAT, BOTTOM_H)];
    _checkInCountPrefixLabel.frame = CGRectMake(260.f, BOTTOM_Y, checkInCountPrefixSize.width, BOTTOM_H);
    
    _checkInCountLabel.text = [NSString stringWithFormat:@"%d", [event.checkinCount intValue]];
    CGSize checkInCountSize = [_checkInCountLabel.text sizeWithFont:_checkInCountPrefixLabel.font constrainedToSize:CGSizeMake(MAXFLOAT, BOTTOM_H)];
    _checkInCountLabel.frame = CGRectMake(_checkInCountPrefixLabel.frame.origin.x + checkInCountPrefixSize.width, BOTTOM_Y, checkInCountSize.width, BOTTOM_H);
    
    _checkInCountSuffixLabel.frame = CGRectMake(_checkInCountPrefixLabel.frame.origin.x + checkInCountPrefixSize.width + checkInCountSize.width, BOTTOM_Y, 90.f, BOTTOM_H);
    _checkInCountSuffixLabel.text = LocaleStringForKey(NSEventPersonTitle, nil);
    
    // line
    [self drawSplitLine:CGRectMake(233.f, BOTTOM_Y, 1, 12) color:COLOR(216, 216, 216)];
    [self drawSplitLine:CGRectMake(233.f, BOTTOM_Y, 1, 12) color:COLOR(228, 228, 228)];
    
    UIImageView *arrowImgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table_arrow.png"]] autorelease];
    arrowImgView.frame = CGRectMake(EVENT_CELL_WIDTH - 10.f, 85.f, 9.f, 14.f);
    arrowImgView.backgroundColor = TRANSPARENT_COLOR;
    [self.contentView addSubview:arrowImgView];
    
    [self drawImage:event.imageUrl];
    
    //    [self setCellStyle:EVENT_LIST_CELL_HEIGHT];
}

- (void)drawSplitLine:(CGRect)lineFrame color:(UIColor *)color {
    
    UIImage *lineImg = [CommonUtils createImageWithColor:color];
    UIImageView *splitLine = [[[UIImageView alloc] initWithImage:lineImg] autorelease];
    splitLine.frame = lineFrame;
    
    [self.contentView addSubview:splitLine];
    lineImg = nil;
}

- (void)drawImage:(NSString *)imageUrl
{
    UIImage *image = nil;
    
    if (imageUrl && [imageUrl length] > 0 && [imageUrl hasPrefix:HTTP_PRIFIX]) {
        self.url = [CommonUtils geneUrl:imageUrl itemType:IMAGE_TY];;
        
        image = [[AppManager instance].imageCache getImage:self.url];
        
        if (!image) {
            WXWAsyncConnectorFacade *connFacade = [[[WXWAsyncConnectorFacade alloc] initWithDelegate:self
                                                                              interactionContentType:IMAGE_TY] autorelease];
            [connFacade fetchGets:self.url];
        }
    } else {
        image = [[UIImage imageNamed:@"eventDefault.png"] imageByScalingToSize:CGSizeMake(POST_IMAGE_W, POST_IMAGE_H)];
    }
    
    if (image) {
        _postImageView.image = [CommonUtils cutPartImage:image
                                                   width:_postImageView.frame.size.width
                                                  height:_postImageView.frame.size.height];//image;
    }
}

#pragma mark - WXWConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(WebItemType)contentType
{
    _postImageView.image = [[UIImage imageNamed:@"eventDefault.png"] imageByScalingToSize:CGSizeMake(POST_IMAGE_W, POST_IMAGE_H)];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(WebItemType)contentType {
    if (url && url.length > 0) {
        UIImage *image = [UIImage imageWithData:result];
        if (image) {
            [[AppManager instance].imageCache saveImageIntoCache:url image:image];
        }
        
        if ([url isEqualToString:self.url]) {
            _postImageView.image = image;
        }
    }
}

- (void)connectCancelled:(NSString *)url
             contentType:(WebItemType)contentType {
    
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(WebItemType)contentType {
    
}

- (void)drawInterValDay:(int)interValDay{
    if (interValDay < 0) {
        _intervalDayLabel.hidden = YES;
        _eventDateImageView.hidden = YES;
        return;
    } else {
        _intervalDayLabel.hidden = NO;
        _eventDateImageView.hidden = NO;
    }
    
    if (0 == interValDay) {
        _intervalDayLabel.text = LocaleStringForKey(NSInProcessTitle, nil);
    } else {
        _intervalDayLabel.text = [NSString stringWithFormat:@"%d %@", interValDay, LocaleStringForKey(NSHoldDayTitle, nil)];
    }
    
}
@end
