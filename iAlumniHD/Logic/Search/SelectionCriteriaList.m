//
//  SelectionCriteriaList.m
//  iAlumniHD
//
//  Created by Adam on 12-10-21.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "SelectionCriteriaList.h"
#import "TextConstants.h"
#import "UserCountry.h"
#import "Industry.h"
#import "ClassGroup.h"
#import "CommonUtils.h"

enum {
    MALE_CELL,
    FEMALE_CELL,
};

@interface SelectionCriteriaList()
@property (nonatomic, retain) id currentSelectedItem;
@end

@implementation SelectionCriteriaList
@synthesize _popController;
@synthesize currentSelectedItem = _currentSelectedItem;

- (id)initWithFrame:(CGRect)frame 
                MOC:(NSManagedObjectContext *)MOC
           itemType:(WebItemType)itemType 
             target:(id)target 
 itemSelectedAction:(SEL)itemSelectedAction 
currentSelectedItem:(id)currentSelectedItem {
    
    self = [super init];
    if (self) {
        _frame = frame;
        _target = target;
        _itemSelectedAction = itemSelectedAction;
        _MOC = MOC;
        _itemType = itemType;
        self.currentSelectedItem = currentSelectedItem;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    
    [NSFetchedResultsController deleteCacheWithName:nil];
    
    _tableView.dataSource = nil;
    _tableView.delegate = nil;
    RELEASE_OBJ(_tableView);
    
    self.currentSelectedItem = nil;
    RELEASE_OBJ(_popController);
    RELEASE_OBJ(_fetchedRC);
    
    [super dealloc];
}

#pragma mark - core data methods
- (void)fetch {
    [NSFetchedResultsController deleteCacheWithName:nil];
    
    NSString *entityName = nil;
    NSPredicate *predicate = nil;
    NSSortDescriptor *orderDesc = nil;
    NSMutableArray *descriptors = [[[NSMutableArray alloc] init] autorelease];
    
    switch (_itemType) {
        case COUNTRY_TY:
        {
            entityName = @"UserCountry";
            //predicate = [NSPredicate predicateWithFormat:@"(countryId > 0)"];
            orderDesc = [[[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES] autorelease];
            [descriptors addObject:orderDesc];
            break;
        }
            
        case INDUSTRY_TY:
            entityName = @"Industry";
            //predicate = [NSPredicate predicateWithFormat:@"(industryId > 0)"];
            orderDesc = [[[NSSortDescriptor alloc] initWithKey:@"industryId" ascending:YES] autorelease];
            [descriptors addObject:orderDesc];
            break;
            
        case CLASS_TY:
            entityName = @"ClassGroup";
            //predicate = [NSPredicate predicateWithFormat:@"(classId > 0)"];
            orderDesc = [[[NSSortDescriptor alloc] initWithKey:@"classId" ascending:YES] autorelease];
            [descriptors addObject:orderDesc];
            break;
            
        default:
            break;
    }
    
    RELEASE_OBJ(_fetchedRC);
    _fetchedRC = [CommonUtils fetchObject:_MOC 
               fetchedResultsController:_fetchedRC 
                             entityName:entityName 
                     sectionNameKeyPath:nil 
                        sortDescriptors:descriptors
                              predicate:predicate];
    NSError *error = nil;
    BOOL res = [_fetchedRC performFetch:&error];
    if (!res) {
		NSAssert1(0, @"Unhandled error performing fetch: %@", [error localizedDescription]);
	}
    
    [_tableView reloadData];
}

#pragma mark - View lifecycle
- (void)initTableView {
    _tableView = [[UITableView alloc] initWithFrame:_frame style:UITableViewStylePlain];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth + UIViewAutoresizingFlexibleHeight;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.frame = _frame;
    [self initTableView];
    
    if (_itemType != GENDER_TY) {
        [self fetch];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIDeviceOrientationLandscapeRight || interfaceOrientation == UIDeviceOrientationLandscapeLeft);
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
- (NSUInteger)supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotate {
  return YES;
}
#endif

#pragma mark - UITableViewDelegate, UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_itemType == GENDER_TY) {
        return 2;
    } else {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedRC sections] objectAtIndex:section];
//        NSLog(@"========================== cell count: %d", [sectionInfo numberOfObjects]);
        return [sectionInfo numberOfObjects];
    }
}

