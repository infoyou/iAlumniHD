//
//  StartUpDetailHeadView.m
//  iAlumniHD
//
//  Created by Adam on 13-1-25.
//
//

#import "StartUpDetailHeadView.h"
#import <QuartzCore/QuartzCore.h>
#import "WXWLabel.h"
#import "Event.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "ECPlainButton.h"
#import "WXWGradientButton.h"
#import "WXWImageButton.h"
#import "AppManager.h"
#import "UIImage-Extensions.h"
#import "WXWUIUtils.h"

#define NAME_WIDTH     LIST_WIDTH - 4*MARGIN

#define BUTTON_H       28.0f
#define FONT_SIZE      13.0f
#define POST_W         133.4f//95.5f
#define POST_H         167.6f//120.f
#define ACTIVITY_W     LIST_WIDTH - POST_W - 5*MARGIN
#define LINE_X         MARGIN
#define LINE_W         ACTIVITY_W - LINE_X * 2
#define ARROW_X        187.f
#define ACTION_BUTTON_WIDTH   LIST_WIDTH/2-3*MARGIN
#define ACTION_BUTTON_HEIGHT  40.0f

enum {
    EVENT_SPONSOR_CELL = 0,
    EVENT_LOCATION_CELL,
    EVENT_CONTRACTS_CELL,
};

enum {
    NO_EVENT_ACTION_TYPE,
    SIGNUP_EVENT_ACTION_TYPE,
    PAY_EVENT_ACTION_TYPE,
    CHECKIN_EVENT_ACTION_TYPE,
} EVENT_ACTION_TYPE;

@implementation StartUpDetailHeadView

#pragma mark - view cycle
- (id)initWithFrame:(CGRect)frame
              event:(Event *)event
           delegate:(id<EventActionDelegate>)delegate
        imageHolder:(id)imageHolder
    saveImageAction:(SEL)saveImageAction
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        _delegate = delegate;
        self.event = event;
        
        _imageHolder = imageHolder;
        _saveImageAction = saveImageAction;
        
        [self initEventTop];
        
        [self initEventMiddle];
        
        [self initEventBottom];
        
        if (self.event.imageUrl && [self.event.imageUrl length]>0 && [self.event.imageUrl hasPrefix:HTTP_PRIFIX]) {
            [[AppManager instance] fetchImage:self.event.imageUrl
                                       caller:self
                                     forceNew:NO];
        }
    }
    return self;
}

- (void)dealloc {
    
    self.event = nil;
    
    [super dealloc];
}

#pragma mark - action
- (void)doAddCalendar:(id)sender {
    [_delegate addCalendar];
}

- (void)doSignUp:(id)sender {
    [_delegate doSignUp];
}

- (void)doTapGesture:(UITapGestureRecognizer *)sender {
    int tapIndex = [(UIGestureRecognizer *)sender view].tag;
    
    switch (tapIndex) {
            
        case EVENT_SPONSOR_CELL:
            [_delegate goSponsor];
            break;
            
        case EVENT_LOCATION_CELL:
            [_delegate goLocation];
            break;
            
        case EVENT_CONTRACTS_CELL:
            // iPad no support tel
            // [_delegate goContracts];
            break;
            
        default:
            break;
    }
}

- (void)goSignUpList:(id)sender {
    [_delegate goSignUpList];
}

- (void)goCheckInList:(id)sender {
    [_delegate goCheckInList];
}

#pragma mark - init event header view

- (void)initEventTop {
    _nameLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                        textColor:CELL_TITLE_COLOR
                                      shadowColor:[UIColor whiteColor]] autorelease];
    _nameLabel.font = BOLD_FONT(17);
    _nameLabel.numberOfLines = 0;
    _nameLabel.textAlignment = UITextAlignmentLeft;
    [self addSubview:_nameLabel];
    
    _nameLabel.text = self.event.title;
    CGSize size = [_nameLabel.text sizeWithFont:_nameLabel.font
                              constrainedToSize:CGSizeMake(NAME_WIDTH, CGFLOAT_MAX)
                                  lineBreakMode:UILineBreakModeWordWrap];
    _nameLabel.frame = CGRectMake(MARGIN * 2, MARGIN * 2,
                                  size.width, size.height);
    
    _timeLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                        textColor:[UIColor blackColor]
                                      shadowColor:[UIColor whiteColor]] autorelease];
    _timeLabel.font = FONT(13);
    [self addSubview:_timeLabel];
    _timeLabel.text = [NSString stringWithFormat:@"%@ %@", self.event.time, self.event.timeStr];
    size = [_timeLabel.text sizeWithFont:_timeLabel.font
                       constrainedToSize:CGSizeMake(self.frame.size.width - MARGIN * 4,
                                                    CGFLOAT_MAX)
                           lineBreakMode:UILineBreakModeWordWrap];
    _timeLabel.frame = CGRectMake(MARGIN * 2,
                                  _nameLabel.frame.origin.y + _nameLabel.frame.size.height + MARGIN*2,
                                  size.width, size.height);
    
    WXWImageButton *add2CalendarBut = [[[WXWImageButton alloc]
                                       initImageButtonWithFrame:CGRectMake(LIST_WIDTH-2*MARGIN-95.0f, _timeLabel.frame.origin.y-MARGIN, 95.0f, 23.0f)
                                       target:self
                                       action:@selector(doAddCalendar:)
                                       title:LocaleStringForKey(NSAdd2CalendarTitle, nil)
                                       image:nil
                                       backImgName:@"add2Calendar.png"
                                       selBackImgName:nil
                                       titleFont:BOLD_FONT(FONT_SIZE)
                                       titleColor:[UIColor whiteColor]
                                       titleShadowColor:TRANSPARENT_COLOR
                                       roundedType:HAS_ROUNDED
                                       imageEdgeInsert:ZERO_EDGE
                                       titleEdgeInsert:UIEdgeInsetsMake(0, 20, 0, 0)] autorelease];
    [self addSubview:add2CalendarBut];
}

