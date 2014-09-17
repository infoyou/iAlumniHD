//
//  CoreDataUtils.m
//  iAlumniHD
//
//  Created by Adam on 12-11-9.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "CoreDataUtils.h"
#import "DebugLogOutput.h"
#import "Report.h"
#import "Upcoming.h"
#import "Event.h"
#import "Tag.h"
#import "SortOption.h"
#import "Place.h"
#import "ComposerTag.h"
#import "ComposerPlace.h"
#import "Country.h"
#import "Post.h"
#import "Invitee.h"
#import "CommonUtils.h"
#import "TextConstants.h"
#import "Distance.h"

#define MAX_SAVED_RECORD_COUNT      50

@implementation CoreDataUtils

#pragma mark - common utility methods
+ (NSManagedObject *)fetchObjectFromMOC:(NSManagedObjectContext *)MOC
                             entityName:(NSString *)entityName
                              predicate:(NSPredicate *)predicate {
    
	NSFetchRequest *fetchRequest1 = [[[NSFetchRequest alloc] init] autorelease];
    fetchRequest1.entity = [NSEntityDescription entityForName:entityName
                                       inManagedObjectContext:MOC];
    if (predicate) {
        fetchRequest1.predicate = predicate;
    }
    fetchRequest1.fetchLimit = 1;
    fetchRequest1.includesPropertyValues = NO;
	
	NSError *error = nil;
	NSArray *objects = [MOC executeFetchRequest:fetchRequest1
                                          error:&error] ;
    if (nil == objects || 0 == [objects count]) {
        return nil;
    } else {
        return [objects lastObject];
    }
}

+ (NSArray *)loadObjectsFromMOC:(NSManagedObjectContext *)MOC
                     entityName:(NSString *)entityName
                      predicate:(NSPredicate *)predicate
         includesPropertyValues:(BOOL)includesPropertyValues {
    
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    fetchRequest.entity = [NSEntityDescription entityForName:entityName
                                      inManagedObjectContext:MOC];
    if (predicate) {
        fetchRequest.predicate = predicate;
    }
    
    fetchRequest.includesPropertyValues = includesPropertyValues;
	
	NSError *error = nil;
	NSArray *objects = [MOC executeFetchRequest:fetchRequest
                                          error:&error] ;
    return objects;
    
}

+ (NSArray *)fetchObjectsFromMOC:(NSManagedObjectContext *)MOC
                      entityName:(NSString *)entityName
                       predicate:(NSPredicate *)predicate {
    
	return [self loadObjectsFromMOC:MOC entityName:entityName predicate:predicate includesPropertyValues:YES];
}

+ (NSInteger)objectCountsFromMOC:(NSManagedObjectContext *)MOC
                      entityName:(NSString *)entityName
                       predicate:(NSPredicate *)predicate {
    return [self loadObjectsFromMOC:MOC entityName:entityName predicate:predicate includesPropertyValues:NO].count;
}

+ (NSArray *)fetchObjectsFromMOC:(NSManagedObjectContext *)MOC
                      entityName:(NSString *)entityName
                       predicate:(NSPredicate *)predicate
                       sortDescs:(NSMutableArray *)sortDescs
                   limitedNumber:(NSInteger)limitedNumber {
    
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    fetchRequest.entity = [NSEntityDescription entityForName:entityName
                                      inManagedObjectContext:MOC];
    if (predicate) {
        fetchRequest.predicate = predicate;
    }
    
    if (limitedNumber > 0) {
        fetchRequest.fetchLimit = limitedNumber;
    }
    
    if (sortDescs && sortDescs.count > 0) {
        fetchRequest.sortDescriptors = sortDescs;
    }
	
	NSError *error = nil;
	NSArray *objects = [MOC executeFetchRequest:fetchRequest
                                          error:&error] ;
    return objects;
}

+ (NSArray *)fetchObjectsFromMOC:(NSManagedObjectContext *)MOC
                      entityName:(NSString *)entityName
                       predicate:(NSPredicate *)predicate
                       sortDescs:(NSMutableArray *)sortDescs {
    
    return [self fetchObjectsFromMOC:MOC
                          entityName:entityName
                           predicate:predicate
                           sortDescs:sortDescs
                       limitedNumber:-1];
}