- (void)drawGenderCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    
    if (_selectSameItem) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        
        switch (indexPath.row) {
            case MALE_CELL:
            {
                cell.textLabel.text = LocaleStringForKey(NSMaleTitle, nil);
                if ([MALE isEqualToString:(NSString *)self.currentSelectedItem]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark; 
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                break;
            }
                
            case FEMALE_CELL:
            {
                cell.textLabel.text = LocaleStringForKey(NSFemaleTitle, nil);
                if ([FEMALE isEqualToString:(NSString *)self.currentSelectedItem]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark; 
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                
                break;
            }
                
            default:
                break;
        }
    }
}

- (void)drawCountryCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    if (_selectSameItem) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        UserCountry *country = (UserCountry *)[_fetchedRC objectAtIndexPath:indexPath];
        switch ([CommonUtils currentLanguage]) {
            case ZH_HANS_TY:
                cell.textLabel.text = country.cnName;
                break;
                
            case EN_TY:
                cell.textLabel.text = country.enName;
                break;
                
            default:
                break;
        }
        
        if ([country.countryId isEqualToString:((UserCountry *)self.currentSelectedItem).countryId]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
}

- (void)drawClassCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    if (_selectSameItem) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        ClassGroup *class = (ClassGroup *)[_fetchedRC objectAtIndexPath:indexPath];
        switch ([CommonUtils currentLanguage]) {
            case ZH_HANS_TY:
                cell.textLabel.text = class.cnName;
                break;
                
            case EN_TY:
                cell.textLabel.text = class.enName;
                break;
            default:
                break;
        }

        if ([class.classId isEqualToString:((ClassGroup *)self.currentSelectedItem).classId]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
}

- (void)drawIndustryCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    if (_selectSameItem) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        Industry *industry = (Industry *)[_fetchedRC objectAtIndexPath:indexPath];
        
        switch ([CommonUtils currentLanguage]) {
            case ZH_HANS_TY:
                cell.textLabel.text = industry.cnName;
                break;
                
            case EN_TY:
                cell.textLabel.text = industry.enName;
                break;
            default:
                break;
        }

        if ([industry.industryId isEqualToString:((Industry *)self.currentSelectedItem).industryId]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCellIdentifier = @"Cell";
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (nil == cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                       reuseIdentifier:kCellIdentifier] autorelease];
        cell.textLabel.font = FONT(17);
    }
    
    switch (_itemType) {
        case GENDER_TY:
            [self drawGenderCell:cell indexPath:indexPath];
            break;
            
        case COUNTRY_TY:
            [self drawCountryCell:cell indexPath:indexPath];
            break;
            
        case CLASS_TY:
            [self drawClassCell:cell indexPath:indexPath];
            break;
            
        case INDUSTRY_TY:
            [self drawIndustryCell:cell indexPath:indexPath];
            break;
        default:
            break;
    }
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellSelectionStyleNone) {
        _selectSameItem = NO;
    } else {
        _selectSameItem = YES;
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_selectSameItem) {
        self.currentSelectedItem = nil;
    } else {
        switch (_itemType) {
            case GENDER_TY:
                switch (indexPath.row) {
                    case MALE_CELL:
                        self.currentSelectedItem = MALE;
                        break;
                        
                    case FEMALE_CELL:
                        self.currentSelectedItem = FEMALE;
                        break;
                        
                    default:
                        break;
                }
                break;
                
            case COUNTRY_TY:
            {
                UserCountry *country = (UserCountry *)[_fetchedRC objectAtIndexPath:indexPath];
                self.currentSelectedItem = country;
                break;
            } 
                
            case CLASS_TY:
            {
                ClassGroup *class = (ClassGroup *)[_fetchedRC objectAtIndexPath:indexPath];
                self.currentSelectedItem = class;
                break;
            }
                
            case INDUSTRY_TY:
            {
                Industry *industry = (Industry *)[_fetchedRC objectAtIndexPath:indexPath];
                self.currentSelectedItem = industry;
                break;
            }
                
            default:
                break;
        }
    }
    
    [_tableView reloadData];
    if (_target && _itemSelectedAction) {
        [_target performSelector:_itemSelectedAction withObject:self.currentSelectedItem];
    }
    
    [_popController dismissPopoverAnimated:NO];
}

@end
