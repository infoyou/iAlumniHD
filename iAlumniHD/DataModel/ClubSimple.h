//
//  ClubSimple.h
//  iAlumniHD
//
//  Created by Adam on 12-11-26.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ClubSimple : NSManagedObject

@property (nonatomic, retain) NSNumber * clubId;
@property (nonatomic, retain) NSNumber * eventcount;
@property (nonatomic, retain) NSString * eventDesc;
@property (nonatomic, retain) NSString * ifadmin;
@property (nonatomic, retain) NSString * ifmember;
@property (nonatomic, retain) NSNumber * lastEventNum;
@property (nonatomic, retain) NSNumber * membercount;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * newEventNum;

@end