+ (BOOL)objectInMOC:(NSManagedObjectContext *)MOC
         entityName:(NSString *)entityName
          predicate:(NSPredicate *)predicate {
    
    if ([self fetchObjectFromMOC:MOC entityName:entityName predicate:predicate] != nil) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)saveMOCChange:(NSManagedObjectContext *)MOC {
    if ([MOC hasChanges]) {
        NSError *error;
        if (![MOC save:&error]) {
            debugLog(@"MOC save with error: %@", [error localizedDescription]);
            return NO;
        }
    }
    
    return YES;
}

+ (NSFetchedResultsController *)fetchObject:(NSManagedObjectContext *)aManagedObjectContext
                   fetchedResultsController:(NSFetchedResultsController *)aFetchedResultsController
                                 entityName:(NSString *)entityName
                         sectionNameKeyPath:(NSString *)sectionNameKeyPath
                            sortDescriptors:(NSMutableArray *)sortDescriptors
                                  predicate:(NSPredicate *)aPredicate {
    
    NSFetchedResultsController *result = nil;
    
    if (aFetchedResultsController == nil) {
		// set entity
		NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
		[fetchRequest setEntity:[NSEntityDescription entityForName:entityName
                                            inManagedObjectContext:aManagedObjectContext]];
		
		// set predicate
		if (aPredicate != nil) {
			[fetchRequest setPredicate:aPredicate];
		}
		
        if (sortDescriptors) {
            [fetchRequest setSortDescriptors:sortDescriptors];
        }
        
		NSString *cacheName = [[NSString alloc] initWithFormat:@"%@Cache", entityName];
        result = [[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                      managedObjectContext:aManagedObjectContext
                                                        sectionNameKeyPath:sectionNameKeyPath
                                                                 cacheName:cacheName] autorelease];
        
        [cacheName release];
		cacheName = nil;
		
	} else {
		result = aFetchedResultsController;
	}
	return result;
}

+ (BOOL)deleteEntitiesFromMOC:(NSManagedObjectContext *)MOC
                   entityName:(NSString *)entityName
                    predicate:(NSPredicate *)predicate {
    
    @autoreleasepool {
        
        NSFetchRequest * fetch = [[[NSFetchRequest alloc] init] autorelease];
        if (predicate) {
            fetch.predicate = predicate;
        }
        fetch.entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:MOC];
        fetch.includesPropertyValues = NO;
        NSError *error = nil;
        NSArray *result = [MOC executeFetchRequest:fetch error:&error];
        if ([result count] ==  0) {
            return YES;
        }
        
        if (nil == error) {
            for (id object in result) {
                [MOC deleteObject:object];
            }
            
            if (![MOC save:&error]) {
                debugLog(@"Delete all %@ failed: %@", entityName, [error domain]);
                return NO;
            } else {
                return YES;
            }
        } else {
            debugLog(@"Delete all %@ failed: %@", entityName, [error domain]);
            return NO;
        }
    }
}

+ (BOOL)deleteEntitiesFromMOC:(NSManagedObjectContext *)MOC
                     entities:(NSArray *)entities {
    
    @autoreleasepool {
        
        if (nil == MOC) {
            return NO;
        }
        
        if ([entities count] ==  0) {
            return YES;
        }
        
        NSError *error = nil;
        for (id object in entities) {
            [MOC deleteObject:object];
        }
        
        if (![MOC save:&error]) {
            debugLog(@"Delete failed: %@", [error domain]);
            return NO;
        } else {
            return YES;
        }
    }
}

