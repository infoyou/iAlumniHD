
//
//  RootViewController.m
//  iAlumniHD
//
//  Created by Adam on 12-10-12.
//
//

#import "RootViewController.h"

#define ASYNC_LOADING_KEY                       @"ASYNC_LOADING_KEY"

#define ASYNC_LOADING_VIEW_HEIGHT               40.0f
#define OPERA_FACEBOOK_HEIGHT                   38.0f
#define OPERA_FACEBOOK_WIDTH                    38.0f
#define OPERA_FACEBOOK_COUNT                    28

#define TINY_NOTIFY_VIEW_HEIGHT                 23.0f

@interface RootViewController ()

@end

@implementation RootViewController
@synthesize frame = _frame;
@synthesize MOC = _MOC;
@synthesize tableView = _tableView;
@synthesize connFacade = _connFacade;
@synthesize connectionErrorMsg = _connectionErrorMsg;
@synthesize connDic = _connDic;
@synthesize errorMsgDic = _errorMsgDic;
@synthesize entityName = _entityName;
@synthesize descriptors = _descriptors;
@synthesize sectionNameKeyPath = _sectionNameKeyPath;
@synthesize predicate = _predicate;
@synthesize imageUrlDic = _imageUrlDic;
@synthesize fetchedRC = _fetchedRC;
@synthesize connectionResultMessage = _connectionResultMessage;
@synthesize disableViewOverlay;
@synthesize modalDisplayedVC;
@synthesize modalDelegate = _modalDelegate;
@synthesize selectedIndexPath = _selectedIndexPath;
@synthesize deSelectCellDelegate = _deSelectCellDelegate;
@synthesize ncDelegate = _ncDelegate;

// Pop View
@synthesize _PopView;
@synthesize _PopBGView;
@synthesize DropDownValArray = _DropDownValArray;
@synthesize PickData = _PickData;
@synthesize _PickerView;

