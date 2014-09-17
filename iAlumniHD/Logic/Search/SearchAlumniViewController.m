//
//  SearchAlumniViewController.m
//  iAlumniHD
//
//  Created by Adam on 12-10-18.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "SearchAlumniViewController.h"
#import "SelectionCriteriaList.h"
#import "UserListViewController.h"
#import "CPPopoverController.h"
#import "ClassGroup.h"
#import "Industry.h"
#import "UserCountry.h"

#define FIELD_BTN_X       130.0f
#define FIELD_WIDTH       260.0f
#define FIELD_HEIGHT      30.0f
#define LABEL_WIDTH       100.0f
#define FILL_VIEW_HEIGHT  40.0f
#define BTN_IMAGE_EDGE    UIEdgeInsetsMake(0, 210, 0.0, 10.0)
#define BTN_TEXT_EDGE     UIEdgeInsetsMake(0, -50, 0.0, 10.0)

#define FONT_SIZE         17.0f

#define CELL_SIZE         7

typedef enum {
    CLASS_TAG = 0,
    NAME_TAG,
    GENDER_TAG,
    COUNTRY_TAG,
    COMPANY_TAG,
    ADDRESS_TAG,
    INDUSTRY_TAG,
} ALUMNI_QUERY_VIEW_TAG;

static int iTableSelectIndex = -1;

@interface SearchAlumniViewController()
@property (nonatomic, copy) NSString *selectedGender;
@property (nonatomic, retain) UIBezierPath *shadowPath;
@property (nonatomic, retain) UserCountry *selectedCountry;
@property (nonatomic, retain) ClassGroup *selectedClass;
@property (nonatomic, retain) Industry *selectedIndustry;
@property (nonatomic, copy) NSString *loadAlumniParam;
@end

@implementation SearchAlumniViewController

@synthesize shadowPath = _shadowPath;
@synthesize selectedGender = _selectedGender;
@synthesize selectedCountry = _selectedCountry;
@synthesize selectedClass = _selectedClass;
@synthesize selectedIndustry = _selectedIndustry;
@synthesize loadAlumniParam = _loadAlumniParam;
@synthesize classFliters;
@synthesize _TableCellShowValArray;
@synthesize _TableCellSaveValArray;

- (id)initWithMOC:(NSManagedObjectContext *)MOC {
    
    self = [super initWithMOC:MOC];
    
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearAlumniList)
                                                     name:CLEAR_ALUMNI_LIST_NOTIFY
                                                   object:nil];
        
        
        _TableCellShowValArray = [[NSMutableArray alloc] init];
        _TableCellSaveValArray = [[NSMutableArray alloc] init];
        for (NSUInteger i=0; i<CELL_SIZE; i++) {
            [_TableCellShowValArray addObject:[NSString stringWithFormat:@"%d",iOriginalSelIndexVal]];
            [_TableCellSaveValArray addObject:[NSString stringWithFormat:@"%@",@""]];
        }

        [super clearPickerSelIndex2Init:4];
        
        [self clearFliter];
    }
    return self;
}

- (void)dealloc {
    
    self.shadowPath = nil;
    self.selectedGender = nil;
    self.selectedClass = nil;
    self.selectedCountry = nil;
    self.selectedIndustry = nil;
    self.loadAlumniParam = nil;
    
    RELEASE_OBJ(_nameField);
    RELEASE_OBJ(_companyField);
    RELEASE_OBJ(_companyAddressField);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CLEAR_ALUMNI_LIST_NOTIFY object:nil];
    
    [[AppManager instance].imageCache clearAllCachedImages];
    
    [CommonUtils unLoadObject:_MOC predicate:nil entityName:@"ClassGroup"];
    [CommonUtils unLoadObject:_MOC predicate:nil entityName:@"UserCountry"];
    [CommonUtils unLoadObject:_MOC predicate:nil entityName:@"Industry"];
    
    [AppManager instance].isLoadClassDataOK = NO;
    [AppManager instance].isLoadIndustryDataOK = NO;
    [AppManager instance].isLoadCountryDataOK = NO;
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Pop Interaction
-(void)onDropDown:(UIButton *)sender
{

    [_nameField resignFirstResponder];
    [_companyField resignFirstResponder];
    [_companyAddressField resignFirstResponder];
    
    iTableSelectIndex = [sender tag];
    
    if (sender.tag != INDUSTRY_TAG) {
        _UIPopoverArrowDirection = UIPopoverArrowDirectionUp;
    } else {
        _UIPopoverArrowDirection = UIPopoverArrowDirectionDown;
    }
    
    [super setPopView];
    
    [_popViewController presentPopoverFromRect:CGRectMake(sender.frame.origin.x, sender.frame.origin.y, sender.frame.size.width, TOOLBAR_HEIGHT)
                                        inView:self.view
                      permittedArrowDirections:UIPopoverArrowDirectionAny
                                      animated:YES];
}

-(void)onPopCancle:(id)sender {
    [super onPopCancle];
    
    [_TableCellShowValArray removeObjectAtIndex:iTableSelectIndex];
    [_TableCellShowValArray insertObject:[NSString stringWithFormat:@"%d",iOriginalSelIndexVal] atIndex:iTableSelectIndex];
    
    [_TableCellSaveValArray removeObjectAtIndex:iTableSelectIndex];
    [_TableCellSaveValArray insertObject:@"" atIndex:iTableSelectIndex];
    
    [_tableView reloadData];
}

