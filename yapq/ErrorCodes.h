//
//  NSObject_ErrorCodes.h
//  yapq
//
//  Created by yapQ Ltd on 7/5/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ERROR_CODES) {
    EC_PACKAGE_INSERT = 1001,
    EC_PLACE_INSERT = 1002,
    EC_PARSING_SERVER_PACAKGE_JSON = 1003,
    EC_UNZIP_PACKAGE_ERROR = 1004,
    EC_PARSING_OR_SAVE_TO_DB_ERROR = 1005,
    EC_LOADING_PROGRESS_OBSERVER = 1006,
    EC_LOADIGN_STATUS_OBSERVER = 1007,
    EC_SETTING_CHANGE_NOTIFICATION = 1008,
    // Web Service
    EC_LOADPLACES_API= 2001,
    EC_REPORT_API = 2002,
    EC_PACAKGE_LIST_LOAD_API = 2003,
    EC_OFFLINE_PACKAGE_LINK_API = 2004,
    EC_VARIFIER_API = 2005,
    EC_CREATE_ACCOUNT_API = 2006,
    EC_SYNC_API = 2007,
    EC_GET_ALL_PACKAGES_API = 2008,
    EC_PUSH_REGISTER_API = 2009,
    EC_SEARCHPLACES_API= 2010,
    EC_GET_ROUTE_API = 2011
};


//id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//[tracker send:[[GAIDictionaryBuilder createExceptionWithDescription:exception.description
//                                                          withFatal:[NSNumber numberWithBool:YES]] build]];