#pragma mark - lifecycle methods
- (id)initWithMOC:(NSManagedObjectContext *)MOC {
    
    self = [super init];
    
    if (self) {
        self.MOC = MOC;
        self.connDic = [NSMutableDictionary dictionary];
        self.errorMsgDic = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC frame:(CGRect)frame {
    
    self = [super init];
    
    if (self) {
        
        self.MOC = MOC;
        self.frame = frame;
        self.connDic = [NSMutableDictionary dictionary];
        self.errorMsgDic = [NSMutableDictionary dictionary];
    }
    return self;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder
 backToHomeAction:(SEL)backToHomeAction
       needGoHome:(BOOL)needGoHome{
    
    return [self initWithMOC:MOC];
}

- (void)dealloc
{
    self.fetchedRC = nil;
    self.connFacade = nil;
    self.connectionErrorMsg = nil;
    self.connDic = nil;
    self.errorMsgDic = nil;
    self.entityName = nil;
    self.sectionNameKeyPath = nil;
    self.descriptors = nil;
    self.predicate = nil;
    self.imageUrlDic = nil;
    self.connectionResultMessage = nil;
    
    self.modalDisplayedVC = nil;
    self.DropDownValArray = nil;
    
    [_PopView release];
    [_PopBGView release];
    
    RELEASE_OBJ(_PickerView);
    
    self.PickData = nil;
    self.disableViewOverlay = nil;
    
    self.modalDelegate = nil;
    
    self.selectedIndexPath = nil;
    self.deSelectCellDelegate = nil;
    self.ncDelegate = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

#pragma mark - init view
- (void)addCloseBar
{
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:LocaleStringForKey(NSCloseTitle, nil)
                                                                               style:UIBarButtonItemStyleBordered
                                                                              target:self
                                                                              action:@selector(close:)] autorelease];
}

#pragma mark - life cycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:[self description]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:[self description]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.frame.size.width <= 0) {
        self.frame = CGRectMake(0, 0, LIST_WIDTH, SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT);
    }
    
    self.view.frame = self.frame;
    self.view.backgroundColor = CELL_COLOR;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - network consumer methods
- (WXWAsyncConnectorFacade *)setupAsyncConnectorForUrl:(NSString *)url
                                          contentType:(WebItemType)contentType {
    WXWAsyncConnectorFacade *connector = [[[WXWAsyncConnectorFacade alloc] initWithDelegate:self
                                                                   interactionContentType:contentType] autorelease];
    [self.connDic setObject:connector forKey:url];
    return connector;
}

#pragma mark - WXWConnectionTriggerHolderDelegate methods
- (void)registerRequestUrl:(NSString *)url connFacade:(WXWAsyncConnectorFacade *)connFacade {
    if (url && url.length > 0) {
        [self.connDic setObject:connFacade forKey:url];
    }
}

#pragma mark - check connection error message
- (BOOL)connectionMessageIsEmpty:(NSError *)error {
  if (self.connectionErrorMsg && self.connectionErrorMsg.length > 0) {
    return NO;
  } else {
    
    if (error) {
      self.connectionErrorMsg = error.localizedDescription;
      return NO;
    }
    
    return YES;
  }
}

#pragma mark - WXWConnectorDelegate methods
- (void)connectStarted:(NSString *)url contentType:(WebItemType)contentType {
    self.connectionResultMessage = nil;
  self.connectionErrorMsg = nil;
}

- (void)connectDone:(NSData *)result
                url:(NSString *)url
        contentType:(WebItemType)contentType
closeAsyncLoadingView:(BOOL)closeAsyncLoadingView {
    
    self.connFacade = nil;
    
    if (closeAsyncLoadingView) {
        [self closeAsyncLoadingView];
    }
    
    if (url && url.length > 0) {
        [self.connDic removeObjectForKey:url];
        [self.errorMsgDic removeObjectForKey:url];
    }
    
}

- (void)connectDone:(NSData *)result
                url:(NSString *)url
        contentType:(WebItemType)contentType {
    
    [self connectDone:result url:url contentType:contentType closeAsyncLoadingView:YES];
}

- (void)connectCancelled:(NSString *)url contentType:(WebItemType)contentType {
    self.connFacade = nil;
    
    [WXWUIUtils closeActivityView];
    [self closeAsyncLoadingView];
    
    if (url && url.length > 0) {
        [self.connDic removeObjectForKey:url];
    }
}

- (void)connectFailed:(NSError *)error url:(NSString *)url contentType:(WebItemType)contentType {
    self.connFacade = nil;
  
  if (self.connectionErrorMsg && self.connectionErrorMsg.length > 0) {
    [WXWUIUtils showNotificationOnTopWithMsg:self.connectionErrorMsg
                                  msgType:ERROR_TY
                       belowNavigationBar:YES];
  }
  
    [WXWUIUtils closeActivityView];
    [self closeAsyncLoadingView];
    
    if (url && url.length > 0) {
        [self.connDic removeObjectForKey:url];
    }
}

- (void)traceParserXMLErrorMessage:(NSString *)message url:(NSString *)url {
    if (url && url.length > 0) {
        [self.errorMsgDic setObject:message forKey:url];
    }
}

- (void)parserConnectionError:(NSError *)error {
  if (nil == error) {
    return;
  }
  
  switch (error.code) {
    case kCFURLErrorTimedOut:
      self.connectionErrorMsg = LocaleStringForKey(NSTimeoutMsg, nil);
      break;
      
    case kCFURLErrorNotConnectedToInternet:
      self.connectionErrorMsg = LocaleStringForKey(NSNetworkUnstableMsg, nil);
      break;
      
    default:
      break;
  }
}

#pragma mark - async loading view
- (void)clearAsyncLoadingViews {
    [_asyncLoadingLabel removeFromSuperview];
    RELEASE_OBJ(_asyncLoadingLabel);
    
    [_operaFacebookImageView removeFromSuperview];
    RELEASE_OBJ(_operaFacebookImageView);
    
    [_asyncLoadingBackgroundView removeFromSuperview];
    RELEASE_OBJ(_asyncLoadingBackgroundView);
    
    // connectionResultMessage will be set when connection done in sub class
    if (self.connectionResultMessage && self.connectionResultMessage.length > 0) {
        [self showTinyNotification:self.connectionResultMessage];
    }
}

- (void)closeAsyncLoadingView {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [WXWUIUtils closeActivityView];
        return;
    }
    
    if (_blockCurrentView) {
        self.view.userInteractionEnabled = YES;
        _blockCurrentView = NO;
    }
    
    _stopAsyncLoading = YES;
    
    if (_asyncLoadingBackgroundView && _asyncLoadingLabel && _operaFacebookImageView) {
        [UIView beginAnimations:ASYNC_LOADING_KEY context:nil];
        [UIView setAnimationDuration:0.2f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(clearAsyncLoadingViews)];
        _asyncLoadingBackgroundView.frame = CGRectMake(0, APP_WINDOW.frame.size.height, APP_WINDOW.frame.size.width, ASYNC_LOADING_VIEW_HEIGHT);
        [UIView commitAnimations];
    }
}

- (void)reverseFacebook {
    
    [UIView beginAnimations:nil
                    context:nil];
	[UIView setAnimationDuration:FADE_IN_DURATION];
    UIViewAnimationTransition transition;
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDelay:1.0f];
    if (_reverseFromRightToLeft) {
        transition = UIViewAnimationTransitionFlipFromRight;
        [UIView setAnimationDidStopSelector:@selector(showSecondRightToLeftOperaFacebooks)];
    } else {
        transition = UIViewAnimationTransitionFlipFromLeft;
        [UIView setAnimationDidStopSelector:@selector(showSecondLeftToRightOperaFacebooks)];
    }
    
    [UIView setAnimationTransition:transition
                           forView:_operaFacebookImageView
                             cache:YES];
    [UIView commitAnimations];
    
    int index = arc4random() % OPERA_FACEBOOK_COUNT;
    _operaFacebookImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"beijingOpera%d.png", index]];
    
}

- (void)addXMoveAnimationFor_operaFacebookImageView:(CGFloat)endPointX {
    CABasicAnimation *moveAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    moveAnimation.duration = 1;
    moveAnimation.repeatCount = 1;
    moveAnimation.toValue = [NSNumber numberWithFloat:endPointX];
    moveAnimation.fillMode = kCAFillModeForwards;
    moveAnimation.removedOnCompletion = NO;
    [_operaFacebookImageView.layer addAnimation:moveAnimation forKey:nil];
}

