//
//  Club.h
//  iAlumniHD
//
//  Created by Adam on 12-12-11.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Club : NSManagedObject

@property (nonatomic, retain) NSString * activity;
@property (nonatomic, retain) NSString * badgeNum;
@property (nonatomic, retain) id baseInfoData;
@property (nonatomic, retain) NSNumber * clubId;
@property (nonatomic, retain) NSString * clubName;
@property (nonatomic, retain) NSString * clubType;
@property (nonatomic, retain) NSString * hostSupTypeValue;
@property (nonatomic, retain) NSString * hostTypeValue;
@property (nonatomic, retain) NSString * iconUrl;
@property (nonatomic, retain) NSString * member;
@property (nonatomic, retain) NSString * postAuthor;
@property (nonatomic, retain) NSString * postDesc;
@property (nonatomic, retain) id postInfoContentData;
@property (nonatomic, retain) NSString * postNum;
@property (nonatomic, retain) NSString * postTime;
@property (nonatomic, retain) NSNumber * showOrder;
@property (nonatomic, retain) NSNumber * usageType;

@end
