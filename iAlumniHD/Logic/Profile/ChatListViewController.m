//
//  ChatListViewController.m
//  iAlumniHD
//
//  Created by Adam on 12-11-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ChatListViewController.h"
#import "AlumniProfileViewController.h"
#import "ChatListCell.h"
#import "Chat.h"

@interface ChatListViewController ()
@property (nonatomic, retain) AlumniDetail  *alumni;
@end

#define TABLEVIEWTAG                300

#define TABLE_HEIGHT                SCREEN_HEIGHT - (20.0f + 44.0f + TOOLBAR_HEIGHT)
#define kKeyboardHeightPortrait     216
#define kKeyboardHeightLandscape    140

#define FONT_SIZE                   15.0f
#define INPUT_MAX_LINE              4

static int iSize = 0;
static int iHistorySize = 0;

typedef enum {
    NONE_INIT_TY = 0,
    UP_TY,
    DOWN_TY,
} CHAT_DIRECTION_TY;

@implementation ChatListViewController

@synthesize alumni = _alumni;
@synthesize startChatId;
@synthesize endChatId;
@synthesize messageString = _messageString;
@synthesize phraseString = _phraseString;
@synthesize faceViewController = _faceViewController;
@synthesize inputToolbar;
@synthesize promptLabel;
@synthesize promptView;

- (id)initWithMOC:(NSManagedObjectContext *)MOC alumni:(AlumniDetail*)alumni
{
    self = [super initNoNeedLoadBackendDataWithMOC:MOC
                       holder:nil
             backToHomeAction:nil
        needRefreshHeaderView:YES
        needRefreshFooterView:YES
                   tableStyle:UITableViewStylePlain
                   needGoHome:NO];
    
    if(self) {
        
        self.alumni = alumni;
        self.startChatId = @"";
        self.endChatId = @"";
        [AppManager instance].visiblePopTipViews = [NSMutableArray array];
	}
	
    return self;
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    
    self.phraseString = nil;
    self.startChatId = nil;
    self.endChatId = nil;
    
    self.inputToolbar = nil;
    self.promptLabel = nil;
    self.promptView = nil;
    
    [[AppManager instance].visiblePopTipViews removeAllObjects];
    [AppManager instance].visiblePopTipViews = nil;
    
    [super dealloc];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    /* Listen for keyboard */
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // 键盘高度变化通知，ios5.0新增的
    if ([CommonUtils currentOSVersion] >= IOS5) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
    
    if (!_autoLoaded) {
		[self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
	}
    
    NSLog(@"self.messageString is %@", self.messageString);
}

- (void)setTAbleProperties {
    
    _tableView.tag = TABLEVIEWTAG;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    keyboardIsVisible = NO;
    
    _tableView.separatorColor = TRANSPARENT_COLOR;
    _tableView.backgroundColor = CELL_COLOR;
    
    self.view.backgroundColor = CELL_COLOR;
    
    /* Create toolbar */
    self.inputToolbar = [[[UIInputToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - TOOLBAR_HEIGHT, self.view.frame.size.width, TOOLBAR_HEIGHT)] autorelease];
    [self.inputToolbar.textView setMaximumNumberOfLines:INPUT_MAX_LINE];
    [self.view addSubview:self.inputToolbar];
    self.inputToolbar.delegate = self;
    
    self.title = _alumni.name;
    
    NSMutableString *tempStr = [NSMutableString stringWithString:@""];
    self.messageString = tempStr;
    
	// Do any additional setup after loading the view.
    self.navigationItem.rightBarButtonItem = BAR_BUTTON(LocaleStringForKey(NSRefreshTitle,nil), UIBarButtonItemStyleBordered, self, @selector(refreshData));
    
    // Add prompt when no records
    NSString *promptMsg = [NSString stringWithFormat:@"%@ %@ %@", LocaleStringForKey(NSChatPrompt1Text, nil), _alumni.name, LocaleStringForKey(NSChatPrompt2Text, nil)];
    
    CGSize constraint = CGSizeMake(LIST_WIDTH-30.f, CGFLOAT_MAX);
    
    CGSize promptSize = [promptMsg sizeWithFont:Arial_FONT(FONT_SIZE)
                              constrainedToSize:constraint
                                  lineBreakMode:UILineBreakModeTailTruncation];
    
    promptView = [[UIView alloc] initWithFrame:CGRectMake(10.f, 20.f, LIST_WIDTH-20.f, promptSize.height+10)];
    promptView.backgroundColor = COLOR(181, 181, 179);
    promptView.layer.borderColor = COLOR(202, 202, 202).CGColor;
    
    promptView.layer.cornerRadius = 6.0f;
    promptView.layer.masksToBounds = YES;
    promptView.layer.borderWidth = 1.0f;
    
    promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.f, 5.f, LIST_WIDTH-30.f, promptSize.height)];
    promptLabel.backgroundColor = TRANSPARENT_COLOR;
    promptLabel.font = Arial_FONT(FONT_SIZE);
    promptLabel.textColor = COLOR(252, 252, 252);
    promptLabel.text = promptMsg;
    
    promptLabel.numberOfLines = 5;
    [promptView addSubview:promptLabel];
    
    [self.view addSubview:promptView];
    promptView.hidden = YES;
    
    [self setTAbleProperties];
    
    keyboardIsVisible = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	/* No longer listen for keyboard */
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    if ([CommonUtils currentOSVersion] >= IOS5) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

