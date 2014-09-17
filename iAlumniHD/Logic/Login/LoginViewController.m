//
//  LoginViewController.h
//  iAlumniHD
//
//  Created by Adam on 12-03-19.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "EncryptUtil.h"
#import "UIWebViewController.h"
#import "WXWLabel.h"

#define FONT_SIZE                     24

typedef enum{
    UPDATE_SOFT_TYPE = 0,
    LOGIN_HELP_TYPE,
} LOGIN_ALERT_TYPE;

@interface LoginViewController()
@property (nonatomic, retain) UITextField *nameField;
@property (nonatomic, retain) UITextField *passwordField;
@property (nonatomic, retain) UIUrlLabel *pswdLabel;

@end

@implementation LoginViewController
@synthesize loginNoteLabel;
@synthesize homepageVC;

- (id)initWithMOC:(NSManagedObjectContext *)MOC autoLogin:(BOOL)autoLogin {
    self = [super init];
    if (self) {
        _MOC = MOC;
        _autoLogin = autoLogin;
    }
    
    return self;
}

- (void)dealloc {
    self.homepageVC = nil;
    
    self.nameField.delegate = nil;
    self.passwordField.delegate = nil;
    self.pswdLabel.delegate = nil;
    
    self.nameField = nil;
    self.passwordField = nil;
    self.pswdLabel = nil;
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!_hostFetched) {
        [self getHostUrl];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark - init view
- (void)initView
{
    if (_autoLogin) {
        
        UIView *backView = [[[UIView alloc] init] autorelease];
        backView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        
        UIImageView *backImgView = [[[UIImageView alloc] init] autorelease];
        backImgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        [backImgView setImage:[UIImage imageNamed:@"login_bg.png"]];
        [backView addSubview:backImgView];
        
        [self.view addSubview:backView];
        return;
    }
    
    UIView *backView = [[[UIView alloc] init] autorelease];
    backView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    
    UIImageView *backImgView = [[[UIImageView alloc] init] autorelease];
    backImgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [backImgView setImage:[UIImage imageNamed:@"login.png"]];
    [backView addSubview:backImgView];
    
    /*
     // Help Image
     UIImageView *mHelpImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"help.png"]];
     mHelpImg.frame = CGRectMake(700, 300, 35, 35);
     mHelpImg.userInteractionEnabled = YES;
     UIGestureRecognizer *mHelpImgTap = [[UITapGestureRecognizer alloc]
     initWithTarget:self action:@selector(doHelpPrompt:)];
     mHelpImgTap.delegate = self;
     [mHelpImg addGestureRecognizer:mHelpImgTap];
     [backView addSubview:mHelpImg];
     [mHelpImg release];
     */
    
    // User Name
    CGRect mName = CGRectMake(337.0f, 308.5f, 228.f, 45.0f);
    self.nameField = [[[UITextField alloc] initWithFrame:mName] autorelease];
    self.nameField.delegate = self;
    self.nameField.text = [[AppManager instance] getUserIdFromLocal];
    self.nameField.placeholder = LocaleStringForKey(NSUserPlaceholder, nil);
    self.nameField.font = [UIFont boldSystemFontOfSize:FONT_SIZE+2];
    self.nameField.keyboardType = UIKeyboardTypeASCIICapable;
    self.nameField.layer.cornerRadius = 6.0f;
    self.nameField.layer.masksToBounds = YES;
    [backView addSubview:self.nameField];
    
    // User Password
    CGRect mPswd = CGRectMake(337.0f, 381.6f, 228.f, 45.0f);
    self.passwordField = [[[UITextField alloc] initWithFrame:mPswd] autorelease];
    self.passwordField.delegate = self;
    self.passwordField.text = [[AppManager instance] getPasswordFromLocal];
    self.passwordField.placeholder = LocaleStringForKey(NSPswdPlaceholder, nil);
    self.passwordField.font = [UIFont boldSystemFontOfSize:FONT_SIZE+2];
    self.passwordField.keyboardType = UIKeyboardTypeASCIICapable;
    self.passwordField.layer.cornerRadius = 6.0f;
    self.passwordField.layer.masksToBounds = YES;
    self.passwordField.secureTextEntry = YES;
    [backView addSubview:self.passwordField];
    
    // Pswd Note Label
    CGRect mPswdFrame = CGRectMake(574.0f, 381.6f, 200.0f, 30.0f);
    self.pswdLabel = [[[UIUrlLabel alloc] initWithFrame:mPswdFrame] autorelease];
    self.pswdLabel.text = LocaleStringForKey(NSLoginPSWDTitle, nil);
    self.pswdLabel.delegate = self;
    self.pswdLabel.tag = 1;
    self.pswdLabel.font = [UIFont boldSystemFontOfSize:(FONT_SIZE-3)];
    self.pswdLabel.backgroundColor = TRANSPARENT_COLOR;
    [backView addSubview:self.pswdLabel];
    
    // Login Button
    CGRect loginFrame = CGRectMake(330.0f, 458.4f, 364.f, 45.0f);
    WXWGradientButton *loginBut = [[[WXWGradientButton alloc] initWithFrame:loginFrame
                                                                     target:self
                                                                     action:@selector(doLogin:)
                                                                  colorType:RED_BTN_COLOR_TY
                                                                      title:LocaleStringForKey(NSLoginTitle, nil)
                                                                      image:nil
                                                                 titleColor:BLUE_BTN_TITLE_COLOR
                                                           titleShadowColor:BLUE_BTN_TITLE_SHADOW_COLOR
                                                                  titleFont:BOLD_FONT(FONT_SIZE)
                                                                roundedType:HAS_ROUNDED
                                                            imageEdgeInsert:ZERO_EDGE
                                                            titleEdgeInsert:ZERO_EDGE] autorelease];
    
    UIGestureRecognizer *loginTap = [[UITapGestureRecognizer alloc]
                                     initWithTarget:self action:@selector(doLogin:)];
    loginTap.delegate = self;
    [loginBut addGestureRecognizer:loginTap];
    [backView addSubview:loginBut];
    
    // Login note
    WXWLabel *comeBackLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                     textColor:DARK_TEXT_COLOR
                                                   shadowColor:TEXT_SHADOW_COLOR] autorelease];
    comeBackLabel.font = BOLD_FONT(15);
    comeBackLabel.text = LocaleStringForKey(NSLoginNote1Title, nil);
    comeBackLabel.textAlignment = UITextAlignmentCenter;
    CGSize size = [comeBackLabel.text sizeWithFont:comeBackLabel.font
                                 constrainedToSize:CGSizeMake(self.view.frame.size.width - MARGIN * 4, CGFLOAT_MAX)
                                     lineBreakMode:UILineBreakModeWordWrap];
    comeBackLabel.frame = CGRectMake((backView.frame.size.width - size.width)/2.0f,
                                     680.0f, size.width, size.height);
    [backView addSubview:comeBackLabel];
    
    // Version
    WXWLabel *versionLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                    textColor:DARK_TEXT_COLOR
                                                  shadowColor:TEXT_SHADOW_COLOR] autorelease];
    versionLabel.font = BOLD_FONT(11);
    versionLabel.text = [NSString stringWithFormat:@"Version %@",VERSION];
    versionLabel.textAlignment = UITextAlignmentCenter;
    size = [versionLabel.text sizeWithFont:versionLabel.font
                         constrainedToSize:CGSizeMake(self.view.frame.size.width - MARGIN * 4, CGFLOAT_MAX)
                             lineBreakMode:UILineBreakModeWordWrap];
    versionLabel.frame = CGRectMake((backView.frame.size.width - size.width)/2.0f,
                                    700.0f, size.width, size.height);
    [backView addSubview:versionLabel];
    
    [self.view addSubview:backView];
}

