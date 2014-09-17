//
//  LanguageListViewController.m
//  iAlumniHD
//
//  Created by Adam on 12-11-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LanguageListViewController.h"

#define FONT_SIZE           16
#define LABEL_Y             10

@interface LanguageListViewController ()

@end

@implementation LanguageListViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        if ([CommonUtils currentLanguage] == EN_TY) {
            selectIndex = 0;
        }else {
            selectIndex = 1;
        }
    }
    return self;
}

- (void)dealloc
{
    isFirst = NO;
    [super dealloc];
}

- (void)initNavibar
{
	
    self.title = LocaleStringForKey(NSLanguageTitle,nil);
    
    self.navigationItem.leftBarButtonItem = BAR_BUTTON(LocaleStringForKey(NSCancelTitle,nil), UIBarButtonItemStyleBordered, self, @selector(close:));
    
	// done
    self.navigationItem.rightBarButtonItem = BAR_BUTTON(LocaleStringForKey(NSDoneTitle,nil), UIBarButtonItemStyleBordered, self, @selector(doSwitch:));
}

- (void)initTableView
{
    CGRect mTabFrame = CGRectMake(0, 0, LIST_WIDTH, self.view.frame.size.height);
	_tableView = [[UITableView alloc] initWithFrame:mTabFrame
                                              style:UITableViewStyleGrouped];
	
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_tableView.dataSource = self;
	_tableView.delegate = self;
	
	[self.view addSubview:_tableView];
    [super initTableView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initNavibar];
    [self initTableView];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - handle empty list
- (BOOL)listIsEmpty {
  return NO;
}

#pragma mark - table
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 2;
            break;
            
        default:
            return 0;
            break;
    }
}

-(void)configureCell:(NSIndexPath *)indexPath aCell:(UITableViewCell *)cell
{
    int row = [indexPath row];
    [cell setBackgroundColor:[UIColor whiteColor]];
    
    switch (row) {
        case 0:
        {
            // Label
            NSString *mText = @"English";
            CGSize mDescSize = [mText sizeWithFont:FONT(FONT_SIZE)];
            UILabel *mUILable = [[[UILabel alloc] initWithFrame:CGRectMake(MARGIN*2, LABEL_Y, mDescSize.width, mDescSize.height)] autorelease];
            mUILable.text = mText;
            mUILable.textColor = COLOR(82, 82, 82);
            [mUILable setBackgroundColor:TRANSPARENT_COLOR];
            mUILable.font = BOLD_FONT(13);
            mUILable.tag = row + 20;
            mUILable.highlightedTextColor = [UIColor whiteColor];
            [cell.contentView addSubview:mUILable];
        }
            break;
            
        case 1:
        {
            // Label
            NSString *mText = @"中文";
            CGSize mDescSize = [mText sizeWithFont:FONT(FONT_SIZE)];
            CGRect labelFrame = CGRectMake(MARGIN*2, LABEL_Y, mDescSize.width, mDescSize.height);
            UILabel *mUILable = [[[UILabel alloc] initWithFrame:labelFrame] autorelease];
            mUILable.text = mText;
            mUILable.textColor = COLOR(82, 82, 82);
            [mUILable setBackgroundColor:TRANSPARENT_COLOR];
            mUILable.font = BOLD_FONT(13);
            mUILable.tag = row + 20;
            mUILable.highlightedTextColor = [UIColor whiteColor];
            [cell.contentView addSubview:mUILable];
        }
            break;
            
        default:
            break;
    }
    
    if (!isFirst && selectIndex == row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        isFirst = YES;
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
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    // Configure the cell...
    [self configureCell:indexPath aCell:cell];
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    currentIndex = [indexPath row];
    
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    newCell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:(1-currentIndex)
                                                    inSection:0];
    UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:lastIndexPath];
    oldCell.accessoryType = UITableViewCellAccessoryNone;
    
    [super deselectCell];
}

#pragma mark - back

- (void)doSwitch:(id)sender{
    
    switch (currentIndex) {
        case 0:
        {
            [AppManager setEN];
        }
            break;
            
        case 1:
        {
            [AppManager setCN];
        }
            break;
            
        default:
            break;
    }
    
    [self triggerReloadForLanguageSwitch];
}

#pragma mark - AppSettingDelegate method

- (void)triggerReloadForLanguageSwitch {
    if (ZH_HANS_TY == [AppManager instance].currentLanguageCode) {
        [WXWUIUtils showActivityView:[APP_DELEGATE foundationView] text:@"正在切换语言..."];
    } else {
        [WXWUIUtils showActivityView:[APP_DELEGATE foundationView] text:@"Setting Language..."];
    }
    
    [CommonUtils setLanguage:[AppManager instance].currentLanguageDesc];
    [[AppManager instance] reloadForLanguageSwitch:self];
}

- (void)languageSwitchDone {
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2f];
    
    [UIView commitAnimations];
    
    [WXWUIUtils closeActivityView];
    
    [WXWUIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSLanguageSwitchDoneMsg, nil)
                           alternativeMsg:nil
                                  msgType:SUCCESS_TY
                       belowNavigationBar:YES];
    
    // reLogin
    [APP_DELEGATE openLogin:NO autoLogin:NO];
}

- (void)closeSpinView {
    [WXWUIUtils closeActivityView];
}

@end
