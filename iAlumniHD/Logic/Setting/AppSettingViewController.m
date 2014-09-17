//
//  AppSettingViewController.m
//  iAlumniHD
//
//  Created by MobGuang on 12-9-29.
//
//

#import "AppSettingViewController.h"
#import "VerticalLayoutItemInfoCell.h"
#import "FeedbackViewController.h"
#import "LanguageListViewController.h"
#import "ConfigurableTextCell.h"
#import "WXApiObject.h"
#import "WXWLabel.h"

enum {
    LANG_SEC,
    COOP_SEC,
    LOGOFF_SEC,
    SHARE_TO_WECHAT_SEC,
};

enum {
    LANG_SEC_CELL,
};

enum {
    SHARE_SEC_WECHAT_CELL,
};

enum {
    COOP_SEC_CELL,
};

enum {
    LOGOFF_SEC_CELL,
};

enum {
    WECHAT_TY,
    LOGOFF_TY,
};

#define SECTION_COUNT       3

#define LANG_SEC_COUNT      1
#define SHARE_SEC_COUNT     1
#define COOP_SEC_COUNT      1
#define LOGOFF_SEC_COUNT    1

#define DEFAULT_CELL_HEIGHT 44.0f

#define FOOTER_HEIGHT       405.0f

#define BUFFER_SIZE         1024 * 100

@interface AppSettingViewController ()
@property (nonatomic, retain) UPOMP_iPad *cpView;
@end

@implementation AppSettingViewController
@synthesize cpView;

#pragma mark - lifecycle methods
- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder
 backToHomeAction:(SEL)backToHomeAction {
    
    self = [super initWithMOC:MOC showCloseButton:NO needRefreshHeaderView:NO needRefreshFooterView:NO tableStyle:UITableViewStyleGrouped];
    
    if (self) {
        
    }
    
    return self;
}

- (void)dealloc {
    
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = CELL_COLOR;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [super checkListWhetherEmpty];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - WXApiDelegate methods
-(void)onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[SendMessageToWXResp class]]) {
        switch (resp.errCode) {
            case WECHAT_OK_CODE:
                [WXWUIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSAppShareByWeChatDoneMsg, nil)
                                              msgType:SUCCESS_TY
                                   belowNavigationBar:YES];
                break;
                
            case WECHAT_BACK_CODE:
                break;
                
            default:
                [WXWUIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSAppShareByWeChatFailedMsg, nil)
                                              msgType:ERROR_TY
                                   belowNavigationBar:YES];
                break;
        }
    }
    /*
     else if ([resp isKindOfClass:[SendAuthResp class]]) {
     NSString *strTitle = [NSString stringWithFormat:@"Auth结果"];
     NSString *strMsg = [NSString stringWithFormat:@"Auth结果:%d", resp.errCode];
     
     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
     [alert show];
     [alert release];
     
     }
     */
}

#pragma mark - handle empty list
- (BOOL)listIsEmpty {
  return NO;
}

#pragma mark - UITableViewDelegate and UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (IS_NEED_3RD_LOGIN == 1) {
        return SECTION_COUNT - 1;
    } else {
        return SECTION_COUNT;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case LANG_SEC:
            return LANG_SEC_COUNT;
            
        case SHARE_TO_WECHAT_SEC:
            return SHARE_SEC_COUNT;
            
        case COOP_SEC:
            return COOP_SEC_COUNT;
            
        case LOGOFF_SEC:
            return LOGOFF_SEC_COUNT;
            
        default:
            return 0;
    }
}

- (UITableViewCell *)drawLangSectionCell:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case LANG_SEC_CELL:
        {
            static NSString *kCellIdentifier = @"langCell";
            
            return [self drawNoShadowVerticalInfoCell:LocaleStringForKey(NSCurrentSystemLanguageTitle,nil)
                                           subTitle:nil
                                            content:nil
                                     cellIdentifier:kCellIdentifier
//                                             height:DEFAULT_CELL_HEIGHT
                                          clickable:YES];
        }
            
        default:
            return nil;
    }
}

- (UITableViewCell *)drawCoopSectionCell:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case COOP_SEC_CELL:
        {
            static NSString *kCellIdentifier = @"coopCell";
            return [self drawNoShadowVerticalInfoCell:LocaleStringForKey(NSFeedbackTitle,nil)
                                           subTitle:nil
                                            content:nil
                                     cellIdentifier:kCellIdentifier
//                                             height:DEFAULT_CELL_HEIGHT
                                          clickable:YES];
        }
            
        default:
            return nil;
    }
}

