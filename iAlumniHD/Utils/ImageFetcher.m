//
//  ImageFetcher.m
//  iAlumniHD
//
//  Created by Adam on 12-11-9.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ImageFetcher.h"

@interface ImageFetcher()
@property (nonatomic, retain) NSMutableDictionary *urlDic;
@end

@implementation ImageFetcher

@synthesize urlDic = _urlDic;

- (void)dealloc {
  
  self.urlDic = nil;
  
  [super dealloc];
}

#pragma mark - get image

- (void)fetchImage:(NSString *)url showAlertMsg:(BOOL)showAlertMsg {
  
  if (nil == self.urlDic) {
    self.urlDic = [NSMutableDictionary dictionary];
  }
  
  if (url && url.length > 0) {
    [self.urlDic setObject:url forKey:url];
    
    [self asyncGet:url showAlertMsg:showAlertMsg];
  }
}

- (BOOL)imageBeingLoaded:(NSString *)url {
  if (self.urlDic) {
    if ([self.urlDic objectForKey:url] && [(NSString *)[self.urlDic objectForKey:url] length] > 0) {
      return YES;
    }
  }
  
  return NO;
}

- (void)cancelFetchImage:(NSString *)url {
  
}

@end
