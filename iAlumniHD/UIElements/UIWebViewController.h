//
//  UIWebViewController.h
//  iAlumniHD
//
//  Created by Adam on 12-10-15.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

@interface UIWebViewController : RootViewController <UIWebViewDelegate> {
    
    BOOL _sessionExpired;
    BOOL _closeAvailable;
}

- (id)initWithUrl:(NSString *)url frame:(CGRect)frame isNeedClose:(BOOL)isNeedClose;

@end
