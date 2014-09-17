//
//  ClubHeadView.m
//  iAlumniHD
//
//  Created by Adam on 12-8-16.
//
//

#import "ClubHeadView.h"
#import "UserListViewController.h"
#import "ClubSimple.h"
#import "ECPlainButton.h"
#import "WXWImageButton.h"
#import "WXWLabel.h"

static int HEADER_VIEW_H = 155.f;

#define FONT_SIZE                       13.0f
#define TOP_VIEW_Y                      2*MARGIN
#define TOP_VIEW_H                      60.f
#define BUTTON_H                        28.0f
#define CLUB_MEMBER_ACTIVITY_BUTTON_W   140.f
#define EVENT_VIEW_H                    72.f
#define DARK_BTN_TITLE_COLOR            COLOR(66, 66, 66)


@interface ClubHeadView ()
@property (nonatomic, retain) ClubSimple *clubSimple;
@property (nonatomic, retain) UIView  *headerView;
@end

@implementation ClubHeadView
@synthesize joinStatus;
@synthesize clubSimple = _clubSimple;
@synthesize headerView = _headerView;

- (id)initWithFrame:(CGRect)frame
                MOC:(NSManagedObjectContext*)MOC
   clubHeadDelegate:(id<ClubManagementDelegate>) clubHeadDelegate
{
  self = [super initWithFrame:frame];
  
  if (self) {
    _delegate = clubHeadDelegate;
    _MOC = MOC;
    
    _frame = frame;
    joinStatus = NO;
    
    HEADER_VIEW_H = _frame.size.height - 1;
    
    [self loadData];
    
    // topSeparator
    UIView *topSeparator = [[[UIView alloc] initWithFrame:CGRectMake(0, HEADER_VIEW_H, LIST_WIDTH, 0.8f)] autorelease];
    topSeparator.backgroundColor = CELL_TOP_COLOR;
    [self addSubview:topSeparator];
    
    // bottomSeparator
    UIView *bottomSeparator = [[[UIView alloc] initWithFrame:CGRectMake(0, HEADER_VIEW_H-0.8f, LIST_WIDTH, 0.8f)] autorelease];
    bottomSeparator.backgroundColor = CELL_BOTTOM_COLOR;
    [self addSubview:bottomSeparator];
  }
  return self;
}

- (void)dealloc {
  self.clubSimple = nil;
  self.headerView = nil;
  
  [super dealloc];
}

- (void)arrangeJointAndQuiteButton {
  CGRect activityFrame = CGRectMake(LIST_WIDTH-CLUB_MEMBER_ACTIVITY_BUTTON_W-MARGIN*2, MARGIN, CLUB_MEMBER_ACTIVITY_BUTTON_W, BUTTON_H);
  
  NSString *title = nil;
  NSString *buttonImageName = nil;
  NSString *buttonSelectedImageName = nil;
  UIColor *titleColor = nil;
    
  if ([@"1" isEqualToString:self.clubSimple.ifmember]) {
    title = LocaleStringForKey(NSQuitButTitle, nil);
    joinStatus = YES;
    
    buttonImageName = @"club_button.png";
    buttonSelectedImageName = @"club_button_selected.png";
    titleColor = DARK_BTN_TITLE_COLOR;
  }else {
    joinStatus = NO;
    title = LocaleStringForKey(NSJoinButTitle, nil);
    buttonImageName = @"button_orange.png";
    buttonSelectedImageName = @"button_orange_selected.png";
    titleColor = [UIColor whiteColor];
  }
  
  _joinAndQuitBut = [[[WXWImageButton alloc]
                      initImageButtonWithFrame:activityFrame
                      target:self
                      action:@selector(doJoin2Quit:)
                      title:title
                      image:nil
                      backImgName:buttonImageName
                      selBackImgName:buttonSelectedImageName
                      titleFont:BOLD_FONT(FONT_SIZE)
                      titleColor:titleColor
                      titleShadowColor:TRANSPARENT_COLOR
                      roundedType:HAS_ROUNDED
                      imageEdgeInsert:ZERO_EDGE
                      titleEdgeInsert:ZERO_EDGE] autorelease];
  
  [_member2ActivityView addSubview:_joinAndQuitBut];

}

