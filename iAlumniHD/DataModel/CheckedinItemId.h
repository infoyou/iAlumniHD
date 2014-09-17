//
//  CheckedinItemId.h
//  iAlumniHD
//
//  Created by Adam on 12-11-26.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CheckedinMember;

@interface CheckedinItemId : NSManagedObject

@property (nonatomic, retain) NSString * itemId;
@property (nonatomic, retain) CheckedinMember *checkedinBy;

@end
