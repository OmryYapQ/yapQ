//
//  Constants.h
//  YAPP
//
//  Created by yapQ Ltd on 11/21/13.
//  Copyright (c) 2013 yapQ Ltd. All rights reserved.
//
#ifndef YAPQ_AppSettings_h
#define YAPQ_AppSettings_h


#define YAP_SPEECH_SPEED 0.2

/*
version =
client 0 iOS
1 android
*/

// used for must see, places and isRoute - unified structure
//#define PLACES_API @"https://api.yapq.com/api.php?"   // live
#define PLACES_API @"https://test.yapq.com/api.php?"    // test
//add to places

//id + lat + long
#define GET_ROUTE_API @"https://route.yapq.com/validator/getRoute.php?"

#define REPORT_API @"https://api.yapq.com/Report.php?"

#define ABOUT_API @"https://api.yapq.com/about.php"

#define TermCondition_API @"https://api.yapq.com/tc.php"

#define PACKAGE_API @"https://api.yapq.com/package.php?"

#define OFFLINE_API @"https://api.yapq.com/offline/api.php?"

#define VARIFIER_API @"https://api.yapq.com/varifier.php"

#define ACCOUNT_API @"https://api.yapq.com/account.php?"

#define SYNC_PACKAGES_API @"https://api.yapq.com/syncPurchases.php?"

#define GET_ALL_PURCHASES_API @"https://api.yapq.com/GetAllPurchases.php?"

#define PUSH_API @"https://api.yapq.com/push.php?"

#define APPSTORE_URL @"https://itunes.apple.com/il/app/yapq/id784765085?mt=8"

#define PLAYSTORE_URL @"https://play.google.com/store/apps/details?id=com.iv.yapq"

#define LINK_TO_SHARE @"http://yapq.com/welcome.php?p=0"
// o - ios, 1 - android

#define ANONYMUS_USER @"https://api.yapq.com/AnonymousUser.php?"

#define RECORD @"https://api.yapq.com/record.php?"

#define GA_ID @"UA-49513744-1"

#define FACEBOOK_APP_ID @"645536292171084"

#define GOOGLE_PLUS_APP_ID @"529807570993-sc3q8dambc1nm6mffrq235roe4jugp9b.apps.googleusercontent.com"

#define SYNC_PLACES @"https://api.yapq.com/syncPlaces.php?"


// MIxpanel ///////////////////////////////////////////////
#define MIXPANEL_TOKEN @"bd4de01d066fc1095736d75c242b810b"
#define MIXPANLE_KEY_SCREEN @"Screen"
#define MIXPANLE_KEY_LANG @"Language"
#define MIXPANLE_KEY_SDK @"SDK"
#define MIXPANLE_KEY_IS_LOGIN @"IsLogin"
#define MIXPANLE_KEY_IS_LOGIN_SYSTEM @"Login System"
#define MIXPANLE_KEY_DEVICE @"Device"
#define MIXPANLE_PURCHASE_TYPE @"Purchase Type"
#define MIXPANLE_PURCHASE_PACKAGE @"Purchased Package"
//////////////////////////////////////////////////////////
#define TEST_LATITUDE 31.238604

#define TEST_LONGITUDE 34.779243

#define TWO_MOTH_IN_SECONDS 5184000

#define MIN_DISCOVER_RADIUS 200

#define MAX_DISCOVER_RADIUS 2500

#define MAX_NUMBER_OF_PLACES 50

#define IN_APP_PURCHASE_UID_TEMPLETE @"com.yapq.offline."

#define MUST_SEE_DB_UPDATE_INTERVAL_SEC (60 * 60 * 24 * 14) // 2 weeks
#define LAST_MUST_SEE_SEC @"LastMustSeeTime"

// ============ TAG's ===================
#define NO_ITEM_FOUND_MESSAGE_VIEW_TAG 11

#define NO_ITEM_FOUND_MESSAGE_VIEW_LABEL_TAG 10

#define STORE_FOOTER_LABEL_TAG 20

#endif