#pragma mark - hot news
+ (void)clearOldItems:(NSManagedObjectContext *)MOC itemType:(ItemType)itemType {
    @autoreleasepool {
        NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
        
        NSString *objName = nil;
        switch (itemType) {
            case NEWS_TY:
                objName = @"News";
                break;
                
            case FEED_TY:
                objName = @"Post";
                break;
                
            case QA_TY:
                objName = @"QAItem";
                break;
                
            default:
                break;
        }
        
        [fetchRequest setEntity:[NSEntityDescription entityForName:objName
                                            inManagedObjectContext:MOC]];
        
        NSMutableArray *descriptors = [[[NSMutableArray alloc] init] autorelease];
        NSSortDescriptor *dateSortDesc = [[[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO] autorelease];
        [descriptors addObject:dateSortDesc];
        fetchRequest.sortDescriptors = descriptors;
        fetchRequest.includesPropertyValues = NO;
        
        NSError *error = nil;
        NSArray *result = [MOC executeFetchRequest:fetchRequest error:&error];
        if ([result count] > MAX_SAVED_RECORD_COUNT) {
            
            Report *lastNews = nil;
            Upcoming *lastPost = nil;
            Event *lastQAItem = nil;
            NSManagedObject *lastObj = [result objectAtIndex:(MAX_SAVED_RECORD_COUNT - 1)];
            switch (itemType) {
                case NEWS_TY:
                    lastNews = (Report *)lastObj;
                    break;
                    
                case FEED_TY:
                    lastPost = (Upcoming *)lastObj;
                    break;
                    
                case QA_TY:
                    lastQAItem = (Event *)lastObj;
                    break;
                    
                default:
                    break;
            }
            
            if (lastObj) {
                
                NSFetchRequest *deleteFetchRequest = [[[NSFetchRequest alloc] init] autorelease];
                deleteFetchRequest.entity = [NSEntityDescription entityForName:objName inManagedObjectContext:MOC];
                switch (itemType) {
                    case NEWS_TY:
                        deleteFetchRequest.predicate = [NSPredicate predicateWithFormat:@"(date < %@)", lastNews.date];
                        break;
                        
                    case FEED_TY:
                        deleteFetchRequest.predicate = [NSPredicate predicateWithFormat:@"(date < %@)", lastPost.date];
                        break;
                        
                    case QA_TY:
                        deleteFetchRequest.predicate = [NSPredicate predicateWithFormat:@"(date < %@)", lastQAItem.date];
                        break;
                        
                    default:
                        break;
                }
                
                deleteFetchRequest.includesPropertyValues = NO;
                
                error = nil;
                NSArray *toBeDeleteObjs = [MOC executeFetchRequest:deleteFetchRequest error:&error];
                for (id obj in toBeDeleteObjs) {
                    long long objId = 0;
                    switch (itemType) {
                        case NEWS_TY:
                            objId = ((Report *)lastObj).newsId.longLongValue;
                            break;
                            
                        case FEED_TY:
                            objId = ((Upcoming *)lastObj).eventId.longLongValue;
                            break;
                            
                        case QA_TY:
                            objId = ((Event *)lastObj).eventId.longLongValue;
                            break;
                            
                        default:
                            break;
                    }
                    
                    NSPredicate *deleteCommentPredicate = [NSPredicate predicateWithFormat:@"(parentId == %lld)", objId];
                    [CoreDataUtils deleteEntitiesFromMOC:MOC entityName:@"Comment" predicate:deleteCommentPredicate];
                    
                    [MOC deleteObject:obj];
                }
                [self saveMOCChange:MOC];
            }
        }
    }
}

#pragma mark - tag
+ (void)resetTags:(NSManagedObjectContext *)MOC clearAll:(BOOL)clearAll {
    NSArray *tags = [CoreDataUtils fetchObjectsFromMOC:MOC entityName:@"Tag" predicate:nil];
    if (clearAll) {
        for (Tag *tag in tags) {
            tag.selected = [NSNumber numberWithBool:NO];
        }
        
    } else {
        for (Tag *tag in tags) {
            if (tag.tagId.longLongValue == TAG_ALL_ID) {
                tag.selected = [NSNumber numberWithBool:YES];
            } else {
                tag.selected = [NSNumber numberWithBool:NO];
            }
        }
    }
    
    [CoreDataUtils saveMOCChange:MOC];
}

+ (void)createComposerTagsForGroupId:(NSString *)groupId
                                 MOC:(NSManagedObjectContext *)MOC {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(groupId == %@)", groupId];
    
    NSArray *tags = [self fetchObjectsFromMOC:MOC
                                   entityName:@"Tag"
                                    predicate:predicate];
    for (Tag *tag in tags) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(tagId == %@)", tag.tagId];
        ComposerTag *checkPoint = (ComposerTag *)[self fetchObjectFromMOC:MOC entityName:@"ComposerTag" predicate:predicate];
        if (checkPoint) {
            checkPoint.selected = [NSNumber numberWithBool:NO];
            checkPoint.tagName = tag.tagName;
            checkPoint.order = tag.order;
            continue;
        }
        
        ComposerTag *composerTag = (ComposerTag *)[NSEntityDescription insertNewObjectForEntityForName:@"ComposerTag"
                                                                                inManagedObjectContext:MOC];
        composerTag.tagId = tag.tagId;
        composerTag.tagName = tag.tagName;
        composerTag.type = tag.type;
        composerTag.order = tag.order;
        composerTag.selected = [NSNumber numberWithBool:NO];
    }
    [self saveMOCChange:MOC];
}