- (void)loadData {
  [NSFetchedResultsController deleteCacheWithName:nil];
  
  NSArray *clubSimpleArray = [CommonUtils objectsInMOC:_MOC
                                            entityName:@"ClubSimple"
                                          sortDescKeys:nil
                                             predicate:nil];
  
  if ([clubSimpleArray count]) {
    self.clubSimple = (ClubSimple*)[clubSimpleArray lastObject];
    
    [self addSubview:self.headerView];
    
    if ([@"1" isEqualToString:self.clubSimple.ifadmin]) {
      [AppManager instance].clubAdmin = YES;
    } else {
      [AppManager instance].clubAdmin = NO;
    }
    
    [self arrangeJointAndQuiteButton];
    
    [_memberBut setTitle:[NSString stringWithFormat: @" %@: %@", LocaleStringForKey(NSClubLabelTitle, nil), self.clubSimple.membercount]
                forState:UIControlStateNormal];
  }
}

#pragma mark - init view

- (UIView *)headerView
{
  if (_headerView == nil) {
    //            if (headerView == nil) {
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, LIST_WIDTH, HEADER_VIEW_H)];
    _headerView.backgroundColor = LIGHT_CELL_COLOR;
    
    CGRect topFrame = CGRectMake(2*MARGIN, TOP_VIEW_Y, LIST_WIDTH - 4*MARGIN, TOP_VIEW_H);
    UIImageView *_topBgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"club_detail_bg.png"]] autorelease];
    _topBgView.frame = topFrame;
    [_headerView addSubview:_topBgView];
    
    UIView *topView = [[[UIView alloc] initWithFrame:topFrame] autorelease];
    topView.backgroundColor = TRANSPARENT_COLOR;
    UIGestureRecognizer *tapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(doDetail:)] autorelease];
    [topView addGestureRecognizer:tapGesture];
    
    UIImageView *arrowIcon = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table_arrow.png"]] autorelease];
    arrowIcon.backgroundColor = TRANSPARENT_COLOR;
    arrowIcon.frame = CGRectMake(topView.frame.size.width - MARGIN - TABLE_ACCESSOR_ARROW_WIDTH,
                                 (topView.frame.size.height - TABLE_ACCESSOR_ARROW_HEIGHT)/2.0f,
                                 TABLE_ACCESSOR_ARROW_WIDTH, TABLE_ACCESSOR_ARROW_HEIGHT);
    [topView addSubview:arrowIcon];
    
    WXWLabel *checkDetailLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                      textColor:BASE_INFO_COLOR
                                                    shadowColor:TRANSPARENT_COLOR] autorelease];
    checkDetailLabel.font = BOLD_FONT(12);
    checkDetailLabel.numberOfLines = 1;
    checkDetailLabel.text = LocaleStringForKey(NSCheckDetailTitle, nil);
    CGSize size = [checkDetailLabel.text sizeWithFont:checkDetailLabel.font
                                    constrainedToSize:CGSizeMake(200, CGFLOAT_MAX)
                                        lineBreakMode:UILineBreakModeWordWrap];
    checkDetailLabel.frame = CGRectMake(arrowIcon.frame.origin.x - MARGIN - size.width,
                                        (topView.frame.size.height - size.height)/2.0f,
                                        size.width, size.height);
    [topView addSubview:checkDetailLabel];
    
    CGFloat nameLimitedWidth = checkDetailLabel.frame.origin.x - MARGIN * 2;
    UILabel *mNameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(MARGIN, MARGIN*2,
                                                                     nameLimitedWidth,
                                                                     TOP_VIEW_H - MARGIN * 4)] autorelease];
    [mNameLabel setTextColor:[UIColor blackColor]];
    [mNameLabel setFont:BOLD_FONT(FONT_SIZE)];
    [mNameLabel setBackgroundColor:TRANSPARENT_COLOR];
    mNameLabel.text = self.clubSimple.name;
    size = [mNameLabel.text sizeWithFont:mNameLabel.font
                       constrainedToSize:CGSizeMake(nameLimitedWidth, mNameLabel.frame.size.height)
                           lineBreakMode:UILineBreakModeWordWrap];
    mNameLabel.frame = CGRectMake(MARGIN, (topView.frame.size.height - size.height)/2.0f,
                                  size.width, size.height);
    [topView addSubview:mNameLabel];
    
    [_headerView addSubview:topView];
    
    // Button
    if ([@"1" isEqualToString:self.clubSimple.ifadmin]) {

      [AppManager instance].clubAdmin = YES;
    } else {
      [AppManager instance].clubAdmin = NO;
      
    }
    
    // member & activity
    _member2ActivityView = [[[UIView alloc] initWithFrame:CGRectMake(0, TOP_VIEW_Y+TOP_VIEW_H, LIST_WIDTH, BUTTON_H+20)] autorelease];
    [_member2ActivityView setBackgroundColor:TRANSPARENT_COLOR];
    
    {
      CGRect memberFrame = CGRectMake(MARGIN*2, MARGIN, CLUB_MEMBER_ACTIVITY_BUTTON_W, BUTTON_H);
      
      _memberBut = [[[WXWImageButton alloc]
                     initImageButtonWithFrame:memberFrame
                     target:self
                     action:@selector(goClubUserList:)
                     title:[NSString stringWithFormat: @" %@: %@", LocaleStringForKey(NSClubLabelTitle, nil), self.clubSimple.membercount]
                     image:[UIImage imageNamed:@"club_member.png"]
                     backImgName:@"club_button.png"selBackImgName:@"club_button_selected.png"
                     titleFont:BOLD_FONT(FONT_SIZE)
                     titleColor:DARK_BTN_TITLE_COLOR
                     titleShadowColor:TRANSPARENT_COLOR
                     roundedType:HAS_ROUNDED
                     imageEdgeInsert:ZERO_EDGE
                     titleEdgeInsert:ZERO_EDGE] autorelease];
      [_member2ActivityView addSubview:_memberBut];
    }
    
    // Activity
    {
      CGRect activityFrame = CGRectMake(LIST_WIDTH-CLUB_MEMBER_ACTIVITY_BUTTON_W-MARGIN*2, MARGIN, CLUB_MEMBER_ACTIVITY_BUTTON_W, BUTTON_H);
      
      NSString *title = nil;
      NSString *buttonImageName = nil;
      NSString *buttonSelectedImageName = nil;
      UIColor *titleColor = nil;
      if ([@"1" isEqualToString:self.clubSimple.ifmember]) {
        title = LocaleStringForKey(NSQuitButTitle, nil);
        joinStatus = YES;
        
        buttonImageName = @"club_button.png";
        buttonSelectedImageName = @"club_button_selected.png";
        titleColor = DARK_BTN_TITLE_COLOR;
      }else {
        joinStatus = NO;
        title = LocaleStringForKey(NSJoinButTitle, nil);
        buttonImageName = @"button_orange.png";
        buttonSelectedImageName = @"button_orange_selected.png";
        titleColor = [UIColor whiteColor];
      }
      
      _joinAndQuitBut = [[[WXWImageButton alloc]
                                     initImageButtonWithFrame:activityFrame
                                     target:self
                                     action:@selector(doJoin2Quit:)
                                     title:title
                                     image:nil
                                     backImgName:buttonImageName
                                     selBackImgName:buttonSelectedImageName
                                     titleFont:BOLD_FONT(FONT_SIZE)
                                     titleColor:titleColor
                                     titleShadowColor:TRANSPARENT_COLOR
                                     roundedType:HAS_ROUNDED
                                     imageEdgeInsert:ZERO_EDGE
                                     titleEdgeInsert:ZERO_EDGE] autorelease];
      
      [_member2ActivityView addSubview:_joinAndQuitBut];
    }
    
    [_headerView addSubview:_member2ActivityView];
    
    // event
    UIView *eventView = [[[UIView alloc] initWithFrame:CGRectMake(0, TOP_VIEW_Y+TOP_VIEW_H+BUTTON_H+MARGIN*3, LIST_WIDTH, EVENT_VIEW_H)] autorelease];
    eventView.backgroundColor = COLOR(238, 238, 238);
    
    [_headerView addSubview:eventView];
    
    UILabel *eventTitleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(MARGIN*2, MARGIN, 200.f, 18.f)] autorelease];
    eventTitleLabel.font = FONT(FONT_SIZE);
    
    int number = [[self.clubSimple newEventNum] intValue];
    eventTitleLabel.text = [NSString stringWithFormat:@"%@ (%d)", LocaleStringForKey(NSGroupEventTitle,nil), number];
    
    [eventTitleLabel setTextColor:COLOR(136, 136, 136)];
    [eventTitleLabel setBackgroundColor:TRANSPARENT_COLOR];
    [eventView addSubview:eventTitleLabel];
    
    UILabel *eventDescLabel = [[[UILabel alloc] initWithFrame:CGRectMake(MARGIN*2, MARGIN*4, LIST_WIDTH - MARGIN*6, 54.f)] autorelease];
    eventDescLabel.font = BOLD_FONT(FONT_SIZE);
    
    if (![@"" isEqualToString:self.clubSimple.eventDesc]) {
      NSArray *eventArray = [self.clubSimple.eventDesc componentsSeparatedByString:@"$"];
      
      if ([eventArray count]>0) {
        NSArray *eventDetailArray = [eventArray[0] componentsSeparatedByString:@"|"];
        
        [eventDescLabel setText:[NSString stringWithFormat:@"%@ (%@) %@", eventDetailArray[0], eventDetailArray[1], eventDetailArray[2]]];
      }
      
      UIImageView *postImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]];
      postImgView.frame = CGRectMake(LIST_WIDTH-20.f, (EVENT_VIEW_H-14.f)/2.f, 10.f, 14.f);
      postImgView.backgroundColor = TRANSPARENT_COLOR;
      [eventView addSubview:postImgView];
      [postImgView release];
      
      UIButton *eventViewClick = [UIButton buttonWithType:UIButtonTypeCustom];
      eventViewClick.frame = eventView.frame;
      [eventViewClick addTarget:self action:@selector(goClubActivity:)forControlEvents:UIControlEventTouchUpInside];
      [_headerView addSubview:eventViewClick];
      
    } else {
      [eventDescLabel setText:LocaleStringForKey(NSNoGroupEventTitle, nil)];
    }
    
    eventDescLabel.lineBreakMode = UILineBreakModeTailTruncation;
    eventDescLabel.numberOfLines = 3;
    [eventDescLabel setTextColor:DARK_BTN_TITLE_COLOR];
    [eventDescLabel setBackgroundColor:TRANSPARENT_COLOR];
    [eventView addSubview:eventDescLabel];
    
    // post area
    UIToolbar *postToolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, TOP_VIEW_Y+TOP_VIEW_H+BUTTON_H + EVENT_VIEW_H + 15, LIST_WIDTH, BUTTON_H+20)] autorelease];
    postToolbar.barStyle = UIBarStyleBlack;
    postToolbar.translucent = YES;
    postToolbar.tintColor = DARK_CELL_COLOR;
    postToolbar.layer.masksToBounds = YES;
    
    [_headerView addSubview:postToolbar];
    
    WXWImageButton *tagFilterButton = [[[WXWImageButton alloc]
                                       initImageButtonWithFrame:CGRectMake(0, 0, 80.f, BUTTON_H)
                                       target:self
                                       action:@selector(showTagFilter:)
                                       title:LocaleStringForKey(NSFilterTitle, nil)
                                       image:nil
                                       backImgName:@"club_button.png"
                                       selBackImgName:@"club_button_selected.png"
                                       titleFont:BOLD_FONT(FONT_SIZE)
                                       titleColor:DARK_BTN_TITLE_COLOR
                                       titleShadowColor:[UIColor whiteColor]
                                       roundedType:HAS_ROUNDED
                                       imageEdgeInsert:ZERO_EDGE
                                       titleEdgeInsert:ZERO_EDGE] autorelease];
    UIBarButtonItem *tagFilterBarButton = [[[UIBarButtonItem alloc] initWithCustomView:tagFilterButton] autorelease];
    
    UIBarButtonItem *space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    
    WXWImageButton *postButton = [[[WXWImageButton alloc]
                                  initImageButtonWithFrame:CGRectMake(0, 0, 80.f, BUTTON_H)
                                  target:self
                                  action:@selector(doPost:)
                                  title:LocaleStringForKey(NSPostTitle, nil)
                                  image:[UIImage imageNamed:@"club_post_white.png"]
                                  backImgName:@"button_orange.png"
                                  selBackImgName:@"button_orange_selected.png"
                                  titleFont:BOLD_FONT(FONT_SIZE)
                                  titleColor:[UIColor whiteColor]
                                  titleShadowColor:TRANSPARENT_COLOR
                                  roundedType:HAS_ROUNDED
                                  imageEdgeInsert:ZERO_EDGE
                                  titleEdgeInsert:ZERO_EDGE] autorelease];
    
    UIBarButtonItem *postBarButton = [[[UIBarButtonItem alloc] initWithCustomView:postButton] autorelease];
    
    [postToolbar setItems:@[tagFilterBarButton, space, postBarButton]];
  }
  
  return _headerView;
}

#pragma mark - action
- (void)doJoin2Quit:(id)sender
{
  [_delegate doJoin2Quit:joinStatus ifAdmin:self.clubSimple.ifadmin];
}

- (void)doDetail:(UITapGestureRecognizer *)recognizer {
    if (_delegate) {
        [_delegate doDetail];
    }
}

- (void)doManage:(UITapGestureRecognizer *)recognizer {
  if (_delegate) {
    [_delegate doManage];
  }
}

- (void)goClubActivity:(id)sender
{
  [_delegate goClubActivity];
}

- (void)goClubUserList:(id)sender
{
  [_delegate goClubUserList];
}

- (void)doPost:(id)sender {
  [_delegate doPost];
}

- (void)showTagFilter:(id)sender {
  [_delegate showFilters];
}

@end
