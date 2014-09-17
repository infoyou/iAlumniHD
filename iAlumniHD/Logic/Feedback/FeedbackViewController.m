
//
//  FeedbackViewController.m
//  iAlumniHD
//
//  Created by Adam on 12-11-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FeedbackViewController.h"
#import "UIWebViewController.h"
#import "Feedback.h"

#define FONT_SIZE               15.0f
#define LABEL_Y                 15.0f
#define TITLE_HEIGHT            190.0f
#define TEXT_FIELD_HEIGHT       200.0f

static int  OneHeight = 0;
static int  Section0Height = 0;
static int  Section1Height = 0;
static int  Section2Height = 0;
static int  InputSize = 0;

@interface FeedbackViewController()
@property (nonatomic, retain) Feedback *feedback;
@property (nonatomic, retain) UITextView *textView;
@end

@implementation FeedbackViewController
@synthesize feedback = _feedback;
@synthesize textView = _textView;

#pragma mark - View lifecycle

- (id)initWithMOC:(NSManagedObjectContext *)MOC
{
    self = [super initWithMOC:MOC];
    
    if (self) {
        _selCellArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    self.feedback = nil;
    RELEASE_OBJ(_textView);
    
    [super dealloc];
}

- (void)loadFeedback
{
    NSString *url = [NSString stringWithFormat:@"%@%@&locale=%@", [AppManager instance].hostUrl, SOFT_FEEDBACK_MSG_URL, [AppManager instance].currentLanguageDesc];
    WXWAsyncConnectorFacade *connector = [self setupAsyncConnectorForUrl:url
                                                            contentType:FETCH_FEEDBACK_MSG_TY];
    
    [connector asyncGet:url showAlertMsg:YES];
}

- (void)initTableView
{
    int offsetY = 0;
    
    CGRect mTabFrame = CGRectMake(0, offsetY, self.view.frame.size.width, self.view.frame.size.height-offsetY);
	_tableView = [[UITableView alloc] initWithFrame:mTabFrame
                                              style:UITableViewStyleGrouped];
	
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_tableView.dataSource = self;
	_tableView.delegate = self;
	
	[self.view addSubview:_tableView];
    
    [self reSizeTable];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadFeedback];
    
    self.title = LocaleStringForKey(NSFeedbackTitle, nil);
    _textView = [[UITextView alloc] initWithFrame:CGRectZero];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - logic
- (void)getLogicSize
{
    CGSize fontSize =[LocaleStringForKey(NSFeedbackMsg, nil) sizeWithFont:BOLD_FONT(FONT_SIZE)
                                                                 forWidth:_frame.size.width-20
                                                            lineBreakMode:UILineBreakModeTailTruncation];
    OneHeight = fontSize.height;
    
    CGSize feedbackConstraint = CGSizeMake(_frame.size.width-20, 2000.0f);
    CGSize feedbackSize = [LocaleStringForKey(NSFeedbackMsg, nil) sizeWithFont:BOLD_FONT(FONT_SIZE) constrainedToSize:feedbackConstraint lineBreakMode:UILineBreakModeWordWrap];
    Section0Height = feedbackSize.height;
    
    CGSize feedback1Constraint = CGSizeMake(_frame.size.width-20, 2000.0f);
    CGSize feedback1Size = [LocaleStringForKey(NSFeedbackMsg1, nil) sizeWithFont:BOLD_FONT(FONT_SIZE) constrainedToSize:feedback1Constraint lineBreakMode:UILineBreakModeWordWrap];
    Section1Height = feedback1Size.height;
    
    CGSize feedback2Constraint = CGSizeMake(_frame.size.width-20, 2000.0f);
    CGSize feedback2Size = [LocaleStringForKey(NSFeedbackMsg2, nil) sizeWithFont:BOLD_FONT(FONT_SIZE) constrainedToSize:feedback2Constraint lineBreakMode:UILineBreakModeWordWrap];
    Section2Height = feedback2Size.height;
}

#pragma mark - handle empty list
- (BOOL)listIsEmpty {
  return NO;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            break;
            
        case 1:
            return [[self.feedback.sampleMsg componentsSeparatedByString:@"|"] count];
            break;
            
        case 2:
            return 2;
            break;
            
        default:
            return 0;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = [indexPath section];
    switch (section) {
        case 0:
            return TEXT_FIELD_HEIGHT;
            break;
            
        case 1:
            return 50;
            break;
            
        case 2:
            return 50;
            break;
            
        default:
            return 0;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return Section2Height*2 + 20;
            break;
            
        case 1:
        case 2:
            return Section2Height+15;
            break;
            
        default:
            return 0;
            break;
    }
}

- (UIView *)initSection0View
{
    CGRect titleFrame = CGRectMake(0, 0, _frame.size.width, Section2Height*2+20);
    UIView *titleView = [[[UIView alloc] initWithFrame:titleFrame] autorelease];
    
    NSURL *loadUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    CGRect htmlFrame = CGRectMake(30, 0, _frame.size.width-60, Section2Height*2+20);
    UIWebView *htmlView = [[[UIWebView alloc] initWithFrame:htmlFrame] autorelease];
    htmlView.delegate = self;
    htmlView.userInteractionEnabled = YES;
    htmlView.backgroundColor = TRANSPARENT_COLOR;
    htmlView.opaque = NO;
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@%@", FEEDBACK_TEXT_HEADER, LocaleStringForKey(NSFeedbackMsg, nil), TEXT_FOOTER];
    [htmlView loadHTMLString:urlStr baseURL:loadUrl];
    
    [titleView addSubview:htmlView];
    [titleView setBackgroundColor:TRANSPARENT_COLOR];
    
    return titleView;
}

- (UIView *)initSection1View
{
    CGRect titleFrame = CGRectMake(0, 0, _frame.size.width, Section1Height+20);
    UIView *titleView = [[[UIView alloc] initWithFrame:titleFrame] autorelease];
    
    // Feedback
    CGRect feedbackFrame = CGRectMake(30, 10, _frame.size.width-20, Section2Height);
    UILabel *feedbackLabel = [[[UILabel alloc] initWithFrame:feedbackFrame] autorelease];
    feedbackLabel.text = LocaleStringForKey(NSFeedbackMsg2, nil);
    feedbackLabel.textColor = [UIColor blackColor];
    feedbackLabel.font = HTML_FONT(FONT_SIZE+1);
    if ( Section2Height % OneHeight == 0 ) {
        feedbackLabel.numberOfLines = Section2Height/OneHeight;
    }else{
        feedbackLabel.numberOfLines = Section2Height/OneHeight + 1;
    }
    feedbackLabel.lineBreakMode = UILineBreakModeWordWrap;
    [feedbackLabel setBackgroundColor:TRANSPARENT_COLOR];
    [titleView addSubview:feedbackLabel];
    
    return titleView;
}

- (UIView *)initSection2View
{
    CGRect titleFrame = CGRectMake(0, 0, _frame.size.width, Section1Height+20);
    UIView *titleView = [[[UIView alloc] initWithFrame:titleFrame] autorelease];
    
    // Feedback
    CGRect feedbackFrame = CGRectMake(30, 10, _frame.size.width-20, Section2Height);
    UILabel *feedbackLabel = [[[UILabel alloc] initWithFrame:feedbackFrame] autorelease];
    feedbackLabel.text = LocaleStringForKey(NSFeedbackMsg3, nil);
    feedbackLabel.textColor = [UIColor blackColor];
    feedbackLabel.font = HTML_FONT(FONT_SIZE+1);
    if ( Section2Height % OneHeight == 0 ) {
        feedbackLabel.numberOfLines = Section2Height/OneHeight;
    }else{
        feedbackLabel.numberOfLines = Section2Height/OneHeight + 1;
    }
    feedbackLabel.lineBreakMode = UILineBreakModeWordWrap;
    [feedbackLabel setBackgroundColor:TRANSPARENT_COLOR];
    [titleView addSubview:feedbackLabel];
    
    return titleView;
}

- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return [self initSection0View];
        case 1:
            return [self initSection1View];
        case 2:
            return [self initSection2View];
        default:
            return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    switch (section) {
        case 1:
            return 40;
            break;
            
        case 0:
        case 2:
            return 10;
            break;
            
        default:
            return 0;
    }
}

