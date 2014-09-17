//
//  Messages.h
//  iAlumniHD
//
//  Created by Adam on 12-11-26.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Messages : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * messageId;
@property (nonatomic, retain) NSNumber * quickViewed;
@property (nonatomic, retain) NSNumber * reviewed;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSString * url;

@end
