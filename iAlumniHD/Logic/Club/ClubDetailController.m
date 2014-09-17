
//
//  ClubDetailController.m
//  iAlumniHD
//
//  Created by Adam on 12-11-15.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ClubDetailController.h"
#import "UserListViewController.h"
#import "UIWebViewController.h"
#import "WXWLabel.h"

#define NAME_WIDTH                      228.0f
#define TITLE_ICON_WIDTH                26.0f
#define TITLE_ICON_HEIGHT               7.0f

#define CELL_LABEL_X                    10.0f
#define TITLE_X                         20.0f
#define HEADER_VIEW_H                   50.0f
#define FONT_SIZE                       13.0f
#define NUMBER_X                        220.f
#define LABEL_X                         10.0f
#define DESC_TITLE_HEIGHT               25.0f
#define DESC_BUTTON_HEIGHT              25.0f
#define LABEL_Y                         10.0f
#define TEL_X                           60.0f

#define LABEL_MAX                       100.0f
#define LABEL_CONTENT_INTERVAL          10.0f
#define NUMBER_X                        220.f
#define BUTTON_W                        90.f
#define PHOTO_WIDTH                     98.0f//110.0f
#define PHOTO_HEIGHT                    80.0f//90.0f

#define MEMBER2ACTIVITY_X               MARGIN*3
#define MEMBER2ACTIVITY_Y               30.0f

#define JOIN2MANAGE_Y                   60.0f

#define SECTION_COUNT                   4

static int iDescHeight = 0;
static int iChargeHeight = 0;
static int iManagerOneHeight = 0;
static int iManagerHeight = 0;
static int iManageCount = 0;

enum {
    nameTag = 0,
    memberLabelTag,
    memberCountTag,
    activityLabelTag,
    activityCountTag,
    joinTag,
    manageTag,
    sendTag,
    descTag,
    activityTag,
    personTag,
};

@interface ClubDetailController()
@property (nonatomic, retain) UIView *headerView;
@property (nonatomic, retain) NSArray *clubInstructionList;
@end

@implementation ClubDetailController
@synthesize iLabel1Array,iValue1Array;
@synthesize _club;
@synthesize headerView = _headerView;
@synthesize clubInstructionList = _clubInstructionList;

- (id)initWithMOC:(NSManagedObjectContext*)MOC
{
    self = [super initWithMOC:MOC];
    if (self) {
        joinStatus = NO;
    }
    return self;
}

- (void)dealloc
{
    self.headerView = nil;
    
    self.iLabel1Array = nil;
    self.iValue1Array = nil;
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)doBack:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - load detail
- (void)loadSponsorDetail {
    [CommonUtils doDelete:_MOC entityName:@"ClubDetail"];
    
    NSString *param = [NSString stringWithFormat:@"<host_id>%@</host_id><host_type>%@</host_type>", [AppManager instance].clubId, [AppManager instance].hostTypeValue];
    
    _currentType = SPONSOR_TY;
    NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
    
    WXWAsyncConnectorFacade *connector = [self setupAsyncConnectorForUrl:url
                                                            contentType:_currentType];
    
    [connector asyncGet:url showAlertMsg:YES];
}

- (void)initResource
{
    // Cell Array
    self.iLabel1Array = [[[NSArray alloc] initWithObjects:LocaleStringForKey(NSTelTitle, nil), LocaleStringForKey(NSEmailTitle, nil), LocaleStringForKey(NSWebSiteTitle, nil), nil] autorelease];
    self.iValue1Array = [[[NSArray alloc] initWithObjects:_club.tel, _club.email, _club.webUrl, nil] autorelease];
    
    // club instruction
    self.clubInstructionList = @[LocaleStringForKey(NSServicePlanTitle, nil),
    LocaleStringForKey(NSConstitutionTitle, nil),
    LocaleStringForKey(NSCouncilListTitle, nil)];
    
    // Desc Height
    CGSize constraint = CGSizeMake(LIST_WIDTH-80, CGFLOAT_MAX);
    CGSize descSize = [_club.desc sizeWithFont:FONT(FONT_SIZE) constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    
    iDescHeight = descSize.height;
    
    CGSize chargeSize = [_club.change sizeWithFont:FONT(FONT_SIZE) constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    
    iChargeHeight = chargeSize.height;
    
    // Manager
    NSArray *aArray = [_club.managerMsg componentsSeparatedByString:@"$"];
    CGSize managerSize = [aArray[0] sizeWithFont:FONT(FONT_SIZE)];
    iManagerOneHeight = managerSize.height;
    
    iManageCount = [aArray count];
    iManagerHeight = iManagerOneHeight*(iManageCount/2);
    
    if(iManageCount%2!=0){
        iManagerHeight += iManagerOneHeight;
    }
}

- (void)initTableView {
    
	CGRect mTabFrame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
	_tableView = [[[UITableView alloc] initWithFrame:mTabFrame
                                                   style:UITableViewStyleGrouped] autorelease];
	
//	_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_tableView.dataSource = self;
	_tableView.delegate = self;
    _tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"lightBackground.png"]];
	
    [self reSizeTable];
	[self.view addSubview:_tableView];
    [super initTableView];
    
}