- (UIView *)tableView:(UITableView *)aTableView viewForFooterInSection:(NSInteger)section {
    switch (section) {
        case 1:
        {
            UIView *mUIView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, _frame.size.width-20, 40)] autorelease];
            
            CGRect mSubmitFrame = CGRectMake(_frame.size.width-120, 2, 80, 30);
            WXWGradientButton *btn = [[[WXWGradientButton alloc] initWithFrame:mSubmitFrame
                                                                      target:self
                                                                      action:@selector(submitClick:)
                                                                   colorType:RED_BTN_COLOR_TY
                                                                       title:LocaleStringForKey(NSSubmitButTitle, nil)
                                                                       image:nil
                                                                  titleColor:BLUE_BTN_TITLE_COLOR
                                                            titleShadowColor:BLUE_BTN_TITLE_SHADOW_COLOR
                                                                   titleFont:BOLD_FONT(FONT_SIZE)
                                                                 roundedType:HAS_ROUNDED
                                                             imageEdgeInsert:ZERO_EDGE
                                                             titleEdgeInsert:ZERO_EDGE] autorelease];
            
            [mUIView addSubview:btn];
            return mUIView;
        }
            break;
            
        default:
            return nil;
            break;
    }
}

-(void)configureCell:(NSIndexPath *)indexPath aCell:(UITableViewCell *)cell
{
    int line = [indexPath section];
    int row = [indexPath row];
    [cell setBackgroundColor:[UIColor whiteColor]];
    
    switch (line) {
            
        case 0:
        {
            self.textView.frame = CGRectMake(0, 0, _frame.size.width-20, TITLE_HEIGHT);
            self.textView.textColor = [UIColor blackColor];
            self.textView.font = BOLD_FONT(FONT_SIZE);
            self.textView.delegate = self;
            self.textView.backgroundColor = TRANSPARENT_COLOR;
            self.textView.returnKeyType = UIReturnKeyDefault;
            self.textView.keyboardType = UIKeyboardTypeDefault;
            // use the default type input method (entire keyboard)
            // self.textView.scrollEnabled = YES;
            
            // this will cause automatic vertical resize when the table is resized
            // self.textView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
            
            // note: for UITextView, if you don't like autocompletion while typing use:
            self.textView.autocorrectionType = UITextAutocorrectionTypeNo;
            self.textView.userInteractionEnabled = YES;
            
            // keyboard view add Done Button
            UIToolbar *topView = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, LIST_WIDTH, 30)] autorelease];
            
            [topView setBarStyle:UIBarStyleBlack];
            
            UIBarButtonItem * keyButton = BAR_BUTTON(LocaleStringForKey(NSKeyboardTitle, nil), UIBarButtonItemStylePlain, self, nil);
            
            UIBarButtonItem * btnSpace = BAR_SYS_BUTTON(UIBarButtonSystemItemFlexibleSpace , self,nil);
            
            UIBarButtonItem * doneButton = BAR_BUTTON(LocaleStringForKey(NSDoneTitle, nil) , UIBarButtonItemStyleDone ,self,@selector(dismissKeyBoard));
            
            NSArray * buttonsArray = [NSArray arrayWithObjects:keyButton, btnSpace,doneButton, nil];
            
            [topView setItems:buttonsArray];
            
            [self.textView setInputAccessoryView:topView];
            [cell.contentView addSubview:self.textView];
        }
            break;
            
        case 1:
        {
            // Label
            NSArray *aArray = [self.feedback.sampleMsg componentsSeparatedByString:@"|"];
            NSString *mText = [aArray objectAtIndex:row];
            CGSize mDescSize = [mText sizeWithFont:BOLD_FONT(FONT_SIZE)];
            UILabel *mUILable = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN * 2, LABEL_Y, mDescSize.width, mDescSize.height)];
            mUILable.text = mText;
            mUILable.textColor = [UIColor blackColor];
            [mUILable setBackgroundColor:TRANSPARENT_COLOR];
            mUILable.font = BOLD_FONT(FONT_SIZE);
            mUILable.tag = row + 10;
            mUILable.highlightedTextColor = [UIColor whiteColor];
            [cell.contentView addSubview:mUILable];
            [mUILable release];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
            break;
            
        case 2:
        {
            switch (row) {
                case 0:
                {
                    // Label
                    NSString *mText = LocaleStringForKey(NSTelTitle,nil);
                    CGSize mDescSize = [mText sizeWithFont:FONT(FONT_SIZE+3)];
                    UILabel *mUILable = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN * 2, LABEL_Y, mDescSize.width, mDescSize.height)];
                    mUILable.text = mText;
                    mUILable.textColor = COLOR(82, 82, 82);
                    [mUILable setBackgroundColor:TRANSPARENT_COLOR];
                    mUILable.font = FONT(FONT_SIZE+3);
                    mUILable.tag = row + 20;
                    mUILable.highlightedTextColor = [UIColor whiteColor];
                    [cell.contentView addSubview:mUILable];
                    [mUILable release];
                    
                    // Number
                    NSString *mNumber = self.feedback.tel;
                    CGSize mNumberSize = [mNumber sizeWithFont:FONT(FONT_SIZE+3)];
                    
                    UILabel *mLable = [[UILabel alloc] init];
                    mLable.text = mNumber;
                    mLable.font = FONT(FONT_SIZE+3);
                    mLable.textColor = [UIColor blackColor];
                    mLable.highlightedTextColor = [UIColor whiteColor];
                    [mLable setBackgroundColor:TRANSPARENT_COLOR];
                    CGRect mLabelFrame = CGRectMake(80, LABEL_Y, mNumberSize.width, mNumberSize.height);
                    mLable.lineBreakMode = UILineBreakModeTailTruncation;
                    mLable.frame = mLabelFrame;
                    
                    [cell.contentView addSubview:mLable];
                    [mLable release];
                    
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                    break;
                    
                case 1:
                {
                    // Label
                    NSString *mText = LocaleStringForKey(NSEmailTitle,nil);
                    CGSize mDescSize = [mText sizeWithFont:FONT(FONT_SIZE+3)];
                    CGRect labelFrame = CGRectMake(MARGIN * 2, LABEL_Y, mDescSize.width, mDescSize.height);
                    UILabel *mUILable = [[UILabel alloc] initWithFrame:labelFrame];
                    mUILable.text = mText;
                    mUILable.textColor = COLOR(82, 82, 82);
                    [mUILable setBackgroundColor:TRANSPARENT_COLOR];
                    mUILable.font = FONT(FONT_SIZE+3);
                    mUILable.tag = row + 20;
                    mUILable.highlightedTextColor = [UIColor whiteColor];
                    [cell.contentView addSubview:mUILable];
                    [mUILable release];
                    
                    // Number
                    NSString *mNumber = self.feedback.email;
                    CGSize mNumberSize = [mNumber sizeWithFont:FONT(FONT_SIZE+3)];
                    
                    UILabel *mLable = [[UILabel alloc] init];
                    mLable.text = mNumber;
                    mLable.font = FONT(FONT_SIZE+3);
                    mLable.textColor = [UIColor blackColor];
                    mLable.highlightedTextColor = [UIColor whiteColor];
                    [mLable setBackgroundColor:TRANSPARENT_COLOR];
                    CGRect mLabelFrame = CGRectMake(80, LABEL_Y, mNumberSize.width, mNumberSize.height);
                    mLable.lineBreakMode = UILineBreakModeTailTruncation;
                    mLable.frame = mLabelFrame;
                    
                    [cell.contentView addSubview:mLable];
                    [mLable release];
                    
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                    break;
            }
        }
            break;
            
        default:
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSArray *subviews = [[NSArray alloc] initWithArray:cell.contentView.subviews];
    
    for (UIView *subview in subviews) {
        [subview removeFromSuperview];
    }
    
    [subviews release];
    
    if (![_selCellArray containsObject:indexPath]) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    // Configure the cell...
    [self configureCell:indexPath aCell:cell];
    return cell;
}

