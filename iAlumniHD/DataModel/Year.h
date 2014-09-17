//
//  Year.h
//  iAlumniHD
//
//  Created by Adam on 12-11-26.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Year : NSManagedObject

@property (nonatomic, retain) NSString * count;
@property (nonatomic, retain) NSNumber * selected;
@property (nonatomic, retain) NSNumber * yearId;

@end