- (void)showMoveOperaFacebooksToMediaPosition {
    
    if (_stopAsyncLoading) {
        return;
    }
    
    int index = arc4random() % OPERA_FACEBOOK_COUNT;
    _operaFacebookImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"beijingOpera%d.png", index]];
    
    CGFloat endX = (_asyncLoadingLabel.frame.origin.x - MARGIN * 2)/2;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.0f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(reverseFacebook)];
    _reverseFromRightToLeft = !_reverseFromRightToLeft;
    _operaFacebookImageView.alpha = 1.0f;
    //_operaFacebookImageView.frame = CGRectMake(endX, _operaFacebookImageView.frame.origin.y, OPERA_FACEBOOK_WIDTH, OPERA_FACEBOOK_HEIGHT);
    
    [self addXMoveAnimationFor_operaFacebookImageView:endX];
    [UIView commitAnimations];
}

- (void)showSecondLeftToRightOperaFacebooks {
    
    if (_stopAsyncLoading) {
        return;
    }
    
    CGFloat endX = _asyncLoadingLabel.frame.origin.x - MARGIN * 2;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.0f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(showMoveOperaFacebooksToMediaPosition)];
    _operaFacebookImageView.alpha = 0.0f;
    //_operaFacebookImageView.frame = CGRectMake(endX, _operaFacebookImageView.frame.origin.y, OPERA_FACEBOOK_WIDTH, OPERA_FACEBOOK_HEIGHT);
    
    [self addXMoveAnimationFor_operaFacebookImageView:endX];
    
    [UIView commitAnimations];
}

- (void)showSecondRightToLeftOperaFacebooks {
    
    if (_stopAsyncLoading) {
        return;
    }
    
    CGFloat endX = 0.0f;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.0f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(showMoveOperaFacebooksToMediaPosition)];
    _operaFacebookImageView.alpha = 0.0f;
    //_operaFacebookImageView.frame = CGRectMake(endX, _operaFacebookImageView.frame.origin.y, OPERA_FACEBOOK_WIDTH, OPERA_FACEBOOK_HEIGHT);
    [self addXMoveAnimationFor_operaFacebookImageView:endX];
    
    [UIView commitAnimations];
}

- (void)changeAsyncLoadingMessage:(NSString *)message {
    if (_asyncLoadingLabel) {
        _asyncLoadingLabel.text = message;
        CGSize size = [_asyncLoadingLabel.text sizeWithFont:_asyncLoadingLabel.font
                                          constrainedToSize:CGSizeMake(200, CGFLOAT_MAX)
                                              lineBreakMode:UILineBreakModeWordWrap];
        _asyncLoadingLabel.frame = CGRectMake(APP_WINDOW.frame.size.width - MARGIN * 2 - size.width, ASYNC_LOADING_VIEW_HEIGHT/2 - size.height/2, size.width, size.height);
    }
}

- (void)showAsyncLoadingView:(NSString *)message blockCurrentView:(BOOL)blockCurrentView {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [WXWUIUtils showActivityView:[APP_DELEGATE foundationView] text:LocaleStringForKey(NSLoadingTitle, nil)];
        return;
    }
    
    if (_asyncLoadingBackgroundView) {
        // async loading view displayed currently, then no need to show it again
        return;
    }
    
    _blockCurrentView = blockCurrentView;
    if (_blockCurrentView) {
        self.view.userInteractionEnabled = NO;
    }
    
    _stopAsyncLoading = NO;
    
    if (nil == _asyncLoadingBackgroundView) {
        _asyncLoadingBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, APP_WINDOW.frame.size.height, APP_WINDOW.frame.size.width, ASYNC_LOADING_VIEW_HEIGHT)];
        _asyncLoadingBackgroundView.backgroundColor = [UIColor blackColor];
        _asyncLoadingBackgroundView.alpha = 0.7f;
        
        [APP_WINDOW addSubview:_asyncLoadingBackgroundView];
    }
    
    if (nil == _asyncLoadingLabel) {
        _asyncLoadingLabel = [[UILabel alloc] init];
        _asyncLoadingLabel.backgroundColor = TRANSPARENT_COLOR;
        _asyncLoadingLabel.textAlignment = UITextAlignmentCenter;
        _asyncLoadingLabel.textColor = [UIColor whiteColor];
        _asyncLoadingLabel.font = BOLD_FONT(13);
        [_asyncLoadingBackgroundView addSubview:_asyncLoadingLabel];
    }
    
    _asyncLoadingLabel.text = message;
    CGSize size = [_asyncLoadingLabel.text sizeWithFont:_asyncLoadingLabel.font
                                      constrainedToSize:CGSizeMake(200, CGFLOAT_MAX)
                                          lineBreakMode:UILineBreakModeWordWrap];
    _asyncLoadingLabel.frame = CGRectMake(APP_WINDOW.frame.size.width - MARGIN * 2 - size.width, ASYNC_LOADING_VIEW_HEIGHT/2 - size.height/2, size.width, size.height);
    
    if (nil == _operaFacebookImageView) {
        _operaFacebookImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, ASYNC_LOADING_VIEW_HEIGHT/2 - OPERA_FACEBOOK_HEIGHT/2, OPERA_FACEBOOK_WIDTH, OPERA_FACEBOOK_HEIGHT)];
        _operaFacebookImageView.backgroundColor = TRANSPARENT_COLOR;
        [_asyncLoadingBackgroundView addSubview:_operaFacebookImageView];
    }
    
    _operaFacebookImageView.alpha = 0.0f;
    
    [UIView beginAnimations:ASYNC_LOADING_KEY context:nil];
    [UIView setAnimationDuration:0.2f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(showMoveOperaFacebooksToMediaPosition)];
    
    _reverseFromRightToLeft = YES;
    
    _asyncLoadingBackgroundView.frame = CGRectMake(0, APP_WINDOW.frame.size.height - ASYNC_LOADING_VIEW_HEIGHT, APP_WINDOW.frame.size.width, ASYNC_LOADING_VIEW_HEIGHT);
    
    [UIView commitAnimations];
}