#pragma mark - logic
- (void)getHostUrl
{
    if ([CommonUtils isConnectionOK]) {
        
        [AppManager instance].hostUrl = @"http://alumniapp.ceibs.edu:8080/ceibs/";
        [self checkSoftVersion];
        
        /*
        WXWAsyncConnectorFacade *connector = [self setupAsyncConnectorForUrl:GET_HOST_URL
                                                                 contentType:GET_HOST_TY];
        [connector asyncGet:GET_HOST_URL showAlertMsg:YES];
         */
        
    } else {
        ShowAlert(self, LocaleStringForKey(NSNoteTitle, nil), LocaleStringForKey(NSConnectionErrorMsg, nil), LocaleStringForKey(NSSureTitle, nil));
        
        _autoLogin = NO;
        [self initView];
    }
    
}

- (void)autoLogin {
    
    _currentType = LOGIN_TY;
    //    NSString *param = [NSString stringWithFormat:@"username=%@&password=%@",
    //                       [[AppManager instance] getUserIdFromLocal],
    //                       [[AppManager instance] getPasswordFromLocal]];
    
    //    NSString *param = [NSString stringWithFormat:@"username=%@&sessionId=%@",
    //                       [AppManager instance].userId,
    //                       [AppManager instance].sessionId];
    
    
    //    NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
    
    NSString *url = STR_FORMAT(@"%@%@&username=%@&sessionId=%@&locale=zh&plat=iPhone&version=%@&device_token=%@&channel=%d", [AppManager instance].hostUrl, ALUMNI_AUTO_LOGIN_REQ_URL, [AppManager instance].userId, [AppManager instance].sessionId, VERSION, [AppManager instance].deviceToken, [AppManager instance].releaseChannelType);
    
    WXWAsyncConnectorFacade *connector = [[[WXWAsyncConnectorFacade alloc] initWithDelegate:self
                                                                     interactionContentType:_currentType] autorelease];
    [connector asyncGet:url showAlertMsg:YES];
}

