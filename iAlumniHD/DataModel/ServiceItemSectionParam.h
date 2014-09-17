//
//  ServiceItemSectionParam.h
//  iAlumniHD
//
//  Created by Adam on 12-11-26.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ServiceItemSection;

@interface ServiceItemSectionParam : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * sortKey;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) ServiceItemSection *section;

@end