#pragma mark - Clear Picker Select Index
- (void)clearPickerSelIndex2Init:(int)size
{
    _pickSize = size;
    [self clearPickerCache];
}

- (void)clearPickerCache {
    if ([AppManager instance].pickerSel0IndexList) {
        //[[AppManager instance].pickerSel0IndexList removeAllObjects];
        [AppManager instance].pickerSel0IndexList = nil;
        
        //[[AppManager instance].pickerSel1IndexList removeAllObjects];
        [AppManager instance].pickerSel1IndexList = nil;
    }
    
    [AppManager instance].pickerSel0IndexList = [NSMutableArray array];
    [AppManager instance].pickerSel1IndexList = [NSMutableArray array];
    
    for (int i = 0; i<_pickSize; i++) {
        [[AppManager instance].pickerSel0IndexList insertObject:[NSString stringWithFormat:@"%d", iOriginalSelIndexVal] atIndex:i];
        [[AppManager instance].pickerSel1IndexList insertObject:[NSString stringWithFormat:@"%d", iOriginalSelIndexVal] atIndex:i];
    }
}

#pragma mark - Pop View
- (void)setDropDownValueArray {
}

-(void)setPopView
{
    isPickSelChange = NO;
    
    UIViewController *fliterViewController = [[UIViewController alloc] init];
    CGRect mPopViewRect = CGRectMake(PopViewX, 0 /*_frame.size.height-PopViewHeight-30 */, _frame.size.width, PopViewHeight);
    
    _PopView = [[UIView alloc] initWithFrame:mPopViewRect];
    [_PopView setBackgroundColor:[UIColor darkGrayColor]];
    
    //设置圆角边框
    _PopView.layer.cornerRadius = 8;
    _PopView.layer.masksToBounds = YES;
    
    //设置边框及边框颜色
    _PopView.layer.borderWidth = 8;
    _PopView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    
    WXWGradientButton *cancelBtn = [[[WXWGradientButton alloc] initWithFrame:CGRectMake(8.f, 8.f, 120.0f, 35.0f)
                                                                    target:self
                                                                    action:@selector(onPopCancle:)
                                                                 colorType:BLACK_BTN_COLOR_TY
                                                                     title:LocaleStringForKey(NSCancelTitle, nil)
                                                                     image:nil
                                                                titleColor:[UIColor whiteColor]
                                                          titleShadowColor:[UIColor blackColor]
                                                                 titleFont:BOLD_FONT(15)
                                                               roundedType:HAS_ROUNDED
                                                           imageEdgeInsert:ZERO_EDGE
                                                           titleEdgeInsert:ZERO_EDGE] autorelease];
    [_PopView addSubview:cancelBtn];
    
    WXWGradientButton *okBtn = [[[WXWGradientButton alloc] initWithFrame:CGRectMake(_frame.size.width - 128.0f, 8.f, 120.0f, 35.0f)
                                                                target:self
                                                                action:@selector(onPopOk:)
                                                             colorType:RED_BTN_COLOR_TY
                                                                 title:LocaleStringForKey(NSSureTitle, nil)
                                                                 image:nil
                                                            titleColor:[UIColor whiteColor]
                                                      titleShadowColor:[UIColor blackColor]
                                                             titleFont:BOLD_FONT(15)
                                                           roundedType:HAS_ROUNDED
                                                       imageEdgeInsert:ZERO_EDGE
                                                       titleEdgeInsert:ZERO_EDGE] autorelease];
    [_PopView addSubview:okBtn];
    
    _PickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 50.f, _frame.size.width, POP_HEIGHT)];
    
    _PickerView.delegate = self;
    _PickerView.dataSource = self;
    
    _PickerView.showsSelectionIndicator = YES;
    
    // Pick Data
    [self setDropDownValueArray];
    
    if (self.DropDownValArray) {
        
        self.PickData = [NSMutableArray array];
        
        int size = [self.DropDownValArray count];
        for (int index =0; index < size; index++) {
            [self.PickData addObject:[[self.DropDownValArray objectAtIndex:index] objectAtIndex:RECORD_NAME]];
        }
    }
    
    NSLog(@"iFliterIndex = %d, row = %d", iFliterIndex , [[[AppManager instance].pickerSel0IndexList objectAtIndex:iFliterIndex] intValue]);
    
    // default select index row = 0
    int mPickSelectIndex = [[[AppManager instance].pickerSel0IndexList objectAtIndex:iFliterIndex] intValue];
    
    if (mPickSelectIndex == -1) {
        mPickSelectIndex = 0;
    }
    
    [_PickerView selectRow:mPickSelectIndex inComponent:PickerOne animated:NO];
    
    if ([_PickerView numberOfComponents] == 2) {
        
        // default select index row = 1
        int mPickSelect1Index = [[[AppManager instance].pickerSel1IndexList objectAtIndex:iFliterIndex] intValue];
        
        if (mPickSelect1Index == -1) {
            mPickSelect1Index = 0;
        }
        
        [_PickerView selectRow:mPickSelect1Index inComponent:PickerTwo animated:NO];
    }
    
    [_PopView addSubview:_PickerView];
    
    fliterViewController.view = _PopView;
    
    _popViewController = [[UIPopoverController alloc] initWithContentViewController:fliterViewController];
    [_popViewController setPopoverContentSize:CGSizeMake(_frame.size.width, PopViewHeight)];
    [_popViewController presentPopoverFromRect:CGRectMake(190.f, 10.f, _frame.size.width, POP_HEIGHT)
                                        inView:self.view
                      permittedArrowDirections:_UIPopoverArrowDirection
                                      animated:YES];
    _popViewController.delegate = self;
    [fliterViewController release];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    CGFloat componentWidth = 0.0f;
    if (component == 0) {
        componentWidth = FIRST_PICKER_WIDTH;
    }else {
        componentWidth = _frame.size.width - FIRST_PICKER_WIDTH;
    }
    return componentWidth;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    _isPop = NO;
    [popoverController release];
}

