//
//  ChatListCell.m
//  iAlumniHD
//
//  Created by Adam on 12-11-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ChatListCell.h"
#import "AlumniDetail.h"
#import "Chat.h"

#define FONT_SIZE                       15.0f

@interface ChatListCell()
@property (nonatomic, retain) id currentPopTipViewTarget;
@property (nonatomic, retain) UIButton *selfImageButton;
@property (nonatomic, retain) UIButton *targetImageButton;
@property (nonatomic, retain) AlumniDetail *alumni;
@end

@implementation ChatListCell
@synthesize currentPopTipViewTarget;
@synthesize parentView;
@synthesize selfImgUrl;
@synthesize targetImgUrl;
@synthesize targetImageButton = _targetImageButton;
@synthesize selfImageButton = _selfImageButton;
@synthesize alumni = _alumni;

#pragma mark - init view
- (id)initWithStyle:(UITableViewCellStyle)style alumni:(AlumniDetail*)alumni reuseIdentifier:(NSString *)reuseIdentifier imageClickableDelegate:(id<ECClickableElementDelegate>)imageClickableDelegate
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selfImgUrl = [CommonUtils geneUrl:[AppManager instance].userImgUrl itemType:IMAGE_TY];
        self.alumni = alumni;
        self.targetImgUrl = self.alumni.imageUrl;
        
        _delegate = imageClickableDelegate;
    }
    return self;
}

- (void)dealloc {
    
    self.selfImgUrl = nil;
    self.targetImgUrl = nil;
    self.targetImageButton = nil;
    self.selfImageButton = nil;
    self.alumni = nil;
    [super dealloc];
}

#pragma mark - open profile
- (void)openSelfProfile:(id)sender {

//    if (_delegate) {
//        [_delegate openProfile:[AppManager instance].personId userType:[AppManager instance].userType];
//    }
}

- (void)openTargetProfile:(id)sender {
    
    if (_delegate) {
        [_delegate openProfile:self.alumni.personId userType:self.alumni.userType];
    }
}

#pragma mark - draw view
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)drawUserIcon {
    NSMutableArray *urls = [NSMutableArray array];

  if (self.selfImgUrl) {
    [urls addObject:self.selfImgUrl];
  }
  
  if (self.targetImgUrl) {
    [urls addObject:self.targetImgUrl];
  }
  
    [self fetchImage:urls forceNew:NO];
}

- (void)drawChat:(Chat *)chart {

    popView = [[UIView alloc] initWithFrame:CGRectZero];
	popView.backgroundColor = TRANSPARENT_COLOR;
       
    dateLabel = [[UILabel alloc] init];
    dateLabel.frame = CGRectMake(0, 0, LIST_WIDTH, 14);
    dateLabel.font = FONT(FONT_SIZE-5.0f);
    dateLabel.backgroundColor = TRANSPARENT_COLOR;
    dateLabel.text = [CommonUtils simpleFormatDate:[CommonUtils convertDateTimeFromUnixTS:[chart.createTime longLongValue]] secondAccuracy:YES];
    dateLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:dateLabel];
    
    // Text
    bubbleLabel = [[UILabel alloc] init];
	bubbleLabel.text = chart.msg;
	bubbleLabel.font = FONT(FONT_SIZE);
    
    CGSize size = [bubbleLabel.text sizeWithFont:bubbleLabel.font constrainedToSize:CGSizeMake(280.0f, CGFLOAT_MAX) lineBreakMode:UILineBreakModeCharacterWrap];
    
	bubbleLabel.frame = CGRectMake(25.0f, 25.0f, size.width+5, size.height+6);
	bubbleLabel.backgroundColor = TRANSPARENT_COLOR;
	bubbleLabel.numberOfLines = 0;
	bubbleLabel.lineBreakMode = UILineBreakModeCharacterWrap;

    // bubble Image
    UIImage *bubbleImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:chart.isWrite.boolValue ? @"bubble0" : @"bubble1" ofType:@"png"]];
	bubbleImageView = [[UIImageView alloc] initWithImage:[bubbleImg stretchableImageWithLeftCapWidth:50 topCapHeight:35]];
	bubbleImageView.frame = CGRectMake(0.0f, 8.0f, size.width+40.f, size.height+26.0f);
        