#pragma mark - UITableViewDelegate method
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ([indexPath section]) {
            
        case 1:
        {
            UITableViewCell *mCell = [tableView cellForRowAtIndexPath:indexPath];
            if (mCell.accessoryType == UITableViewCellAccessoryCheckmark) {
                mCell.accessoryType = UITableViewCellAccessoryNone;
                [_selCellArray removeObject:indexPath];
            } else {
                mCell.accessoryType = UITableViewCellAccessoryCheckmark;
                [_selCellArray addObject:indexPath];
                NSString *url = [NSString stringWithFormat:@"%@index=%d&user_id=%@&locale=%@", COOPRATION_SAMPLE_URL, [indexPath row]+1, [AppManager instance].userId, [AppManager instance].currentLanguageDesc];
                
                [self goUrl:url aTitle:@""];
            }
        }
            break;
            
        case 2:
        {
            int row = [indexPath row];
            switch (row) {
                case 0:
                {
                    // [self goCallPhone];
                }
                    break;
                    
                case 1:
                {
                    /*
                     NSString *url = [NSString stringWithFormat:@"mailto://%@", self.feedback.email];
                     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
                     */
                    [self doSendEmail:self.feedback.email];
                }
                    break;
                    
                default:
                    break;
            }
            
        }
            break;
        default:
            break;
    }
    
    [super deselectCell];
}

