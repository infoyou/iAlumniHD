//
//  ComposerPlace.h
//  iAlumniHD
//
//  Created by Adam on 12-11-26.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ComposerPlace : NSManagedObject

@property (nonatomic, retain) NSNumber * centerItemId;
@property (nonatomic, retain) NSNumber * cityId;
@property (nonatomic, retain) NSString * cityName;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSString * placeId;
@property (nonatomic, retain) NSString * placeName;
@property (nonatomic, retain) NSNumber * selected;

@end
