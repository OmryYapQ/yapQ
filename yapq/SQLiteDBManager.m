//
//  SQLiteDBManager.m
//  yapq
//
//  Created by Omry Levy on 6/4/15.
//  Copyright (c) 2015 yapQ . All rights reserved.
//

#import "SQLiteDBManager.h"
#import "JSONKit.h"
#import "SBJson.h"

static SQLiteDBManager *_instance = nil;

static NSString*convertEntities(NSString *string)
{
    NSString    *returnStr = nil;
    
    if( string )
    {
        returnStr = [ string stringByReplacingOccurrencesOfString:@"&amp;" withString: @"&"  ];
        
        returnStr = [ returnStr stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""  ];
        
        returnStr = [ returnStr stringByReplacingOccurrencesOfString:@"&#27;" withString:@"'"  ];
        
        returnStr = [ returnStr stringByReplacingOccurrencesOfString:@"&#39;" withString:@"'"  ];
        
        returnStr = [ returnStr stringByReplacingOccurrencesOfString:@"&#92;" withString:@"'"  ];
        
        returnStr = [ returnStr stringByReplacingOccurrencesOfString:@"&#96;" withString:@"'"  ];
        
        returnStr = [ returnStr stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"  ];
        
        returnStr = [ returnStr stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"  ];
        
        returnStr = [ [ NSString alloc ] initWithString:returnStr ];
    }
    
    return returnStr;
}

char * str_replace ( const char *string, const char *substr, const char *replacement ){
    char *tok = NULL;
    char *newstr = NULL;
    char *oldstr = NULL;
    char *head = NULL;
    
    /* if either substr or replacement is NULL, duplicate string a let caller handle it */
    if ( substr == NULL || replacement == NULL ) return strdup (string);
    
    newstr = strdup (string);
    head = newstr;
    
    while ( (tok = strstr ( head, substr ))){
        oldstr = newstr;
        newstr = malloc ( strlen ( oldstr ) - strlen ( substr ) + strlen ( replacement ) + 1 );
        /*failed to alloc mem, free old string and return NULL */
        if ( newstr == NULL ){
            free (oldstr);
            return NULL;
        }
        
        memcpy ( newstr, oldstr, tok - oldstr );
        memcpy ( newstr + (tok - oldstr), replacement, strlen ( replacement ) );
        memcpy ( newstr + (tok - oldstr) + strlen( replacement ), tok + strlen ( substr ), strlen ( oldstr ) - strlen ( substr ) - ( tok - oldstr ) );
        memset ( newstr + strlen ( oldstr ) - strlen ( substr ) + strlen ( replacement ) , 0, 1 );
        /* move back head right after the last replacement */
        head = newstr + (tok - oldstr) + strlen( replacement );
        free (oldstr);
    }
    return newstr;
}

@implementation SQLiteDBManager

+(SQLiteDBManager*) sharedInstance {
    if (NULL == _instance) {
        _instance = [[super allocWithZone:NULL]init];
    }
    
    return _instance;
}

-(BOOL) createDB {
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent: @"YapQSqlite.db"]];
    
    BOOL isSuccess = YES;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: databasePath ] == NO) {
        NSString *sourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"YapQSqlite.db"];
        NSError *error;
        [[NSFileManager defaultManager] copyItemAtPath:sourcePath
                                                toPath:databasePath
                                                 error:&error];
        NSLog(@"The copy error is: %@", error);
        
        NSDictionary *fileAttributes = [filemgr attributesOfItemAtPath:databasePath error:nil];
        NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
        long long fileSize = [fileSizeNumber longLongValue];
        
        // Check that it worked.
        
        NSLog(@"database size %lld", fileSize);
    }
    
    return isSuccess;
}

- (NSString *) getDeviceLocally {
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    return language;
}


- (NSMutableDictionary *) getDB:(sqlite3 *)db countriesBySearchString:(NSString *)search {
    const char *dbpath = [databasePath UTF8String];
    NSMutableDictionary *ret = NULL;
    NSString *localle = [self getDeviceLocally];
    
    if (search != NULL && search.length > 0) {
        sqlite3 *database = nil;
        if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
            NSString *querySQL = [NSString stringWithFormat:@"SELECT id,ttl FROM Countries WHERE searchString LIKE '%%%@%%'", search];
            const char *query_stmt = [querySQL UTF8String];
            
            sqlite3_stmt *statement = NULL;
            if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
                ret = [[NSMutableDictionary alloc] init];
                
                while (sqlite3_step(statement) == SQLITE_ROW) {
                    unsigned int ID = sqlite3_column_int(statement, 0);
                    
                    const char *rawTTL = (const char *) sqlite3_column_text(statement, 1);
                    
                    // remove extrenous backslashes
                    char *temp = str_replace(rawTTL, "\\\\", "\\");
                    NSString *raw = [NSString stringWithUTF8String:temp];
                    
                    NSData *data = [raw dataUsingEncoding:NSUTF8StringEncoding];
                    free(temp);
                    
                    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    
                    if (NULL != jsonDict) {
                        NSString *result = [jsonDict valueForKey:localle];
                        if (NULL == result) {
                            result = [jsonDict valueForKey:@"en"];
                        }
    
                        if (NULL != result) {
                            // decode HTML escape chars
                            result = convertEntities(result);
                            [ret setObject:result forKey:[NSNumber numberWithInt:ID]];
                        }
                    }
                }
                
                sqlite3_finalize(statement);
            }
            else {
                NSLog(@"%s", sqlite3_errmsg(database));
            }
            
            sqlite3_close(database);
        }
    }
    
    return ret;
}

-(void) updateMustSeePlacesWithResponseString:(NSString *)jsonString {
    if (jsonString != NULL) {
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSArray *jsonArr = [parser objectWithString:jsonString];
        if (jsonArr != NULL && jsonArr.count > 0) {
            sqlite3 *database = nil;
            const char *dbpath = [databasePath UTF8String];
            
            if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
                NSString *querySQL = @"DELETE FROM Countries";
                
                sqlite3_stmt *statement;
                if (sqlite3_prepare_v2( database, [querySQL UTF8String], -1, &statement, NULL) == SQLITE_OK) {
                    while (sqlite3_step(statement) == SQLITE_DONE) {
                    }
                    
                    sqlite3_finalize(statement);
                    
                    querySQL = @"insert into Countries (id, searchString, ttl) VALUES (?, ?, ?)";
                    if (sqlite3_prepare_v2( database, [querySQL UTF8String], -1, &statement, NULL) == SQLITE_OK) {
                        
                        for (int i=0;i<jsonArr.count;i++) {
                            NSDictionary *dict = [jsonArr objectAtIndex:i];
                            
                            int ID = [[dict objectForKey:@"id"] intValue];
                            sqlite3_bind_int(statement, 1, ID);
                            
                            NSString *searchString = [dict objectForKey:@"searchString"];
                            sqlite3_bind_text(statement, 2, [searchString UTF8String], -1, NULL);
                            
                            NSString *ttl = [dict objectForKey:@"ttl"];
                            sqlite3_bind_text(statement, 3, [ttl UTF8String], -1, NULL);
                            
                            if (sqlite3_step(statement) == SQLITE_DONE) {
                                if (i == (jsonArr.count - 1))
                                    sqlite3_finalize(statement);
                                else
                                    sqlite3_reset(statement);
                            }
                            else {
                                NSLog(@"Error !!!!");
                                sqlite3_finalize(statement);
                                break;
                            }
                        }
                    }
                }
                
                sqlite3_close(database);
            }
        }
    }
}

@end