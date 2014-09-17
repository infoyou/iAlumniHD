//
//  ServiceItemSection.h
//  iAlumniHD
//
//  Created by Adam on 12-11-26.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ServiceItem, ServiceItemSectionParam;

@interface ServiceItemSection : NSManagedObject

@property (nonatomic, retain) NSNumber * cellCount;
@property (nonatomic, retain) NSString * cellList;
@property (nonatomic, retain) NSNumber * hasSpecialParams;
@property (nonatomic, retain) NSString * sectionType;
@property (nonatomic, retain) NSNumber * sortKey;
@property (nonatomic, retain) ServiceItem *serviceItem;
@property (nonatomic, retain) NSSet *specialParams;
@end

@interface ServiceItemSection (CoreDataGeneratedAccessors)

- (void)addSpecialParamsObject:(ServiceItemSectionParam *)value;
- (void)removeSpecialParamsObject:(ServiceItemSectionParam *)value;
- (void)addSpecialParams:(NSSet *)values;
- (void)removeSpecialParams:(NSSet *)values;
@end