#pragma mark - sort options
+ (void)prepareVenueSortOptions:(NSManagedObjectContext *)MOC {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((optionId == %d) AND (usageType == %d))", SI_SORT_BY_DISTANCE_TY, VENUE_ITEM_TY];
    SortOption *checkPoint = (SortOption *)[CoreDataUtils fetchObjectFromMOC:MOC
                                                                  entityName:@"SortOption"
                                                                   predicate:predicate];
    
    NSString *name = LocaleStringForKey(NSSortByDistanceTitle, nil);
    if (checkPoint) {
        checkPoint.optionName = name;
    } else {
        SortOption *distanceOption = (SortOption *)[NSEntityDescription insertNewObjectForEntityForName:@"SortOption"
                                                                                 inManagedObjectContext:MOC];
        distanceOption.optionId = [NSNumber numberWithInt:SI_SORT_BY_DISTANCE_TY];
        distanceOption.optionName = name;
        distanceOption.selected = [NSNumber numberWithBool:YES];
        distanceOption.usageType = [NSNumber numberWithInt:VENUE_ITEM_TY];
    }
    
    /*
     checkPoint = nil;
     name = LocaleStringForKey(NSSortByMyCountryRateTitle, nil);
     predicate = [NSPredicate predicateWithFormat:@"(optionId == %d)", SI_SORT_BY_MY_CO_LIKE_TY];
     checkPoint = (SortOption *)[CoreDataUtils fetchObjectFromMOC:MOC
     entityName:@"SortOption"
     predicate:predicate];
     if (checkPoint) {
     checkPoint.optionName = name;
     } else {
     SortOption *myCountryOption = (SortOption *)[NSEntityDescription insertNewObjectForEntityForName:@"SortOption"
     inManagedObjectContext:MOC];
     myCountryOption.optionId = [NSNumber numberWithInt:SI_SORT_BY_MY_CO_LIKE_TY];
     myCountryOption.optionName = name;
     myCountryOption.selected = [NSNumber numberWithBool:NO];
     myCountryOption.usageType = [NSNumber numberWithInt:VENUE_ITEM_TY];
     }
     */
    
    checkPoint = nil;
    name = LocaleStringForKey(NSSortByCommonRateTitle, nil);
    predicate = [NSPredicate predicateWithFormat:@"((optionId == %d) AND (usageType == %d))",
                 SI_SORT_BY_LIKE_COUNT_TY, VENUE_ITEM_TY];
    checkPoint = (SortOption *)[CoreDataUtils fetchObjectFromMOC:MOC
                                                      entityName:@"SortOption"
                                                       predicate:predicate];
    if (checkPoint) {
        checkPoint.optionName = name;
    } else {
        SortOption *likeCountOption = (SortOption *)[NSEntityDescription insertNewObjectForEntityForName:@"SortOption"
                                                                                  inManagedObjectContext:MOC];
        likeCountOption.optionId = [NSNumber numberWithInt:SI_SORT_BY_LIKE_COUNT_TY];
        likeCountOption.optionName = name;
        likeCountOption.selected = [NSNumber numberWithBool:NO];
        likeCountOption.usageType = [NSNumber numberWithInt:VENUE_ITEM_TY];
    }
    
    checkPoint = nil;
    name = LocaleStringForKey(NSSortByCommentTitle, nil);
    predicate = [NSPredicate predicateWithFormat:@"((optionId == %d) AND (usageType == %d))", SI_SORT_BY_COMMENT_COUNT_TY, VENUE_ITEM_TY];
    checkPoint = (SortOption *)[CoreDataUtils fetchObjectFromMOC:MOC
                                                      entityName:@"SortOption"
                                                       predicate:predicate];
    if (checkPoint) {
        checkPoint.optionName = name;
    } else {
        SortOption *commentCountOption = (SortOption *)[NSEntityDescription insertNewObjectForEntityForName:@"SortOption"
                                                                                     inManagedObjectContext:MOC];
        commentCountOption.optionId = [NSNumber numberWithInt:SI_SORT_BY_COMMENT_COUNT_TY];
        commentCountOption.optionName = name;
        commentCountOption.selected = [NSNumber numberWithBool:NO];
        commentCountOption.usageType = [NSNumber numberWithInt:VENUE_ITEM_TY];
    }
    
    SAVE_MOC(MOC);
}