-(void)onPopOk:(id)sender {
    
    [super onPopSelectedOk];
    int iPickSelectIndex = [super pickerList0Index];

    if ( iTableSelectIndex == 0 ) {
        [self setTableCellVal:iTableSelectIndex aShowVal:[[self.classFliters objectAtIndex:pickSel1Index] objectAtIndex:1]
                     aSaveVal:[[self.classFliters objectAtIndex:pickSel1Index] objectAtIndex:0] isFresh:YES];
    } else {
        [self setTableCellVal:iTableSelectIndex aShowVal:[[self.DropDownValArray objectAtIndex:iPickSelectIndex] objectAtIndex:1]
                     aSaveVal:[[self.DropDownValArray objectAtIndex:iPickSelectIndex] objectAtIndex:0] isFresh:YES];
    }
}

#pragma mark - Save TableCell Value
-(void)setTableCellVal:(int)index aShowVal:(NSString*)aShowVal aSaveVal:(NSString*)aSaveVal isFresh:(BOOL)isFresh
{
    [_TableCellShowValArray removeObjectAtIndex:index];
    [_TableCellShowValArray insertObject:aShowVal atIndex:index];
    
    [_TableCellSaveValArray removeObjectAtIndex:index];
    [_TableCellSaveValArray insertObject:aSaveVal atIndex:index];
    
    switch (index) {
        case CLASS_TAG:
        {
            [self selectClass:aShowVal];
        }
            break;
            
        case GENDER_TAG:
        {
            [self selectGender:aShowVal];
        }
            break;
            
        case COUNTRY_TAG:
        {
            [self selectCountry:aShowVal];
        }
            break;

        case INDUSTRY_TAG:
        {
            [self selectIndustry:aShowVal];
        }
            break;

            
        default:
            break;
    }
}

#pragma mark - condition selection
- (void)selectClass:(NSString *)className {
    
    if (className) {
        [_classSelectBtn setTitle:className forState:UIControlStateNormal];
    } else {
        [_classSelectBtn setTitle:LocaleStringForKey(NSPleaseSelectTitle, nil) forState:UIControlStateNormal];
    }
    
}

- (void)selectGender:(NSString *)gender {
    self.selectedGender = gender;
    
    NSString *title = nil;
    if (gender && [gender length] > 0) {
        if ([MALE isEqualToString:gender]) {
            title = LocaleStringForKey(NSMaleTitle, nil);
        } else if ([FEMALE isEqualToString:gender]) {
            title = LocaleStringForKey(NSFemaleTitle, nil);
        }
    } else {
        title = LocaleStringForKey(NSPleaseSelectTitle, nil);
    }
    
    [_genderSelectBtn setTitle:title forState:UIControlStateNormal];
}

- (void)showGenderList:(id)sender {
    [_nameField resignFirstResponder];
    [_companyField resignFirstResponder];
    [_companyAddressField resignFirstResponder];
    
    SelectionCriteriaList *criteriaList = [[[SelectionCriteriaList alloc] initWithFrame:CGRectMake(0, 0, 100, 100)
                                                                                    MOC:_MOC
                                                                               itemType:GENDER_TY
                                                                                 target:self
                                                                     itemSelectedAction:@selector(selectGender:)
                                                                    currentSelectedItem:self.selectedGender] autorelease];
    _popoverView = nil;
    _popoverView = [CPPopoverController popoverForViewController:criteriaList];
    criteriaList._popController = _popoverView;
    [_popoverView presentPopoverFromView:sender];
}

- (void)selectCountry:(NSString *)country {

    if (country) {
        [_countrySelectBtn setTitle:country forState:UIControlStateNormal];
    } else {
        [_countrySelectBtn setTitle:LocaleStringForKey(NSPleaseSelectTitle, nil) forState:UIControlStateNormal];
    }
}

- (void)selectIndustry:(NSString *)industry {

    if (industry) {
        
        [_industrySelectBtn setTitle:industry forState:UIControlStateNormal];
        
    } else {
        [_industrySelectBtn setTitle:LocaleStringForKey(NSPleaseSelectTitle, nil) forState:UIControlStateNormal];
    }
}

#pragma mark - query action
- (void)clearAlumniList {
    // why this method
    //    RELEASE_OBJ(_alumniListVC);
}

- (void)doClear:(id)sender {
    
    [self selectClass:nil];
    [self selectCountry:nil];
    [self selectGender:nil];
    [self selectIndustry:nil];
    
    _nameField.text = @"";
    _companyField.text = @"";
    _companyAddressField.text = @"";
    
    for (NSUInteger i=0; i<CELL_SIZE; i++) {
        [_TableCellShowValArray insertObject:[NSString stringWithFormat:@"%d",iOriginalSelIndexVal] atIndex:i];
        [_TableCellSaveValArray insertObject:[NSString stringWithFormat:@"%@",@""] atIndex:i];
    }
}

