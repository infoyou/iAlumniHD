//
//  RecommendAlumni.h
//  iAlumniHD
//
//  Created by Adam on 12-12-11.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Alumni.h"

@class ReferenceRelationship;

@interface RecommendAlumni : Alumni

@property (nonatomic, retain) NSSet *links;
@end

@interface RecommendAlumni (CoreDataGeneratedAccessors)

- (void)addLinksObject:(ReferenceRelationship *)value;
- (void)removeLinksObject:(ReferenceRelationship *)value;
- (void)addLinks:(NSSet *)values;
- (void)removeLinks:(NSSet *)values;
@end
