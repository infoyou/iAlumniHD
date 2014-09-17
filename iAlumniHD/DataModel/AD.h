//
//  AD.h
//  iAlumniHD
//
//  Created by Adam on 12-11-26.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AD : NSManagedObject

@property (nonatomic, retain) NSNumber * adId;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSString * website;

@end
