//
//  HelpViewController.m
//  iAlumniHD
//
//  Created by Adam on 13-3-8.
//
//

#import "HelpViewController.h"
#import "UIWebViewController.h"
#import "WXWLabel.h"

#define FONT_SIZE                     24

typedef enum{
    UPDATE_SOFT_TYPE = 0,
    NO_WECHAT_TYPE,
} HELP_ALERT_TYPE;

@interface HelpViewController()
@end

@implementation HelpViewController

- (id)initWithMOC:(NSManagedObjectContext *)MOC {
    self = [super init];
    
    if (self) {
        _MOC = MOC;
    }
    
    return self;
}

- (void)dealloc {
    
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

    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"lightBackground.png"]];
    
    UIView *backView = [[[UIView alloc] init] autorelease];
    backView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [backView setBackgroundColor:[UIColor clearColor]];
    
//    UIImageView *backImgView = [[[UIImageView alloc] init] autorelease];
//    backImgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
//    [backImgView setImage:[UIImage imageNamed:@"lightBackground.png"]];
//    [backView addSubview:backImgView];
    
    // note
    WXWLabel *noteLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                 textColor:DARK_TEXT_COLOR
                                               shadowColor:TEXT_SHADOW_COLOR] autorelease];
    noteLabel.font = BOLD_FONT(25);
    noteLabel.text = LocaleStringForKey(NSLoginFailedMsg, nil);
    noteLabel.textAlignment = UITextAlignmentCenter;
    CGSize size = [noteLabel.text sizeWithFont:noteLabel.font
                             constrainedToSize:CGSizeMake(SCREEN_WIDTH - MARGIN * 4, CGFLOAT_MAX)
                                 lineBreakMode:UILineBreakModeWordWrap];
    noteLabel.frame = CGRectMake((SCREEN_WIDTH-size.width)/2, 250.0f, size.width, size.height);
    [backView addSubview:noteLabel];
    
    // Login
    CGRect loginFrame = CGRectMake(330.0f, 398.4f, 364.f, 45.0f);
    WXWGradientButton *loginBut = [[[WXWGradientButton alloc] initWithFrame:loginFrame
                                                                     target:self
                                                                     action:@selector(doLogin:)
                                                                  colorType:RED_BTN_COLOR_TY
                                                                      title:LocaleStringForKey(NSReLoginTitle, nil)
                                                                      image:nil
                                                                 titleColor:BLUE_BTN_TITLE_COLOR
                                                           titleShadowColor:BLUE_BTN_TITLE_SHADOW_COLOR
                                                                  titleFont:BOLD_FONT(FONT_SIZE)
                                                                roundedType:HAS_ROUNDED
                                                            imageEdgeInsert:ZERO_EDGE
                                                            titleEdgeInsert:ZERO_EDGE] autorelease];
    
    [backView addSubview:loginBut];
    
    // Forgot Password
    CGRect helpFrame = CGRectMake(330.0f, 458.4f, 364.f, 45.0f);
    WXWGradientButton *helpBut = [[[WXWGradientButton alloc] initWithFrame:helpFrame
                                                                    target:self
                                                                    action:@selector(doHelp:)
                                                                 colorType:TINY_GRAY_BTN_COLOR_TY
                                                                     title:LocaleStringForKey(NSLoginPSWDTitle, nil)
                                                                     image:nil
                                                                titleColor:COLOR(117, 117, 117)
                                                          titleShadowColor:GRAY_BTN_TITLE_SHADOW_COLOR
                                                                 titleFont:BOLD_FONT(FONT_SIZE)
                                                               roundedType:HAS_ROUNDED
                                                           imageEdgeInsert:ZERO_EDGE
                                                           titleEdgeInsert:ZERO_EDGE] autorelease];
    
    [backView addSubview:helpBut];
    
    // Winxin
    CGRect weixinFrame = CGRectMake(330.0f, 518.4f, 364.f, 45.0f);
    WXWGradientButton *weixinBut = [[[WXWGradientButton alloc] initWithFrame:weixinFrame
                                                                      target:self
                                                                      action:@selector(doWeixin:)
                                                                   colorType:RED_BTN_COLOR_TY
                                                                       title:@"关注iAlumni微信帮助平台"
                                                                       image:nil
                                                                  titleColor:BLUE_BTN_TITLE_COLOR
                                                            titleShadowColor:BLUE_BTN_TITLE_SHADOW_COLOR
                                                                   titleFont:BOLD_FONT(FONT_SIZE)
                                                                 roundedType:HAS_ROUNDED
                                                             imageEdgeInsert:ZERO_EDGE
                                                             titleEdgeInsert:ZERO_EDGE] autorelease];
    [backView addSubview:weixinBut];
    
    [self.view addSubview:backView];
}