#pragma mark - View lifecycle

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!_autoLoaded) {
        [self loadSponsorDetail];
    }
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self hideTable];
    self.view.frame = _frame;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - Table View

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:{
            //            if (self.headerView == nil) {
            self.headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, _tableView.frame.origin.y, LIST_WIDTH, HEADER_VIEW_H)] autorelease];
            
            UIImageView *_leftTitleIcon = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title.png"]] autorelease];
            _leftTitleIcon.backgroundColor = TRANSPARENT_COLOR;
            [self.headerView addSubview:_leftTitleIcon];
            
            UIImageView *_rightTitleIcon = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title.png"]] autorelease];
            _rightTitleIcon.backgroundColor = TRANSPARENT_COLOR;
            [self.headerView addSubview:_rightTitleIcon];
            
            WXWLabel *_nameLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                        textColor:CELL_TITLE_COLOR
                                                      shadowColor:[UIColor whiteColor]] autorelease];
            _nameLabel.font = BOLD_FONT(15);
            _nameLabel.numberOfLines = 0;
            _nameLabel.textAlignment = UITextAlignmentCenter;
            [self.headerView addSubview:_nameLabel];
            
            _nameLabel.text = _club.name;
            CGSize size = [_nameLabel.text sizeWithFont:_nameLabel.font
                                      constrainedToSize:CGSizeMake(NAME_WIDTH, CGFLOAT_MAX)
                                          lineBreakMode:UILineBreakModeWordWrap];
            _nameLabel.frame = CGRectMake((LIST_WIDTH - size.width)/2.0f, MARGIN * 2,
                                          size.width, size.height);
            
            CGFloat y = _nameLabel.frame.origin.y;
            _leftTitleIcon.frame = CGRectMake(MARGIN * 2, y + (_nameLabel.frame.size.height - TITLE_ICON_HEIGHT)/2.0f,
                                              TITLE_ICON_WIDTH,
                                              TITLE_ICON_HEIGHT);
            _rightTitleIcon.frame = CGRectMake(LIST_WIDTH - MARGIN * 2 - TITLE_ICON_WIDTH,
                                               _leftTitleIcon.frame.origin.y,
                                               TITLE_ICON_WIDTH, TITLE_ICON_HEIGHT);
            return self.headerView;
        }
            break;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ClubDetailCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSArray *subviews = [[NSArray alloc] initWithArray:cell.contentView.subviews];
    for (UIView *subview in subviews) {
        [subview removeFromSuperview];
    }
    [subviews release];
    
    // Configure the cell...
    [self configureCell:indexPath aCell:cell];
    
    // Selected Style
    cell.selectedBackgroundView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, LIST_WIDTH, cell.frame.size.height)] autorelease];
    cell.selectedBackgroundView.backgroundColor = CELL_SELECTED_COLOR;
    
    return cell;
}