#pragma mark - Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedRC sections] objectAtIndex:section];
    iSize = [sectionInfo numberOfObjects];
    return [sectionInfo numberOfObjects];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Chat *chat = [self.fetchedRC objectAtIndexPath:indexPath];
    if ([indexPath row] == 0) {
        self.startChatId = [chat.chartId stringValue];
    }
    
    if (iSize-1 == [indexPath row]) {
        self.endChatId = [chat.chartId stringValue];
    }
    
    CGSize size = [chat.msg sizeWithFont:FONT(FONT_SIZE) constrainedToSize:CGSizeMake(150.0f, CGFLOAT_MAX) lineBreakMode:UILineBreakModeCharacterWrap];
    
	return size.height+50.0f;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"ChatCell";
    
    ChatListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[ChatListCell alloc] initWithStyle:UITableViewCellStyleDefault alumni:self.alumni reuseIdentifier:CellIdentifier imageClickableDelegate:self] autorelease];
		cell.backgroundColor = [UIColor colorWithRed:0.859f green:0.886f blue:0.929f alpha:1.0f];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.parentView = self.view;
    }
    
    // Set up the cell...
	for(UIView *subview in [cell.contentView subviews])
		[subview removeFromSuperview];
    
    Chat *chat = [self.fetchedRC objectAtIndexPath:indexPath];
	[cell drawChat:chat];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
}

#pragma mark - Table view methods
- (UIView *)bubbleView:(NSString *)text from:(BOOL)fromSelf {
    
	// build single chat bubble cell with given text
	UIView *returnView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
	returnView.backgroundColor = TRANSPARENT_COLOR;
    
	UIImage *bubble = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fromSelf ? @"bubbleSelf" : @"bubble" ofType:@"png"]];
	UIImageView *bubbleImageView = [[[UIImageView alloc] initWithImage:[bubble stretchableImageWithLeftCapWidth:21 topCapHeight:14]] autorelease];
    
	UIFont *font = [UIFont systemFontOfSize:12];
	CGSize size = [text sizeWithFont:font constrainedToSize:CGSizeMake(150.0f, CGFLOAT_MAX) lineBreakMode:UILineBreakModeCharacterWrap];
    
	UILabel *bubbleText = [[[UILabel alloc] initWithFrame:CGRectMake(21.0f, 14.0f, size.width+10, size.height+10)] autorelease];
	bubbleText.backgroundColor = TRANSPARENT_COLOR;
	bubbleText.font = font;
	bubbleText.numberOfLines = 0;
	bubbleText.lineBreakMode = UILineBreakModeCharacterWrap;
	bubbleText.text = text;
	
	bubbleImageView.frame = CGRectMake(0.0f, 0.0f, 200.0f, size.height+40.0f);
	if(fromSelf)
		returnView.frame = CGRectMake(120.0f, 10.0f, 200.0f, size.height+50.0f);
	else
		returnView.frame = CGRectMake(0.0f, 10.0f, 200.0f, size.height+50.0f);
	
	[returnView addSubview:bubbleImageView];
	[returnView addSubview:bubbleText];
    
	return returnView;
}