//    popView.backgroundColor = [UIColor blueColor];
    
	if(chart.isWrite.boolValue) {
        
        // self Img Button
        self.selfImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.selfImageButton.layer.cornerRadius = 6.0f;
        self.selfImageButton.layer.masksToBounds = YES;
        self.selfImageButton.layer.borderWidth = 1.0f;
        self.selfImageButton.layer.borderColor = [UIColor grayColor].CGColor;
        self.selfImageButton.showsTouchWhenHighlighted = YES;
        [self.selfImageButton addTarget:self action:@selector(openSelfProfile:) forControlEvents:UIControlEventTouchUpInside];
//        self.selfImageButton.frame = CGRectMake(265.0f, size.height - 10.0f, CHART_PHOTO_WIDTH, CHART_PHOTO_HEIGHT);
        self.selfImageButton.frame = CGRectMake(LIST_WIDTH - 55.0f, MARGIN*3, CHART_PHOTO_WIDTH, CHART_PHOTO_HEIGHT);
        [self.contentView addSubview:self.selfImageButton];

		popView.frame = CGRectMake(350.0f - size.width, MARGIN*2, size.width + 40.f, size.height + 30.0f);

        bubbleLabel.frame = CGRectMake(15.0f, 15.0f, size.width+5, size.height+6);
	} else {
        
        // target Img Button
        self.targetImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.targetImageButton.layer.cornerRadius = 6.0f;
        self.targetImageButton.layer.masksToBounds = YES;
        self.targetImageButton.layer.borderWidth = 1.0f;
        self.targetImageButton.layer.borderColor = [UIColor grayColor].CGColor;
        self.targetImageButton.showsTouchWhenHighlighted = YES;
        [self.targetImageButton addTarget:self action:@selector(openTargetProfile:) forControlEvents:UIControlEventTouchUpInside];
//        self.targetImageButton.frame = CGRectMake(MARGIN, size.height - 10.0f, CHART_PHOTO_WIDTH, CHART_PHOTO_HEIGHT);
        self.targetImageButton.frame = CGRectMake(MARGIN, MARGIN*3, CHART_PHOTO_WIDTH, CHART_PHOTO_HEIGHT);
        [self.contentView addSubview:self.targetImageButton];
        
		popView.frame = CGRectMake(2*MARGIN+CHART_PHOTO_WIDTH, MARGIN*2, size.width+40.f, size.height+30.0f);

        bubbleLabel.frame = CGRectMake(20.0f, 15.0f, size.width+5, size.height+6);
    }
    
	[popView addSubview:bubbleImageView];
	[bubbleImageView release];
	[popView addSubview:bubbleLabel];
    
    [self.contentView addSubview:popView];
    
    // copy
    _popViewBut = [UIButton buttonWithType:UIButtonTypeCustom];
    _popViewBut.layer.cornerRadius = 6.0f;
    _popViewBut.layer.masksToBounds = YES;
    [_popViewBut addTarget:self action:@selector(doPopView:) forControlEvents:UIControlEventTouchUpInside];
    _popViewBut.frame = popView.frame;
    [self.contentView addSubview:_popViewBut];
    
    [self drawUserIcon];
}

- (void)dismissAllPopTipViews {
	while ([[AppManager instance].visiblePopTipViews count] > 0) {
		CMPopTipView *popTipView = [[AppManager instance].visiblePopTipViews objectAtIndex:0];
		[[AppManager instance].visiblePopTipViews removeObjectAtIndex:0];
		[popTipView dismissAnimated:YES];
	}
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    [self dismissAllPopTipViews];
    [_delegate hideKeyboard];
}

- (void)doPopView:(id)sender {
    [self dismissAllPopTipViews];
    
    if (sender == currentPopTipViewTarget) {
		// Dismiss the popTipView and that is all
		self.currentPopTipViewTarget = nil;
	}else {
        CMPopTipView *popTipView = [[CMPopTipView alloc] initWithMessage:@"Copy"];
        popTipView.delegate = self;
        popTipView.backgroundColor = [UIColor blackColor];
        popTipView.textColor = [UIColor whiteColor];
        popTipView.animation = arc4random() % 2;
        [popTipView presentPointingAtView:bubbleLabel inView:parentView animated:YES];
        [[AppManager instance].visiblePopTipViews addObject:popTipView];
        self.currentPopTipViewTarget = sender;
    }
    
}

#pragma mark - CMPopTipViewDelegate method
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
    NSLog(@"bubbleLabel text is %@", bubbleLabel.text);
    [AppManager instance].chartContent = bubbleLabel.text;
    [[AppManager instance].visiblePopTipViews removeObject:popTipView];
    self.currentPopTipViewTarget = nil;
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:bubbleLabel.text];
}

#pragma mark - ImageFetcherDelegate methods
- (void)imageFetchStarted:(NSString *)url {
    if ([self currentUrlMatchCell:url]) {
        if ([url isEqualToString:self.selfImgUrl]) {
            [self.selfImageButton setImage:[UIImage imageNamed:@"defaultUser.png"]
                                forState:UIControlStateNormal];
        } else if ([url isEqualToString:self.targetImgUrl]) {
            [self.targetImageButton setImage:[UIImage imageNamed:@"defaultUser.png"]
                                forState:UIControlStateNormal];
        }
    }
}

- (void)imageFetchDone:(UIImage *)image url:(NSString *)url {
    if ([self currentUrlMatchCell:url]) {
        
        if ([url isEqualToString:self.selfImgUrl]) {
            [self.selfImageButton.layer addAnimation:[self imageTransition] forKey:nil];
            [self.selfImageButton setImage:image
                                forState:UIControlStateNormal];
        } else if ([url isEqualToString:self.targetImgUrl]) {
            [self.targetImageButton.layer addAnimation:[self imageTransition] forKey:nil];
            [self.targetImageButton setImage:image
                                forState:UIControlStateNormal];
        }
    }
}

- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url {
    if ([self currentUrlMatchCell:url]) {
        if ([url isEqualToString:self.selfImgUrl]) {
            [self.selfImageButton setImage:image
                                forState:UIControlStateNormal];
        } else if ([url isEqualToString:self.targetImgUrl]) {
            [self.targetImageButton setImage:image
                                forState:UIControlStateNormal];
        }
    }
}

- (void)imageFetchFailed:(NSError *)error url:(NSString *)url {
    
}

@end