#pragma mark - UITextViewDelegate method
- (void)textViewDidBeginEditing:(UITextView *)textArea{
    NSString *temp = LocaleStringForKey(NSFeedbackPromptTitle, nil);
	if ([textArea.text isEqualToString:temp]) {
		textArea.textColor = [UIColor blackColor];
		textArea.text = @"";
	}
}

- (void)textViewDidEndEditing:(UITextView *)textArea{
	if ([textArea.text isEqualToString:@""]) {
		textArea.textColor = [UIColor grayColor];
		textArea.text = LocaleStringForKey(NSFeedbackPromptTitle, nil);
	}
}

- (void)dismissKeyBoard
{
    [self.textView resignFirstResponder];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    InputSize = [self.textView.text length];
    return YES;
}

#pragma mark - Core data
- (void)setFetchCondition {
    
    self.entityName = @"Feedback";
    self.descriptors = nil;
    self.descriptors = [[[NSMutableArray alloc] init] autorelease];
    
    NSSortDescriptor *dateDesc = [[[NSSortDescriptor alloc] initWithKey:@"tel" ascending:YES] autorelease];
    [self.descriptors addObject:dateDesc];
    
    self.predicate = [NSPredicate predicateWithFormat:@"(sampleMsg != %@)", @""];
}

- (NSFetchedResultsController *)prepareFetchRC {
    
    [self setFetchCondition];
    
    self.fetchedRC = nil;
    self.fetchedRC = [CommonUtils fetchObject:_MOC
                     fetchedResultsController:self.fetchedRC
                                   entityName:self.entityName
                           sectionNameKeyPath:nil
                              sortDescriptors:self.descriptors
                                    predicate:self.predicate];
    
    return self.fetchedRC;
}

