//
//  LikedItemId.h
//  iAlumniHD
//
//  Created by Adam on 12-11-26.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Liker;

@interface LikedItemId : NSManagedObject

@property (nonatomic, retain) NSString * itemId;
@property (nonatomic, retain) Liker *likedBy;

@end
