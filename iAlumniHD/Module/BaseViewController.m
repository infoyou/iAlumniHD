//
//  BaseViewController.m
//  iAlumniHD
//
//  Created by Adam on 12-12-14.
//
//

#import "BaseViewController.h"
#import "UIWebViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - web
- (void)goUrl:(NSString*)url aTitle:(NSString*)title
{
    
    int offsetY = 0;
    if ([CommonUtils is7System]) {
        offsetY = 20;
    }
    
    CGRect mFrame = CGRectMake(0, offsetY, UI_MODAL_FORM_SHEET_WIDTH, self.view.frame.size.height-offsetY);
    
    UIWebViewController *webVC = [[[UIWebViewController alloc]
                                   initWithUrl:url
                                   frame:mFrame
                                   isNeedClose:YES] autorelease];
    
    webVC.title = title;
	webVC.modalDelegate = self;
    WXWNavigationController *detailNC = [[[WXWNavigationController alloc] initWithRootViewController:webVC] autorelease];
    
	detailNC.modalPresentationStyle = UIModalPresentationPageSheet;
	[self presentModalViewController:detailNC animated:YES];
}

@end
