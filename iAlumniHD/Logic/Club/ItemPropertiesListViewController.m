//
//  ItemPropertiesListViewController.m
//  iAlumniHD
//
//  Created by Adam on 12-11-22.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ItemPropertiesListViewController.h"
#import "ItemListSectionView.h"
#import "ItemPropertyCell.h"
#import "ComposerTag.h"
#import "Distance.h"
#import "Country.h"
#import "Place.h"
#import "Tag.h"

enum {
    //    LOCATION_SEC,
    //    FAVORITE_SEC,
    TAG_SEC,
};

#define FILTERS_SECTION_COUNT   1

#define SECTION_VIEW_HEIGHT     18.0f

@interface ItemPropertiesListViewController()
@property (nonatomic, retain) NSFetchedResultsController *filterTagFetchedRC;
@property (nonatomic, retain) NSFetchedResultsController *filterPlaceFetchedRC;
@property (nonatomic, retain) NSFetchedResultsController *filterCountryFetchedRC;
@end

@implementation ItemPropertiesListViewController

@synthesize filterTagFetchedRC = _filterTagFetchedRC;
@synthesize filterPlaceFetchedRC = _filterPlaceFetchedRC;
@synthesize filterCountryFetchedRC = _filterCountryFetchedRC;

#pragma mark - init
- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder
 backToHomeAction:(SEL)backToHomeAction
     propertyType:(ItemPropertyType)propertyType
          tagType:(TagType)tagType {
    
    self = [super initWithMOC:MOC holder:holder backToHomeAction:backToHomeAction needRefreshHeaderView:NO needRefreshFooterView:NO needGoHome:NO];
    
    if (self) {
        _type = propertyType;
        _tagType = tagType;
        isFromComposer = NO;
    }
    
    return self;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
 composerDelegate:(id<ComposerDelegate>)composerDelegate
     propertyType:(ItemPropertyType)propertyType
       moveDownUI:(BOOL)moveDownUI
          tagType:(TagType)tagType {
    
    self = [super initWithMOC:MOC
              showCloseButton:YES
        needRefreshHeaderView:NO
        needRefreshFooterView:NO];
    
    if (self) {
        self.frame = CGRectMake(0, 0, 540.5f, SCREEN_HEIGHT);
        _composerDelegate = composerDelegate;
        _moveDownUI = moveDownUI;
        _tagType = tagType;
        isFromComposer = YES;
    }
    
    return self;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder
 backToHomeAction:(SEL)backToHomeAction
parentEditorDelegate:(id<ECEditorDelegate>)parentEditorDelegate
     propertyType:(ItemPropertyType)propertyType
  filterCountryId:(long long)filterCountryId
          tagType:(TagType)tagType {
    
    self = [self initWithMOC:MOC
                      holder:holder
            backToHomeAction:backToHomeAction
                propertyType:propertyType
                     tagType:tagType];
    if (self) {
        _lastSelectedCountryId = filterCountryId;
        _parentEditorDelegate = parentEditorDelegate;
    }
    return self;
}

#pragma mark - load filter data
- (void)loadFilterTags {
    [NSFetchedResultsController deleteCacheWithName:@"TagCache"];
    
    NSMutableArray *sortDesc = [NSMutableArray array];
    NSSortDescriptor *descriptor = [[[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES] autorelease];
    [sortDesc addObject:descriptor];
    
    self.filterTagFetchedRC = nil;
    self.filterTagFetchedRC = [CoreDataUtils fetchObject:_MOC
                                fetchedResultsController:self.filterTagFetchedRC
                                              entityName:@"Tag"
                                      sectionNameKeyPath:nil
                                         sortDescriptors:sortDesc
                                               predicate:nil];
    
    NSError *error = nil;
    if (![self.filterTagFetchedRC performFetch:&error]) {
        debugLog(@"Unhandled error performing fetch: %@", [error localizedDescription]);
		NSAssert1(0, @"Unhandled error performing fetch: %@", [error localizedDescription]);
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(selected == 1)"];
    if (![CoreDataUtils objectInMOC:_MOC entityName:@"Tag" predicate:predicate]) {
        // no tag selected, then 'All' tag default selected
        Tag *allTag = (Tag *)[CoreDataUtils fetchObjectFromMOC:_MOC
                                                    entityName:@"Tag"
                                                     predicate:[NSPredicate predicateWithFormat:@"(tagId == %lld)", TAG_ALL_ID]];
        allTag.selected = [NSNumber numberWithBool:YES];
        [CoreDataUtils saveMOCChange:_MOC];
    }
}

- (void)loadFilterDistances {
    [NSFetchedResultsController deleteCacheWithName:@"DistanceCache"];
    
    NSMutableArray *sortDesc = [NSMutableArray array];
    NSSortDescriptor *descriptor = [[[NSSortDescriptor alloc] initWithKey:@"valueFloat" ascending:YES] autorelease];
    [sortDesc addObject:descriptor];
    
    self.filterPlaceFetchedRC = nil;
    self.filterPlaceFetchedRC = [CoreDataUtils fetchObject:_MOC
                                  fetchedResultsController:self.filterPlaceFetchedRC
                                                entityName:@"Distance"
                                        sectionNameKeyPath:nil
                                           sortDescriptors:sortDesc
                                                 predicate:nil];
    
    NSError *error = nil;
    if (![self.filterPlaceFetchedRC performFetch:&error]) {
        debugLog(@"Unhandled error performing fetch: %@", [error localizedDescription]);
		NSAssert1(0, @"Unhandled error performing fetch: %@", [error localizedDescription]);
    }
    
    if (![CoreDataUtils objectInMOC:_MOC entityName:@"Distance" predicate:SELECTED_PREDICATE]) {
        // no place selected, then 'All' place default selected
        Distance *allRadiusPlace = (Distance *)[CoreDataUtils fetchObjectFromMOC:_MOC
                                                                      entityName:@"Distance"
                                                                       predicate:nil];
        allRadiusPlace.selected = [NSNumber numberWithBool:YES];
        SAVE_MOC(_MOC);
    }
}

#pragma mark - View lifecycle
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)initTableViewProperties {
    
    _tableView.backgroundColor = [UIColor whiteColor];
    
    int width = LIST_WIDTH;
    if (isFromComposer) {
        width = 540.5f;
    }
    
    _tableView.tableFooterView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0,
                                                                           width,
                                                                           0.5f)] autorelease];
    _tableView.tableFooterView.backgroundColor = CELL_BORDER_COLOR;
    
    if (_moveDownUI) {
        
        _tableView.frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y + NAVIGATION_BAR_HEIGHT, _tableView.frame.size.width, _tableView.frame.size.height - NAVIGATION_BAR_HEIGHT);
    }
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (isFromComposer) {
        
        self.navigationItem.leftBarButtonItem = BAR_BUTTON(LocaleStringForKey(NSBackTitle,nil), UIBarButtonItemStyleBordered, self, @selector(doOK:));
    }
    
    [self initTableViewProperties];
    
    switch (_type) {
        case TAG_TY:
            // if type is FEED_FILTER_TY, then the table view will be refreshed after place list loaded
            [self refreshTable];
            break;
            
        case FEED_FILTER_TY:
        {
            [self loadFilterTags];
            [_tableView reloadData];
            break;
        }
            
        case SHARING_FILTER_TY:
        {
            [self loadFilterTags];
            [self loadFilterDistances];
            [_tableView reloadData];
            break;
        }
            
        default:
            break;
    }
    [self checkListWhetherEmpty];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)dealloc {
    
    self.filterPlaceFetchedRC = nil;
    self.filterTagFetchedRC = nil;
    self.filterCountryFetchedRC = nil;
    
    RELEASE_OBJ(_placeHeaderView);
    RELEASE_OBJ(_tagHeaderView);
    RELEASE_OBJ(_favoriteHeaderView);
    
    [super dealloc];
}

