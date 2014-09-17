//
//  UIWebViewController.m
//  iAlumniHD
//
//  Created by Adam on 12-10-15.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "UIWebViewController.h"

@interface UIWebViewController()
@property (nonatomic, copy) NSString *urlStr;
@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, assign) int fontSize;
@property (nonatomic, retain) UIPopoverController *popController;
@end

@implementation UIWebViewController

- (id)initWithUrl:(NSString *)url frame:(CGRect)frame isNeedClose:(BOOL)isNeedClose
{
    self = [super initWithMOC:nil frame:frame];
    
    if (self) {
        self.urlStr = url;
        self.fontSize = 150;
        _closeAvailable = isNeedClose;
    }
    
    return self;
}

- (void)stopLoading {
    [self.webView stopLoading];
    
    if ([WXWUIUtils activityViewIsAnimating]) {
        [WXWUIUtils closeActivityView];
    }
    
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)dealloc {
    
    self.urlStr = nil;
    self.popController = nil;
    [self stopLoading];
    self.fontSize = nil;
    self.webView.delegate = nil;
    self.webView = nil;
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - add bar button

- (void)addLeftBarButton {
    
//    UIToolbar *toolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 100.f, TOOLBAR_HEIGHT)] autorelease];

    UIToolbar *toolbar = [[[UIToolbar alloc] initWithFrame:CGRectZero] autorelease];
    
    toolbar.barStyle = -1;
    toolbar.tintColor = NAVIGATION_BAR_COLOR;
    
    UIBarButtonItem *upBarButton = BAR_IMG_BUTTON([UIImage imageNamed:@"fontSizeUp.png"], UIBarButtonSystemItemFixedSpace, self, @selector(fontSizeUp:));

    UIBarButtonItem *space = BAR_SYS_BUTTON(UIBarButtonSystemItemFixedSpace, nil, nil);
    
    UIBarButtonItem *downBarButton = BAR_IMG_BUTTON([UIImage imageNamed:@"fontSizeDown.png"], UIBarButtonSystemItemFixedSpace, self, @selector(fontSizeDown:));
    
    [toolbar setItems:[NSArray arrayWithObjects:upBarButton, space, downBarButton, nil] animated:NO];
    
    toolbar.frame = CGRectMake(0, 0, 100.f, TOOLBAR_HEIGHT);
    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:toolbar] autorelease];
}

#pragma mark - user action
- (void)close:(id)sender {
    
    if (!self.popController) {
        [super close:sender];
    }else{
        [self.popController dismissPopoverAnimated:NO];
    }
}

- (void)modifyFontSize {
    
    NSString *jsStr = [[NSString alloc] initWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%d%%'", self.fontSize];
    [self.webView stringByEvaluatingJavaScriptFromString:jsStr];
    RELEASE_OBJ(jsStr);
}

- (void)fontSizeDown:(id)sender {
    
    self.fontSize = (self.fontSize > 50) ? self.fontSize - 5 : self.fontSize;
    [self modifyFontSize];
}

- (void)fontSizeUp:(id)sender {
    
    self.fontSize = (self.fontSize < 300) ? self.fontSize + 5 : self.fontSize;
    [self modifyFontSize];
}

#pragma mark - View lifecycle

- (void)initWebView {
    
    CGRect webFrame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    
    if (self.modalDelegate) {
        webFrame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    }
    
    self.webView = [[UIWebView alloc] initWithFrame:webFrame];
    self.webView.userInteractionEnabled = YES;
    self.webView.delegate = self;
    self.webView.scalesPageToFit = YES;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth + UIViewAutoresizingFlexibleHeight;

    [self.view addSubview:self.webView];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initWebView];
    
    [self addRightBarButton:@selector(doClose:)];
    
    [self addLeftBarButton];
    
    if (self.urlStr && [self.urlStr length] > 0) {
        
        if (![self.urlStr hasPrefix:@"http://"]) {
            self.urlStr = [NSString stringWithFormat:@"http://%@",self.urlStr];
        }
        NSURL *url = [NSURL URLWithString:[self.urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
        
        [self.webView loadRequest:requestObj];
        
        /*
         NSURLRequest *request = [NSURLRequest requestWithURL:url
         cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
         timeoutInterval:20.0];
         [self.webView loadRequest:request];
         */
        
    }
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark - UIWebViewDelegate methods
- (void)webViewDidStartLoad:(UIWebView *)webView {
    
	[WXWUIUtils showActivityView:[APP_DELEGATE foundationView] text:LocaleStringForKey(NSLoadingTitle, nil)];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *url = [[request URL] absoluteString];
    if (url && [url length] > 0) {
        if ([url rangeOfString:NO_PAGE_URL].length > 0) {
            _sessionExpired = YES;
        }
    }
	return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    [self modifyFontSize];
    if (_sessionExpired) {
        [APP_DELEGATE openLogin:YES autoLogin:NO];
    }
    
    [WXWUIUtils closeActivityView];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)doClose:(id)sender {
    
    if (self.modalDelegate) {
        [self closeModal:sender];
    } else {
        [self close:sender];
    }
}

@end