- (void)doQuery:(id)sender {
    
    if (nil == self.selectedGender || [self.selectedGender length] == 0) {
        self.selectedGender = [[[NSString alloc] initWithString:@""] autorelease];
    }
    if (nil == self.selectedCountry.countryId || [self.selectedCountry.countryId length] == 0) {
        self.selectedCountry.countryId = [[[NSString alloc] initWithString:@""] autorelease];
    }
    if (nil == self.selectedClass.classId || [self.selectedClass.classId length] == 0) {
        self.selectedClass.classId = [[[NSString alloc] initWithString:@""] autorelease];
    }
    if (nil == self.selectedIndustry.industryId || [self.selectedIndustry.industryId length] == 0) {
        self.selectedIndustry.industryId = [[[NSString alloc] initWithString:@""] autorelease];
    }
    if (nil == _nameField.text || [_nameField.text length] == 0) {
        _nameField.text = [[[NSString alloc] initWithString:@""] autorelease];
    }
    if (nil == _companyField.text || [_companyField.text length] == 0) {
        _companyField.text = [[[NSString alloc] initWithString:@""] autorelease];
    }
    if (nil == _companyAddressField.text || [_companyAddressField.text length] == 0) {
        _companyAddressField.text = [[[NSString alloc] initWithString:@""] autorelease];
    }
    
    [[AppManager instance].imageCache clearAllCachedImages];
    
    NSString *param = [NSString stringWithFormat:
                       @"<classId>%@</classId><name>%@</name><gender>%@</gender><nationality>%@</nationality><company>%@</company><companyLocation>%@</companyLocation><industry>%@</industry><page>0</page><grade></grade><course></course>",
                       [_TableCellSaveValArray objectAtIndex:CLASS_TAG],
                       _nameField.text,
                       self.selectedGender,
                       [_TableCellSaveValArray objectAtIndex:COUNTRY_TAG],
                       _companyField.text,
                       _companyAddressField.text,
                       [_TableCellSaveValArray objectAtIndex:INDUSTRY_TAG]];
    
    self.loadAlumniParam = param;
    
    [_nameField resignFirstResponder];
    [_companyField resignFirstResponder];
    [_companyAddressField resignFirstResponder];
    
    [self gotoAlumniList];
}

- (void)gotoAlumniList
{
    [CommonUtils doDelete:_MOC entityName:@"Alumni"];
    
    //-----------
    UserListViewController *userListVC = [[[UserListViewController alloc] initWithType:ALUMNI_TY needGoToHome:YES MOC:_MOC] autorelease];
    userListVC.pageIndex = 0;
    userListVC.requestParam = self.loadAlumniParam;
    userListVC.title = LocaleStringForKey(NSAlumniTitle, nil);
    //-----------
    
    WXWNavigationController *mNC = [[[WXWNavigationController alloc] initWithRootViewController:userListVC] autorelease];
    
    [APP_DELEGATE addViewInSlider:mNC
               invokeByController:self
                   stackStartView:NO];
}

#pragma mark - UITextField delegate methods
- (void)arrangeViewsForMoveup {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.1f];
    
    self.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(self.shadowPath.bounds.origin.x,
                                                                  self.shadowPath.bounds.origin.y + _animatedDistance,
                                                                  self.shadowPath.bounds.size.width,
                                                                  self.shadowPath.bounds.size.height)];
    self.view.layer.shadowPath = self.shadowPath.CGPath;
    [UIView commitAnimations];
}

- (void)moveupViews:(UITextField *)textField {
	
    CGRect viewRect = [self.view.window convertRect:self.view.bounds fromView:self.view];
	
    CGFloat numerator = 131.399f;
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
	CGFloat heightFraction = numerator / denominator;
	
	if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
	
    _animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= _animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(arrangeViewsForMoveup)];
    
    self.view.frame = viewFrame;
    _shieldView.frame = CGRectMake(_shieldView.frame.origin.x,
                                   _shieldView.frame.origin.y + _animatedDistance,
                                   _shieldView.frame.size.width,
                                   _shieldView.frame.size.height);
    
    self.view.layer.borderColor = TRANSPARENT_COLOR.CGColor;
    _classTitleLabel.hidden = YES;
    _classSelectBtn.hidden = YES;
    
    [UIView commitAnimations];
    
    _currentMovedup = YES;
}

- (void)recoverViews {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.1f];
    self.view.layer.borderColor = COLOR(201, 201, 201).CGColor;
    _classTitleLabel.hidden = NO;
    _classSelectBtn.hidden = NO;
    _shieldView.frame = CGRectMake(_shieldView.frame.origin.x,
                                   _shieldView.frame.origin.y - _animatedDistance,
                                   _shieldView.frame.size.width,
                                   _shieldView.frame.size.height);
    
    self.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(self.shadowPath.bounds.origin.x,
                                                                  self.shadowPath.bounds.origin.y - _animatedDistance,
                                                                  self.shadowPath.bounds.size.width,
                                                                  self.shadowPath.bounds.size.height)];
    self.view.layer.shadowPath = self.shadowPath.CGPath;
    
    [UIView commitAnimations];
}

