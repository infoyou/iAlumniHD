//
//  SearchClubViewController.m
//  iAlumniHD
//
//  Created by Adam on 12-11-20.
//
//

#import "SearchClubViewController.h"
#import "ClubListViewController.h"

#define SEARCH_BAR_H        44.f

@interface SearchClubViewController ()

@end

@implementation SearchClubViewController
@synthesize closeSearchBarBut;
@synthesize searchBar;
@synthesize searchBarBGView;
@synthesize uiCascadeView;

- (id)initWithMOC:(NSManagedObjectContext *)MOC
{
    self = [super init];
    
    if (self) {
        _MOC = MOC;
    }
    
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    
    self.searchBar = nil;
    self.closeSearchBarBut = nil;
    self.searchBarBGView = nil;
    self.uiCascadeView = nil;
    
    DELETE_OBJS_FROM_MOC(_MOC, @"Club", nil);
    
    [super dealloc];
}

- (void)viewDidAppear:(BOOL)animated {
    
    if (self.searchBar != nil && ![@"" isEqualToString:self.searchBar.text]) {
        [self doCloseSearchBar:nil];
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Search Bar
    self.searchBarBGView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, LIST_WIDTH, SEARCH_BAR_H)] autorelease];
    [self.searchBarBGView setBackgroundColor:COLOR(243, 238, 225)];
    
    self.searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, LIST_WIDTH, SEARCH_BAR_H)] autorelease];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = LocaleStringForKey(NSSearchPromptTitle, nil);
    [(self.searchBar.subviews)[0]removeFromSuperview];
    [self.searchBar setBackgroundColor:TRANSPARENT_COLOR];
    
    [self.searchBarBGView addSubview:self.searchBar];
    
    self.closeSearchBarBut = [[[WXWGradientButton alloc] initWithFrame:CGRectMake(LIST_WIDTH-70.f, MARGIN, 60.f, 30.f)
                                                               target:self
                                                               action:@selector(doCloseSearchBar:)
                                                            colorType:TINY_GRAY_BTN_COLOR_TY
                                                                title:LocaleStringForKey(NSCancelTitle, nil)
                                                                image:nil
                                                           titleColor:COLOR(117, 117, 117)
                                                     titleShadowColor:GRAY_BTN_TITLE_SHADOW_COLOR
                                                            titleFont:BOLD_FONT(13)
                                                          roundedType:HAS_ROUNDED
                                                      imageEdgeInsert:ZERO_EDGE
                                                      titleEdgeInsert:ZERO_EDGE] autorelease];
    [self.searchBarBGView addSubview:self.closeSearchBarBut];
    self.closeSearchBarBut.hidden = YES;
    
    [self.view addSubview:self.searchBarBGView];
    
    // Table Cascade view
    self.uiCascadeView = [[[UICascadeView alloc] initWithFrame:CGRectMake(0, SEARCH_BAR_H, LIST_WIDTH, SCREEN_HEIGHT-(SEARCH_BAR_H*2+20.f)) tableCascadeDelegate:self] autorelease];
    
    [self.view addSubview:self.uiCascadeView];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

#pragma mark - UISearchBarDelegate method
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)aSearchBar
{
    
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)aSearchBar
{
    [super initDisableView:CGRectMake(0.0f, 44.0f, LIST_WIDTH, SCREEN_HEIGHT)];
    [self showDisableView];
    
    self.searchBar.frame = CGRectMake(0, 0, LIST_WIDTH-80.f, SEARCH_BAR_H);
    
    self.closeSearchBarBut.hidden = NO;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)aSearchBar {
    // Clear the search text
    // Deactivate the UISearchBar
    self.searchBar.text = @"";
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar {
    
    [self.searchBar resignFirstResponder];
    [AppManager instance].clubKeyWord = self.searchBar.text;
    
    [self goClubView:nil];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)aSearchBar
{
    [self.searchBar resignFirstResponder];
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)aSearchBar
{
    
}

-(void)didSelectResult:(int)leftIndex rightStr:(int)rightIndex {
    
    self.searchBar.text = @"";
    [AppManager instance].clubKeyWord = @"";
    [self goClubView:nil];
}

#pragma mark - action
- (void)doCloseSearchBar:(id)sender {

    self.searchBar.text = @"";
    self.searchBar.frame = CGRectMake(0, 0, LIST_WIDTH, SEARCH_BAR_H);
    [self.searchBar resignFirstResponder];
    
    self.closeSearchBarBut.hidden = YES;
    
    [self removeDisableView];
}

- (void)goClubView:(id)sender {
    [super close:nil];
    
    [CommonUtils doDelete:_MOC entityName:@"Club"];
    
    ClubListViewController *clubListVC = [[[ClubListViewController alloc] initWithMOC:_MOC listType:CLUB_LIST_BY_NAME] autorelease];
    
    clubListVC.title = LocaleStringForKey(NSClubTitle, nil);
    clubListVC.pageIndex = 0;
    
    [self.navigationController pushViewController:clubListVC animated:YES];
}

@end
