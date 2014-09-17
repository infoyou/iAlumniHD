//
//  ShakeViewController.m
//  iAlumniHD
//
//  Created by Adam on 12-11-11.ƒ
//  Copyright (c) 2012年 __MyCompanyName__. All rights ƒreserved.
//

#import "ShakeViewController.h"
#import "Place2ThingViewController.h"
#import "UIWebViewController.h"
#import "UserListViewController.h"
#import "WXWLabel.h"
#import "Shake.h"

#define FONT_SIZE       20

static BOOL checkShakeing(UIAcceleration* last, UIAcceleration* current, double threshold) {
    double
    deltaX = fabs(last.x - current.x),
    deltaY = fabs(last.y - current.y),
    deltaZ = fabs(last.z - current.z);
    
    return
    (deltaX > threshold && deltaY > threshold) ||
    (deltaX > threshold && deltaZ > threshold) ||
    (deltaY > threshold && deltaZ > threshold);
}

@interface ShakeViewController ()
@property(nonatomic, retain) UIAcceleration *lastAcceleration;
@end

@implementation ShakeViewController
@synthesize imageView;
@synthesize shakeStartImg;
@synthesize shakeEndImg;
@synthesize lastAcceleration;

- (id)initWithMOC:(NSManagedObjectContext *)MOC {
    
    self = [super initWithMOC:MOC frame:CGRectMake(0, 0, SCREEN_WIDTH - VERTICAL_MENU_WIDTH, SCREEN_HEIGHT)];
    
    if (self) {
        // Custom initialization
        _eventId = 0;
    }
    return self;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC eventId:(long long)eventId {
    self = [self initWithMOC:MOC];
    
    if (self) {
        _eventId = eventId;
    }
    return self;
}

- (void)dealloc
{
    self.imageView = nil;
    self.shakeStartImg = nil;
    self.shakeEndImg = nil;
    
    self.lastAcceleration = nil;

    [super dealloc];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    isRun = NO;
    [UIAccelerometer sharedAccelerometer].delegate = nil;
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {

    isRun = YES;
    [UIAccelerometer sharedAccelerometer].delegate = self;
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
    
    [self changeImages:self.imageView];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    [self initResource];
    
    [self initView];
    
    if (_eventId != 0) {
        
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:LocaleStringForKey(NSCloseTitle, nil) style:UIBarButtonItemStyleDone target:self action:@selector(doClose:)] autorelease];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - load data

- (void)triggerLocationAndFetch:(id)sender {
    
    if (_processing) {
        return;
    }
    
    _processing = YES;
    
    [self prepareLocationCondition];
}

- (void)loadData
{
    [CommonUtils doDelete:_MOC entityName:@"Tag"];
    [CommonUtils doDelete:_MOC entityName:@"Place"];
    _currentType = SHAKE_PLACE_THING_TY;
    
    NSString *param = [NSString stringWithFormat:@"<latitude>%f</latitude><longitude>%f</longitude>",
                       [AppManager instance].latitude,
                       [AppManager instance].longitude];
    
    NSMutableString *requestParam = [NSMutableString stringWithString:param];
    if (!isShakeAction) {
        [requestParam appendString:@"<not_shake>1</not_shake>"];
    } else {
        isShakeAction = NO;
    }
    
    NSString *url = [CommonUtils geneUrl:requestParam itemType:_currentType];
    WXWAsyncConnectorFacade *connFacade = [[[WXWAsyncConnectorFacade alloc] initWithDelegate:self
                                                                    interactionContentType:_currentType] autorelease];
    // [self.connDic setObject:connFacade forKey:url];
    [connFacade fetchGets:url];
}

#pragma mark - init view
- (void)initResource
{
    // Img
    self.shakeStartImg = [UIImage imageNamed:@"shake0.png"];
    self.shakeEndImg = [UIImage imageNamed:@"shake1.png"];
    
    // Sound
    NSString *shakePath = [[NSBundle mainBundle] pathForResource:@"shake"
                                                          ofType:@"wav"];
    AudioServicesCreateSystemSoundID((CFURLRef)[NSURL
                                                fileURLWithPath:shakePath], &shakeSoundID);
    
}

- (void)changeImages:(UIImageView *)aImageView
{
    if (!isRun) {
        return;
    }
    
    NSTimeInterval timeInterval = 1.0;
    if (!_isShakeImg) {
        aImageView.transform = CGAffineTransformMakeRotation(150);
        _isShakeImg = YES;
        timeInterval = 0.5;
    }else {
        aImageView.transform = CGAffineTransformMakeRotation(0);
        _isShakeImg = NO;
        timeInterval = 2.0;
    }
    
    [self performSelector:@selector(changeImages:)
               withObject:aImageView
               afterDelay:timeInterval
     ];
}

- (void)initView
{
    CGRect mFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    UIView *backView = [[[UIView alloc] initWithFrame:mFrame] autorelease];
    
    
    UIImageView *backImgView = [[[UIImageView alloc] initWithFrame:mFrame] autorelease];
    [backImgView setImage:[UIImage imageNamed:@"shakeBg.png"]];
    
    [backView addSubview:backImgView];
    
    // Image
    self.imageView = [[[UIImageView alloc] init] autorelease];
    self.imageView.frame = CGRectMake((self.view.frame.size.width-shakeStartImg.size.width)/2, 190.f, shakeStartImg.size.width, shakeStartImg.size.height);
    self.imageView.image = shakeStartImg;
    [backView addSubview:self.imageView];
    
    // Note
    WXWLabel *shakeAlumnusLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                       textColor:COLOR(162, 162, 162)
                                                     shadowColor:TRANSPARENT_COLOR] autorelease];
    shakeAlumnusLabel.font = BOLD_FONT(FONT_SIZE - 1);
    shakeAlumnusLabel.textAlignment = UITextAlignmentCenter;
    shakeAlumnusLabel.text = LocaleStringForKey(NSShakeNoteTitle, nil);
    CGSize size = [shakeAlumnusLabel.text sizeWithFont:shakeAlumnusLabel.font
                                     constrainedToSize:CGSizeMake(self.view.frame.size.width - 30, CGFLOAT_MAX)
                                         lineBreakMode:UILineBreakModeWordWrap];
    shakeAlumnusLabel.frame = CGRectMake(15, 450.f, self.view.frame.size.width - 30, size.height);
    
    [shakeAlumnusLabel setUserInteractionEnabled:YES];
    [backView addSubview:shakeAlumnusLabel];
    
    [self.view addSubview:backView];
    
    [backView becomeFirstResponder];
}

