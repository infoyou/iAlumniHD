//
//  SearchKeyword.h
//  iAlumniHD
//
//  Created by Adam on 12-11-26.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SearchKeyword : NSManagedObject

@property (nonatomic, retain) NSString * searchString;
@property (nonatomic, retain) NSNumber * timestamp;

@end