- (void)entryAlumnus {
    
    if ([CommonUtils isConnectionOK]) {
        _currentType = LOGIN_TY;
        NSString *param = [NSString stringWithFormat:@"username=%@&password=%@",
                           [self.nameField.text lowercaseString],
                           self.passwordField.text];
        
        NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
        WXWAsyncConnectorFacade *connector = [self setupAsyncConnectorForUrl:url
                                                                 contentType:_currentType];
        
        [connector asyncGet:url showAlertMsg:YES];
    } else {
        ShowAlert(self, LocaleStringForKey(NSNoteTitle, nil), LocaleStringForKey(NSConnectionErrorMsg, nil), LocaleStringForKey(NSSureTitle, nil));
    }
}

- (void)checkSoftVersion
{
    _currentType = CHECK_VERSION_TY;
    
    NSString *url = [CommonUtils geneUrl:@"" itemType:CHECK_VERSION_TY];
    WXWAsyncConnectorFacade *connector = [self setupAsyncConnectorForUrl:url
                                                             contentType:CHECK_VERSION_TY];
    
    [connector asyncGet:url showAlertMsg:YES];
    
}

// check value is available
- (BOOL)checkForLogin:(NSString *)userAccount
             password:(NSString *)password {
    
	if ([userAccount isEqualToString:@""] || 0 == [userAccount length]) {
		debugLog(@"userAccount is nil");
        [WXWUIUtils showNotificationWithMsg:LocaleStringForKey(NSUserInfoNeeded, nil)
                                    msgType:ERROR_TY
                                 holderView:self.view];
		[WXWUIUtils closeActivityView];
		return NO;
	}
	
	if ([password isEqualToString:@""] || 0 == [password length]) {
		debugLog(@"Password is nil");
		
        [WXWUIUtils showNotificationWithMsg:LocaleStringForKey(NSPswdInfoNeeded, nil)
                                    msgType:ERROR_TY
                                 holderView:self.view];
		[WXWUIUtils closeActivityView];
		return NO;
	}
	
	return YES;
}

- (void)loginLogic
{
    if (self.nameField.isFirstResponder) {
        [self.nameField resignFirstResponder];
    }
    
    if (self.passwordField.isFirstResponder) {
        [self.passwordField resignFirstResponder];
    }
    
    if (![self checkForLogin:[self.nameField.text lowercaseString] password:self.passwordField.text]) {
        return;
    }
    
    [self entryAlumnus];
}