#pragma mark - prepare Condition
- (void)prepareLocationCondition
{
    
    [AppManager instance].defaultPlace = @"";
    [AppManager instance].defaultThing = @"";
    
    if (![IPAD_SIMULATOR isEqualToString:[CommonUtils deviceModel]]) {
        
        [AppManager instance].latitude = 0.0;
        [AppManager instance].longitude = 0.0;
        
        [self getCurrentLocationInfoIfNecessary];
        //        [WXWUIUtils showActivityView:[APP_DELEGATE foundationView]
        //                             text:LocaleStringForKey(NSShakeLoadingTitle, nil)];
    } else {
        [AppManager instance].latitude = [SIMULATION_LATITUDE doubleValue];
        [AppManager instance].longitude = [SIMULATION_LONGITUDE doubleValue];
        [self loadData];
    }
}

#pragma mark - do action
- (void)doPlace2Thing
{
    /*
    Place2ThingViewController *placeVC = [[[Place2ThingViewController alloc] initWithMOC:_MOC aPlaces:_shake.places aThings:_shake.things] autorelease];
    placeVC.title = LocaleStringForKey(NSShakeTitle, nil);

    [self.navigationController pushViewController:placeVC animated:YES];
     */
}

- (void)goUserList {
    
    [UIAccelerometer sharedAccelerometer].delegate = nil;
    
    // User List
    [CommonUtils doDelete:_MOC entityName:@"Alumni"];
    
    UserListViewController *userListVC = [[[UserListViewController alloc] initWithType:SHAKE_USER_LIST_TY needGoToHome:NO MOC:_MOC] autorelease];
    
    userListVC.pageIndex = 0;
    userListVC.requestParam = [NSString stringWithFormat:@"<longitude>%f</longitude><latitude>%f</latitude><distance_scope>10</distance_scope><time_scope>1000</time_scope><order_by_column>datetime</order_by_column><shake_where>%@</shake_where><shake_what>%@</shake_what><page>0</page><page_size>30</page_size><refresh_only>0</refresh_only>", [AppManager instance].longitude, [AppManager instance].latitude, @"", @""];
    
    [AppManager instance].shakeLocationHistory = [NSString stringWithFormat:@"<longitude>%f</longitude><latitude>%f</latitude>",[AppManager instance].longitude, [AppManager instance].latitude];
    userListVC.title = LocaleStringForKey(NSAlumniTitle, nil);
    
    WXWNavigationController *mNC = [[[WXWNavigationController alloc] initWithRootViewController:userListVC shadowType:SHADOW_RIGHT] autorelease];
    
    [APP_DELEGATE addViewInSlider:mNC
               invokeByController:self
                   stackStartView:YES];

}