- (UITableViewCell *)drawLogoffSectionCell:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case LOGOFF_SEC_CELL:
        {
            static NSString *kCellIdentifier = @"logoffCell";
            return [self drawNoShadowVerticalInfoCell:LocaleStringForKey(NSLogoutTitle,nil)
                                           subTitle:nil
                                            content:nil
                                     cellIdentifier:kCellIdentifier
//                                             height:DEFAULT_CELL_HEIGHT
                                          clickable:YES];
        }
            
        default:
            return nil;
    }
}

- (UITableViewCell *)drawShareToWeChat:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case SHARE_SEC_WECHAT_CELL:
        {
            static NSString *kCellIdentifier = @"shareToWeChatCell";
            return [self drawNoShadowVerticalInfoCell:LocaleStringForKey(NSAppShareToWeChatGroupTitle, nil)
                                           subTitle:nil
                                            content:nil
                                     cellIdentifier:kCellIdentifier
//                                             height:DEFAULT_CELL_HEIGHT
                                          clickable:YES];
            
        }
        default:
            return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case LANG_SEC:
            return [self drawLangSectionCell:indexPath];
            
        case SHARE_TO_WECHAT_SEC:
            return [self drawShareToWeChat:indexPath];
            
        case COOP_SEC:
            return [self drawCoopSectionCell:indexPath];
            
        case LOGOFF_SEC:
            return [self drawLogoffSectionCell:indexPath];
            
        default:
            return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    switch (indexPath.section) {
        case LANG_SEC:
        {
            LanguageListViewController *languageVC = [[[LanguageListViewController alloc] init] autorelease];
            
            languageVC.deSelectCellDelegate = self;
            self.selectedIndexPath = indexPath;
            
            WXWNavigationController *detailNC = [[[WXWNavigationController alloc] initWithRootViewController:languageVC] autorelease];
            
            [APP_DELEGATE addViewInSlider:detailNC
                       invokeByController:self
                           stackStartView:NO];
            
            break;
        }
            
        case SHARE_TO_WECHAT_SEC:
        {
            if ([WXApi isWXAppInstalled]) {
                //        APP_DELEGATE.wxApiDelegate = self;
                
                NSString *url = [NSString stringWithFormat:@"%@event?action=page_load&page_name=alumni_app_download&locale=%@&channel=%d",
                                 [AppManager instance].hostUrl,
                                 [AppManager instance].currentLanguageDesc,
                                 [AppManager instance].releaseChannelType];
                
                [CommonUtils shareByWeChat:WXSceneTimeline
                                     title:LocaleStringForKey(NSAppRecommendTitle, nil)
                               description:[AppManager instance].recommend
                                       url:url];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                message:LocaleStringForKey(NSNoWeChatMsg, nil)
                                                               delegate:self
                                                      cancelButtonTitle:LocaleStringForKey(NSDonotInstallTitle, nil)
                                                      otherButtonTitles:LocaleStringForKey(NSInstallTitle, nil), nil];
                [alert show];
                [alert release];
                
                _alertOwnerType = WECHAT_TY;
            }
            break;
        }
            
        case COOP_SEC:
        {
            
            FeedbackViewController *feedbackVC = [[[FeedbackViewController alloc] initWithMOC:_MOC] autorelease];
            feedbackVC.title = LocaleStringForKey(NSFeedbackTitle,nil);
            
            feedbackVC.deSelectCellDelegate = self;
            self.selectedIndexPath = indexPath;
            
            WXWNavigationController *detailNC = [[[WXWNavigationController alloc] initWithRootViewController:feedbackVC] autorelease];
            
            [APP_DELEGATE addViewInSlider:detailNC
                       invokeByController:self
                           stackStartView:NO];
            
            break;
        }
            
        case LOGOFF_SEC:
        {
//            银联支付
//            [self getPayXMLData];

            if ([@"-1" isEqualToString:[AppManager instance].personId]) {
                [APP_DELEGATE openLogin:NO autoLogin:NO];
            } else {
                ShowAlertWithTwoButton(self, LocaleStringForKey(NSNoteTitle, nil), LocaleStringForKey(NSLogoutMsgTitle, nil), LocaleStringForKey(NSCancelTitle, nil), LocaleStringForKey(NSSureTitle, nil));
                
                _alertOwnerType = LOGOFF_TY;
            }

            break;
        }
            
        default:
            break;
    }
    
    [super deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    switch (section) {
        case LOGOFF_SEC:
        {
            return FOOTER_HEIGHT;
        }
            
        default:
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    /*
     switch (indexPath.section) {
     case LANG_SEC:
     return DEFAULT_CELL_HEIGHT + [ConfigurableTextCell tableView:tableView
     neededHeightForIndexPath:indexPath];
     break;
     
     default:
     return DEFAULT_CELL_HEIGHT;
     }
     */
    return DEFAULT_CELL_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    switch (section) {
        case LOGOFF_SEC:
        {
            if (nil == _footerView) {
                _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, FOOTER_HEIGHT)];
                _footerView.backgroundColor = TRANSPARENT_COLOR;
                
                WXWLabel *infoLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                           textColor:BASE_INFO_COLOR
                                                         shadowColor:[UIColor whiteColor]] autorelease];
                infoLabel.font = BOLD_FONT(12);
                infoLabel.text = [NSString stringWithFormat:@"Copyright © 2014 Weixun Inc. All rights reserved."];
                [_footerView addSubview:infoLabel];
                CGSize size = [infoLabel.text sizeWithFont:infoLabel.font
                                         constrainedToSize:CGSizeMake(self.view.frame.size.width, CGFLOAT_MAX)
                                             lineBreakMode:UILineBreakModeWordWrap];
                infoLabel.frame = CGRectMake((self.view.frame.size.width - size.width) / 2.0f,
                                             FOOTER_HEIGHT - size.height - MARGIN,
                                             size.width, size.height);
                
                WXWLabel *versionLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                              textColor:BASE_INFO_COLOR
                                                            shadowColor:[UIColor whiteColor]] autorelease];
                versionLabel.font = BOLD_FONT(12);
                versionLabel.text = [NSString stringWithFormat:@"Version %@",VERSION];
                [_footerView addSubview:versionLabel];
                size = [versionLabel.text sizeWithFont:versionLabel.font
                                     constrainedToSize:CGSizeMake(self.view.frame.size.width, CGFLOAT_MAX)
                                         lineBreakMode:UILineBreakModeWordWrap];
                
                versionLabel.frame = CGRectMake((self.view.frame.size.width - size.width)/2.0f,
                                                infoLabel.frame.origin.y - MARGIN - size.height, size.width, size.height);
                
            }
            return _footerView;
            
        }
            
        default:
            return nil;
    }
}

