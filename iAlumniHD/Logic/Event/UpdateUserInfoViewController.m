//
//  UpdateUserInfoViewController.m
//  iAlumniHD
//
//  Created by Adam on 12-11-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UpdateUserInfoViewController.h"

#define FONT_SIZE           20.0f
#define CELL_SIZE           3

#define LABEL_X             20.0f
#define CONTENT_X           80.0f
#define NOTE_Y              10.0f
#define EMAIL_Y             70.0f
#define MOBILE_Y            110.0f
#define WEIBO_Y             150.0f
#define LABEL_H             30.0f

typedef enum {
    EMAIL_TAG,
    MOBILE_TAG,
    WEIBO_TAG,
} UPDATE_USERINFO_VIEW_TAG;

@interface UpdateUserInfoViewController ()

@end

@implementation UpdateUserInfoViewController
@synthesize _TableCellShowValArray;
@synthesize _TableCellSaveValArray;
@synthesize _emailField;
@synthesize _mobileField;
@synthesize _weiboField;
@synthesize email;
@synthesize mobile;
@synthesize userId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _TableCellShowValArray = [[NSMutableArray alloc] init];
        _TableCellSaveValArray = [[NSMutableArray alloc] init];
        for (NSUInteger i=0; i<CELL_SIZE; i++) {
            [_TableCellShowValArray addObject:[NSString stringWithFormat:@"%d",iOriginalSelIndexVal]];
            [_TableCellSaveValArray addObject:[NSString stringWithFormat:@"%@",@""]];
        }
    }
    return self;
}

- (void)dealloc
{
    RELEASE_OBJ(_emailField);
    RELEASE_OBJ(_mobileField);
    RELEASE_OBJ(_weiboField);
    self.userId = nil;
    
    [super dealloc];
}

