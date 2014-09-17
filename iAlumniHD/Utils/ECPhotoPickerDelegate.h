//
//  ECPhotoPickerDelegate.h
//  iAlumniHD
//
//  Created by Adam on 12-11-21.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ECPhotoPickerDelegate <NSObject>

@required
- (void)selectPhoto:(UIImage *)selectedImage;

@end
