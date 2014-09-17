//
//  DBConnection.h
//  iAlumniHD
//
//  Created by Adam on 12-11-9.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <sqlite3.h>

@class Statement;

@interface DBConnection : NSObject {
  
}

+ (sqlite3 *)prepareBizDB;
+ (void)beginTransaction;
+ (void)commitTransaction;
+ (Statement*)statementWithQuery:(const char *)sql;
+ (void)closeDB;
+ (void)alertAndOutputLog;

@end
