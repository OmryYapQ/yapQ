//
//  SQLiteDBManager.h
//  yapq
//
//  Created by Omry Levy on 6/4/15.
//  Copyright (c) 2015 yapQ . All rights reserved.
//
#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface SQLiteDBManager : NSObject
{
    NSString *databasePath;
}

+(SQLiteDBManager*)sharedInstance;

-(BOOL)createDB;
-(NSMutableDictionary *) getDB:(sqlite3 *)db countriesBySearchString:(NSString *)search;
-(void) updateMustSeePlacesWithResponseString:(NSString *)jsonString;

@end