#pragma mark - WXWConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(WebItemType)contentType
{
    
    [WXWUIUtils showActivityView:[APP_DELEGATE foundationView]
                         text:LocaleStringForKey(NSShakeLoadingTitle, nil)];
    [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(WebItemType)contentType
{
    [WXWUIUtils closeActivityView];
    switch (contentType) {
            
        case SHAKE_PLACE_THING_TY:
        {
            if ([XMLParser parserSyncResponseXml:result type:SHAKE_PLACE_THING_SRC MOC:_MOC]) {
                [self goUserList];
                
            } else {
                [WXWUIUtils showNotificationOnTopWithMsg:@"Failed Msg"
                                              msgType:ERROR_TY
                                   belowNavigationBar:YES];
            }
            _processing = NO;
            
            break;
        }
            
        case LOAD_EVENT_AWARD_RESULT_TY:
        {
            if ([XMLParser parserResponseXml:result
                                        type:contentType
                                         MOC:_MOC
                           connectorDelegate:self
                                         url:url]) {
                
                [self displayAwardResult];
                
            } else {
                
                [WXWUIUtils showNotificationOnTopWithMsg:(self.errorMsgDic)[url]
                                       alternativeMsg:LocaleStringForKey(NSEventAwardFailedMsg, nil)
                                              msgType:ERROR_TY
                                   belowNavigationBar:YES];
            }
            break;
        }
            
        default:
            break;
    }
    
}

- (void)connectCancelled:(NSString *)url
             contentType:(WebItemType)contentType
{
    [WXWUIUtils closeActivityView];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(WebItemType)contentType
{
    
    [WXWUIUtils closeActivityView];
    _processing = NO;
    
    switch (contentType) {
            
        case LOAD_EVENT_AWARD_RESULT_TY:
        {
            if ([self connectionMessageIsEmpty:error]) {
                [WXWUIUtils showNotificationOnTopWithMsg:(self.errorMsgDic)[url]
                                       alternativeMsg:LocaleStringForKey(NSEventAwardFailedMsg, nil)
                                              msgType:ERROR_TY
                                   belowNavigationBar:YES];
            }
            break;
        }
            
        default:
            break;
    }
    
    [super connectFailed:error url:url contentType:contentType];
}

#pragma mark - location result
- (void)locationResult:(int)type{
    NSLog(@"shake type is %d", type);
    
    [WXWUIUtils closeActivityView];
    
    switch (type) {
        case 0:
        {
            [self loadData];
        }
            break;
            
        case 1:
        {
            [WXWUIUtils showNotificationOnTopWithMsg:@"定位失败"
                                          msgType:ERROR_TY
                               belowNavigationBar:YES];
            _processing = NO;
            isShakeAction = NO;
        }
            break;
            
        default:
            break;
    }
    
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    
    if (self.lastAcceleration) {
        
        if (!_processing) {
            if (checkShakeing(self.lastAcceleration, acceleration, 0.3)) {
                /* SHAKE DETECTED. DO HERE WHAT YOU WANT. */
                AudioServicesPlaySystemSound(shakeSoundID);
                self.imageView.image = shakeEndImg;
                
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                
                _processing = YES;
                isShakeAction = YES;
                
                // [self prepareLocationCondition];
                [self loadAwardResult];
            }
        }
    }
    
    self.lastAcceleration = acceleration;
}

- (void)loadAwardResult {
    _currentType = LOAD_EVENT_AWARD_RESULT_TY;
    NSString *param = [NSString stringWithFormat:@"<event_id>%lld</event_id><latitude>%f</latitude><longitude>%f</longitude>", _eventId, [AppManager instance].latitude,
                       [AppManager instance].longitude];
    
    NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
    
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                              contentType:_currentType];
    [connFacade asyncGet:url showAlertMsg:YES];
}

#pragma mark - handle award
- (void)displayAwardResult {
    NSString *url = [NSString stringWithFormat:@"%@event?action=page_load&page_name=shake_it_off_wap&locale=%@&user_id=%@&plat=%@&version=%@&sessionId=%@&person_id=%@&channel=%d&user_name=%@&user_type=%@&class_id=%@&class_name=%@&latitude=%f&longitude=%f&winner_type=%d&event_id=%lld",
                     [AppManager instance].hostUrl,
                     [AppManager instance].currentLanguageDesc,
                     [AppManager instance].userId,
                     PLATFORM,
                     VERSION,
                     [AppManager instance].sessionId,
                     [AppManager instance].personId,
                     [AppManager instance].releaseChannelType,
                     [AppManager instance].username,
                     [AppManager instance].userType,
                     [AppManager instance].classGroupId,
                     [AppManager instance].className,
                     [AppManager instance].latitude,
                     [AppManager instance].longitude,
                     [AppManager instance].shakeWinnerType,
                     _eventId];
    
    UIWebViewController *webVC = [[[UIWebViewController alloc]
                                   initWithUrl:url
                                   frame:self.frame
                                   isNeedClose:YES] autorelease];
    webVC.modalDelegate = self;
    [self.navigationController pushViewController:webVC animated:YES];
}

- (void)doClose:(id)sender {
    
    if (self.modalDelegate) {
        [self closeModal:sender];
    }
}

@end