-(void)onPopCancle {
    
    [_popViewController dismissPopoverAnimated:NO];
    //    [self clearPickerCache];
    _isPop = NO;
}

-(void)onPopSelectedOk {
    
    if (isPickSelChange) {
        [[AppManager instance].pickerSel0IndexList removeObjectAtIndex:iFliterIndex];
        [[AppManager instance].pickerSel0IndexList insertObject:[NSString stringWithFormat:@"%d", pickSel0Index] atIndex:iFliterIndex];
        
        [[AppManager instance].pickerSel1IndexList removeObjectAtIndex:iFliterIndex];
        [[AppManager instance].pickerSel1IndexList insertObject:[NSString stringWithFormat:@"%d", pickSel1Index] atIndex:iFliterIndex];
    }
    
    [_popViewController dismissPopoverAnimated:NO];
    _isPop = NO;
}

- (int)pickerList0Index{
    int iPickSelectIndex = [[[AppManager instance].pickerSel0IndexList objectAtIndex:iFliterIndex] intValue];
    if (iPickSelectIndex == -1) {
        iPickSelectIndex = 0;
    }
    return iPickSelectIndex;
}

#pragma mark - UIPickerViewDelegate
- (void)pickerSelectRow:(NSInteger)row
{
    NSLog(@"pickerView %d", row);
    
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return @"";
}

#pragma mark - core data
- (void)setFetchCondition {
    // implemented by subclass
}

- (NSFetchedResultsController *)prepareFetchRC {
    
    [self setFetchCondition];
    
    self.fetchedRC = [CommonUtils fetchObject:_MOC
                     fetchedResultsController:self.fetchedRC
                                   entityName:self.entityName
                           sectionNameKeyPath:nil
                              sortDescriptors:self.descriptors
                                    predicate:self.predicate];
    return self.fetchedRC;
}

- (void)deselectCell
{
	NSIndexPath *selection = [_tableView indexPathForSelectedRow];
	if (selection) {
		[_tableView deselectRowAtIndexPath:selection animated:YES];
	}
}

#pragma mark - LocationFetcherDelegate methods
- (void)locationManagerDidUpdateLocation:(LocationManager *)manager location:(CLLocation *)location
{
    return;
}

- (void)locationManagerDidReceiveLocation:(LocationManager *)manager location:(CLLocation *)location
{
    [AppManager instance].latitude = location.coordinate.latitude;
    [AppManager instance].longitude = location.coordinate.longitude;
    
    [manager autorelease];
    _locationManager = nil;
    
    [self locationResult:0];
}

- (void)locationManagerDidFail:(LocationManager *)manager {
    if (!_userCancelledLocate) {
        [manager autorelease];
    } else {
        _userCancelledLocate = NO;
    }
    _locationManager = nil;
    [self locationResult:1];
}

- (void)locationManagerCancelled:(LocationManager *)manager {
    [manager autorelease];
    _locationManager = nil;
    _userCancelledLocate = YES;
    [self locationResult:1];
}

- (void)locationResult:(int)type{
}

#pragma mark - location fetch
- (void)triggerGetLocation {
    
    if ([CommonUtils currentOSVersion] >= IOS4_2) {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:LocaleStringForKey(NSNearbyServiceUnavailableMsg, nil)
                                                             message:LocaleStringForKey(NSLocationServiceDeniedMsg, nil)
                                                            delegate:self
                                                   cancelButtonTitle:nil
                                                   otherButtonTitles:LocaleStringForKey(NSOKTitle, nil), nil] autorelease];
            [alert show];
            
            return;
        }
    }
    
    _locationManager = nil;
    _locationManager = [[LocationManager alloc] initWithDelegate:self
                                                    showAlertMsg:_showLocationErrorMsg];
    [_locationManager getCurrentLocation];
    
}