#pragma mark - handle empty list
- (BOOL)listIsEmpty {
  switch (_type) {
    case TAG_TY:
    {
      if (0 == self.fetchedRC.fetchedObjects.count) {
        return YES;
      } else {
        return NO;
      }
    }
      
    case SHARING_FILTER_TY:
    {
      if (0 == self.filterTagFetchedRC.fetchedObjects.count) {
        return YES;
      } else {
        return NO;
      }
    }
      
    default:
      return YES;
  }
}

#pragma mark - override methods
- (void)setPredicate {
    switch (_type) {
        case TAG_TY:
        {
            self.entityName = @"ComposerTag";
            
            self.descriptors = [NSMutableArray array];
            NSSortDescriptor *orderDesc = [[[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES] autorelease];
            [self.descriptors addObject:orderDesc];
            
            break;
        }
            
        default:
            break;
    }
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    switch (_type) {
        case TAG_TY:
            return 1;
            
        case SHARING_FILTER_TY:
            return FILTERS_SECTION_COUNT;
            
        default:
            return 0;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (_type) {
        case TAG_TY:
        {
            if (self.fetchedRC.fetchedObjects.count % 2 == 0) {
                return self.fetchedRC.fetchedObjects.count/2;
            } else {
                return self.fetchedRC.fetchedObjects.count/2 + 1;
            }
        }
            
        case SHARING_FILTER_TY:
        {
            switch (section) {
                    /*
                     case LOCATION_SEC:
                     {
                     if (self.filterPlaceFetchedRC.fetchedObjects.count % 2 == 0) {
                     return self.filterPlaceFetchedRC.fetchedObjects.count/2;
                     } else {
                     return self.filterPlaceFetchedRC.fetchedObjects.count/2 + 1;
                     }
                     
                     }
                     */
                case TAG_SEC:
                {
                    if (self.filterTagFetchedRC.fetchedObjects.count % 2 == 0) {
                        return self.filterTagFetchedRC.fetchedObjects.count/2;
                    } else {
                        return self.filterTagFetchedRC.fetchedObjects.count/2 + 1;
                    }
                    
                }
                default:
                    return 0;
            }
            break;
        }
        default:
            return 0;
    }
}

- (ItemPropertyCell *)drawTagCell:(NSIndexPath *)indexPath
                        fetchedRC:(NSFetchedResultsController *)fetchedRC {
    
    NSManagedObject *leftTag = nil;
    NSManagedObject *rightTag = nil;
    
    if (fetchedRC.fetchedObjects.count % 2 == 0) {
        
        leftTag = [fetchedRC.fetchedObjects objectAtIndex:indexPath.row * 2];
        rightTag = [fetchedRC.fetchedObjects objectAtIndex:indexPath.row * 2 + 1];
    } else {
        leftTag = [fetchedRC.fetchedObjects objectAtIndex:indexPath.row * 2];
        if (indexPath.row * 2 + 1 < fetchedRC.fetchedObjects.count) {
            rightTag = [fetchedRC.fetchedObjects objectAtIndex:(indexPath.row * 2 + 1)];
        }
    }
    
    static NSString *kTagCellIdentifier = @"TagCell";
    ItemPropertyCell *cell = [_tableView dequeueReusableCellWithIdentifier:kTagCellIdentifier];
    if (nil == cell) {
        cell = [[[ItemPropertyCell alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier:kTagCellIdentifier
                                         editorDelegate:self
                                               itemType:TWO_TY
                                                    MOC:_MOC
                                      sharingFilterType:TAG_FILTER_TY
                                         isFromComposer:isFromComposer] autorelease];
    }
    
    [cell drawTag:leftTag rightTag:rightTag];
    return cell;
}

- (ItemPropertyCell *)drawDistanceCell:(NSIndexPath *)indexPath
                             fetchedRC:(NSFetchedResultsController *)fetchedRC {
    Distance *leftDistance = nil;
    Distance *rightDistance = nil;
    
    if (fetchedRC.fetchedObjects.count % 2 == 0) {
        leftDistance = [fetchedRC.fetchedObjects objectAtIndex:indexPath.row * 2];
        rightDistance = [fetchedRC.fetchedObjects objectAtIndex:indexPath.row * 2 + 1];
        
    } else {
        leftDistance = [fetchedRC.fetchedObjects objectAtIndex:indexPath.row * 2];
        
        if (indexPath.row * 2 + 1 < fetchedRC.fetchedObjects.count) {
            rightDistance = [fetchedRC.fetchedObjects objectAtIndex:(indexPath.row * 2 + 1)];
        }
    }
    
    static NSString *kPlaceCellIdentifier = @"PlaceCell";
    ItemPropertyCell *cell = [_tableView dequeueReusableCellWithIdentifier:kPlaceCellIdentifier];
    if (nil == cell) {
        cell = [[[ItemPropertyCell alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier:kPlaceCellIdentifier
                                         editorDelegate:self
                                               itemType:TWO_TY
                                                    MOC:_MOC
                                      sharingFilterType:DISTANTCE_FILTER_TY] autorelease];
    }
    [cell drawLeftDistance:leftDistance rightDistance:rightDistance];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (_type) {
        case TAG_TY:
            return [self drawTagCell:indexPath fetchedRC:self.fetchedRC];
            
        case SHARING_FILTER_TY:
        {
            switch (indexPath.section) {
                    /*
                     case LOCATION_SEC:
                     return [self drawDistanceCell:indexPath fetchedRC:self.filterPlaceFetchedRC];
                     */
                    
                case TAG_SEC:
                    return [self drawTagCell:indexPath fetchedRC:self.filterTagFetchedRC];
                    
                default:
                    break;
            }
            
        }
        default:
            return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (_type) {
        case TAG_TY:
            return;
            
        case FEED_FILTER_TY:
        case SHARING_FILTER_TY:
        {
            switch (indexPath.section) {
                case TAG_SEC:
                    return;
                default:
                    return;
            }
        }
        default:
            return;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ITEM_PROPERTY_CELL_HEIGHT;
    
    switch (_type) {
        case TAG_TY:
            return ITEM_PROPERTY_CELL_HEIGHT;
            
        case FEED_FILTER_TY:
        case SHARING_FILTER_TY:
            switch (indexPath.section) {
                    /*
                     case LOCATION_SEC:
                     return 0;
                     */
                case TAG_SEC:
                    return ITEM_PROPERTY_CELL_HEIGHT;
                default:
                    return 0;
            }
            
        default:
            return 0;
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    switch (_type) {
        case TAG_TY:
            return _tableView.tableFooterView;
            
        default:
            return nil;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.5f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    switch (_type) {
        case TAG_TY:
            return nil;
            
        case SHARING_FILTER_TY:
        {
            switch (section) {
                    /*
                     case LOCATION_SEC:
                     {
                     if (nil == _placeHeaderView) {
                     _placeHeaderView = [[ItemListSectionView alloc] initWithFrame:CGRectMake(0, 0,
                     self.view.frame.size.width,
                     SECTION_VIEW_HEIGHT)
                     title:LocaleStringForKey(NSPlaceTitle, nil)];
                     
                     }
                     return _placeHeaderView;
                     }
                     */
                    
                case TAG_SEC:
                {
                    if (nil == _tagHeaderView) {
                        _tagHeaderView = [[ItemListSectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, SECTION_VIEW_HEIGHT)
                                                                              title:LocaleStringForKey(NSTagTitle, nil)];
                    }
                    return _tagHeaderView;
                }
                    
                default:
                    return nil;
            }
            
        }
            
        default:
            return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    switch (_type) {
        case TAG_TY:
            return 0;
            
        case SHARING_FILTER_TY:
            return SECTION_VIEW_HEIGHT;
            
        default:
            return 0;
    }
}

#pragma mark - WXWConnectorDelegate methods
- (void)connectStarted:(NSString *)url contentType:(WebItemType)contentType {
    
    [WXWUIUtils showActivityView:[APP_DELEGATE foundationView] text:LocaleStringForKey(NSLoadingTitle, nil)];
    [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(WebItemType)contentType {
    
    [WXWUIUtils closeActivityView];
    
    if ([XMLParser parserResponseXml:result
                                type:contentType
                                 MOC:_MOC
                   connectorDelegate:self
                                 url:url]) {
        
    } else {
        
        [WXWUIUtils showNotificationOnTopWithMsg:[self.errorMsgDic objectForKey:url]
                               alternativeMsg:LocaleStringForKey(NSLoadCountryFailedMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
    }
    
    [super connectDone:result url:url contentType:contentType];
}

- (void)connectCancelled:(NSString *)url contentType:(WebItemType)contentType {
    
    [WXWUIUtils closeActivityView];
    [super connectCancelled:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error url:(NSString *)url contentType:(WebItemType)contentType {
    
    NSString *msg = nil;
    if (error) {
        msg = [error localizedDescription];
    } else {
        msg = LocaleStringForKey(NSLoadCountryFailedMsg, nil);
    }
    
    [WXWUIUtils closeActivityView];
    
    [WXWUIUtils showNotificationOnTopWithMsg:msg
                                  msgType:ERROR_TY
                       belowNavigationBar:YES];
    
    // should be called at end of method to clear connFacade instance
    [super connectFailed:error url:url contentType:contentType];
}

#pragma mark - ECEditorDelegate method
- (void)chooseTags {
    switch (_type) {
        case TAG_TY:
            [self refreshTable];
            break;
            
        case SHARING_FILTER_TY:
        {
            [self loadFilterTags];
            [_tableView reloadData];
            break;
        }
            
        default:
            break;
    }
}

- (void)chooseDistance {
    [self loadFilterDistances];
    [_tableView reloadData];
}

- (void)doOK:(id)sender {
    
    [_composerDelegate addTagText];
    [self dismissModalViewControllerAnimated:YES];
}

@end
