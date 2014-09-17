//
//  AlumniWithMeLink.h
//  iAlumniHD
//
//  Created by Adam on 12-12-11.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AlumniWithMeLink : NSManagedObject

@property (nonatomic, retain) NSString * classificationName;
@property (nonatomic, retain) NSNumber * classificationType;
@property (nonatomic, retain) NSNumber * linkId;
@property (nonatomic, retain) NSString * linkName;
@property (nonatomic, retain) NSNumber * sortKey;

@end
