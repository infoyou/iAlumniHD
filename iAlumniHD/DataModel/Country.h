//
//  Country.h
//  iAlumniHD
//
//  Created by Adam on 12-11-26.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Country : NSManagedObject

@property (nonatomic, retain) NSNumber * countryId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * selected;

@end
