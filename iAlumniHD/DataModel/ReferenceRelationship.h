//
//  ReferenceRelationship.h
//  iAlumniHD
//
//  Created by Adam on 12-12-11.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RecommendAlumni;

@interface ReferenceRelationship : NSManagedObject

@property (nonatomic, retain) NSNumber * endAlumniId;
@property (nonatomic, retain) NSNumber * referenceId;
@property (nonatomic, retain) NSNumber * startAlumniId;
@property (nonatomic, retain) RecommendAlumni *reference;

@end
