//
//  ItemPropertiesListViewController.h
//  iAlumniHD
//
//  Created by Adam on 12-11-22.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "BaseListViewController.h"
#import "ECEditorDelegate.h"
#import "ECPickerViewDelegate.h"
#import "ComposerDelegate.h"

@class ItemListSectionView;

@interface ItemPropertiesListViewController : BaseListViewController <ECEditorDelegate> {
    
    BOOL isFromComposer;
    
@private
    ItemPropertyType _type;
    NSFetchedResultsController *_filterTagFetchedRC;
    NSFetchedResultsController *_filterPlaceFetchedRC;
    NSFetchedResultsController *_filterCountryFetchedRC;
    
    ItemListSectionView *_placeHeaderView;
    ItemListSectionView *_tagHeaderView;
    ItemListSectionView *_favoriteHeaderView;
    
    long long _lastSelectedCountryId;
    
    BOOL _moveDownUI;
    
    TagType _tagType;

    id<ECEditorDelegate> _parentEditorDelegate;
    id<ComposerDelegate> _composerDelegate;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder
 backToHomeAction:(SEL)backToHomeAction
     propertyType:(ItemPropertyType)propertyType
          tagType:(TagType)tagType;

- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder
 backToHomeAction:(SEL)backToHomeAction
parentEditorDelegate:(id<ECEditorDelegate>)parentEditorDelegate
     propertyType:(ItemPropertyType)propertyType
  filterCountryId:(long long)filterCountryId
          tagType:(TagType)tagType;

- (id)initWithMOC:(NSManagedObjectContext *)MOC
 composerDelegate:(id<ComposerDelegate>)composerDelegate
     propertyType:(ItemPropertyType)propertyType
       moveDownUI:(BOOL)moveDownUI
          tagType:(TagType)tagType;

@end