- (void)initEventMiddle {
    
    // post image Button
    _postImgButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _postImgButton.backgroundColor = [UIColor whiteColor];
    _postImgButton.frame = CGRectMake(MARGIN*2, _timeLabel.frame.origin.y + _timeLabel.frame.size.height + MARGIN*3, POST_W, POST_H);
    [_postImgButton addTarget:self action:@selector(showBigPicture:) forControlEvents:UIControlEventTouchUpInside];
    [_postImgButton setImage:[[UIImage imageNamed:@"eventDefault.png"] imageByScalingToSize:CGSizeMake(POST_W, POST_H)]
                    forState:UIControlStateNormal];
    
    [self addSubview:_postImgButton];
    
    CGRect activityFrame = CGRectMake(POST_W+MARGIN*3, _postImgButton.frame.origin.y, ACTIVITY_W, POST_H);
    _activityView = [[[UIView alloc] initWithFrame:activityFrame] autorelease];
    [_activityView setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:_activityView];
    
    // sponsor
    [self drawLogicCell:self.event.hostName imageName:@"sponsor.png" offset:EVENT_SPONSOR_CELL];
    
    // location
    [self drawLogicCell:self.event.address imageName:@"eventLocation.png" offset:EVENT_LOCATION_CELL];
    
    // contracts
    [self drawLogicCell:[NSString stringWithFormat:@"%@ %@", self.event.contact, self.event.tel] imageName:@"contacts.png" offset:EVENT_CONTRACTS_CELL];
    
    // split
    [self drawSplitLine:CGRectMake(LINE_X, POST_H/3.f-1, LINE_W, 1.f) color:COLOR(206, 206, 206)];
    
    // split
    [self drawSplitLine:CGRectMake(LINE_X, POST_H/3.f*2-1, LINE_W, 1.f) color:COLOR(206, 206, 206)];
}

- (void)initEventBottom {
    
    _eventSignBut = [[[WXWImageButton alloc]
                      initImageButtonWithFrame:CGRectMake(2 * MARGIN, _postImgButton.frame.origin.y + POST_H + 2 * MARGIN, ACTION_BUTTON_WIDTH, ACTION_BUTTON_HEIGHT)
                      target:self
                      action:@selector(goSignUpList:)
                      title:LocaleStringForKey(NSEventJoinedTitle, nil)
                      image:nil
                      backImgName:@"whiteButton.png"
                      selBackImgName:nil
                      titleFont:FONT(16.f)
                      titleColor:BASE_INFO_COLOR
                      titleShadowColor:TRANSPARENT_COLOR
                      roundedType:NO_ROUNDED
                      imageEdgeInsert:ZERO_EDGE
                      titleEdgeInsert:UIEdgeInsetsMake(0, -75, 0, 0)] autorelease];
    
    [WXWUIUtils addShadowForButton:_eventSignBut];
    
    [self addSubview:_eventSignBut];
    
    WXWLabel *signUpNumLabel = [[[WXWLabel alloc] initWithFrame:CGRectMake(ARROW_X - 64.f, 11.f, 60.f, 20.f) textColor:[UIColor blackColor] shadowColor:[UIColor grayColor]] autorelease];
    signUpNumLabel.font = FONT(22);
    signUpNumLabel.text = [NSString stringWithFormat:@"%@", self.event.backerCount];
    signUpNumLabel.textAlignment = NSTextAlignmentCenter;
    [_eventSignBut addSubview:signUpNumLabel];
    
    UIImageView *signUpArrowView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"eventArrow.png"]] autorelease];
    signUpArrowView.frame = CGRectMake(ARROW_X, 13.f, 7.f, 11.f);
    [_eventSignBut addSubview:signUpArrowView];
    
    /*
    _eventCheckinBut = [[[WXWImageButton alloc]
                         initImageButtonWithFrame:CGRectMake(LIST_WIDTH/2+MARGIN, _postImgButton.frame.origin.y + POST_H + 2 * MARGIN, LIST_WIDTH/2-3*MARGIN, 40.f)
                         target:self
                         action:@selector(goCheckInList:)
                         title:LocaleStringForKey(NSAttendTitle, nil)
                         image:nil
                         backImgName:@"whiteButton.png"
                         selBackImgName:nil
                         titleFont:FONT(16.f)
                         titleColor:BASE_INFO_COLOR
                         titleShadowColor:TRANSPARENT_COLOR
                         roundedType:NO_ROUNDED
                         imageEdgeInsert:ZERO_EDGE
                         titleEdgeInsert:UIEdgeInsetsMake(0, -75, 0, 0)] autorelease];
    [self addSubview:_eventCheckinBut];
    
    WXWLabel *checkInNumLabel = [[[WXWLabel alloc] initWithFrame:CGRectMake(ARROW_X - 64.f, 11.f, 60.f, 20.f) textColor:[UIColor blackColor] shadowColor:[UIColor grayColor]] autorelease];
    checkInNumLabel.font = FONT(20);
    checkInNumLabel.textAlignment = NSTextAlignmentCenter;
    checkInNumLabel.text = [NSString stringWithFormat:@"%@", self.event.checkinCount];
    [_eventCheckinBut addSubview:checkInNumLabel];
    
    UIImageView *checkInArrowView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"eventArrow.png"]] autorelease];
    checkInArrowView.frame = CGRectMake(ARROW_X, 13.f, 7.f, 11.f);
    [_eventCheckinBut addSubview:checkInArrowView];
    */
    
}

