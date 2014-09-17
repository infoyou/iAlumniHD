//
//  Brand.h
//  iAlumniHD
//
//  Created by Adam on 13-3-12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Brand : NSManagedObject

@property (nonatomic, retain) NSString * avatarUrl;
@property (nonatomic, retain) NSString * bio;
@property (nonatomic, retain) NSNumber * brandId;
@property (nonatomic, retain) NSNumber * commentCount;
@property (nonatomic, retain) NSString * companyType;
@property (nonatomic, retain) NSString * couponInfo;
@property (nonatomic, retain) NSNumber * itemTotal;
@property (nonatomic, retain) NSString * latestComment;
@property (nonatomic, retain) NSString * latestCommentBranchName;
@property (nonatomic, retain) NSString * latestCommentElapsedTime;
@property (nonatomic, retain) NSNumber * latestCommenterId;
@property (nonatomic, retain) NSString * latestCommenterName;
@property (nonatomic, retain) NSNumber * latestCommentTimestamp;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * nearestDistance;
@property (nonatomic, retain) NSString * tags;

@end