#pragma mark - button method
- (void)doHelpPrompt:(UIGestureRecognizer *)recognizer
{
    /*
     UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:LocaleStringForKey(NSNoteTitle, nil) message:LocaleStringForKey(NSLoginHelpTitle, nil) delegate:self cancelButtonTitle:LocaleStringForKey(NSSureTitle, nil) otherButtonTitles:nil] autorelease];
     [alert show];
     */
}

- (void)doLogin:(UIGestureRecognizer *)recognizer
{
    if (![AppManager instance].hostUrl || [[AppManager instance].hostUrl isEqualToString:@""]) {
        [self getHostUrl];
        isBreakFlag = YES;
        return;
    }
    [self loginLogic];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration {
    /*
     _nameFieldIsFirstResponder = self.nameField.isFirstResponder;
     _pswdFieldIsFirstResponder = self.passwordField.isFirstResponder;
     
     if (self.nameField.isFirstResponder) {
     [self.nameField resignFirstResponder];
     }
     
     if (self.passwordField.isFirstResponder) {
     [self.passwordField resignFirstResponder];
     }
     */
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    //    if (_nameFieldIsFirstResponder) {
    //        [self.nameField becomeFirstResponder];
    //    }
    //
    //    if (_pswdFieldIsFirstResponder) {
    //        [self.passwordField becomeFirstResponder];
    //    }
}

- (NSFetchedResultsController *)prepareFetchRC {
    
    RELEASE_OBJ(_fetchedRC);
    NSMutableArray *descriptors = [[[NSMutableArray alloc] init] autorelease];
    NSSortDescriptor *nameDesc = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease];
    [descriptors addObject:nameDesc];
    
    _fetchedRC = [CommonUtils fetchObject:_MOC
                 fetchedResultsController:_fetchedRC
                               entityName:_entityName
                       sectionNameKeyPath:nil
                          sortDescriptors:descriptors
                                predicate:nil];
    
    return _fetchedRC;
}

#pragma mark - UITextField delegate methods
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGFloat heightFraction = 0.3f;
    
    _animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    
    /*Finally, apply the animation. Note the use of setAnimationBeginsFromCurrentState:
     * — this will allow a smooth transition to new text field if the user taps on another.
     */
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= _animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CGRect viewFrame = self.view.frame;
    
    viewFrame.origin.y += _animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
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
    if (!_autoLogin) {
        [WXWUIUtils showActivityView:self.view
                                text:LocaleStringForKey(NSLoadingTitle, nil)];
        [super connectStarted:url contentType:contentType];
    }
}

