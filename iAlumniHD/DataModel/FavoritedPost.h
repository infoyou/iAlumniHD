//
//  FavoritedPost.h
//  iAlumniHD
//
//  Created by Adam on 12-11-26.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FavoritedPost : NSManagedObject

@property (nonatomic, retain) NSNumber * favoritedBy;

@end