- (void)drawIntroCell:(UITableViewCell *)cell {
    
    UIView *mCellView = [[UIView alloc] initWithFrame:CGRectMake(2, 2, LIST_WIDTH-55, DESC_TITLE_HEIGHT+MARGIN*2+iDescHeight)];
    [mCellView setBackgroundColor:COLOR(222, 222, 222)];
    
    CGRect descTitleFrame = CGRectMake(CELL_LABEL_X, 0, LIST_WIDTH-24, DESC_TITLE_HEIGHT);
    UILabel *mLabel = [[UILabel alloc] initWithFrame:descTitleFrame];
    [mLabel setText:LocaleStringForKey(NSIntroductionTitle, nil)];
    [mLabel setFont:BOLD_FONT(FONT_SIZE+2)];
    [mLabel setTextColor:COLOR(196, 24, 32)];
    [mLabel setBackgroundColor:TRANSPARENT_COLOR];
    [mCellView addSubview:mLabel];
    [mLabel release];
    
    CGRect descFrame = CGRectMake(CELL_LABEL_X, DESC_TITLE_HEIGHT, LIST_WIDTH-80, iDescHeight);
    UILabel *mDesc = [[UILabel alloc] initWithFrame:descFrame];
    [mDesc setText:_club.desc];
    mDesc.numberOfLines = 0;
    mDesc.lineBreakMode = UILineBreakModeCharacterWrap;
    [mDesc setFont:FONT(FONT_SIZE)];
    [mDesc setBackgroundColor:TRANSPARENT_COLOR];
    [mDesc setTextColor:[UIColor blackColor]];
    [mCellView addSubview:mDesc];
    [mDesc release];
    
    [mCellView setBackgroundColor:TRANSPARENT_COLOR];
    [cell.contentView addSubview:mCellView];
    [mCellView release];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)drawManagementCell:(UITableViewCell *)cell {
    
    UIView *mCellView = [[UIView alloc] initWithFrame:CGRectMake(2, 2, LIST_WIDTH-55, DESC_TITLE_HEIGHT+MARGIN*2+iDescHeight)];
    [mCellView setBackgroundColor:COLOR(222, 222, 222)];
    
    CGRect descTitleFrame = CGRectMake(CELL_LABEL_X, (DEFAULT_CELL_HEIGHT - DESC_TITLE_HEIGHT)/2.0f, LIST_WIDTH-24, DESC_TITLE_HEIGHT);
    UILabel *mLabel = [[UILabel alloc] initWithFrame:descTitleFrame];
    [mLabel setText:LocaleStringForKey(NSGroupManagementTitle, nil)];
    [mLabel setFont:BOLD_FONT(FONT_SIZE+2)];
    [mLabel setTextColor:COLOR(196, 24, 32)];
    [mLabel setBackgroundColor:TRANSPARENT_COLOR];
    [mCellView addSubview:mLabel];
    [mLabel release];
    
    [mCellView setBackgroundColor:TRANSPARENT_COLOR];
    [cell.contentView addSubview:mCellView];
    [mCellView release];
    
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

#pragma mark - handle empty list
- (BOOL)listIsEmpty {
  return NO;
}

#pragma mark - Table view delegate
-(void)configureCell:(NSIndexPath *)indexPath aCell:(UITableViewCell *)cell
{
    int section = [indexPath section];
    int row = [indexPath row];
    [cell setBackgroundColor:[UIColor whiteColor]];
    switch (section) {
        case 0:
        {
            
            if (indexPath.row == 0) {
                [self drawIntroCell:cell];
            }
            
            if ([AppManager instance].clubAdmin && indexPath.row == 1) {
                [self drawManagementCell:cell];
            }
            
            break;
        }
            
        case 1:
        {
            UIView *mCellView = [[UIView alloc] initWithFrame:CGRectMake(2, 2, LIST_WIDTH-55, DESC_TITLE_HEIGHT+MARGIN*2+iChargeHeight)];
            [mCellView setBackgroundColor:COLOR(222, 222, 222)];
            CGRect descTitleFrame = CGRectMake(CELL_LABEL_X, 0, LIST_WIDTH-20-4, DESC_TITLE_HEIGHT);
            UILabel *mLabel = [[UILabel alloc] initWithFrame:descTitleFrame];
            [mLabel setText:LocaleStringForKey(NSChangeTitle, nil)];
            [mLabel setFont:BOLD_FONT(FONT_SIZE+2)];
            [mLabel setTextColor:COLOR(196, 24, 32)];
            [mLabel setBackgroundColor:TRANSPARENT_COLOR];
            [mCellView addSubview:mLabel];
            [mLabel release];
            
            CGRect descFrame = CGRectMake(CELL_LABEL_X, DESC_TITLE_HEIGHT, LIST_WIDTH-80, iChargeHeight);
            UILabel *mDesc = [[UILabel alloc] initWithFrame:descFrame];
            [mDesc setText:_club.change];
            mDesc.numberOfLines = 0;
            mDesc.lineBreakMode = UILineBreakModeCharacterWrap;
            [mDesc setFont:FONT(FONT_SIZE)];
            [mDesc setBackgroundColor:TRANSPARENT_COLOR];
            [mDesc setTextColor:[UIColor blackColor]];
            [mCellView addSubview:mDesc];
            [mDesc release];
            
            [mCellView setBackgroundColor:TRANSPARENT_COLOR];
            [cell.contentView addSubview:mCellView];
            [mCellView release];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            break;
        }
            
        case 2:
        {
            NSString *mText = (self.clubInstructionList)[row];
            CGSize mDescSize = [mText sizeWithFont:FONT(FONT_SIZE + 3)];
            UILabel *mUILable = [[UILabel alloc] initWithFrame:CGRectMake(CELL_LABEL_X, LABEL_Y, mDescSize.width, mDescSize.height)];
            mUILable.text = mText;
            mUILable.textColor = COLOR(82, 82, 82);
            [mUILable setBackgroundColor:TRANSPARENT_COLOR];
            mUILable.font = BOLD_FONT(FONT_SIZE);
            mUILable.tag = row + 40;
            [cell.contentView addSubview:mUILable];
            [mUILable release];
            
            break;
        }
            
        case 3:
        {
            // Label
            NSString *mText = iLabel1Array[row];
            CGSize mDescSize = [mText sizeWithFont:FONT(FONT_SIZE + 3)];
            UILabel *mUILable = [[UILabel alloc] initWithFrame:CGRectMake(CELL_LABEL_X, LABEL_Y, mDescSize.width, mDescSize.height)];
            mUILable.text = mText;
            mUILable.textColor = COLOR(82, 82, 82);
            [mUILable setBackgroundColor:TRANSPARENT_COLOR];
            mUILable.font = BOLD_FONT(FONT_SIZE);
            mUILable.tag = row + 40;
            [cell.contentView addSubview:mUILable];
            [mUILable release];
            
            // Number
            NSString *mNumber = iValue1Array[row];
            CGSize mNumberSize = [mNumber sizeWithFont:FONT(FONT_SIZE + 3)];
            
            UILabel *mLable = [[UILabel alloc] init];
            mLable.text = mNumber;
            mLable.font = FONT(FONT_SIZE + 3);
            mLable.textColor = [UIColor blackColor];
            [mLable setBackgroundColor:TRANSPARENT_COLOR];
            CGRect mLabelFrame = CGRectMake(TEL_X, LABEL_Y, 200, mNumberSize.height);
            
            mLable.frame = mLabelFrame;
            mLable.lineBreakMode = UILineBreakModeTailTruncation;
            
            [cell.contentView addSubview:mLable];
            [mLable release];
            
            if (![mNumber isEqualToString:@""]) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }else{
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            break;
        }
            
        default:
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ([indexPath section]) {
        case 0:
        {
            if ([AppManager instance].clubAdmin && indexPath.row == 1) {
                
                NSString *url = [NSString stringWithFormat:@"%@app_login.jsp?logname=%@&password=%@", [AppManager instance].hostUrl, [EncryptUtil TripleDES:[AppManager instance].userId
                                                                                                                                           encryptOrDecrypt:kCCEncrypt],
                                 [EncryptUtil TripleDES:[AppManager instance].passwd
                                       encryptOrDecrypt:kCCEncrypt]];
                
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            }
            break;
        }
            
        case 2:
        {
            NSString *url = nil;
            NSString *title = nil;
            switch (indexPath.row) {
                case 0:
                {
                    url = [NSString stringWithFormat:@"%@%@&host_id=%@&locale=%@&plat=%@&version=%@&sessionId=%@", [AppManager instance].hostUrl, EVENT_SERVICE_PLAN_URL, [AppManager instance].clubId, [AppManager instance].currentLanguageDesc, PLATFORM, VERSION, [AppManager instance].sessionId];
                    title = LocaleStringForKey(NSServicePlanTitle, nil);
                    break;
                }
                    
                case 1:
                {
                    url = [NSString stringWithFormat:@"%@%@&host_id=%@&locale=%@&plat=%@&version=%@&sessionId=%@", [AppManager instance].hostUrl, EVENT_CONSTITUTION_URL, [AppManager instance].clubId, [AppManager instance].currentLanguageDesc, PLATFORM, VERSION, [AppManager instance].sessionId];
                    title = LocaleStringForKey(NSConstitutionTitle, nil);
                    break;
                }
                    
                case 2:
                {
                    url = [NSString stringWithFormat:@"%@%@&host_id=%@&locale=%@&plat=%@&version=%@&sessionId=%@", [AppManager instance].hostUrl, EVENT_COUNCIL_LIST_URL, [AppManager instance].clubId, [AppManager instance].currentLanguageDesc, PLATFORM, VERSION, [AppManager instance].sessionId];
                    title = LocaleStringForKey(NSCouncilListTitle, nil);
                    break;
                }
                    
                default:
                    break;
            }
            
            [self goUrl:url aTitle:title];
            
            break;
        }
            
        case 3:
        {
            switch ([indexPath row]) {
                case 0:
                {
//                    [self goCallPhone];
                    
                    break;
                }
                    
                case 1:
                {
                    NSString *url;
                    url = [NSString stringWithFormat:@"mailto://%@",_club.email];
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
                    
                    break;
                }
                    
                case 2:
                {
                    [self goUrl:_club.webUrl
                           aTitle:_club.name];
                    
                    break;
                }
                    
                default:
                    break;
            }
            
            break;
        }
            
        default:
            break;
    }
    
    [super deselectCell];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return SECTION_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            if ([AppManager instance].clubAdmin) {
                return 2;
            } else {
                return 1;
            }
        case 1:
            return 1;
        case 2:
            return 3;
        case 3:
            return 3;
        default:
            return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return HEADER_VIEW_H;
            
        default:
            return 2;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch ([indexPath section]) {
        case 0:
        {
            if (indexPath.row == 0) {
                return (DESC_TITLE_HEIGHT+MARGIN*3+iDescHeight);
            }
            
            if ([AppManager instance].clubAdmin && indexPath.row == 1) {
                return DEFAULT_CELL_HEIGHT;
            }
        }
            
        case 1:
            return DESC_TITLE_HEIGHT+MARGIN*3 + iChargeHeight;
            
        case 5:
            return (DESC_TITLE_HEIGHT+MARGIN*3+iManagerHeight);
            
        default:
            return 40;
    }
}

#pragma mark - WXWConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(WebItemType)contentType
{
    [WXWUIUtils showActivityView:[APP_DELEGATE foundationView]
                         text:LocaleStringForKey(NSLoadingTitle, nil)];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(WebItemType)contentType
{
    [WXWUIUtils closeActivityView];
    
    switch (contentType) {
        case SPONSOR_TY:
        {
            if ([XMLParser parserSyncResponseXml:result type:FETCH_SPONSOR_SRC MOC:_MOC]) {
                [self fetchItems];
                _autoLoaded = YES;
                [self showTable];
            } else {
                [WXWUIUtils showNotificationOnTopWithMsg:@"Failed Msg"
                                              msgType:ERROR_TY
                                   belowNavigationBar:YES];
                
            }
        }
            break;
                        
        default:
            break;
    }
}

- (void)connectCancelled:(NSString *)url
             contentType:(WebItemType)contentType {
    [WXWUIUtils closeActivityView];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(WebItemType)contentType {
    [WXWUIUtils closeActivityView];
  
  [super connectFailed:error url:url contentType:contentType];
}

#pragma mark - core date parameter
- (void)setFetchCondition {
    self.entityName = @"ClubDetail";
    
    self.descriptors = [NSMutableArray array];
    
    NSSortDescriptor *dateDesc = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease];
    [self.descriptors addObject:dateDesc];
}

- (void)fetchItems {
    [NSFetchedResultsController deleteCacheWithName:nil];
    
    NSError *error = nil;
    BOOL res = [[super prepareFetchRC] performFetch:&error];
    if (!res) {
		NSAssert1(0, @"Unhandled error performing fetch: %@", [error localizedDescription]);
	}
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(sponsorId == %@)", [AppManager instance].clubId];
    NSArray *sponsorDetail = [CommonUtils objectsInMOC:_MOC
                                            entityName:self.entityName
                                          sortDescKeys:nil
                                             predicate:predicate];
    
    if ([sponsorDetail count]) {
        _club = (ClubDetail*)[sponsorDetail lastObject];
        [AppManager instance].hostSupTypeValue = [NSString stringWithFormat:@"%@",  _club.hostSupTypeValue];
    }
    
    [self initResource];
    [self initTableView];
}

@end