+ (void)preparePostSortOptions:(NSManagedObjectContext *)MOC {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((optionId == %d) AND (usageType == %d))", SORT_BY_ID_TY, POST_ITEM_TY];
    SortOption *checkPoint = (SortOption *)[CoreDataUtils fetchObjectFromMOC:MOC
                                                                  entityName:@"SortOption"
                                                                   predicate:predicate];
    NSString *name = LocaleStringForKey(NSSortByCreateTimeTitle, nil);
    if (checkPoint) {
        checkPoint.optionName = name;
    } else {
        SortOption *createTimeOption = (SortOption *)[NSEntityDescription insertNewObjectForEntityForName:@"SortOption"
                                                                                   inManagedObjectContext:MOC];
        createTimeOption.optionId = [NSNumber numberWithInt:SORT_BY_ID_TY];
        createTimeOption.optionName = name;
        createTimeOption.selected = [NSNumber numberWithBool:YES];
        createTimeOption.usageType = [NSNumber numberWithInt:POST_ITEM_TY];
    }
    
    checkPoint = nil;
    predicate = [NSPredicate predicateWithFormat:@"((optionId == %d) AND (usageType == %d))", SORT_BY_PRAISE_COUNT_TY, POST_ITEM_TY];
    checkPoint = (SortOption *)[CoreDataUtils fetchObjectFromMOC:MOC
                                                      entityName:@"SortOption"
                                                       predicate:predicate];
    name = LocaleStringForKey(NSSortByPraiseTitle, nil);
    if (checkPoint) {
        checkPoint.optionName = name;
    } else {
        SortOption *praiseCountOption = (SortOption *)[NSEntityDescription insertNewObjectForEntityForName:@"SortOption"
                                                                                    inManagedObjectContext:MOC];
        praiseCountOption.optionId = [NSNumber numberWithInt:SORT_BY_PRAISE_COUNT_TY];
        praiseCountOption.optionName = name;
        praiseCountOption.selected = [NSNumber numberWithBool:NO];
        praiseCountOption.usageType = [NSNumber numberWithInt:POST_ITEM_TY];
    }
    
    checkPoint = nil;
    predicate = [NSPredicate predicateWithFormat:@"((optionId == %d) AND (usageType == %d))", SORT_BY_COMMENT_COUNT_TY, POST_ITEM_TY];
    checkPoint = (SortOption *)[CoreDataUtils fetchObjectFromMOC:MOC
                                                      entityName:@"SortOption"
                                                       predicate:predicate];
    name = LocaleStringForKey(NSSortByCommentCountTitle, nil);
    if (checkPoint) {
        checkPoint.optionName = name;
    } else {
        SortOption *commentCountOption = (SortOption *)[NSEntityDescription insertNewObjectForEntityForName:@"SortOption"
                                                                                     inManagedObjectContext:MOC];
        commentCountOption.optionId = [NSNumber numberWithInt:SORT_BY_COMMENT_COUNT_TY];
        commentCountOption.optionName = name;
        commentCountOption.selected = [NSNumber numberWithBool:NO];
        commentCountOption.usageType = [NSNumber numberWithInt:POST_ITEM_TY];
    }
    
    [CoreDataUtils saveMOCChange:MOC];
    
}

