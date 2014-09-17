//
//  RelationshipLink.h
//  iAlumniHD
//
//  Created by Adam on 12-12-11.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RelationshipLink : NSManagedObject

@property (nonatomic, retain) NSNumber * favorited;
@property (nonatomic, retain) NSNumber * linkId;
@property (nonatomic, retain) NSString * referenceAvatarUrl;
@property (nonatomic, retain) NSNumber * referenceId;
@property (nonatomic, retain) NSString * referenceName;
@property (nonatomic, retain) NSNumber * referenceType;
@property (nonatomic, retain) NSString * withMeEvent;
@property (nonatomic, retain) NSString * withTargetEvent;

@end
