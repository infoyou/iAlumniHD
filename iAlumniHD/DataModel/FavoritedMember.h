//
//  FavoritedMember.h
//  iAlumniHD
//
//  Created by Adam on 12-11-26.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Member.h"


@interface FavoritedMember : Member

@property (nonatomic, retain) NSNumber * favoritedBy;

@end