#pragma mark - view life cycle
- (void)initView
{
    
    UIView *bgView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, LIST_WIDTH, SCREEN_HEIGHT - 45)] autorelease];
    bgView.backgroundColor = TRANSPARENT_COLOR;
    
    // Note
    CGRect noteFrame = CGRectMake(LABEL_X, NOTE_Y, LIST_WIDTH, LABEL_H+20);
    UILabel *noteLabel = [[[UILabel alloc] initWithFrame:noteFrame] autorelease];
    noteLabel.text = LocaleStringForKey(NSUpdateUserInfoNote, nil);
    noteLabel.font = Arial_FONT(FONT_SIZE);
    noteLabel.textColor = COLOR(165, 165, 165);
    noteLabel.numberOfLines = 2;
    [bgView addSubview:noteLabel];
    
    // Email
    CGRect emailFrame = CGRectMake(LABEL_X, EMAIL_Y, LIST_WIDTH, LABEL_H);
    UILabel *emailLabel = [[[UILabel alloc] initWithFrame:emailFrame] autorelease];
    emailLabel.text = [NSString stringWithFormat:@"%@:",LocaleStringForKey(NSEmailTitle, nil)];
    emailLabel.textColor = COLOR(165, 165, 165);
    emailLabel.font = Arial_FONT(FONT_SIZE);
    [bgView addSubview:emailLabel];
    
    // Text Field
    CGRect emailTextFrame = CGRectMake(CONTENT_X, EMAIL_Y+5, LIST_WIDTH-100, LABEL_H);
    _emailField = [[UITextField alloc] initWithFrame:emailTextFrame];
    _emailField.tag = EMAIL_TAG;
    _emailField.returnKeyType = UIReturnKeyDone;
    
    _emailField.text = [AppManager instance].eventAlumniEmail;
    _emailField.delegate = self;
    _emailField.placeholder = LocaleStringForKey(NSEmailTitle, nil);
    _emailField.borderStyle = UITextBorderStyleNone;
    _emailField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _emailField.keyboardType = UIKeyboardTypeASCIICapable;
    [bgView addSubview:_emailField];
    
    // name line
    CGRect nameLineFrame = CGRectMake(LABEL_X, EMAIL_Y+LABEL_H, LIST_WIDTH-2*LABEL_X, 1);
    UIView *nameLine = [[[UIView alloc] initWithFrame:nameLineFrame] autorelease];
    nameLine.backgroundColor = COLOR(209, 216, 228);
    [bgView addSubview:nameLine];
    
    // Mobile
    CGRect mobileFrame = CGRectMake(LABEL_X, MOBILE_Y, LIST_WIDTH, LABEL_H);
    UILabel *mobileLabel = [[[UILabel alloc] initWithFrame:mobileFrame] autorelease];
    mobileLabel.text = [NSString stringWithFormat:@"%@:",LocaleStringForKey(NSMobileTitle, nil)];
    mobileLabel.textColor = COLOR(165, 165, 165);
    mobileLabel.font = Arial_FONT(FONT_SIZE);
    [bgView addSubview:mobileLabel];
    
    // Mobile Field Text
    CGRect mobileTextFrame = CGRectMake(CONTENT_X, MOBILE_Y+5, LIST_WIDTH-100, LABEL_H);
    _mobileField = [[UITextField alloc] initWithFrame:mobileTextFrame];
    _mobileField.tag = MOBILE_TAG;
    _mobileField.returnKeyType = UIReturnKeyDone;
    
    _mobileField.text = [AppManager instance].eventAlumniMobile;
    _mobileField.delegate = self;
    _mobileField.placeholder = LocaleStringForKey(NSMobileTitle, nil);
    _mobileField.borderStyle = UITextBorderStyleNone;
    _mobileField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _mobileField.keyboardType = UIKeyboardTypePhonePad;
    [bgView addSubview:_mobileField];
    
    CGRect classLineFrame = CGRectMake(LABEL_X, MOBILE_Y+LABEL_H, LIST_WIDTH-2*LABEL_X, 1);
    UIView *classLine = [[[UIView alloc] initWithFrame:classLineFrame] autorelease];
    classLine.backgroundColor = COLOR(209, 216, 228);
    [bgView addSubview:classLine];
    
    // sina weibo
    CGRect weiboFrame = CGRectMake(LABEL_X, WEIBO_Y, LIST_WIDTH, LABEL_H);
    UILabel *weiboLabel = [[[UILabel alloc] initWithFrame:weiboFrame] autorelease];
    weiboLabel.text = [NSString stringWithFormat:@"%@:",LocaleStringForKey(NSSinaWeiboTitle, nil)];
    weiboLabel.textColor = COLOR(165, 165, 165);
    weiboLabel.font = Arial_FONT(FONT_SIZE);
    [bgView addSubview:weiboLabel];
    
    // Mobile Field Text
    CGRect weiboTextFrame = CGRectMake(CONTENT_X+30, WEIBO_Y+5, LIST_WIDTH-120, LABEL_H);
    _weiboField = [[UITextField alloc] initWithFrame:weiboTextFrame];
    _weiboField.tag = WEIBO_TAG;
    _weiboField.returnKeyType = UIReturnKeyDone;
    
    _weiboField.text = [AppManager instance].eventAlumniWeibo;
    _weiboField.delegate = self;
    _weiboField.placeholder = LocaleStringForKey(NSSinaWeiboTitle, nil);
    _weiboField.borderStyle = UITextBorderStyleNone;
    _weiboField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _weiboField.keyboardType = UIKeyboardTypeEmailAddress;
    [bgView addSubview:_weiboField];
    
    CGRect weiboLineFrame = CGRectMake(LABEL_X, WEIBO_Y+LABEL_H, LIST_WIDTH-2*LABEL_X, 1);
    UIView *weiboLine = [[[UIView alloc] initWithFrame:weiboLineFrame] autorelease];
    weiboLine.backgroundColor = COLOR(209, 216, 228);
    [bgView addSubview:weiboLine];
    
    [self.view addSubview:bgView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = LocaleStringForKey(NSUpdateUserInfoTitle, nil);
    
	// Do any additional setup after loading the view.
    [self initView];
    
    self.navigationItem.rightBarButtonItem = BAR_BUTTON(LocaleStringForKey(NSDoneTitle, nil), UIBarButtonItemStyleDone, self, @selector(doModify:));
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

#pragma mark - action

- (void)doModify:(id)sender {
    [_emailField resignFirstResponder];
    [_mobileField resignFirstResponder];
    [_weiboField resignFirstResponder];
    
    _currentType = EVENT_CHECK_IN_UPDATE_TY;
    
    NSString *param = [NSString stringWithFormat:@"<target_user_id>%@</target_user_id><update_mobile>%@</update_mobile><update_email>%@</update_email><update_sina_username>%@</update_sina_username><is_from_admin>%d</is_from_admin>",
                       self.userId,
                       _mobileField.text,
                       _emailField.text,
                       _weiboField.text,
                       [AppManager instance].isAdminCheckIn == NO ? 0 : 1];
    
    NSString *url = [CommonUtils geneUrl:param itemType:_currentType];

    WXWAsyncConnectorFacade *connector = [self setupAsyncConnectorForUrl:url
                                                            contentType:_currentType];
    
    [connector asyncGet:url showAlertMsg:YES];
}

#pragma mark - UITextField delegate methods
- (void)textFieldDidBeginEditing:(UITextField *)textField
{	
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - WXWConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(WebItemType)contentType
{
    [WXWUIUtils showActivityView:_tableView text:LocaleStringForKey(NSLoadingTitle, nil)];
    [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(WebItemType)contentType{
    [WXWUIUtils closeActivityView];
    
    switch (contentType) {
            
        case EVENT_CHECK_IN_UPDATE_TY:
        {
            if (result == nil || [result length] == 0) {
                [WXWUIUtils showNotificationWithMsg:LocaleStringForKey(NSParserXmlNullMsg, nil)
                                         msgType:ERROR_TY
                                      holderView:[APP_DELEGATE foundationView]];
                return;
            }
            
            ReturnCode ret = [XMLParser handleCommonResult:result showFlag:YES];
            if (ret == RESP_OK) {
                
                if ([self.userId isEqualToString:[AppManager instance].personId]) {
                    [self doBack:self];
                    return;
                }
                
                if ([@"" isEqualToString:_mobileField.text] || _mobileField.text.length < 1) {
                    [self doBack:self];
                } else {
                    ShowAlertWithTwoButton(self, LocaleStringForKey(NSNoteTitle, nil), LocaleStringForKey(NSAdminCheckSmsTitle, nil), LocaleStringForKey(NSCancelTitle, nil), LocaleStringForKey(NSSureTitle, nil));
                }
            }
        }
            break;
            
        case EVENT_ADMIN_CHECK_SMS_TY:
        {
            if (result == nil || [result length] == 0) {
                [WXWUIUtils showNotificationWithMsg:LocaleStringForKey(NSParserXmlNullMsg, nil)
                                         msgType:ERROR_TY
                                      holderView:[APP_DELEGATE foundationView]];
                return;
            }
            
            ReturnCode ret = [XMLParser handleCommonResult:result showFlag:YES];
            if (ret == RESP_OK) {
                [self doBack:self];
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

- (void)doAdminCheckSms
{
    
    NSString *param = nil;
    _currentType = EVENT_ADMIN_CHECK_SMS_TY;
    
    param = [NSString stringWithFormat:@"<sms_mobile>%@</sms_mobile>", _mobileField.text];
    
    NSString *url = [CommonUtils geneUrl:param itemType:_currentType];

    WXWAsyncConnectorFacade *connector = [self setupAsyncConnectorForUrl:url
                                                            contentType:_currentType];
    
    [connector asyncGet:url showAlertMsg:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        [self doAdminCheckSms];
        return;
    } else {
        [self doBack:self];
    }
}

- (void)doBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
