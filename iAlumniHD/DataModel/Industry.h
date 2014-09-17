//
//  Industry.h
//  iAlumniHD
//
//  Created by Adam on 12-11-26.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Industry : NSManagedObject

@property (nonatomic, retain) NSString * cnName;
@property (nonatomic, retain) NSString * enName;
@property (nonatomic, retain) NSString * industryId;

@end
