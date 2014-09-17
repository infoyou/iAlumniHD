//
//  Chat.h
//  iAlumniHD
//
//  Created by Adam on 12-11-26.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Chat : NSManagedObject

@property (nonatomic, retain) NSNumber * chartId;
@property (nonatomic, retain) NSString * createTime;
@property (nonatomic, retain) NSNumber * isWrite;
@property (nonatomic, retain) NSString * msg;
@property (nonatomic, retain) NSNumber * orders;
@property (nonatomic, retain) NSString * readTime;
@property (nonatomic, retain) NSNumber * status;

@end