- (void)connectDone:(NSData *)result
                url:(NSString *)url
        contentType:(WebItemType)contentType
{
    if (!_autoLogin) {
        [WXWUIUtils closeActivityView];
    }
    NSData *decryptedData = [EncryptUtil TripleDESforNSData:result encryptOrDecrypt:kCCDecrypt];
    
    switch (contentType) {
        case GET_HOST_TY:
        {
            NSString *hostStr = [[[NSString alloc] initWithData:result
                                                       encoding:NSUTF8StringEncoding] autorelease];
            if ([hostStr hasPrefix:@"http://"]) {
                [AppManager instance].hostUrl = hostStr;
                [self checkSoftVersion];
            } else {
                [AppManager instance].hostUrl = [[AppManager instance] getHostStrFromLocal];
            }
            break;
        }
            
        case CHECK_VERSION_TY:
        {
            ReturnCode ret = [XMLParser handleSoftMsg:result MOC:_MOC];
            
            switch (ret) {
                case RESP_OK:
                {
                    if (_autoLogin) {
                        [self autoLogin];
                        return;
                    }
                    
                    if (isBreakFlag) {
                        [self loginLogic];
                        isBreakFlag = NO;
                    }
                }
                    break;
                    
                case SOFT_UPDATE_CODE:
                {
                    _alertType = UPDATE_SOFT_TYPE;
                    ShowAlert(self, LocaleStringForKey(NSNoteTitle, nil),[AppManager instance].softDesc, LocaleStringForKey(NSSureTitle, nil));
                    break;
                }
                    
                case ERR_CODE:
                {
                    [WXWUIUtils showNotificationWithMsg:LocaleStringForKey(NSNetworkUnstableMsg, nil)
                                                msgType:ERROR_TY];
                    break;
                }
                    
                default:
                    break;
            }
            
            break;
        }
            
        case LOGIN_TY:
        {
            if ([XMLParser parserSyncResponseXml:decryptedData type:LOGIN_SRC MOC:_MOC]) {
                
                if (!_autoLogin) {
                    [AppManager instance].passwd = self.passwordField.text;
                    [[AppManager instance] saveUserInfoIntoLocal];
                }
                NSLog(@"EncryptUtil pswd = %@", [EncryptUtil TripleDES:@"hv6f5%2FlvFrQc21uBUYHYqHKur6K0UUnL"
                                                      encryptOrDecrypt:kCCEncrypt]);
                
                NSLog(@"EncryptUtil = %@|%@", [EncryptUtil TripleDES:[AppManager instance].userId
                                                    encryptOrDecrypt:kCCEncrypt],
                      [EncryptUtil TripleDES:[AppManager instance].passwd
                            encryptOrDecrypt:kCCEncrypt]);
                
                self.homepageVC = [[[HomepageViewController alloc] initWithMOC:_MOC] autorelease];
                [self.navigationController pushViewController:self.homepageVC animated:YES];
            } else {
                _autoLogin = NO;
                [self initView];
                _alertType = LOGIN_HELP_TYPE;
                
                ShowAlertWithTwoButton(self, LocaleStringForKey(NSNoteTitle, nil), [AppManager instance].errDesc, LocaleStringForKey(NSIKnowTitle, nil), LocaleStringForKey(NSLoginHelpButtonTitle, nil));
            }
            break;
        }
            
        default:
            break;
    }
    
    [super connectDone:result url:url contentType:contentType];
}

- (void)connectCancelled:(NSString *)url
             contentType:(WebItemType)contentType
{
    
    if (!_autoLogin) {
        [WXWUIUtils closeActivityView];
    } else {
        _autoLogin = NO;
        [self initView];
    }
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(WebItemType)contentType {
    
    if (_autoLogin) {
        _autoLogin = NO;
        [self initView];
    }
    
    switch (contentType) {
        case GET_HOST_TY:
        {
            [AppManager instance].hostUrl = [CommonUtils fetchStringValueFromLocal:HOST_LOCAL_KEY];
            _hostFetched = YES;
            
            break;
        }
            
        default:
            break;
    }
    
    if (!_autoLogin) {
        [WXWUIUtils closeActivityView];
    }
}

#pragma mark - UIActionSheetDelegate method

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    switch (_alertType) {
        case UPDATE_SOFT_TYPE:
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[AppManager instance].softUrl]];
        }
            break;
            
        case LOGIN_HELP_TYPE:
        {
            if (buttonIndex == 1) {
                NSString *url = [NSString stringWithFormat:@"%@%@",[AppManager instance].hostUrl, [AppManager instance].loginHelpUrl];
                
                [self goWebView:url];
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - Touch Url Label
- (void)urlLabel:(UIUrlLabel *)urlLabel touchesWithTag:(NSInteger)tag
{
    
    NSString *url = [NSString stringWithFormat:@"%@%@?locale=%@",[AppManager instance].hostUrl, LOGIN_HELP_URL, [AppManager instance].currentLanguageDesc];
    [self goWebView:url];
}

- (void)goWebView:(NSString *)url
{
    CGRect mFrame = CGRectMake(0, 0, UI_MODAL_FORM_SHEET_WIDTH, self.view.frame.size.height);
    
    UIWebViewController *webVC = [[[UIWebViewController alloc]
                                   initWithUrl:url
                                   frame:mFrame
                                   isNeedClose:YES] autorelease];
    
    webVC.title = LocaleStringForKey(NSLoginPSWDTitle, nil);
	webVC.modalDelegate = self;
    WXWNavigationController *detailNC = [[[WXWNavigationController alloc] initWithRootViewController:webVC] autorelease];
    
	detailNC.modalPresentationStyle = UIModalPresentationPageSheet;
	[self presentModalViewController:detailNC animated:YES];
}

@end
