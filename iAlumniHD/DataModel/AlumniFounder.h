//
//  AlumniFounder.h
//  iAlumniHD
//
//  Created by Adam on 12-11-26.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Alumni.h"


@interface AlumniFounder : Alumni

@property (nonatomic, retain) NSNumber * brandId;
@property (nonatomic, retain) NSString * title;

@end
