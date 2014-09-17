//
//  ClassGroup.h
//  iAlumniHD
//
//  Created by Adam on 12-11-26.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ClassGroup : NSManagedObject

@property (nonatomic, retain) NSString * classId;
@property (nonatomic, retain) NSString * cnCourse;
@property (nonatomic, retain) NSString * cnName;
@property (nonatomic, retain) NSString * enCourse;
@property (nonatomic, retain) NSString * enName;

@end
