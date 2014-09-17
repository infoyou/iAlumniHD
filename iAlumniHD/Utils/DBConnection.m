//
//  DBConnection.m
//  iAlumniHD
//
//  Created by Adam on 12-11-9.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "DBConnection.h"
#import "Statement.h"
#import "DebugLogOutput.h"
#import "CommonUtils.h"
#import "AppManager.h"
#import "WXWUIUtils.h"

static sqlite3* theDB		= nil;

@implementation DBConnection

+ (NSString *)assembleBizDBPath:(NSString *)dbFileName {
	NSString *docDir = [CommonUtils documentsDirectory];
	NSString *dbPath = [docDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@_%@.sqlite", dbFileName, VERSION, [AppManager instance].userId]];
	return dbPath;
}

+ (sqlite3 *)doOpenDB:(NSString *)dbPath {
	sqlite3 *instance;
	
	if (sqlite3_open([dbPath UTF8String], &instance) != SQLITE_OK) {
		sqlite3_close(instance);
		
		debugLog(@"Failed to open db. Reason: %s", sqlite3_errmsg(instance));
		NSAssert1(0, @"Failed to open db. Reason: %s", sqlite3_errmsg(instance));
		return nil;
	}
	
	return instance;
}

+ (sqlite3 *)openBizDatabase:(NSString *)dbFilename {
  
	NSString *dbPath = [self assembleBizDBPath:dbFilename];
	return [self doOpenDB:dbPath];
}

+ (sqlite3 *)prepareBizDB {
	
	if (theDB == nil) {
		theDB = [self openBizDatabase:DB_NAME];
	}
	
	// prepare table images that be used to cache the images
	Statement *imgStmt = [self statementWithQuery:"create table if not exists images (url TEXT PRIMARY KEY, image BLOB, updated_at double);"];
	int ret = [imgStmt step];
	if (ret != SQLITE_DONE) {
		debugLog(@"Failed to create 'images' table.");
		NSAssert1(0, @"Failed to create 'images' table.", nil);
	}
	
	return theDB;
}

+ (void)closeDB {
	if (theDB) {
		sqlite3_close(theDB);
	}
	
	theDB = nil;
}

+ (Statement *)statementWithQuery:(const char *)sql {
  if (theDB) {
    Statement *stmt = [Statement statementWithDB:theDB query:sql];
    return stmt;
  } else {
    return nil;
  }
}

+ (void)beginTransaction {
	char *errMsg;
	sqlite3_exec(theDB, "BEGIN", NULL, NULL, &errMsg);
}

+ (void)commitTransaction {
	char *errMsg;
	sqlite3_exec(theDB, "COMMIT", NULL, NULL, &errMsg);
}

#pragma mark - alert
+ (void)alertAndOutputLog {
	NSString *sqlite3Err = [[NSString alloc] initWithUTF8String:sqlite3_errmsg(theDB)];
	debugLog(@"db error: %@", sqlite3Err);
	
	[WXWUIUtils alert:@"Database Error" 
         message:sqlite3Err];
	
	[sqlite3Err release];
	sqlite3Err = nil;
	
}


@end