#pragma mark - draw cell [sponsor, location, contracts]
- (void)drawLogicCell:labelText imageName:(NSString *)imageName offset:(int)offset{
    
    UIView *cellView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    cellView.frame = CGRectMake(0, offset * (POST_H/3), ACTIVITY_W, POST_H/3);
    
    UIImageView *imageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]] autorelease];
    imageView.frame = CGRectMake(MARGIN, (POST_H/3.f-10.f)/2.f, 10.f, 10.f);
    [cellView addSubview:imageView];
    
    WXWLabel *label = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                             textColor:[UIColor blackColor]
                                           shadowColor:[UIColor whiteColor]] autorelease];
    label.font = Arial_FONT(15);
    label.text = labelText;
    label.numberOfLines = 2;
    [cellView addSubview:label];
    
    CGSize size = [label.text sizeWithFont:label.font
                         constrainedToSize:CGSizeMake(ACTIVITY_W - 45.f, CGFLOAT_MAX)
                             lineBreakMode:UILineBreakModeTailTruncation];
    label.frame = CGRectMake(20.f, (POST_H/3-size.height)/2.f,
                             size.width, size.height);
    
    // arrow
    if (![@"" isEqualToString:labelText] && [labelText length]>0 && offset != EVENT_CONTRACTS_CELL) {
        UIImageView *arrowView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"eventArrow.png"]] autorelease];
        arrowView.frame = CGRectMake(ACTIVITY_W - 20.f, (POST_H/3.f-11.f)/2.f, 7.f, 11.f);
        [cellView addSubview:arrowView];
    }
    
    cellView.tag = offset;
    cellView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doTapGesture:)];
    [cellView addGestureRecognizer:tapGesture];
    
    [_activityView addSubview:cellView];
}

#pragma mark - draw cell split line
- (void)drawSplitLine:(CGRect)lineFrame color:(UIColor *)color {
    
    UIView *lineView = [[[UIView alloc] initWithFrame:lineFrame] autorelease];
    lineView.backgroundColor = color;
    [_activityView addSubview:lineView];
}

#pragma mark - update event post
- (void)updateEventPostImg:(UIImage *)image {
    
    [_postImgButton setImage:/*[CommonUtils cutPartImage:image
                              width:POST_W
                              height:POST_H]*/
     [image imageByScalingToSize:CGSizeMake(POST_W, POST_H)]
                    forState:UIControlStateNormal];
}

#pragma mark - ImageFetcherDelegate methods
- (void)imageFetchStarted:(NSString *)url {
    
}

- (void)imageFetchDone:(UIImage *)image url:(NSString *)url {
    
    [self updateEventPostImg:image];
    
    if (_imageHolder && _saveImageAction) {
        [_imageHolder performSelector:_saveImageAction withObject:image];
    }
}

- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url {
    
    [_postImgButton setImage:[image imageByScalingToSize:CGSizeMake(POST_W, POST_H)]
                    forState:UIControlStateNormal];
    
    if (_imageHolder && _saveImageAction) {
        [_imageHolder performSelector:_saveImageAction withObject:image];
    }
}

- (void)imageFetchFailed:(NSError *)error url:(NSString *)url {
}

#pragma mark - show big picture
- (void)showBigPicture:(id)sender {
    
    if (_delegate) {
        [_delegate showBigPhotoWithUrl:self.event.imageUrl
                            imageFrame:_postImgButton.frame];
    }
}

@end
