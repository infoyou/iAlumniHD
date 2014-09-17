//
//  EventTopic.h
//  iAlumniHD
//
//  Created by Adam on 12-11-26.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface EventTopic : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * eventId;
@property (nonatomic, retain) NSNumber * sequenceNumber;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * topicId;
@property (nonatomic, retain) NSNumber * voted;

@end
