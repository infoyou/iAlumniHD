//
//  Place2ThingViewController.m
//  iAlumniHD
//
//  Created by user on 12-6-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Place2ThingViewController.h"
#import "UserListViewController.h"
#import "ItemPropertyCell.h"
#import "DebugLogOutput.h"
#import "Tag.h"
#import "NearbyViewController.h"

#define FONT_SIZE   14.0f

typedef enum {
    SHAKE_THING_TAG = 1,
    SHAKE_PLACE_TAG = 2
} SHAKE_VIEW_TAG;

@interface Place2ThingViewController()
@property (nonatomic, retain) NSFetchedResultsController *filterTagFetchedRC;
@property (nonatomic, retain) NSFetchedResultsController *filterPlaceFetchedRC;
@end

@implementation Place2ThingViewController
@synthesize thingText;
@synthesize placeText;
@synthesize thingTextVal;
@synthesize placeTextVal;

@synthesize filterTagFetchedRC = _filterTagFetchedRC;
@synthesize filterPlaceFetchedRC = _filterPlaceFetchedRC;

- (id)initWithMOC:(NSManagedObjectContext *)MOC aPlaces:(NSString*)aPlaces aThings:(NSString*)aThings
{
    self = [super initWithMOC:MOC holder:nil backToHomeAction:nil needGoHome:NO];
    if (self) {

        // Custom initialization
        [self loadFilterTags];
        [self loadFilterPlaces];
        self.thingTextVal = @"";
        self.placeTextVal = @"";
    }
    return self;
}

