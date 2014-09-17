//
//  Place2ThingViewController.h
//  iAlumniHD
//
//  Created by user on 12-6-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "ECEditorDelegate.h"

@interface Place2ThingViewController : RootViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, ECEditorDelegate>
{
    UITextField *thingText;
    UITextField *placeText;
    NSString *thingTextVal;
    NSString *placeTextVal;
    
    NSFetchedResultsController *_filterTagFetchedRC;
    NSFetchedResultsController *_filterPlaceFetchedRC;

    CGFloat _animatedDistance;
  
  UIView *_thingSectionHeaderView;
  UIView *_placeSectionHeaderView;
}

@property (nonatomic, retain) UITextField *thingText;
@property (nonatomic, retain) UITextField *placeText;
@property (nonatomic, copy) NSString *thingTextVal;
@property (nonatomic, copy) NSString *placeTextVal;

- (void)loadFilterTags;
- (void)loadFilterPlaces;

- (id)initWithMOC:(NSManagedObjectContext *)MOC aPlaces:(NSString*)aPlaces aThings:(NSString*)aThings;

@end