- (void)movebackViews {
    CGRect viewFrame = self.view.frame;
	
    viewFrame.origin.y += _animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(recoverViews)];
    
    self.view.frame = viewFrame;
    
    [UIView commitAnimations];
    
    _currentMovedup = NO;
    _manualHideKeyboard = NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    if ([CommonUtils currentOrientation] == UIDeviceOrientationPortrait
        || [CommonUtils currentOrientation] == UIDeviceOrientationPortraitUpsideDown
        || _currentMovedup) {
        return;
    }
    
    if (textField.tag != NAME_TAG) {
        [self moveupViews:textField];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    _manualHideKeyboard = YES;
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([CommonUtils currentOrientation] == UIDeviceOrientationPortrait
        || [CommonUtils currentOrientation] == UIDeviceOrientationPortraitUpsideDown
        || !_manualHideKeyboard) {
        return;
    }
    
    if (textField.tag != NAME_TAG) {
        [self movebackViews];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    _manualHideKeyboard = YES;
    [textField resignFirstResponder];
    [self doQuery:nil];
    return YES;
}

- (void)hideKeyboard:(id)sender {
    _manualHideKeyboard = YES;
    [sender resignFirstResponder];
}

#pragma mark - life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadAlumniInfoIfNeeded];

    self.view.backgroundColor = CELL_COLOR;
    
    CGFloat shortLabel_x = 20;
    
    _classTitleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(shortLabel_x, 60.f, LABEL_WIDTH, FIELD_HEIGHT)] autorelease];
    _classTitleLabel.backgroundColor = TRANSPARENT_COLOR;
    _classTitleLabel.font = FONT(FONT_SIZE);
    
    if([AppManager instance].currentLanguageCode == EN_TY) {
        _classTitleLabel.textAlignment = UITextAlignmentRight;
    } else {
        _classTitleLabel.textAlignment = UITextAlignmentCenter;
    }
    _classTitleLabel.shadowColor = [UIColor whiteColor];
    _classTitleLabel.shadowOffset = CGSizeMake(0, 1.0f);
    _classTitleLabel.text = LocaleStringForKey(NSClassQueryTitle, nil);
    [self.view addSubview:_classTitleLabel];
    
    _classSelectBtn = [[[WXWGradientButton alloc] initWithFrame:CGRectMake(FIELD_BTN_X, _classTitleLabel.frame.origin.y, FIELD_WIDTH, FILL_VIEW_HEIGHT)
                                                      target:self
                                                      action:@selector(onDropDown:)
                                                   colorType:LIGHT_GRAY_BTN_COLOR_TY
                                                       title:LocaleStringForKey(NSPleaseSelectTitle, nil)
                                                       image:[UIImage imageNamed:@"downArrow.png"]
                                                  titleColor:LIGHT_GRAY_BTN_TITLE_COLOR
                                            titleShadowColor:LIGHT_GRAY_BTN_TITLE_SHADOW_COLOR
                                                   titleFont:FONT(FONT_SIZE)
                                                roundedType:HAS_ROUNDED
                                             imageEdgeInsert:BTN_IMAGE_EDGE
                                             titleEdgeInsert:BTN_TEXT_EDGE] autorelease];
    _classSelectBtn.tag = CLASS_TAG;
    [self.view addSubview:_classSelectBtn];
    
    UILabel *nameTitleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(shortLabel_x, _classTitleLabel.frame.origin.y + FIELD_HEIGHT + MARGIN * 6, LABEL_WIDTH, FIELD_HEIGHT)] autorelease];
    
    nameTitleLabel.backgroundColor = TRANSPARENT_COLOR;
    nameTitleLabel.font = FONT(FONT_SIZE);
    if([AppManager instance].currentLanguageCode == EN_TY) {
        nameTitleLabel.textAlignment = UITextAlignmentRight;
    } else {
        nameTitleLabel.textAlignment = UITextAlignmentCenter;
    }
    nameTitleLabel.shadowColor = [UIColor whiteColor];
    nameTitleLabel.shadowOffset = CGSizeMake(0, 1.0f);
    nameTitleLabel.text = LocaleStringForKey(NSNameTitle, nil);
    [self.view addSubview:nameTitleLabel];
    
    _nameField = [[UITextField alloc] initWithFrame:CGRectMake(FIELD_BTN_X, nameTitleLabel.frame.origin.y, FIELD_WIDTH, FILL_VIEW_HEIGHT - MARGIN)];
    _nameField.backgroundColor = TRANSPARENT_COLOR;
    _nameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _nameField.returnKeyType = UIReturnKeySearch;
    _nameField.font = FONT(FONT_SIZE);
    _nameField.borderStyle = UITextBorderStyleRoundedRect;
    _nameField.delegate = self;
    _nameField.tag = NAME_TAG;
    _nameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter; 
    [_nameField addTarget:self
                   action:@selector(hideKeyboard:)
         forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.view addSubview:_nameField];
    
    UILabel *genderTitleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(shortLabel_x, nameTitleLabel.frame.origin.y + FIELD_HEIGHT + MARGIN * 6, LABEL_WIDTH, FIELD_HEIGHT)] autorelease];
    genderTitleLabel.backgroundColor = TRANSPARENT_COLOR;
    genderTitleLabel.font = FONT(FONT_SIZE);
    if([AppManager instance].currentLanguageCode == EN_TY) {
        genderTitleLabel.textAlignment = UITextAlignmentRight;
    } else {
        genderTitleLabel.textAlignment = UITextAlignmentCenter;
    }
    genderTitleLabel.shadowColor = [UIColor whiteColor];
    genderTitleLabel.shadowOffset = CGSizeMake(0, 1.0f);
    genderTitleLabel.text = LocaleStringForKey(NSGenderTitle, nil);
    [self.view addSubview:genderTitleLabel];
    
    _genderSelectBtn = [[[WXWGradientButton alloc] initWithFrame:CGRectMake(FIELD_BTN_X, genderTitleLabel.frame.origin.y, FIELD_WIDTH, FILL_VIEW_HEIGHT)
                                                       target:self
                                                       action:@selector(showGenderList:)
                                                    colorType:LIGHT_GRAY_BTN_COLOR_TY
                                                        title:LocaleStringForKey(NSPleaseSelectTitle, nil)
                                                        image:[UIImage imageNamed:@"downArrow.png"]
                                                   titleColor:LIGHT_GRAY_BTN_TITLE_COLOR
                                             titleShadowColor:LIGHT_GRAY_BTN_TITLE_SHADOW_COLOR
                                                    titleFont:FONT(FONT_SIZE)
                                                 roundedType:HAS_ROUNDED
                                              imageEdgeInsert:BTN_IMAGE_EDGE
                                              titleEdgeInsert:BTN_TEXT_EDGE] autorelease];
    _genderSelectBtn.tag = GENDER_TAG;
    [self.view addSubview:_genderSelectBtn];
    
    UILabel *countryTitlelabel = [[[UILabel alloc] initWithFrame:CGRectMake(shortLabel_x, genderTitleLabel.frame.origin.y + FIELD_HEIGHT + MARGIN * 6, LABEL_WIDTH, FIELD_HEIGHT)] autorelease];
    countryTitlelabel.backgroundColor = TRANSPARENT_COLOR;
    countryTitlelabel.font = FONT(FONT_SIZE);
    if([AppManager instance].currentLanguageCode == EN_TY) {
        countryTitlelabel.textAlignment = UITextAlignmentRight;
    } else {
        countryTitlelabel.textAlignment = UITextAlignmentCenter;
    }
    countryTitlelabel.shadowColor = [UIColor whiteColor];
    countryTitlelabel.shadowOffset = CGSizeMake(0, 1.0f);
    countryTitlelabel.text = LocaleStringForKey(NSCountryTitle, nil);
    [self.view addSubview:countryTitlelabel];
    
    _countrySelectBtn = [[[WXWGradientButton alloc] initWithFrame:CGRectMake(FIELD_BTN_X, countryTitlelabel.frame.origin.y, FIELD_WIDTH, FILL_VIEW_HEIGHT)
                                                        target:self
                                                        action:@selector(onDropDown:)
                                                     colorType:LIGHT_GRAY_BTN_COLOR_TY
                                                         title:LocaleStringForKey(NSPleaseSelectTitle, nil)
                                                         image:[UIImage imageNamed:@"downArrow.png"]
                                                    titleColor:LIGHT_GRAY_BTN_TITLE_COLOR
                                              titleShadowColor:LIGHT_GRAY_BTN_TITLE_SHADOW_COLOR
                                                     titleFont:FONT(FONT_SIZE)
                                                  roundedType:HAS_ROUNDED
                                               imageEdgeInsert:BTN_IMAGE_EDGE
                                               titleEdgeInsert:BTN_TEXT_EDGE] autorelease];
    _countrySelectBtn.tag = COUNTRY_TAG;
    [self.view addSubview:_countrySelectBtn];
    
    UILabel *companyTitlelabel = [[[UILabel alloc] initWithFrame:CGRectMake(shortLabel_x, countryTitlelabel.frame.origin.y + FIELD_HEIGHT + MARGIN * 6, LABEL_WIDTH, FIELD_HEIGHT)] autorelease];
    companyTitlelabel.backgroundColor = TRANSPARENT_COLOR;
    companyTitlelabel.font = FONT(FONT_SIZE);
    if([AppManager instance].currentLanguageCode == EN_TY) {
        companyTitlelabel.textAlignment = UITextAlignmentRight;
    } else {
        companyTitlelabel.textAlignment = UITextAlignmentCenter;
    }
    companyTitlelabel.shadowColor = [UIColor whiteColor];
    companyTitlelabel.shadowOffset = CGSizeMake(0, 1.0f);
    companyTitlelabel.text = LocaleStringForKey(NSCompanyTitle, nil);
    [self.view addSubview:companyTitlelabel];
    
    _companyField = [[UITextField alloc] initWithFrame:CGRectMake(FIELD_BTN_X, companyTitlelabel.frame.origin.y, FIELD_WIDTH, FILL_VIEW_HEIGHT - MARGIN)];
    _companyField.backgroundColor = TRANSPARENT_COLOR;
    _companyField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _companyField.returnKeyType = UIReturnKeySearch;
    _companyField.font = FONT(FONT_SIZE);
    _companyField.borderStyle = UITextBorderStyleRoundedRect;
    _companyField.delegate = self;
    _companyField.tag = COMPANY_TAG;
    _companyField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter; 
    [_companyField addTarget:self
                      action:@selector(hideKeyboard:)
            forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.view addSubview:_companyField];
    
    UILabel *companyAddressTitlelabel = [[[UILabel alloc] initWithFrame:CGRectMake(shortLabel_x, companyTitlelabel.frame.origin.y + FIELD_HEIGHT + MARGIN * 6, LABEL_WIDTH, FIELD_HEIGHT)] autorelease];
    companyAddressTitlelabel.backgroundColor = TRANSPARENT_COLOR;
    companyAddressTitlelabel.font = FONT(FONT_SIZE);
    if([AppManager instance].currentLanguageCode == EN_TY) {
        companyAddressTitlelabel.textAlignment = UITextAlignmentRight;
    } else {
        companyAddressTitlelabel.textAlignment = UITextAlignmentCenter;
    }
    companyAddressTitlelabel.shadowColor = [UIColor whiteColor];
    companyAddressTitlelabel.shadowOffset = CGSizeMake(0, 1.0f);
    companyAddressTitlelabel.text = LocaleStringForKey(NSCompanyAddressTitle, nil);
    [self.view addSubview:companyAddressTitlelabel];
    
    _companyAddressField = [[UITextField alloc] initWithFrame:CGRectMake(FIELD_BTN_X, companyAddressTitlelabel.frame.origin.y, FIELD_WIDTH, FILL_VIEW_HEIGHT - MARGIN)];
    _companyAddressField.backgroundColor = TRANSPARENT_COLOR;
    _companyAddressField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _companyAddressField.returnKeyType = UIReturnKeySearch;
    _companyAddressField.font = FONT(FONT_SIZE);
    _companyAddressField.borderStyle = UITextBorderStyleRoundedRect;
    _companyAddressField.delegate = self;
    _companyAddressField.tag = COMPANY_TAG;
    _companyAddressField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter; 
    [_companyAddressField addTarget:self
                             action:@selector(hideKeyboard:)
                   forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.view addSubview:_companyAddressField];
    
    UILabel *industryTitlelabel = [[[UILabel alloc] initWithFrame:CGRectMake(shortLabel_x, companyAddressTitlelabel.frame.origin.y + FIELD_HEIGHT + MARGIN * 6, LABEL_WIDTH, FIELD_HEIGHT)] autorelease];
    industryTitlelabel.backgroundColor = TRANSPARENT_COLOR;
    industryTitlelabel.font = FONT(FONT_SIZE);
    if([AppManager instance].currentLanguageCode == EN_TY) {
        industryTitlelabel.textAlignment = UITextAlignmentRight;
    } else {
        industryTitlelabel.textAlignment = UITextAlignmentCenter;
    }
    industryTitlelabel.shadowColor = [UIColor whiteColor];
    industryTitlelabel.shadowOffset = CGSizeMake(0, 1.0f);
    industryTitlelabel.text = LocaleStringForKey(NSIndustryTitle, nil);
    [self.view addSubview:industryTitlelabel];
    
    _industrySelectBtn = [[[WXWGradientButton alloc] initWithFrame:CGRectMake(FIELD_BTN_X, industryTitlelabel.frame.origin.y, FIELD_WIDTH, FILL_VIEW_HEIGHT)
                                                         target:self
                                                         action:@selector(onDropDown:)
                                                      colorType:LIGHT_GRAY_BTN_COLOR_TY
                                                          title:LocaleStringForKey(NSPleaseSelectTitle, nil)
                                                          image:[UIImage imageNamed:@"downArrow.png"]
                                                     titleColor:LIGHT_GRAY_BTN_TITLE_COLOR
                                               titleShadowColor:LIGHT_GRAY_BTN_TITLE_SHADOW_COLOR
                                                      titleFont:FONT(FONT_SIZE)
                                                   roundedType:HAS_ROUNDED
                                                imageEdgeInsert:BTN_IMAGE_EDGE
                                                titleEdgeInsert:BTN_TEXT_EDGE] autorelease];
    _industrySelectBtn.tag = INDUSTRY_TAG;
    [self.view addSubview:_industrySelectBtn];
    
    CGRect clearFrame = CGRectMake(45.f, _industrySelectBtn.frame.origin.y + 75.f, 100.f, FILL_VIEW_HEIGHT);
    WXWGradientButton *mClearBut = [[[WXWGradientButton alloc] initWithFrame:clearFrame
                                                                target:self
                                                                action:@selector(doClear:)
                                                             colorType:WHITE_BTN_COLOR_TY
                                                                 title:LocaleStringForKey(NSClearTitle, nil)
                                                                 image:nil
                                                            titleColor:BLACK_BTN_TITLE_SHADOW_COLOR
                                                      titleShadowColor:BLACK_BTN_TITLE_COLOR
                                                             titleFont:BOLD_FONT(FONT_SIZE)
                                                        roundedType:HAS_ROUNDED
                                                       imageEdgeInsert:ZERO_EDGE
                                                       titleEdgeInsert:ZERO_EDGE] autorelease];
    [self.view addSubview:mClearBut];
    
    CGRect queryFrame = CGRectMake(290.f, clearFrame.origin.y, 100, FILL_VIEW_HEIGHT);
    WXWGradientButton *mQueryBut = [[[WXWGradientButton alloc] initWithFrame:queryFrame
                                                                target:self
                                                                action:@selector(doQuery:)
                                                             colorType:RED_BTN_COLOR_TY
                                                                 title:LocaleStringForKey(NSQueryTitle, nil)
                                                                 image:nil
                                                            titleColor:BLUE_BTN_TITLE_COLOR
                                                      titleShadowColor:BLUE_BTN_TITLE_SHADOW_COLOR
                                                             titleFont:BOLD_FONT(FONT_SIZE)
                                                        roundedType:HAS_ROUNDED
                                                       imageEdgeInsert:ZERO_EDGE
                                                       titleEdgeInsert:ZERO_EDGE] autorelease];
    [self.view addSubview:mQueryBut];
    
    self.title = LocaleStringForKey(NSAlumniSearchTitle, nil);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if ([WXWUIUtils activityViewIsAnimating]) {
        [WXWUIUtils closeActivityView];
    }
}