#pragma mark - alert delegate method
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (_alertOwnerType) {
        case LOGOFF_TY:
            if (buttonIndex == 1) {
                [APP_DELEGATE openLogin:NO autoLogin:NO];
            }
            break;
            
        case WECHAT_TY:
            switch (buttonIndex) {
                case 1:
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:WECHAT_ITUNES_URL]];
                    break;
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
    
}

#pragma mark - WXWConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(WebItemType)contentType
{
    [WXWUIUtils showActivityView:[APP_DELEGATE foundationView]
                         text:LocaleStringForKey(NSLoadingTitle, nil)];
}

- (void)connectDone:(NSData *)result
                url:(NSString *)url
        contentType:(WebItemType)contentType
{
    [WXWUIUtils closeActivityView];
    
    //    NSData *decryptedData = [EncryptUtil TripleDESforNSData:result encryptOrDecrypt:kCCDecrypt];
    
    switch (contentType) {
        case PAY_DATA_TY:
        {
            [self goPay:result];
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
        case PAY_DATA_TY:
        {
            break;
        }
            
        default:
            break;
    }
    
    [WXWUIUtils closeActivityView];
}

#pragma mark - pay
- (void)getPayXMLData {
    
    NSString *param = [NSString stringWithFormat:@"<order_id>%@</order_id>", @"10982"];
    NSString *url = [CommonUtils geneUrl:param itemType:PAY_DATA_TY];
    
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url contentType:PAY_DATA_TY];
    [connFacade fetchGets:url];
}

- (void)goPay:(NSData *)result {
    
    cpView = [[UPOMP_iPad alloc] init];
    
    cpView.viewDelegate = self;
    cpView.modalPresentationStyle = UIModalPresentationFullScreen;
    [[APP_DELEGATE foundationRootViewController] presentModalViewController:cpView animated:YES];
    
    [cpView setXmlData:result]; //初始接口传入支付报文（报文数据格式为NSData）
}

#pragma mark - UPOMP_iPad_Delegate method
-(void)viewClose:(NSData*)data {
    
    //获得返回数据并释放内存
    //以下为自定义相关操作
    cpView.viewDelegate = nil;
    RELEASE_OBJ(cpView);
    
    NSString *resultStr = [[[NSString alloc] initWithData:data
                                                 encoding:NSUTF8StringEncoding] autorelease];
    NSLog(@"resultStr = %@", resultStr);
    
    /*
     [self readXML:data]; //对回传数据进行解析(自行实现)
     if(respCode==0){//对返回码进行判定并处理（自行实现）
     [tableView reloadData];
     }
     */
    //    详细报文及返回码信息可参见：插件返回报文
}

@end