- (void)dealloc
{
    RELEASE_OBJ(thingText);
    RELEASE_OBJ(placeText);
    self.thingTextVal = nil;
    self.placeTextVal = nil;
    
    RELEASE_OBJ(_thingSectionHeaderView);
    RELEASE_OBJ(_placeSectionHeaderView);
    
    self.filterPlaceFetchedRC = nil;
    self.filterTagFetchedRC = nil;
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - init view
- (void)initTableView
{
    CGRect mTabFrame = CGRectMake(0, 0, LIST_WIDTH, self.view.frame.size.height);
	_tableView = [[UITableView alloc] initWithFrame:mTabFrame
                                              style:UITableViewStylePlain];
	
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_tableView.dataSource = self;
	_tableView.delegate = self;
	
	[self.view addSubview:_tableView];
    [super initTableView];
}

- (void)loadFilterTags {
    [NSFetchedResultsController deleteCacheWithName:@"TagCache"];
    
    NSMutableArray *sortDesc = [NSMutableArray array];
    NSSortDescriptor *descriptor = [[[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES] autorelease];
    [sortDesc addObject:descriptor];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(type == %d)", THING_TY];
    
    self.filterTagFetchedRC = nil;
    self.filterTagFetchedRC = [CoreDataUtils fetchObject:_MOC
                                fetchedResultsController:self.filterTagFetchedRC
                                              entityName:@"Tag"
                                      sectionNameKeyPath:nil
                                         sortDescriptors:sortDesc
                                               predicate:predicate];
    
    NSError *error = nil;
    if (![self.filterTagFetchedRC performFetch:&error]) {
        debugLog(@"Unhandled error performing fetch: %@", [error localizedDescription]);
		NSAssert1(0, @"Unhandled error performing fetch: %@", [error localizedDescription]);
    }
}

- (void)loadFilterPlaces {
    [NSFetchedResultsController deleteCacheWithName:@"TagCache"];
    
    NSMutableArray *sortDesc = [NSMutableArray array];
    NSSortDescriptor *descriptor = [[[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES] autorelease];
    [sortDesc addObject:descriptor];
    
    self.filterPlaceFetchedRC = nil;
    self.filterPlaceFetchedRC = [CoreDataUtils fetchObject:_MOC
                                  fetchedResultsController:self.filterPlaceFetchedRC
                                                entityName:@"Tag"
                                        sectionNameKeyPath:nil
                                           sortDescriptors:sortDesc
                                                 predicate:[NSPredicate predicateWithFormat:@"(type == %d)", PLACE_TY]];
    
    NSError *error = nil;
    if (![self.filterPlaceFetchedRC performFetch:&error]) {
        debugLog(@"Unhandled error performing fetch: %@", [error localizedDescription]);
		NSAssert1(0, @"Unhandled error performing fetch: %@", [error localizedDescription]);
    }else {
        //        NSFetchedResultsController *leftTag = [self.filterPlaceFetchedRC.fetchedObjects objectAtIndex:0];
        //        Tag *place = (Tag*)leftTag;
        //        place.selected = [NSNumber numberWithBool:YES];
        //        SAVE_MOC(_MOC);
        //        [AppManager instance].defaultPlace = place.tagName;
    }
}

#pragma mark - View lifecycle
/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initTableView];
    
    self.navigationItem.rightBarButtonItem = BAR_BUTTON(LocaleStringForKey(NSDoneTitle, nil), UIBarButtonItemStyleBordered, self, @selector(gotoUserList:));
    
//    self.navigationItem.leftBarButtonItem = BAR_BUTTON(LocaleStringForKey(NSCloseTitle, nil), UIBarButtonItemStyleBordered, self, @selector(close:));
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - Table View
- (UITableViewCell*)drawThingText:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"ThingTextCell";
    
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    CGRect frame = CGRectMake(5, 5, 280, 25);
    thingText = [[UITextField alloc] initWithFrame:frame];
    thingText.tag = SHAKE_THING_TAG;
    thingText.backgroundColor = TRANSPARENT_COLOR;
    thingText.adjustsFontSizeToFitWidth = YES;
    thingText.textColor = [UIColor blackColor];
    thingText.keyboardType = UIKeyboardTypeDefault;
    thingText.borderStyle = UITextBorderStyleRoundedRect;
    thingText.returnKeyType = UIReturnKeyDone;
    thingText.font = BOLD_FONT(FONT_SIZE);
    thingText.autocorrectionType = UITextAutocorrectionTypeNo;
    thingText.autocapitalizationType = UITextAutocapitalizationTypeNone;
    thingText.clearsOnBeginEditing = NO;
    thingText.textAlignment = UITextAlignmentLeft;
    thingText.delegate = self;
    [thingText addTarget:self
                  action:@selector(hideKeyboard:)
        forControlEvents:UIControlEventEditingDidEndOnExit];
    thingText.placeholder = LocaleStringForKey(NSShakeThingNoteTitle, nil);
    thingText.clearButtonMode = UITextFieldViewModeWhileEditing;
    [thingText setEnabled:YES];
    thingText.text = thingTextVal;
    [cell.contentView addSubview:thingText];
    
    [cell.contentView setBackgroundColor:[UIColor whiteColor]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UITableViewCell*)drawPlaceText:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"PlaceTextCell";
    
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    
    CGRect frame = CGRectMake(5, 5, 280, 25);
    placeText = [[UITextField alloc] initWithFrame:frame];
    placeText.tag = SHAKE_PLACE_TAG;
    placeText.backgroundColor = TRANSPARENT_COLOR;
    placeText.adjustsFontSizeToFitWidth = YES;
    placeText.textColor = [UIColor blackColor];
    placeText.keyboardType = UIKeyboardTypeDefault;
    placeText.borderStyle = UITextBorderStyleRoundedRect;
    placeText.returnKeyType = UIReturnKeyDone;
    placeText.font = BOLD_FONT(FONT_SIZE);
    placeText.autocorrectionType = UITextAutocorrectionTypeNo;
    placeText.autocapitalizationType = UITextAutocapitalizationTypeNone;
    placeText.clearsOnBeginEditing = NO;
    placeText.textAlignment = UITextAlignmentLeft;
    placeText.delegate = self;
    [placeText addTarget:self
                  action:@selector(hideKeyboard:)
        forControlEvents:UIControlEventEditingDidEndOnExit];
    placeText.placeholder = LocaleStringForKey(NSShakePlaceNoteTitle, nil);
    placeText.clearButtonMode = UITextFieldViewModeWhileEditing;
    [placeText setEnabled:YES];
    placeText.text = placeTextVal;
    [cell.contentView addSubview:placeText];
    
    [cell.contentView setBackgroundColor:[UIColor whiteColor]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (ItemPropertyCell *)drawPlaceCell:(NSIndexPath *)indexPath fetchedRC:(NSFetchedResultsController *)fetchedRC {
    
    NSManagedObject *leftTag = nil;
    
    int index = 0;
    index = indexPath.row;
    
    leftTag = [fetchedRC.fetchedObjects objectAtIndex:index];
    
    static NSString *kTagCellIdentifier = @"PlaceCell";
    ItemPropertyCell *cell = [_tableView dequeueReusableCellWithIdentifier:kTagCellIdentifier];
    if (nil == cell) {
        
        cell = [[[ItemPropertyCell alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier:kTagCellIdentifier
                                         editorDelegate:self
                                               itemType:ONE_TY
                                                    MOC:_MOC
                                                tagType:PLACE_TY] autorelease];
    }
    
    [cell drawPlace:leftTag];
    return cell;
}

- (ItemPropertyCell *)drawTagCell:(NSIndexPath *)indexPath
                        fetchedRC:(NSFetchedResultsController *)fetchedRC {
    
    NSManagedObject *leftTag = nil;
    NSManagedObject *rightTag = nil;
    int index = 0;
    index = indexPath.row * 2;
    
    if (fetchedRC.fetchedObjects.count % 2 == 0) {
        leftTag = [fetchedRC.fetchedObjects objectAtIndex:index];
        rightTag = [fetchedRC.fetchedObjects objectAtIndex:index + 1];
    } else {
        leftTag = [fetchedRC.fetchedObjects objectAtIndex:index];
        if (index + 1 < fetchedRC.fetchedObjects.count) {
            rightTag = [fetchedRC.fetchedObjects objectAtIndex:(index + 1)];
        }
    }
    
    static NSString *kTagCellIdentifier = @"ThingCell";
    ItemPropertyCell *cell = [_tableView dequeueReusableCellWithIdentifier:kTagCellIdentifier];
    if (nil == cell) {
        
        cell = [[[ItemPropertyCell alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier:kTagCellIdentifier
                                         editorDelegate:self
                                               itemType:TWO_TY
                                                    MOC:_MOC
                                                tagType:THING_TY] autorelease];
    }
    
    [cell drawThing:leftTag rightTag:rightTag];
    return cell;
}

#pragma mark - handle empty list
- (BOOL)listIsEmpty {
  return NO;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return self.filterTagFetchedRC.fetchedObjects.count/2+self.filterTagFetchedRC.fetchedObjects.count%2;
            break;
        case 2:
            return 1;
            break;
        case 3:
            return self.filterPlaceFetchedRC.fetchedObjects.count;
            break;
            
        default:
            return 0;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = [indexPath section];
    switch (section) {
        case 0:
        case 1:
        case 2:
        case 3:
            return 40;
            break;
            
        default:
            return 0;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 20;
            break;
            
        case 2:
            return 20;
            break;
            
        default:
            return 0;
            break;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
        {
            if (nil == _thingSectionHeaderView) {
                _thingSectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, LIST_WIDTH, 20)];
                _thingSectionHeaderView.backgroundColor = COLOR(169, 169, 169);
                
                UILabel *label = [[[UILabel alloc] init] autorelease];
                label.text = LocaleStringForKey(NSShakeThingTitle, nil);
                label.font = FONT(FONT_SIZE-1);
                label.textColor = [UIColor whiteColor];
                label.backgroundColor = TRANSPARENT_COLOR;
                label.frame = CGRectMake(5, 0, 200, 20);
                [_thingSectionHeaderView addSubview:label];
            }
            
            return _thingSectionHeaderView;
        }
            
        case 2:
        {
            if (nil == _placeSectionHeaderView) {
                _placeSectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, LIST_WIDTH, 20)];
                _placeSectionHeaderView.backgroundColor = COLOR(169, 169, 169);
                
                UILabel *label = [[[UILabel alloc] init] autorelease];
                label.text = LocaleStringForKey(NSShakePlaceTitle, nil);
                label.font = FONT(FONT_SIZE-1);
                label.textColor = [UIColor whiteColor];
                label.backgroundColor = TRANSPARENT_COLOR;
                label.frame = CGRectMake(5, 0, 200, 20);
                [_placeSectionHeaderView addSubview:label];
            }
            
            return _placeSectionHeaderView;
        }
            
        default:
            return nil;
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return LocaleStringForKey(NSShakeThingTitle, nil);
            break;
            
        case 2:
            return LocaleStringForKey(NSShakePlaceTitle, nil);
            break;
            
        default:
            return 0;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    switch (section) {
            
        default:
            return 0;
    }
}

-(void)configureCell:(NSIndexPath *)indexPath aCell:(UITableViewCell *)cell
{
    [cell setBackgroundColor:[UIColor whiteColor]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = indexPath.section;
    
    switch (section) {
        case 0:
        {
            return [self drawThingText:indexPath];
        }
        case 1:
        {
            return [self drawTagCell:indexPath fetchedRC:self.filterTagFetchedRC];
        }
        case 2:
        {
            return [self drawPlaceText:indexPath];
        }
        case 3:
        {
            return [self drawPlaceCell:indexPath fetchedRC:self.filterPlaceFetchedRC];
        }
            
        default:
            break;
    }
    return nil;
}

#pragma mark - UITextFieldDelegate method
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    int tag = [textField tag];
    switch (tag) {
        case SHAKE_THING_TAG:
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"( (type == %d) AND (selected == 1) )", THING_TY];
            Tag *lastSelectedTag = (Tag *)[CoreDataUtils fetchObjectFromMOC:_MOC entityName:@"Tag" predicate:predicate];
            lastSelectedTag.selected = [NSNumber numberWithBool:NO];
            
            [CoreDataUtils saveMOCChange:lastSelectedTag.managedObjectContext];
            break;
        }
            
        case SHAKE_PLACE_TAG:
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"( (type == %d) AND (selected == 1) )", PLACE_TY];
            Tag *lastSelectedTag = (Tag *)[CoreDataUtils fetchObjectFromMOC:_MOC entityName:@"Tag" predicate:predicate];
            lastSelectedTag.selected = [NSNumber numberWithBool:NO];
            
            [CoreDataUtils saveMOCChange:lastSelectedTag.managedObjectContext];
            break;
        }
            
        default:
            break;
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    int tag = [textField tag];
    switch (tag) {
        case SHAKE_THING_TAG:
        {
            NSLog(@"SHAKE_THING_TAG");
            break;
        }
            
        case SHAKE_PLACE_TAG:
        {
            // UIView Up
            CGFloat heightFraction = 0.50f;
            _animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
            NSLog(@"heightFraction: %f", heightFraction);
            CGRect viewFrame = self.view.frame;
            viewFrame.origin.y -= _animatedDistance;
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
            
            [self.view setFrame:viewFrame];
            [UIView commitAnimations];
            
            break;
        }
            
        default:
            break;
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    int tag = [textField tag];
    
    if (tag == SHAKE_PLACE_TAG) {
        // UIView Down
        CGRect viewFrame = self.view.frame;
        viewFrame.origin.y += _animatedDistance;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
        
        [self.view setFrame:viewFrame];
        [UIView commitAnimations];
    }
    
    
    if (textField.text.length < 1) {
        return;
    }
    
    
    switch (tag) {
        case SHAKE_THING_TAG:
        {
            self.thingTextVal = thingText.text;
            break;
        }
            
        case SHAKE_PLACE_TAG:
        {
            self.placeTextVal = placeText.text;
            break;
        }
            
        default:
            break;
    }
    
    [_tableView reloadData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    return YES;
}

#pragma mark - action

- (void)showNearbyItems:(id)sender {
    NearbyViewController *nearbyVC = [[[NearbyViewController alloc] initWithMOC:_MOC] autorelease];
    
    nearbyVC.title = LocaleStringForKey(NSNearbyTitle, nil);
    
    [self.navigationController pushViewController:nearbyVC animated:YES];
}

- (void)gotoUserList:(id)sender
{
    // Thing & Place
    if(thingText.text.length > 1)
        [AppManager instance].defaultThing = thingText.text;
    if (placeText.text.length > 1) {
        [AppManager instance].defaultPlace = placeText.text;
    }
    
    // User List
    [CommonUtils doDelete:_MOC entityName:@"Alumni"];
    
    UserListViewController *userListVC = [[UserListViewController alloc] initWithType:SHAKE_USER_LIST_TY needGoToHome:NO MOC:_MOC];
    userListVC.pageIndex = 0;
    userListVC.requestParam = [NSString stringWithFormat:@"<longitude>%f</longitude><latitude>%f</latitude><distance_scope>10</distance_scope><time_scope>1000</time_scope><order_by_column>datetime</order_by_column><shake_where>%@</shake_where><shake_what>%@</shake_what><page>0</page><page_size>30</page_size><refresh_only>0</refresh_only><is_for_namecard>0</is_for_namecard>", [AppManager instance].longitude, [AppManager instance].latitude, [AppManager instance].defaultPlace, [AppManager instance].defaultThing];
    [AppManager instance].shakeLocationHistory = [NSString stringWithFormat:@"<longitude>%f</longitude><latitude>%f</latitude>",[AppManager instance].longitude, [AppManager instance].latitude];
    userListVC.title = LocaleStringForKey(NSAlumniTitle, nil);
    [self.navigationController pushViewController:userListVC animated:YES];
    RELEASE_OBJ(userListVC);
}

#pragma mark - UIText Interaction
- (void)hideKeyboard:(id)sender {
    UITextField * textField = (UITextField *)sender;
    [textField resignFirstResponder];
}

- (void)chooseTags {
    self.thingTextVal = @"";
    [_tableView reloadData];
}

- (void)choosePlace {
    self.placeTextVal = @"";
    [_tableView reloadData];
}

@end