+ (void)resetSortOptions:(NSManagedObjectContext *)MOC {
    NSArray *options = [CoreDataUtils fetchObjectsFromMOC:MOC entityName:@"SortOption" predicate:nil];
    for (SortOption *option in options) {
        if (option.optionId.intValue == SORT_BY_ID_TY) {
            option.selected = [NSNumber numberWithBool:YES];
        } else {
            option.selected = [NSNumber numberWithBool:NO];
        }
    }
    [CoreDataUtils saveMOCChange:MOC];
}

#pragma mark - place
+ (void)resetPlaces:(NSManagedObjectContext *)MOC {
    NSArray *places = [CoreDataUtils fetchObjectsFromMOC:MOC entityName:@"Place" predicate:nil];
    for (Place *place in places) {
        place.selected = [NSNumber numberWithBool:NO];
    }
    [CoreDataUtils saveMOCChange:MOC];
}

+ (void)resetDistance:(NSManagedObjectContext *)MOC {
    NSArray *distances = [CoreDataUtils fetchObjectsFromMOC:MOC entityName:@"Distance" predicate:nil];
    for (Distance *distance in distances) {
        if (distance.valueFloat.floatValue == ALL_LOCATION_RADIUS) {
            distance.selected = [NSNumber numberWithBool:YES];
        } else {
            distance.selected = [NSNumber numberWithBool:NO];
        }
    }
    SAVE_MOC(MOC);
}

+ (void)resetComposerPlaces:(NSManagedObjectContext *)MOC {
    NSArray *places = [CoreDataUtils fetchObjectsFromMOC:MOC entityName:@"ComposerPlace" predicate:nil];
    for (ComposerPlace *place in places) {
        place.selected = [NSNumber numberWithBool:NO];
    }
    [CoreDataUtils saveMOCChange:MOC];
}

+ (void)createComposerPlaces:(NSManagedObjectContext *)MOC {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(placeType == %d)", NORMAL_PLACE_TY];
    
    NSArray *places = [self fetchObjectsFromMOC:MOC entityName:@"Place" predicate:predicate];
    for (Place *place in places) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(placeId == %@)", place.placeId];
        ComposerPlace *checkPoint = (ComposerPlace *)[self fetchObjectFromMOC:MOC entityName:@"ComposerPlace" predicate:predicate];
        if (checkPoint) {
            checkPoint.selected = [NSNumber numberWithBool:NO];
            continue;
        }
        
        ComposerPlace *composerPlace = (ComposerPlace *)[NSEntityDescription insertNewObjectForEntityForName:@"ComposerPlace"
                                                                                      inManagedObjectContext:MOC];
        composerPlace.placeId = place.placeId;
        composerPlace.cityName = place.cityName;
        composerPlace.placeName = place.placeName;        
        composerPlace.cityId = place.cityId;
        composerPlace.selected = [NSNumber numberWithBool:NO];
        composerPlace.centerItemId = place.centerItemId;
        composerPlace.distance = place.distance;
    }
    [self saveMOCChange:MOC];
}

#pragma mark - country
+ (void)resetCountries:(NSManagedObjectContext *)MOC {
    
    Country *country = (Country *)[CoreDataUtils fetchObjectFromMOC:MOC entityName:@"Country" predicate:SELECTED_PREDICATE];
    if (country) {
        country.selected = [NSNumber numberWithBool:NO];
    }
    
    [CoreDataUtils saveMOCChange:MOC];
}

+ (void)resetCountryAllObjectName:(NSManagedObjectContext *)MOC {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(countryId == %lld)", CO_ALL_ID];
    Country *all = (Country *)[CoreDataUtils fetchObjectFromMOC:MOC entityName:@"Country" predicate:predicate];
    if (all) {
        all.selected = [NSNumber numberWithBool:YES];
        all.name = LocaleStringForKey(NSAllTitle, nil);
    }
}

#pragma mark - assemble email from address book
+ (void)resetSelectedInvitee:(NSManagedObjectContext *)MOC snsType:(UserSnsType)snsType {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(sourceType == %d)", snsType];
    NSArray *invitees = [self fetchObjectsFromMOC:MOC entityName:@"Invitee" predicate:predicate];
    for (Invitee *invitee in invitees) {
        invitee.selected = [NSNumber numberWithBool:NO];
    }
    
    SAVE_MOC(MOC);
}

@end
