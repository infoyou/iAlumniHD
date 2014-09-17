//
//  ImageCache.m
//  iAlumniHD
//
//  Created by Adam on 12-11-9.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ImageCache.h"
#import "Statement.h"
#import "DBConnection.h"
#import "ImageFetcher.h"
#import "DebugLogOutput.h"
#import "GlobalConstants.h"
#import "CommonUtils.h"

#define MAX_CONNECTION 15

@interface ImageCache()
@property (nonatomic, retain) NSMutableDictionary *imageDic;
@property (nonatomic, retain) NSMutableDictionary *callerDic;
@property (nonatomic, retain) NSMutableDictionary *pendingDic;
@end

@implementation ImageCache

@synthesize imageDic = _imageDic;
@synthesize callerDic = _callerDic;
@synthesize pendingDic = _pendingDic;

- (id)init {
	self = [super init];
  if (self) {
    self.imageDic = [NSMutableDictionary dictionary];
    self.pendingDic = [NSMutableDictionary dictionary];
    self.callerDic = [NSMutableDictionary dictionary];
  }
  return self;
}

- (void)saveImageIntoCache:(NSString *)url image:(UIImage *)image {
    [self.imageDic setObject:image forKey:url];
}

- (UIImage *)getImage:(NSString*)anUrl {
	
	UIImage *image = [self.imageDic objectForKey:anUrl];
    if (image) {
        return image;
    } else {
        return nil;
    }
}

- (void)clearAllCache {
    [self.imageDic removeAllObjects];
}

- (void)removeDelegate:(id)delegate forUrl:(NSString *)key
{
	NSMutableArray *arr = [self.imageDic objectForKey:key];
	if (arr) {
		[arr removeObject:delegate];
		if ([arr count] == 0) {
			[self.imageDic removeObjectForKey:key];
		}
	}
}

- (void)dealloc {
  
  self.imageDic = nil;
  self.pendingDic = nil;
  self.callerDic = nil;
  
  [super dealloc];
}

#pragma mark - image db management
- (void)insertImageIntoDB:(NSData *)imgData forUrl:(NSString *)anUrl {
	static Statement *inserStmt = nil;
	if (inserStmt == nil) {
		inserStmt = [DBConnection statementWithQuery:"INSERT OR REPLACE INTO images VALUES(?,?,?)"];
		[inserStmt retain];
	}
	[inserStmt bindString:anUrl forIndex:1];
	[inserStmt bindData:imgData forIndex:2];
  [inserStmt bindDouble:[CommonUtils convertToUnixTS:[NSDate date]] forIndex:3];
	
	//ignore error
	[inserStmt step];
	[inserStmt reset];
}

- (UIImage *)fetchImageFromDB:(NSString *)url {
  UIImage *image = nil;
	static Statement *stmt = nil;
	if (stmt == nil) {
		stmt = [DBConnection statementWithQuery:"SELECT image FROM images WHERE url=?"];
    // because the image table may not have been created at this moment, e.g., user photo loaded
    // from linkedin during sign up confirmation, but the user has not been created, then no need
    // to save the image into DB
    if (nil == stmt) {
      return nil;
    }
		[stmt retain];
	}
	
	[stmt bindString:url forIndex:1];
	if ([stmt step] == SQLITE_ROW) {
		NSData *data = [stmt getData:0];
		image = [UIImage imageWithData:data];
	}
	
	[stmt reset];
	return image;
}

- (void)deleteImageFromDB:(NSString *)url {
  Statement *deleteStmt = [DBConnection statementWithQuery:"DELETE FROM images WHERE url=?;"];
	  
	[deleteStmt bindString:url 
                forIndex:1];
	
	if ([deleteStmt step] != SQLITE_DONE) {
		debugLog(@"delete image for url: %@ failed", url);
	}
  
	[deleteStmt reset];
}

#pragma mark - image cache management
- (UIImage *)fetchImageFromCache:(NSString *)url {
  UIImage *image = nil;
  if (url && url.length > 0) {
    image = [self.imageDic objectForKey:url];
  }
  if (image) {
    return image;
  }
  
  image = [self fetchImageFromDB:url];
  if (image) {
    if (url && url.length > 0) {
      [self.imageDic setObject:image forKey:url];
    }
    return image;
  }
  return nil;
}

- (void)fetchImage:(NSString*)url 
            caller:(id<ImageFetcherDelegate>)caller
          forceNew:(BOOL)forceNew {
  
  UIImage *image = nil;
  if (forceNew) {
    if ([self.imageDic objectForKey:url]) {
      [self.imageDic removeObjectForKey:url];
    }
  } else {
    image = [self fetchImageFromCache:url];
    if (image) {
      
      //[caller imageFetchDone:image url:url];
      [caller imageFetchFromeCacheDone:image url:url];
      return;
    }
  }
  
  if (url && url.length > 0) {
    ImageFetcher *imageFetcher = [self.pendingDic objectForKey:url];
    if (nil == imageFetcher) {
      imageFetcher = [[[ImageFetcher alloc] initWithDelegate:self interactionContentType:LOAD_IMAGE_TY] autorelease];
      [self.pendingDic setObject:imageFetcher forKey:url];
    }
    
    NSMutableArray *array = [self.callerDic objectForKey:url];
    if (array) {
      [array addObject:caller];
    } else {
      
      [self.callerDic setObject:[NSMutableArray arrayWithObject:caller]
                         forKey:url];
    }
    
    if ([self.pendingDic count] <= MAX_CONNECTION) {
            
      [imageFetcher fetchImage:url showAlertMsg:NO];
    }
  }
}

