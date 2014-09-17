//
//  FavoritedServiceItem.h
//  iAlumniHD
//
//  Created by Adam on 12-11-26.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ServiceItem.h"


@interface FavoritedServiceItem : ServiceItem

@property (nonatomic, retain) NSNumber * favoritedBy;

@end