#pragma mark - action
- (void)refreshData {
    
    [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
}

- (void)showFaceInfo:(id)sender
{
    self.messageString =[NSMutableString stringWithFormat:@"%@", self.inputToolbar.textView.text];
	[self.inputToolbar.textView resignFirstResponder];
	if (self.faceViewController == nil) {
		ChatFaceViewController *temp = [[[ChatFaceViewController alloc] initWithObject:self] autorelease];
		self.faceViewController = temp;
	}
    
	[self presentModalViewController:self.faceViewController animated:YES];
}

#pragma mark - load data
- (void)loadListData:(LoadTriggerType)triggerType forNew:(BOOL)forNew
{
    [super loadListData:triggerType forNew:forNew];
    
    iHistorySize = iSize;
    
    NSString *param = [NSString stringWithFormat:@"<target_user_id>%@</target_user_id><target_user_type>%@</target_user_type><id>%@</id><page_turning>%d</page_turning><page_size>6</page_size>", self.alumni.personId, self.alumni.userType, forNew == NO ? self.endChatId : self.startChatId, forNew == NO ? 2 : 1];
    
    NSString *url = [CommonUtils geneUrl:param itemType:CHART_LIST_TY];
    
    WXWAsyncConnectorFacade *connector = [self setupAsyncConnectorForUrl:url
                                                            contentType:CHART_LIST_TY];
    [connector asyncGet:url showAlertMsg:YES];
}

#pragma mark - fetch charts
- (void)setFetchCondition {
    
    self.predicate = [NSPredicate predicateWithFormat:@"(chartId > 0)"];
    self.entityName = @"Chat";
    
    self.descriptors = [NSMutableArray array];
    NSSortDescriptor *dateDesc = [[[NSSortDescriptor alloc] initWithKey:@"chartId" ascending:YES] autorelease];
    [self.descriptors addObject:dateDesc];
    
}

- (int)getPointIndex {
    
    int pointIndex = 0;
    NSIndexPath *indexPath = nil;
    for (int i=0; i<iSize; i++) {
        indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        Chat *chat = [self.fetchedRC objectAtIndexPath:indexPath];
        if ([startChatId isEqualToString:[chat.chartId stringValue]]) {
            pointIndex = i;
            break;
        }
    }
    
    return pointIndex;
}

- (void)fetchItems {
    
    [NSFetchedResultsController deleteCacheWithName:nil];
    
    NSError *error = nil;
    BOOL res = [[super prepareFetchRC] performFetch:&error];
    if (!res) {
		NSAssert1(0, @"Unhandled error performing fetch: %@", [error localizedDescription]);
	}
    
    [_tableView reloadData];
    
    if (iSize-1 < 0) {
        promptView.hidden = NO;
        return;
    } else {
        promptView.hidden = YES;
    }
    
    switch (flag) {
        case NONE_INIT_TY:
        {
            [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(iSize-1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
            break;
            
        case UP_TY:
        {
            if (iSize > iHistorySize) {
                [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(iSize-iHistorySize-1) inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            } else {
                [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            }
        }
            break;
            
        case DOWN_TY:
        {
            if (iSize > iHistorySize) {
                [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(iHistorySize) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
            } else {
                [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(iSize-1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
            }
        }
            break;
            
        default:
            break;
    }
    
}

#pragma mark - reset refresh header/footer view status
- (void)resetHeaderRefreshViewStatus {
    
	_reloading = NO;
	[WXWUIUtils dataSourceDidFinishLoadingNewData:_tableView
                                    headerView:_headerRefreshView];
}

- (void)resetFooterRefreshViewStatus {
    
	_reloading = NO;
	[WXWUIUtils dataSourceDidFinishLoadingOldData:_tableView
                                    footerView:_footerRefreshView];
}

- (void)resetHeaderOrFooterViewStatus {
    
    if (_loadForNewItem) {
        flag = UP_TY;
        [self resetHeaderRefreshViewStatus];
    } else {
        flag = DOWN_TY;
        [self resetFooterRefreshViewStatus];
    }
}

- (void)resetUIElementsForConnectDoneOrFailed {
    
    switch (_currentLoadTriggerType) {
        case TRIGGERED_BY_AUTOLOAD:
            flag = NONE_INIT_TY;
            _autoLoaded = YES;
            break;
            
        case TRIGGERED_BY_SCROLL:
            [self resetHeaderOrFooterViewStatus];
            break;
            
        default:
            break;
    }
}

#pragma mark - WXWConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(WebItemType)contentType
{
    switch (contentType) {
        case CHART_LIST_TY:
            [WXWUIUtils showActivityView:[APP_DELEGATE foundationView]
                                 text:LocaleStringForKey(NSLoadingTitle, nil)];
            break;
            
        default:
            break;
    }
    
    [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(WebItemType)contentType
{
    switch (contentType) {
        case CHAT_SUBMIT_TY:
            if( RESP_OK == [XMLParser handleCommonResult:result showFlag:YES] ){
                _autoLoaded = NO;
                [self loadListData:TRIGGERED_BY_SCROLL forNew:NO];
            }
            break;
            
        case CHART_LIST_TY:
        {
            if ([XMLParser parserSyncResponseXml:result type:CHART_LIST_SRC MOC:_MOC]) {
                //                _autoLoaded = YES;
                
                [self resetUIElementsForConnectDoneOrFailed];
                [self fetchItems];
            } else {
                [WXWUIUtils showNotificationWithMsg:LocaleStringForKey(NSActionFaildMsg, nil)
                                         msgType:ERROR_TY
                                      holderView:[APP_DELEGATE foundationView]];
            }
        }
            break;
            
        default:
            break;
    }
    [super connectDone:result url:url contentType:contentType];
}

- (void)connectCancelled:(NSString *)url
             contentType:(WebItemType)contentType
{
    switch (contentType) {
        case CHART_LIST_TY:
            [WXWUIUtils closeActivityView];
            break;
            
        default:
            break;
    }
    
    [super connectCancelled:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(WebItemType)contentType
{
    switch (contentType) {
        case CHART_LIST_TY:
            [WXWUIUtils closeActivityView];
            break;
            
        default:
            break;
    }
    
    [super connectFailed:error url:url contentType:contentType];
}

#pragma mark - keyboard

- (void)moveInputBarWithKeyboardHeight:(CGFloat)height withDuration:(CFTimeInterval)animationDuration {
    
    CGRect r = self.inputToolbar.frame;
    r.origin.y = self.view.frame.size.height - self.inputToolbar.frame.size.height;
    if (keyboardIsVisible) {
        r.origin.y -= height;
    }
    
    self.inputToolbar.frame = r;
	UITableView *tableView = (UITableView *)[self.view viewWithTag:TABLEVIEWTAG];
	tableView.frame = CGRectMake(0.0f, 0.0f, LIST_WIDTH, self.inputToolbar.frame.origin.y);
}

#pragma mark - Notifications
- (void)keyboardWillShow:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    keyboardIsVisible = YES;
    [self moveInputBarWithKeyboardHeight:keyboardRect.size.width withDuration:animationDuration];
    
    if (iSize > 1) {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(iSize-1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary* userInfo = [notification userInfo];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    keyboardIsVisible = NO;
    [self moveInputBarWithKeyboardHeight:0.0 withDuration:animationDuration];
}

#pragma mark - UIInputToolbarDelegate method
-(void)inputButtonPressed:(NSString *)inputText
{
    /* Called when toolbar button is pressed */
    NSLog(@"Pressed button with text: '%@'", inputText);
    
    //submit
    NSString *param = [NSString stringWithFormat:@"<target_user_id>%@</target_user_id><target_user_type>%@</target_user_type><message>%@</message>", self.alumni.personId, self.alumni.userType, inputText];
    
    NSString *url = [CommonUtils geneUrl:param itemType:CHAT_SUBMIT_TY];
    
    WXWAsyncConnectorFacade *connector = [self setupAsyncConnectorForUrl:url
                                                            contentType:CHAT_SUBMIT_TY];
    [connector asyncGet:url showAlertMsg:YES];
}

- (void)notifyTableHeight
{
	UITableView *tableView = (UITableView *)[self.view viewWithTag:TABLEVIEWTAG];
	tableView.frame = CGRectMake(0.0f, 0.0f, LIST_WIDTH, self.inputToolbar.frame.origin.y);
}

#pragma mark - ECClickableElementDelegate method

- (void)openProfile:(NSString*)personId userType:(NSString*)userType
{
    AlumniProfileViewController *profileVC = [[[AlumniProfileViewController alloc] initWithMOC:_MOC
                                                                                      personId:personId
                                                                                      userType:ALUMNI_USER_TY] autorelease];
    profileVC.title = LocaleStringForKey(NSAlumniDetailTitle, nil);
    [self.navigationController pushViewController:profileVC animated:YES];
}

- (void)hideKeyboard {
    
    [self.inputToolbar.textView resignFirstResponder];
    keyboardIsVisible = NO;
    [self moveInputBarWithKeyboardHeight:0.0 withDuration:0.0];
}

@end