- (void)forceGetLocation {
    _showLocationErrorMsg = NO;
    [self triggerGetLocation];
}

- (void)getCurrentLocationInfoIfNecessary {
    _showLocationErrorMsg = NO;
    [self triggerGetLocation];
}

- (void)forceGetLocationNeedShowErrorMsg:(BOOL)showErrorMsg {
    _showLocationErrorMsg = showErrorMsg;
    [self triggerGetLocation];
}

#pragma mark - Table
- (void)initTableView
{
    self.tableView.backgroundColor = BACKGROUND_COLOR;
}

#pragma mark - ImageDisplayerDelegate method
- (void)registerImageUrl:(NSString *)url {
    if (nil == self.imageUrlDic) {
        self.imageUrlDic = [NSMutableDictionary dictionary];
    }
    if (url && url.length > 0) {
        [self.imageUrlDic setObject:url forKey:url];
    }
}

#pragma mark - cancel connection / location when navigation back to parent layer
- (void)cancelSubViewConnections {
    // stop the connection for sub views, e.g., some kind of table view cells in list, which triggered load comments,
    // if the UI being destructed, the processing loading should be stopped, then this connection will be cancelled in
    // following code;
    // these connections registered by the protocal WXWConnectionTriggerHolderDelegate method
    for (NSString *url in self.connDic.allKeys) {
        WXWAsyncConnectorFacade *connFacade = [self.connDic objectForKey:url];
        [connFacade cancelConnection];
    }
    
    [self.connDic removeAllObjects];
    
}

- (void)cancelConnection {
    if (self.connFacade) {
        [self.connFacade cancelConnection];
    }
    
    [self cancelSubViewConnections];
}

- (void)cancelLocation {
    if (_locationManager) {
        [_locationManager cancelLocation];
    }
}

#pragma mark - cancel connection and image loading
- (void)cancelConnectionAndImageLoading {
    [self cancelConnection];
    
    [[AppManager instance].imageCache cancelPendingImageLoadProcess:self.imageUrlDic];
}

#pragma mark - DisableView option
- (void)initDisableView:(CGRect)frame {
    
    self.disableViewOverlay = [[[UIView alloc]
                                initWithFrame:frame] autorelease];
    self.disableViewOverlay.backgroundColor=[UIColor blackColor];
    self.disableViewOverlay.alpha = 0;
}

- (void)showDisableView {
    
    if (self.navigationItem && !([CommonUtils currentOSVersion] < IOS5)) {
        self.navigationItem.hidesBackButton = YES;
    }
    
    if (self.navigationItem.leftBarButtonItem) {
        self.navigationItem.leftBarButtonItem.enabled = NO;
    }
    
    if (self.navigationItem.rightBarButtonItem) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
    self.disableViewOverlay.alpha = 0;
    [self.view addSubview:self.disableViewOverlay];
    
    [UIView beginAnimations:@"FadeIn" context:nil];
    [UIView setAnimationDuration:0.5];
    self.disableViewOverlay.alpha = 0.6;
    [UIView commitAnimations];
}

- (void)removeDisableView {
    
    if (self.navigationItem && !([CommonUtils currentOSVersion] < IOS5)) {
        self.navigationItem.hidesBackButton = NO;
    }
    
    if (self.navigationItem.leftBarButtonItem) {
        self.navigationItem.leftBarButtonItem.enabled = YES;
    }
    
    if (self.navigationItem.rightBarButtonItem) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    
    [self.disableViewOverlay removeFromSuperview];
}

#pragma mark - back to homepage
- (void)backToHomepage:(id)sender {
    
    [self cancelConnection];
    
    [self cancelLocation];
    
    [[AppManager instance].imageCache cancelPendingImageLoadProcess:self.imageUrlDic];
    
    if (_holder && _backToHomeAction) {
        [_holder performSelector:_backToHomeAction];
    }
}

#pragma mark - show tiny notification

- (void)clearTinyNotifyViews {
    [_tinyNotifyLabel removeFromSuperview];
    RELEASE_OBJ(_tinyNotifyLabel);
    
    [_tinyNotifyBackgroundView removeFromSuperview];
    RELEASE_OBJ(_tinyNotifyBackgroundView);
}

- (void)tinyInfoShowDone {
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDelay:2.0];
	[UIView setAnimationDuration:0.2];
    [UIView setAnimationDidStopSelector:@selector(clearTinyNotifyViews)];
    
    _tinyNotifyBackgroundView.frame = CGRectMake(_tinyNotifyBackgroundView.frame.origin.x, APP_WINDOW.frame.size.height, APP_WINDOW.frame.size.width, ASYNC_LOADING_VIEW_HEIGHT);
    
    [UIView commitAnimations];
}

