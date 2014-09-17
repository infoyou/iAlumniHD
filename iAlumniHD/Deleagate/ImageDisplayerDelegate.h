//
//  ImageDisplayerDelegate.h
//  iAlumniHD
//
//  Created by Adam on 12-11-16.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ImageDisplayerDelegate <NSObject>

@optional
- (void)saveDisplayedImage:(UIImage *)image;

@required
- (void)registerImageUrl:(NSString *)url;

@end