#pragma mark - Base Data
- (void)getAlumniClass {
    
    NSString *url = ALUMNI_CLASS_REQ_URL;
    
    WXWAsyncConnectorFacade *connector = [self setupAsyncConnectorForUrl:url
                                                            contentType:CLASS_TY];
    
    [connector asyncGet:url showAlertMsg:YES];
}

- (void) getAlumniNationality {
    
    NSString *url = ALUMNI_NATION_REQ_URL;

    WXWAsyncConnectorFacade *connector = [self setupAsyncConnectorForUrl:url
                                                            contentType:COUNTRY_TY];
    
    [connector asyncGet:url showAlertMsg:YES];
}

- (void) getIndustry {
    NSString *url = ALUMNI_INDUSTRY_REQ_URL;

    WXWAsyncConnectorFacade *connector = [self setupAsyncConnectorForUrl:url
                                                            contentType:INDUSTRY_TY];
    
    [connector asyncGet:url showAlertMsg:YES];
}

- (void)loadAlumniInfoIfNeeded {
    
    if (![AppManager instance].isLoadClassDataOK) {
        [self getAlumniClass];
    } else if (![AppManager instance].isLoadCountryDataOK) {
        [self getAlumniNationality];
    } else if (![AppManager instance].isLoadIndustryDataOK) {
        [self getIndustry];
    }
}

