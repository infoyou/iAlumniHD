//
//  PlaceListViewController.m
//  ExpatCircle
//
//  Created by Mobguang on 11-11-24.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "PlaceListViewController.h"
#import "PlaceCell.h"
#import "Place.h"

@implementation PlaceListViewController
@synthesize _popVC;

- (id)initWithMOC:(NSManagedObjectContext *)MOC
         composerDelegate:(id<ComposerDelegate>)composerDelegate
{
    self = [super initWithMOC:MOC];
    
    if (self) {
        _composerDelegate = composerDelegate;
    }
    
    return self;
}

#pragma mark - refresh place list after location changed
- (void)refreshPlaceList:(NSNotification *)notification {
    [self refreshTable];
}

#pragma mark - lifecycle methods

- (void)dealloc {
    
    _popVC = nil;
    
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView.backgroundColor = [UIColor whiteColor];
    
    if (![CoreDataUtils objectInMOC:_MOC entityName:@"Place" predicate:nil]) {
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSFetchPlacesFailedMsg, nil)
                                      msgType:WARNING_TY
                           belowNavigationBar:YES];
    } else {
        [self refreshTable];
    }
}

#pragma mark - override methods

- (void)setPredicate {
    self.entityName = @"Place";
    
    self.descriptors = [NSMutableArray array];
    NSSortDescriptor *descriptor = [[[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES] autorelease];
    [self.descriptors addObject:descriptor];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_fetchedRC.fetchedObjects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *kCellIdentifier = @"kPlaceCell";
    
    PlaceCell *cell = (PlaceCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (nil == cell) {
        cell = [[[PlaceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier] autorelease];
    }
    Place *place = [_fetchedRC objectAtIndexPath:indexPath];
    [cell drawPlace:place];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Place *selectedPlace = (Place *)[_fetchedRC objectAtIndexPath:indexPath];
    
    NSString *distance = [NSString stringWithFormat:@"%.01f %@",
                          selectedPlace.distance.floatValue * 1000,
                          LocaleStringForKey(NSMeterTitle, nil)];
    
    CGSize size = [distance sizeWithFont:FONT(13)
                       constrainedToSize:CGSizeMake(LIST_WIDTH, CGFLOAT_MAX)
                           lineBreakMode:UILineBreakModeWordWrap];
    
    size = [selectedPlace.placeName sizeWithFont:BOLD_FONT(14)
                               constrainedToSize:CGSizeMake(self.view.frame.size.width -
                                                            size.width - MARGIN - MARGIN * 4,
                                                            CGFLOAT_MAX)
                                   lineBreakMode:UILineBreakModeWordWrap];
    
    CGFloat height = size.height + MARGIN * 4;
    
    if (height < 44.0f) {
        height = 44.0f;
    }
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    for (Place *place in _fetchedRC.fetchedObjects) {
        place.selected = [NSNumber numberWithBool:NO];
    }
    
    Place *selectedPlace = (Place *)[_fetchedRC objectAtIndexPath:indexPath];
    selectedPlace.selected = [NSNumber numberWithBool:YES];
    
    [CoreDataUtils saveMOCChange:_MOC];
    
    [AppManager instance].composerPlace = selectedPlace.placeName;
    
    if (_popVC) {
        [_popVC dismissPopoverAnimated:NO];
        [_composerDelegate addPlaceText];
    }
    
    //  [self.navigationController popViewControllerAnimated:YES];
}

@end