- (void)fetchPendingImage:(NSString *)requestUrl {
  [self.pendingDic removeObjectForKey:requestUrl];
  
  NSArray *keys = [self.pendingDic allKeys];
  
  for (NSString *url in keys) {
    ImageFetcher *imageFetcher = [self.pendingDic objectForKey:url];
    
    NSMutableArray *array = [self.callerDic objectForKey:url];
    if (nil == array) {
      [self.pendingDic removeObjectForKey:url];      
    } else if (0 == [array count]) {
      [self.callerDic removeObjectForKey:url];
      
      [self.pendingDic removeObjectForKey:url];
    } else {
      //if (nil == imageFetcher.requestUrl) {
      if (![imageFetcher imageBeingLoaded:url]) {
        [imageFetcher fetchImage:url showAlertMsg:NO];
        break;
      }
    }
  }
}

- (void)cancelPendingImageLoadProcess:(NSMutableDictionary *)urlDic {
  NSArray *urls = [urlDic allValues];
  for (NSString *url in urls) {
    ImageFetcher *imageFetcher = [self.pendingDic objectForKey:url];
    if (imageFetcher) {
      [imageFetcher cancelConnection];
    }
  }
}

// should be called in caller dealloc method
- (void)clearCallerFromCache:(NSString *)url {
  
  if (nil == url || [url length] == 0) {
    return;
  }
  
  NSLog(@"dic count: %d", self.callerDic.count);
  if (self.callerDic.count == -1) {
    NSLog(@"this is -1!");
  }
  if (self.callerDic.count != -1) {   // why cout could be -1 sometimes???
    
    //if ([[self.callerDic allKeys] containsObject:url]) {
    
    // avoid get null value for null key, so check whether this url (key) existing in dic firstly
    
    NSMutableArray *array = [self.callerDic objectForKey:url];   
    if (array) { 
      [self.callerDic removeObjectForKey:url];
      /*
       if ([array count] > 0) {
       [array removeLastObject];
       
       if (array) {
       if (0 == [array count]) {
       [self.callerDic removeObjectForKey:url];
       
       RELEASE_OBJ(array);
       }      
       }
       
       }
       */
    }     
    //NSLog(@"after remove dic: %@", self.callerDic);
    // }
    
    [self.pendingDic removeObjectForKey:url];
  }

  NSLog(@"=========================================");
}

// be called in dealloc method of image consumer to keep cache in low footprint
- (void)clearAllCachedImages {
  [self.imageDic removeAllObjects];
}

// be called when app terminal or startup
- (void)clearAllCachedAndLocalImages {
  [self clearAllCachedImages];
  
  // delete the images that loaded a month ago
  NSDate *monthAgoDatetime = [CommonUtils getOffsetDateTime:[NSDate date] offset:-30];
  
  Statement *deleteStmt = [DBConnection statementWithQuery:"DELETE FROM images where updated_at < ?;"];
  [deleteStmt bindDouble:[CommonUtils convertToUnixTS:monthAgoDatetime] forIndex:1];
	
  if ([deleteStmt step] != SQLITE_DONE) {
		debugLog(@"delete all images");
	}
  
	[deleteStmt reset];
}

- (void)didReceiveMemoryWarning {
	NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
	for (id key in self.imageDic) {
		UIImage *image = [self.imageDic objectForKey:key];
		if (image.retainCount == 1) {
      [array addObject:key];
		}
	}
	[self.imageDic removeObjectsForKeys:array];
}

#pragma mark - WXWConnectorDelegate methods 
- (void)connectStarted:(NSString *)url contentType:(WebItemType)contentType {
  if (url && url.length > 0) {
    NSMutableArray *array = [self.callerDic objectForKey:url];
    for (id<ImageFetcherDelegate> caller in array) {
      [caller imageFetchStarted:url];
    }
  }
}

- (void)connectFailed:(NSError *)error url:(NSString *)url contentType:(WebItemType)contentType {
  [self fetchPendingImage:url];
  
  NSMutableArray *array = [self.callerDic objectForKey:url];
  for (id<ImageFetcherDelegate> caller in array) {
    [caller imageFetchFailed:error url:url];
  }

  [self.callerDic removeObjectForKey:url];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(WebItemType)contentType {
  
  UIImage *image = [UIImage imageWithData:result];
  
  if (image) {
    NSMutableArray *array = [self.callerDic objectForKey:url];
    
    [self insertImageIntoDB:result forUrl:url];
  
    if (array) {
      for (id<ImageFetcherDelegate> caller in array) {
        [caller imageFetchDone:image url:url];        
      }
      
      [self.callerDic removeObjectForKey:url];
    }
    
    [self.imageDic setObject:image forKey:url];
  }
  
  [self fetchPendingImage:url];
}

- (void)connectCancelled:(NSString *)url contentType:(WebItemType)contentType {
  [self clearCallerFromCache:url];  
}

@end
