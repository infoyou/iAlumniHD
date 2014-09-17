//
//  News.h
//  iAlumniHD
//
//  Created by Adam on 13-3-15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface News : NSManagedObject

@property (nonatomic, retain) NSString * date;
@property (nonatomic, retain) NSString * dateSeparator;
@property (nonatomic, retain) NSString * drawnFrom;
@property (nonatomic, retain) NSNumber * elapsedDayCount;
@property (nonatomic, retain) NSString * elapsedTime;
@property (nonatomic, retain) NSNumber * imageAttached;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSNumber * newsId;
@property (nonatomic, retain) NSNumber * originalImageHeight;
@property (nonatomic, retain) NSNumber * originalImageWidth;
@property (nonatomic, retain) NSString * subTitle;
@property (nonatomic, retain) NSString * thumbnailUrl;
@property (nonatomic, retain) NSNumber * timestamp;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSString * url;

@end