- (void)fetchItems {
    [NSFetchedResultsController deleteCacheWithName:nil];
    
    NSError *error = nil;
    BOOL res = [[self prepareFetchRC] performFetch:&error];
    if (!res) {
		NSAssert1(0, @"Unhandled error performing fetch: %@", [error localizedDescription]);
	}
    
    NSArray *feedbackDetail = [CommonUtils objectsInMOC:_MOC
                                             entityName:self.entityName
                                           sortDescKeys:nil
                                              predicate:nil];
    
    if ([feedbackDetail count]) {
        self.feedback = (Feedback*)[feedbackDetail lastObject];
    }
    
    [self getLogicSize];
    [self initTableView];
}

#pragma mark - WXWConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(WebItemType)contentType
{
    [WXWUIUtils showActivityView:[APP_DELEGATE foundationView]
                         text:LocaleStringForKey(NSLoadingTitle, nil)];
  [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result
                url:(NSString *)url
        contentType:(WebItemType)contentType
{
    //    [WXWUIUtils closeActivityView];
    
    switch (contentType) {
        case FETCH_FEEDBACK_SUBMIT_TY:
            [XMLParser handleCommonResult:result showFlag:YES];
            break;
            
        case FETCH_FEEDBACK_MSG_TY:
        {
            if ([XMLParser parserSyncResponseXml:result type:FETCH_FEEDBACK_SRC MOC:_MOC]) {
                _autoLoad = YES;
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
    [WXWUIUtils closeActivityView];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(WebItemType)contentType {
    
    [WXWUIUtils closeActivityView];
  [super connectFailed:error url:url contentType:contentType];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // Find the next entry field
    [self.textView becomeFirstResponder];
    
    return NO;
}

- (void)getCheckMsg
{
    checkMsg = @"";
    int size = [_selCellArray count];
    for (int i=0; i<size; i++) {
        NSIndexPath *mIndexPath = (NSIndexPath *)[_selCellArray objectAtIndex:i];
        if (![checkMsg isEqualToString:@""]) {
            checkMsg = [NSString stringWithFormat:@"%@,%d",checkMsg,[mIndexPath row]];
        }else{
            checkMsg = [NSString stringWithFormat:@"%d",[mIndexPath row]];
        }
    }
}

-(void)submitClick:(id)sender
{
    //submit
    NSString *temp = LocaleStringForKey(NSNoteTitle, nil);
    if ([self.textView.text isEqualToString:temp] || [self.textView.text length] == 0) {
        
        [WXWUIUtils showNotificationWithMsg:LocaleStringForKey(NSFeecbackEmptyWarningMsg, nil)
                                 msgType:ERROR_TY
                              holderView:[APP_DELEGATE foundationView]];
	} else {
        [self getCheckMsg];
        
        NSString *param = [NSString stringWithFormat:@"<items_selected>%@</items_selected><message>%@</message><type>2</type>",
                           checkMsg,
                           self.textView.text];
        
        NSString *url = [CommonUtils geneUrl:param itemType:FETCH_FEEDBACK_SUBMIT_TY];
        
        WXWAsyncConnectorFacade *connector = [self setupAsyncConnectorForUrl:url
                                                                contentType:FETCH_FEEDBACK_SUBMIT_TY];
        
        [connector asyncGet:url showAlertMsg:YES];
    }
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType
{
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        NSString *url = [[inRequest URL] absoluteString];
        url = [url stringByReplacingOccurrencesOfString:@"file:///%22" withString:@""];
        url = [url stringByReplacingOccurrencesOfString:@"/%22" withString:@""];
        if ([url isEqualToString:@"http://www.jitmarketing.cn"]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            return NO;
        }else {
            return NO;
        }
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView{}
- (void)webViewDidFinishLoad:(UIWebView *)webView{}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{}

#pragma mark - user actions
- (void)doSendEmail:(NSString *)email {
    
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailComposeVC = [[[MFMailComposeViewController alloc] init] autorelease];
        
        mailComposeVC.mailComposeDelegate = self;
        
        [mailComposeVC setToRecipients:[NSArray arrayWithObject:email]];
        [mailComposeVC setSubject:LocaleStringForKey(NSCaseShareEmailSubjectMsg, nil)];
        
        [self presentModalViewController:mailComposeVC animated:YES];
        
    } else {
        [WXWUIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSCannotSendEmailMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
    }
    
}

#pragma mark - MFMailComposeViewControllerDelegate method
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
    switch (result)
	{
		case MFMailComposeResultCancelled:
			break;
            
		case MFMailComposeResultSaved:
			
			break;
		case MFMailComposeResultSent:
			
			break;
		case MFMailComposeResultFailed:
			
			break;
		default:
			
			break;
	}
    
	[self dismissModalViewControllerAnimated:YES];
}

@end