- (void)showTinyNotification:(NSString *)message {
    
    if (_tinyNotifyBackgroundView || nil == message || message.length == 0) {
        return;
    }
    
    _tinyNotifyBackgroundView = [[UIView alloc] init];
    _tinyNotifyBackgroundView.backgroundColor = [UIColor blackColor];
    _tinyNotifyBackgroundView.alpha = 0.7f;
    [APP_WINDOW addSubview:_tinyNotifyBackgroundView];
    
    if (nil == _tinyNotifyLabel) {
        _tinyNotifyLabel = [[UILabel alloc] init];
        _tinyNotifyLabel.font = BOLD_FONT(13);
        _tinyNotifyLabel.backgroundColor = TRANSPARENT_COLOR;
        _tinyNotifyLabel.textAlignment = UITextAlignmentCenter;
        _tinyNotifyLabel.textColor = [UIColor whiteColor];
        [_tinyNotifyBackgroundView addSubview:_tinyNotifyLabel];
    }
    
    _tinyNotifyLabel.text = message;
    CGSize size = [message sizeWithFont:_tinyNotifyLabel.font
                               forWidth:self.view.frame.size.width
                          lineBreakMode:UILineBreakModeWordWrap];
    _tinyNotifyLabel.frame = CGRectMake(MARGIN, MARGIN, size.width, size.height);
    _tinyNotifyBackgroundView.frame = CGRectMake(APP_WINDOW.frame.size.width - (MARGIN * 2 + _tinyNotifyLabel.frame.size.width), APP_WINDOW.frame.size.height, MARGIN * 2 + _tinyNotifyLabel.frame.size.width, TINY_NOTIFY_VIEW_HEIGHT);
    
    [UIView beginAnimations:ASYNC_LOADING_KEY context:nil];
    [UIView setAnimationDuration:0.2f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(tinyInfoShowDone)];
    
    _tinyNotifyBackgroundView.frame = CGRectMake(_tinyNotifyBackgroundView.frame.origin.x, APP_WINDOW.frame.size.height - TINY_NOTIFY_VIEW_HEIGHT, _tinyNotifyBackgroundView.frame.size.width, TINY_NOTIFY_VIEW_HEIGHT);
    
    [UIView commitAnimations];
    
}

#pragma mark - manage modal view controller
- (UIView*)parentTarget {
/*
    // To make it work with UINav & UITabbar as well
    UIViewController * target = self;
    while (target.parentViewController != nil) {
        target = target.parentViewController;
    }
 
    return target.view;
 */
  return ((UIViewController *)self).view;
}

- (CAAnimationGroup*)animationGroupForward:(BOOL)_forward {
    
    // Create animation keys, forwards and backwards
    CATransform3D t1 = CATransform3DIdentity;
    t1.m34 = 1.0/-900;
    t1 = CATransform3DScale(t1, 0.95, 0.95, 1);
    t1 = CATransform3DRotate(t1, 15.0f*M_PI/180.0f, 1, 0, 0);
    
    CATransform3D t2 = CATransform3DIdentity;
    t2.m34 = t1.m34;
    t2 = CATransform3DTranslate(t2, 0, [self parentTarget].frame.size.height*-0.08, 0);
    t2 = CATransform3DScale(t2, 0.8, 0.8, 1);
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.toValue = [NSValue valueWithCATransform3D:t1];
    animation.duration = 0.2f;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    
    CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation2.toValue = [NSValue valueWithCATransform3D:(_forward?t2:CATransform3DIdentity)];
    animation2.beginTime = animation.duration;
    animation2.duration = animation.duration;
    animation2.fillMode = kCAFillModeForwards;
    animation2.removedOnCompletion = NO;
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    [group setDuration:animation.duration*2];
    [group setAnimations:[NSArray arrayWithObjects:animation,animation2, nil]];
    return group;
}

- (void)presentModalQuickViewController:(UIViewController*)vc {
    
    self.modalDisplayedVC = vc;
    
    [self presentModalQuickView:vc.view];
}

- (void)presentModalQuickView:(UIView*)vc {
  

    // Determine target
    UIView * target = [self parentTarget];
  
    if (![target.subviews containsObject:vc]) {
        // Calulate all frames
        CGRect sf = vc.frame;
        CGRect vf = target.frame;
        CGRect f  = CGRectMake(0, vf.size.height-sf.size.height, vf.size.width, sf.size.height);
        CGRect of = CGRectMake(0, 0, vf.size.width, vf.size.height-sf.size.height);
        
        // Add semi overlay
        UIView * overlay = [[[UIView alloc] initWithFrame:target.bounds] autorelease];
        overlay.backgroundColor = [UIColor blackColor];
        
        // Take screenshot and scale
        //UIGraphicsBeginImageContext(target.bounds.size);
      
        UIGraphicsBeginImageContextWithOptions(target.bounds.size, target.opaque, 2.0);
      
        [target.layer renderInContext:UIGraphicsGetCurrentContext()];
      
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        UIImageView * ss = [[[UIImageView alloc] initWithImage:image] autorelease];
        [overlay addSubview:ss];
        [target addSubview:overlay];
      
        // Dismiss button
        // Don't use UITapGestureRecognizer to avoid complex handling
        UIButton * dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [dismissButton addTarget:self
                          action:@selector(dismissModalQuickView)
                forControlEvents:UIControlEventTouchUpInside];
        dismissButton.backgroundColor = TRANSPARENT_COLOR;
        dismissButton.frame = of;
        [overlay addSubview:dismissButton];
        
        // Begin overlay animation
        [ss.layer addAnimation:[self animationGroupForward:YES] forKey:@"pushedBackAnimation"];
        [UIView animateWithDuration:0.2f
                         animations:^{
                             ss.alpha = 0.5;
                         }];
        
        // Present view animated
        vc.frame = CGRectMake(0, vf.size.height, vf.size.width, sf.size.height);
        [target addSubview:vc];
        vc.layer.shadowColor = [[UIColor blackColor] CGColor];
        vc.layer.shadowOffset = CGSizeMake(0, -2);
        vc.layer.shadowRadius = 5.0;
        vc.layer.shadowOpacity = 0.8;
        [UIView animateWithDuration:0.2f
                         animations:^{
            vc.frame = f;
        }
                         completion:^(BOOL finished){
                           [WXWUIUtils closeActivityView];
                         }];
    }
}

