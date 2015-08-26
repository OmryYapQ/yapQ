//
//  DBConsts.h
//  yapq
//
//  Created by yapQ Ltd on 5/16/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#ifndef yapq_DBConsts_h
#define yapq_DBConsts_h
/* PACKAGE Table keys */
#define kTABLE_DBPACKAGE @"DBPackage"

#define kP_ID @"p_id"

#define kP_COUNTRY @"p_country"

#define kP_CITY @"p_city"

#define kP_NAME @"p_name"

#define kP_NUM_OF_PLACES @"p_num_of_places"

#define kP_RADIUS @"p_radius"

#define kP_CARD_CODE @"p_card_code"

#define kP_EXP_DATE @"p_exp_date"

#define kP_MORE_JSON @"p_more_json"
/*********************/

/* PLACE Table keys */
#define kTABLE_DBPLACE @"DBPlace"

#define kPL_ID @"pl_id"

#define kPL_FK_ID @"p_fk_id"

#define kPL_TITLE @"pl_title"

#define kPL_DESCR @"pl_descr"

#define kPL_IMG_URL @"pl_img_url"

#define kPL_CODE_NAME @"pl_code_name"

#define kPL_AUDIO @"pl_audio"

#define kPL_WIKI @"pl_wiki"

/********************/

/* DBPlaceCoord */
#define kTABLE_DBPLACE_COORD @"DBPlaceCoord"

#define kPC_DISTANCE @"pc_distance"

#define kPC_CLAT @"pc_clat"

#define kPC_CLON @"pc_clon"

/*****************/

/* DBPurchasedPackages */
#define kTABLE_DBPURCHASED_PACKAGES @"DBPurchasedPackages"

#endif