#pragma mark - WXWConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(WebItemType)contentType
{
    [WXWUIUtils showActivityView:[APP_DELEGATE foundationView] text:LocaleStringForKey(NSLoadingTitle, nil)];
    [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(WebItemType)contentType
{
    [WXWUIUtils closeActivityView];
    
    switch (contentType) {
        case CLASS_TY:
        {
            if([XMLParser parserSyncResponseXml:result
                                           type:FETCH_CLASS_SRC
                                            MOC:_MOC]) {
                [self getAlumniNationality];
            } else {

                [WXWUIUtils showNotificationWithMsg:LocaleStringForKey(NSActionFaildMsg, nil)
                                         msgType:ERROR_TY
                                      holderView:[APP_DELEGATE foundationView]];
            }
        }
            break;
            
        case COUNTRY_TY:
        {
            if([XMLParser parserSyncResponseXml:result
                                           type:FETCH_COUNTRY_SRC
                                            MOC:_MOC]) {
                [self getIndustry];
            } else {
                [WXWUIUtils showNotificationWithMsg:LocaleStringForKey(NSActionFaildMsg, nil)
                                         msgType:ERROR_TY
                                      holderView:[APP_DELEGATE foundationView]];
            }
        }
            break;
            
        case INDUSTRY_TY:
        {
            if([XMLParser parserSyncResponseXml:result
                                           type:FETCH_INDUSTRY_SRC
                                            MOC:_MOC]) {
            } else {
                [WXWUIUtils showNotificationWithMsg:LocaleStringForKey(NSActionFaildMsg, nil)
                                         msgType:ERROR_TY
                                      holderView:[APP_DELEGATE foundationView]];
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

#pragma mark - UIPickerViewDelegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (iTableSelectIndex == 0) {
        if (component == PickerOne) {
            pickSel0Index = row;
            self.classFliters = [[AppManager instance].classFilterList objectAtIndex:row];
            [_PickerView selectRow:0 inComponent:PickerTwo animated:YES];
            [_PickerView reloadComponent:PickerTwo];
            pickSel1Index = 0;
        }
        
        if (component == PickerTwo){
            pickSel1Index = row;
        }
    } else {
        pickSel0Index = row;
    }
    
    isPickSelChange = YES;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (iTableSelectIndex == 0) {
        return 2;
    }
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (iTableSelectIndex == 0) {
        if (component == PickerOne)
            return [[AppManager instance].supClassFilterList count];
        return [self.classFliters count];
    }
    return [_PickData count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (iTableSelectIndex == 0) {
        if (component == PickerOne)
            return [[[AppManager instance].supClassFilterList objectAtIndex:row] objectAtIndex:1];
        return [[self.classFliters objectAtIndex:row] objectAtIndex:1];
    }
    return [_PickData objectAtIndex:row];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    CGFloat componentWidth = _frame.size.width;
    
    if (iTableSelectIndex == 0) {
        if (component == 0) {
            componentWidth = FIRST_PICKER_WIDTH;
        }else {
            componentWidth = _frame.size.width - FIRST_PICKER_WIDTH;
        }
        return componentWidth;
    }
    
    return componentWidth;
}

- (void)clearFliter
{
    // Clear Fliter
    [[AppManager instance].supClassFilterList removeAllObjects];
    [AppManager instance].supClassFilterList = nil;
    [[AppManager instance].classFilterList removeAllObjects];
    [AppManager instance].classFilterList = nil;
    [AppManager instance].classFliterLoaded = NO;
}

- (void)setDropDownValueArray {
    
    [NSFetchedResultsController deleteCacheWithName:nil];
    
    self.descriptors = [NSMutableArray array];
    self.DropDownValArray = [[[NSMutableArray alloc] init] autorelease];
    switch (iTableSelectIndex) {
        case 0:
        {
            iFliterIndex = 0;
            if ([AppManager instance].classFliterLoaded) {
                pickSel0Index = [super pickerList0Index];
                self.classFliters = [[AppManager instance].classFilterList objectAtIndex:pickSel0Index];
                return;
            }
            
            NSSortDescriptor *courseDesc = [[[NSSortDescriptor alloc] initWithKey:@"enCourse" ascending:YES] autorelease];
            [self.descriptors addObject:courseDesc];
            
            NSSortDescriptor *classDesc = [[[NSSortDescriptor alloc] initWithKey:@"classId" ascending:YES] autorelease];
            [self.descriptors addObject:classDesc];
            
            self.entityName = @"ClassGroup";
            
            NSError *error = nil;
            BOOL res = [[super prepareFetchRC] performFetch:&error];
            if (!res) {
                NSAssert1(0, @"Unhandled error performing fetch: %@", [error localizedDescription]);
            }
            
            NSArray *classDetail = [CommonUtils objectsInMOC:_MOC
                                                  entityName:self.entityName
                                                sortDescKeys:self.descriptors
                                                   predicate:nil];
            
            int size = [classDetail count];
            int supIndex = 0;
            
            [AppManager instance].supClassFilterList = [NSMutableArray array];
            [AppManager instance].classFilterList = [NSMutableArray array];
            
            for (NSUInteger i=0; i<size; i++) {
                ClassGroup* mClassGroup = (ClassGroup*)[classDetail objectAtIndex:i];
                
                NSMutableArray *supClassesArray = [NSMutableArray arrayWithObjects:mClassGroup.enCourse, mClassGroup.cnCourse, nil];
                
                NSMutableArray *detailArray = [NSMutableArray arrayWithObjects:mClassGroup.classId, mClassGroup.enName, mClassGroup.cnName, nil];
                
                if (![[AppManager instance].supClassFilterList containsObject:supClassesArray]) {
                    [[AppManager instance].supClassFilterList insertObject:supClassesArray atIndex:supIndex];
                    NSMutableArray *classesArray = [NSMutableArray array];
                    [classesArray insertObject:detailArray atIndex:0];
                    [[AppManager instance].classFilterList insertObject:classesArray atIndex:supIndex];
                    supIndex++;
                } else {
                    int keyIndex = [[AppManager instance].supClassFilterList indexOfObject:supClassesArray];
                    NSMutableArray *classesArray = [[AppManager instance].classFilterList objectAtIndex:keyIndex];
                    
                    int targetIndex = [classesArray count];
                    [classesArray insertObject:detailArray atIndex:targetIndex];
                    [[AppManager instance].classFilterList removeObjectAtIndex:keyIndex];
                    [[AppManager instance].classFilterList insertObject:classesArray atIndex:keyIndex];
                }
                
            }
            
            [AppManager instance].classFliterLoaded = YES;
            self.classFliters = [[AppManager instance].classFilterList objectAtIndex:0];
        }
            break;
            
        case 2:
        {
            iFliterIndex = 1;
            NSMutableArray *line0Array = [[NSMutableArray alloc] init];
            [line0Array insertObject:FEMALE atIndex:0];
            [line0Array insertObject:LocaleStringForKey(NSFemaleTitle, nil) atIndex:1];
            [self.DropDownValArray insertObject:line0Array atIndex:0];
            [line0Array release];
            
            NSMutableArray *line1Array = [[NSMutableArray alloc] init];
            [line1Array insertObject:MALE atIndex:0];
            [line1Array insertObject:LocaleStringForKey(NSMaleTitle, nil) atIndex:1];
            [self.DropDownValArray insertObject:line1Array atIndex:1];
            [line1Array release];
        }
            break;
            
        case 3:
        {
            iFliterIndex = 2;
            NSSortDescriptor *orderDesc = [[[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES] autorelease];
            [self.descriptors addObject:orderDesc];
            
            self.entityName = @"UserCountry";
            
            NSError *error = nil;
            BOOL res = [[super prepareFetchRC] performFetch:&error];
            if (!res) {
                NSAssert1(0, @"Unhandled error performing fetch: %@", [error localizedDescription]);
            }
            
            NSArray *countryDetail = [CommonUtils objectsInMOC:_MOC
                                                    entityName:self.entityName
                                                  sortDescKeys:self.descriptors
                                                     predicate:nil];
            
            int size = [countryDetail count];
            for (NSUInteger i=0; i<size; i++) {
                UserCountry* mCountry = (UserCountry*)[countryDetail objectAtIndex:i];
                NSMutableArray *mArray = [[NSMutableArray alloc] init];
                [mArray insertObject:mCountry.countryId atIndex:0];
                if ([AppManager instance].currentLanguageCode == EN_TY) {
                    [mArray insertObject:mCountry.enName atIndex:1];
                }else{
                    [mArray insertObject:mCountry.cnName atIndex:1];
                }
                [self.DropDownValArray insertObject:mArray atIndex:i];
                [mArray release];
            }
        }
            break;
            
        case 6:
        {
            iFliterIndex = 3;
            NSSortDescriptor *nameDesc = [[[NSSortDescriptor alloc] initWithKey:@"industryId" ascending:YES] autorelease];
            [self.descriptors addObject:nameDesc];
            
            self.entityName = @"Industry";
            
            NSError *error = nil;
            BOOL res = [[super prepareFetchRC] performFetch:&error];
            if (!res) {
                NSAssert1(0, @"Unhandled error performing fetch: %@", [error localizedDescription]);
            }
            
            NSArray *industryDetail = [CommonUtils objectsInMOC:_MOC
                                                     entityName:self.entityName
                                                   sortDescKeys:self.descriptors
                                                      predicate:nil];
            
            int size = [industryDetail count];
            for (NSUInteger i=0; i<size; i++) {
                Industry* mIndustry = (Industry*)[industryDetail objectAtIndex:i];
                NSMutableArray *mArray = [[NSMutableArray alloc] init];
                [mArray insertObject:mIndustry.industryId atIndex:0];
                if ([AppManager instance].currentLanguageCode == EN_TY) {
                    [mArray insertObject:mIndustry.enName atIndex:1];
                }else{
                    [mArray insertObject:mIndustry.cnName atIndex:1];
                }                [self.DropDownValArray insertObject:mArray atIndex:i];
                [mArray release];
            }
            
        }
            break;
    }
}

@end
