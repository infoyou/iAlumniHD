//
//  UnicodeUtils.h
//  iAlumniHD
//
//  Created by Adam on 12-11-15.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UnicodeUtils : NSObject {
    
}

+ (char)pinyinFirstLetter:(NSUInteger)hanzi;

+ (NSString *)Chinese_To_Hex:(NSString *)ChineseStr;

@end
