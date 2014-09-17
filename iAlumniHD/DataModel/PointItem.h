//
//  PointItem.h
//  iAlumniHD
//
//  Created by Adam on 12-11-26.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PointItem : NSManagedObject

@property (nonatomic, retain) NSNumber * count;
@property (nonatomic, retain) NSString * detail;
@property (nonatomic, retain) NSNumber * experienceTotal;
@property (nonatomic, retain) NSNumber * experienceUnitValue;
@property (nonatomic, retain) NSNumber * memberId;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSNumber * pointTotal;
@property (nonatomic, retain) NSNumber * pointUnitValue;
@property (nonatomic, retain) NSNumber * type;

@end