- (void)dismissModalQuickView {
    
    UIView * target = [self parentTarget];
    UIView * modal = [target.subviews objectAtIndex:target.subviews.count-1];
    UIView * overlay = [target.subviews objectAtIndex:target.subviews.count-2];
    
    [UIView animateWithDuration:FADE_IN_DURATION animations:^{
        modal.frame = CGRectMake(0, target.frame.size.height, modal.frame.size.width, modal.frame.size.height);
    } completion:^(BOOL finished) {
        [overlay removeFromSuperview];
        [modal removeFromSuperview];
        self.modalDisplayedVC = nil;
    }];
    
    // Begin overlay animation
    UIImageView * ss = (UIImageView*)[overlay.subviews objectAtIndex:0];
    [ss.layer addAnimation:[self animationGroupForward:NO] forKey:@"bringForwardAnimation"];
    [UIView animateWithDuration:FADE_IN_DURATION animations:^{
        ss.alpha = 1;
    }];
}

#pragma mark - close view stack action
- (void)close:(id)sender {
    
    if (self.deSelectCellDelegate) {
        [self.deSelectCellDelegate deSelectCell];
    }
    
    [APP_DELEGATE closeViewStack];
}

#pragma mark - ModalViewControllerDelegate method
-(void)modalViewControllerDidFinish {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)closeModal:(id)sender {
    [self.modalDelegate modalViewControllerDidFinish];
}

#pragma mark - DeSelectCellDelegate method
- (void)deSelectCell
{
    if (self.selectedIndexPath) {
        NSLog(@"deSelectCell selectedIndexPath = %@", self.selectedIndexPath);
        [_tableView deselectRowAtIndexPath:self.selectedIndexPath animated:YES];
    }
}

#pragma mark - UINavigationControllerDelegate method
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    if (self.ncDelegate) {
        [viewController viewWillAppear:animated];
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    if (self.ncDelegate) {
        [viewController viewDidAppear:animated];
    }
}

#pragma mark - set bar item buttons
- (void)setRightButtonTitle:(NSString *)title {
    
    if (self.navigationItem.rightBarButtonItem) {
        [self.navigationItem.rightBarButtonItem setTitle:title];
    }
    
}

- (void)setLeftButtonTitle:(NSString *)title {
    if (self.navigationItem.leftBarButtonItem) {
        [self.navigationItem.leftBarButtonItem setTitle:title];
    }
}

- (void)addRightBarButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action {
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleDone target:self action:action] autorelease];
}

- (void)addLeftBarButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action {
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleDone target:self action:action] autorelease];
}

#pragma mark - RefreshDelegate method
- (void)doParentRefresh {
    
    if ([AppManager instance].rootVC) {
        [[AppManager instance].rootVC doParentRefreshView];
    }
}

- (void)doParentRefreshView {}

- (void)setRefreshVC:(RootViewController *)rootVC
{
    [AppManager instance].rootVC = rootVC;
}

#pragma mark - table option
- (void)hideTable {
    
    _tableView.alpha = 1.0f;
    _tableView.frame = CGRectMake(0, 0, self.frame.size.width, 0);
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)showTable
{
    [UIView animateWithDuration:FADE_IN_DURATION
                     animations:^{
                         _tableView.frame = self.frame;
                         _tableView.alpha = 1.0f;
                     }];
}

#pragma mark - add right bar button
- (void)addRightBarButton:(SEL)action {
    
    UIToolbar *toolbar = [[[UIToolbar alloc] initWithFrame:CGRectZero] autorelease];
    toolbar.barStyle = -1;
    toolbar.tintColor = NAVIGATION_BAR_COLOR;
    
    UIBarButtonItem *closeButton = BAR_IMG_BUTTON([UIImage imageNamed:@"close.png"], UIBarButtonItemStylePlain, self, action);
    
    [toolbar setItems:[NSArray arrayWithObjects:closeButton, nil]];
    toolbar.frame = CGRectMake(0, 0, 50.f, TOOLBAR_HEIGHT);
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:toolbar] autorelease];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotate {
    return YES;
}
#endif

- (void)reSizeTable {
    int offsetY = 0;
    
    if ([CommonUtils is7System]) {
        offsetY = 44;
    }
    
    _tableView.frame = CGRectMake(0, offsetY, _tableView.frame.size.width, _tableView.frame.size.height - offsetY);
}

@end