#pragma mark - logic
- (void)getHostUrl
{
    if ([CommonUtils isConnectionOK]) {
        
        WXWAsyncConnectorFacade *connector = [self setupAsyncConnectorForUrl:GET_HOST_URL
                                                                 contentType:GET_HOST_TY];
        
        [connector asyncGet:GET_HOST_URL showAlertMsg:YES];
    } else {
        ShowAlert(self, LocaleStringForKey(NSNoteTitle, nil), LocaleStringForKey(NSConnectionErrorMsg, nil), LocaleStringForKey(NSSureTitle, nil));
        
        [self initView];
    }
    
}

- (void)autoLogin {
    
    NSString *param = [NSString stringWithFormat:@"username=%@&password=%@",
                       @"", @""];
    
    NSString *url = [CommonUtils geneUrl:param itemType:LOGIN_TY];
    
    WXWAsyncConnectorFacade *connector = [[[WXWAsyncConnectorFacade alloc] initWithDelegate:self
                                                                     interactionContentType:LOGIN_TY] autorelease];
    [connector asyncGet:url showAlertMsg:YES];
}

- (void)checkSoftVersion
{
    _currentType = CHECK_VERSION_TY;
    
    NSString *url = [CommonUtils geneUrl:@"" itemType:CHECK_VERSION_TY];
    WXWAsyncConnectorFacade *connector = [self setupAsyncConnectorForUrl:url
                                                             contentType:CHECK_VERSION_TY];
    
    [connector asyncGet:url showAlertMsg:YES];
    
}

#pragma mark - logic

- (void)doWeixin:(id)recognizer
{
    if ([WXApi isWXAppInstalled]) {
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:WECHAT_PUBLIC_NO_URL]];
        
    } else {
        
        _alertType = NO_WECHAT_TYPE;
        
        ShowAlertWithTwoButton(self, nil, LocaleStringForKey(NSNoWeChatMsg, nil), LocaleStringForKey(NSDonotInstallTitle, nil),LocaleStringForKey(NSInstallTitle, nil));
    }
}

- (void)doHelp:(id)recognizer
{
    [self goWebView:[NSString stringWithFormat:@"%@%@?locale=%@",[AppManager instance].hostUrl, LOGIN_HELP_URL, [AppManager instance].currentLanguageDesc]];
}

- (void)doLogin:(id)recognizer
{

    [APP_DELEGATE singleLogin];
}

#pragma mark - WXWConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(WebItemType)contentType
{
}

- (void)connectDone:(NSData *)result
                url:(NSString *)url
        contentType:(WebItemType)contentType
{
    
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
                    
                    if (isBreakFlag) {
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

}

#pragma mark - UIActionSheetDelegate method

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    switch (_alertType) {
        case UPDATE_SOFT_TYPE:
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[AppManager instance].softUrl]];
        }
            break;
            
        case NO_WECHAT_TYPE:
        {
            if (buttonIndex == 1) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:WECHAT_ITUNES_URL]];
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - Touch Url Label

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
